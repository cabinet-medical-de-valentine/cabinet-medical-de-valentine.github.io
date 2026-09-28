import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";

const cors = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS"
};

const json = (body: unknown, status = 200) =>
  new Response(JSON.stringify(body), {
    status,
    headers: { ...cors, "Content-Type": "application/json", "Cache-Control": "no-store" }
  });

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: cors });

  try {
    const authHeader = req.headers.get("Authorization") || "";
    const token = authHeader.replace(/^Bearer\s+/i, "").trim();
    if (!token) return json({ error: "Session absente" }, 401);

    const url = Deno.env.get("SUPABASE_URL")!;
    const service = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
    const admin = createClient(url, service, { auth: { persistSession: false } });

    const { data: authData, error: authError } = await admin.auth.getUser(token);
    const user = authData?.user;
    if (authError || !user) return json({ error: "Session invalide" }, 401);

    const { data: profile, error: profileError } = await admin
      .from("profiles")
      .select("access_status")
      .eq("id", user.id)
      .single();

    if (profileError || profile?.access_status !== "approved") {
      return json({ error: "Accès au cabinet refusé" }, 403);
    }

    const { data: settings, error: settingsError } = await admin
      .from("cabinet_state")
      .select("giphy_api_key")
      .eq("id", 1)
      .single();

    if (settingsError || !settings?.giphy_api_key) {
      return json({ error: "GIPHY n'est pas configuré" }, 503);
    }

    const body = await req.json().catch(() => ({}));
    const q = String(body?.q || "").trim().slice(0, 50);
    const endpoint = q
      ? "https://api.giphy.com/v1/gifs/search"
      : "https://api.giphy.com/v1/gifs/trending";

    const target = new URL(endpoint);
    target.searchParams.set("api_key", settings.giphy_api_key);
    target.searchParams.set("limit", "24");
    target.searchParams.set("rating", "pg-13");
    if (q) {
      target.searchParams.set("q", q);
      target.searchParams.set("lang", "fr");
    }

    const giphy = await fetch(target.toString());
    const payload = await giphy.json().catch(() => ({}));

    if (!giphy.ok) {
      return json({
        error: payload?.message || payload?.meta?.msg || "Erreur GIPHY",
        status: giphy.status
      }, 502);
    }

    const data = (payload?.data || []).map((g: any) => ({
      id: g.id,
      title: g.title,
      url: g.url,
      images: {
        preview:
          g.images?.fixed_width_small?.url ||
          g.images?.fixed_width?.url ||
          g.images?.downsized?.url ||
          g.images?.original?.url ||
          "",
        original:
          g.images?.original?.url ||
          g.images?.downsized?.url ||
          g.images?.fixed_width?.url ||
          ""
      }
    }));

    return json({ data });
  } catch (error) {
    return json({ error: error instanceof Error ? error.message : "Erreur interne" }, 500);
  }
});