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
  if (req.method !== "POST") return json({ error: "Méthode non autorisée" }, 405);

  try {
    const authHeader = req.headers.get("Authorization") || "";
    const token = authHeader.replace(/^Bearer\s+/i, "").trim();
    if (!token) return json({ error: "Session absente" }, 401);

    const url = Deno.env.get("SUPABASE_URL")!;
    const service = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
    const admin = createClient(url, service, { auth: { persistSession: false } });

    const { data: authData, error: authError } = await admin.auth.getUser(token);
    const actor = authData?.user;
    if (authError || !actor) return json({ error: "Session invalide" }, 401);

    const { data: actorProfile, error: actorProfileError } = await admin
      .from("profiles")
      .select("role, medical_grade, access_status")
      .eq("id", actor.id)
      .single();

    if (
      actorProfileError ||
      actorProfile?.access_status !== "approved" ||
      actorProfile?.role !== "admin" ||
      actorProfile?.medical_grade !== "chef_de_cabinet"
    ) {
      return json({ error: "Action réservée au Chef de cabinet" }, 403);
    }

    const body = await req.json().catch(() => ({}));
    const targetId = String(body?.user_id || "").trim();
    if (!targetId) return json({ error: "Compte introuvable" }, 400);
    if (targetId === actor.id) return json({ error: "Tu ne peux pas supprimer ton propre compte" }, 400);

    const { data: targetProfile, error: targetError } = await admin
      .from("profiles")
      .select("display_name, role, medical_grade")
      .eq("id", targetId)
      .single();

    if (targetError || !targetProfile) return json({ error: "Compte introuvable" }, 404);
    if (targetProfile.role === "admin" || targetProfile.medical_grade === "chef_de_cabinet") {
      return json({ error: "Un compte Chef de cabinet ne peut pas être supprimé ici" }, 403);
    }

    await admin.from("bureau_typing").delete().eq("user_id", targetId);

    try {
      const { data: files } = await admin.storage.from("bureau-chat").list(targetId, { limit: 1000 });
      const paths = (files || []).filter((f: any) => f?.name).map((f: any) => targetId + "/" + f.name);
      if (paths.length) await admin.storage.from("bureau-chat").remove(paths);
    } catch (_) {}

    const { error: deleteError } = await admin.auth.admin.deleteUser(targetId);
    if (deleteError) return json({ error: deleteError.message || "Suppression impossible" }, 500);

    return json({ ok: true, display_name: targetProfile.display_name || "" });
  } catch (error) {
    return json({ error: error instanceof Error ? error.message : "Erreur interne" }, 500);
  }
});