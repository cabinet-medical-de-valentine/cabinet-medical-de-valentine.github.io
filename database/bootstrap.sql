begin;
set local check_function_bodies=off;
create schema if not exists private;
grant usage on schema public,private to authenticated;
create table "public"."movements" (
"id" uuid default gen_random_uuid() not null,
"movement_type" text not null,
"resource_id" uuid,
"quantity_delta" numeric(12,2) default 0 not null,
"unit_price" numeric(12,2),
"cash_delta" numeric(12,2) default 0 not null,
"note" text,
"details" jsonb default '{}'::jsonb not null,
"created_by" uuid default auth.uid(),
"created_at" timestamp with time zone default now() not null,
"effective_date" date default CURRENT_DATE not null);
alter table "public"."movements" enable row level security;
create table "public"."resources" (
"id" uuid default gen_random_uuid() not null,
"name" text not null,
"category" text default 'ingredient'::text not null,
"unit_price" numeric(12,2) default 0 not null,
"stock" numeric(12,2) default 0 not null,
"active" boolean default true not null,
"created_at" timestamp with time zone default now() not null,
"updated_at" timestamp with time zone default now() not null);
alter table "public"."resources" enable row level security;
create table "public"."recipes" (
"id" uuid default gen_random_uuid() not null,
"name" text not null,
"product_resource_id" uuid not null,
"output_quantity" numeric(12,2) default 1 not null,
"active" boolean default true not null,
"created_at" timestamp with time zone default now() not null,
"updated_at" timestamp with time zone default now() not null);
alter table "public"."recipes" enable row level security;
create table "public"."recipe_ingredients" (
"recipe_id" uuid not null,
"ingredient_resource_id" uuid not null,
"quantity" numeric(12,2) not null);
alter table "public"."recipe_ingredients" enable row level security;
create table "public"."suppliers" (
"id" uuid default gen_random_uuid() not null,
"resource_id" uuid,
"supplier_name" text,
"telegram" text,
"location" text,
"unit_price" numeric(12,2),
"notes" text,
"active" boolean default true not null,
"created_at" timestamp with time zone default now() not null,
"updated_at" timestamp with time zone default now() not null);
alter table "public"."suppliers" enable row level security;
create table "public"."orders" (
"id" uuid default gen_random_uuid() not null,
"resource_id" uuid not null,
"quantity" numeric not null,
"unit_price" numeric not null,
"total_price" numeric generated always as ((quantity * unit_price)) stored,
"delivery_fee" numeric default 0 not null,
"status" text default 'en_cours'::text not null,
"created_by" uuid default auth.uid(),
"delivered_by" uuid,
"created_at" timestamp with time zone default now() not null,
"delivered_at" timestamp with time zone,
"delivery_date" date default CURRENT_DATE,
"delivery_time" time without time zone,
"supplier_id" uuid);
alter table "public"."orders" enable row level security;
create table "public"."profiles" (
"id" uuid not null,
"display_name" text,
"role" text default 'medecin'::text not null,
"created_at" timestamp with time zone default now() not null,
"updated_at" timestamp with time zone default now() not null,
"email" text,
"access_status" text default 'pending'::text not null,
"approved_at" timestamp with time zone,
"approved_by" uuid,
"medical_grade" text default 'apprenti'::text not null);
alter table "public"."profiles" enable row level security;
create table "public"."edit_locks" (
"lock_key" text not null,
"user_id" uuid not null,
"display_name" text not null,
"last_activity" timestamp with time zone default now() not null);
alter table "public"."edit_locks" enable row level security;
create table "public"."cabinet_state" (
"id" smallint default 1 not null,
"cash_balance" numeric(12,2) default 0 not null,
"telegram" text default ''::text not null,
"telegram_owner_name" text default ''::text not null,
"updated_at" timestamp with time zone default now() not null,
"cabinet_name" text default 'Cabinet Médical de Valentine'::text not null,
"place" text default 'Valentine · New Hanover'::text not null,
"giphy_api_key" text default ''::text not null);
alter table "public"."cabinet_state" enable row level security;
create table "public"."recipe_pricing" (
"product_resource_id" uuid not null,
"pharmacy_price" numeric,
"recommended_price" numeric default 0 not null,
"cabinet_return" numeric default 0 not null,
"pharmacy_sellable" boolean default true not null,
"updated_at" timestamp with time zone default now() not null,
"updated_by" uuid);
alter table "public"."recipe_pricing" enable row level security;
create table "public"."bureau_messages" (
"id" uuid default gen_random_uuid() not null,
"author_id" uuid default auth.uid() not null,
"body" text default ''::text not null,
"attachment_path" text,
"attachment_name" text,
"attachment_type" text,
"attachment_size" bigint,
"created_at" timestamp with time zone default now() not null,
"external_url" text,
"external_page_url" text,
"external_provider" text,
"external_id" text);
alter table "public"."bureau_messages" enable row level security;
create table "public"."bureau_typing" (
"user_id" uuid not null,
"updated_at" timestamp with time zone default now() not null);
alter table "public"."bureau_typing" enable row level security;
create table "public"."fabrication_plans" (
"recipe_id" uuid not null,
"quantity" numeric not null,
"updated_by" uuid,
"updated_at" timestamp with time zone default now() not null);
alter table "public"."fabrication_plans" enable row level security;
create table "private"."bureau_read_state" (
"user_id" uuid not null,
"last_seen_at" timestamp with time zone default now() not null,
"updated_at" timestamp with time zone default now() not null);
alter table "private"."bureau_read_state" enable row level security;
create table "public"."consultation_categories" (
"id" uuid default gen_random_uuid() not null,
"name" text not null,
"slug" text not null,
"sort_order" integer default 0 not null,
"color" text default '#8f2419'::text not null,
"active" boolean default true not null,
"created_at" timestamp with time zone default now() not null,
"updated_at" timestamp with time zone default now() not null);
alter table "public"."consultation_categories" enable row level security;
create table "public"."consultation_templates" (
"id" uuid default gen_random_uuid() not null,
"category_id" uuid not null,
"title" text not null,
"subcategory" text default ''::text not null,
"body" text default ''::text not null,
"sort_order" integer default 0 not null,
"active" boolean default true not null,
"created_at" timestamp with time zone default now() not null,
"updated_at" timestamp with time zone default now() not null);
alter table "public"."consultation_templates" enable row level security;
create table "public"."navigation_preferences" (
"id" integer not null,
"item_order" text[] default '{}'::text[] not null,
"version" integer default 1 not null);
alter table "public"."navigation_preferences" enable row level security;
create table "public"."pharmacy_stock" (
"product_resource_id" uuid not null,
"quantity" numeric(12,2) default 0 not null,
"updated_at" timestamp with time zone default now() not null,
"updated_by" uuid);
alter table "public"."pharmacy_stock" enable row level security;
create table "public"."unpaid_debts" (
"id" uuid default gen_random_uuid() not null,
"last_name" text not null,
"first_name" text not null,
"telegram" text default ''::text not null,
"amount" numeric(12,2) not null,
"debt_date" date not null,
"debt_time" time without time zone not null,
"created_by" uuid,
"created_at" timestamp with time zone default now() not null);
alter table "public"."unpaid_debts" enable row level security;
create table "public"."consultation_notebooks" (
"owner_id" uuid not null,
"initialized_at" timestamp with time zone default now() not null,
"updated_at" timestamp with time zone default now() not null);
alter table "public"."consultation_notebooks" enable row level security;
create table "public"."consultation_user_categories" (
"id" uuid default gen_random_uuid() not null,
"owner_id" uuid not null,
"source_category_id" uuid,
"name" text not null,
"sort_order" integer default 0 not null,
"color" text default '#8f2419'::text not null,
"created_at" timestamp with time zone default now() not null,
"updated_at" timestamp with time zone default now() not null);
alter table "public"."consultation_user_categories" enable row level security;
create table "public"."consultation_user_templates" (
"id" uuid default gen_random_uuid() not null,
"owner_id" uuid not null,
"source_template_id" uuid,
"category_id" uuid not null,
"title" text not null,
"subcategory" text default ''::text not null,
"body" text default ''::text not null,
"sort_order" integer default 0 not null,
"active" boolean default true not null,
"created_at" timestamp with time zone default now() not null,
"updated_at" timestamp with time zone default now() not null);
alter table "public"."consultation_user_templates" enable row level security;
alter table "public"."profiles" add constraint "profiles_role_check" CHECK ((role = ANY (ARRAY['medecin'::text, 'admin'::text])));
alter table "public"."profiles" add constraint "profiles_pkey" PRIMARY KEY (id);
alter table "public"."resources" add constraint "resources_category_check" CHECK ((category = ANY (ARRAY['ingredient'::text, 'produit'::text])));
alter table "public"."resources" add constraint "resources_unit_price_check" CHECK ((unit_price >= (0)::numeric));
alter table "public"."resources" add constraint "resources_stock_check" CHECK ((stock >= (0)::numeric));
alter table "public"."resources" add constraint "resources_pkey" PRIMARY KEY (id);
alter table "public"."resources" add constraint "resources_name_key" UNIQUE (name);
alter table "public"."recipes" add constraint "recipes_output_quantity_check" CHECK ((output_quantity > (0)::numeric));
alter table "public"."recipes" add constraint "recipes_pkey" PRIMARY KEY (id);
alter table "public"."recipes" add constraint "recipes_name_key" UNIQUE (name);
alter table "public"."recipes" add constraint "recipes_product_resource_id_key" UNIQUE (product_resource_id);
alter table "public"."recipe_ingredients" add constraint "recipe_ingredients_quantity_check" CHECK ((quantity > (0)::numeric));
alter table "public"."recipe_ingredients" add constraint "recipe_ingredients_pkey" PRIMARY KEY (recipe_id, ingredient_resource_id);
alter table "public"."suppliers" add constraint "suppliers_unit_price_check" CHECK (((unit_price IS NULL) OR (unit_price >= (0)::numeric)));
alter table "public"."suppliers" add constraint "suppliers_pkey" PRIMARY KEY (id);
alter table "public"."cabinet_state" add constraint "cabinet_state_id_check" CHECK ((id = 1));
alter table "public"."cabinet_state" add constraint "cabinet_state_pkey" PRIMARY KEY (id);
alter table "public"."movements" add constraint "movements_pkey" PRIMARY KEY (id);
alter table "public"."profiles" add constraint "profiles_access_status_check" CHECK ((access_status = ANY (ARRAY['pending'::text, 'approved'::text, 'revoked'::text])));
alter table "public"."edit_locks" add constraint "edit_locks_pkey" PRIMARY KEY (lock_key);
alter table "public"."orders" add constraint "orders_quantity_check" CHECK ((quantity > (0)::numeric));
alter table "public"."orders" add constraint "orders_unit_price_check" CHECK ((unit_price >= (0)::numeric));
alter table "public"."orders" add constraint "orders_delivery_fee_check" CHECK ((delivery_fee >= (0)::numeric));
alter table "public"."orders" add constraint "orders_pkey" PRIMARY KEY (id);
alter table "public"."recipe_pricing" add constraint "recipe_pricing_pharmacy_price_check" CHECK (((pharmacy_price IS NULL) OR (pharmacy_price >= (0)::numeric)));
alter table "public"."recipe_pricing" add constraint "recipe_pricing_recommended_price_check" CHECK ((recommended_price >= (0)::numeric));
alter table "public"."recipe_pricing" add constraint "recipe_pricing_cabinet_return_check" CHECK ((cabinet_return >= (0)::numeric));
alter table "public"."recipe_pricing" add constraint "recipe_pricing_pkey" PRIMARY KEY (product_resource_id);
alter table "public"."profiles" add constraint "profiles_medical_grade_check" CHECK ((medical_grade = ANY (ARRAY['apprenti'::text, 'medecin'::text, 'medecin_adjoint'::text, 'chef_de_cabinet'::text])));
alter table "public"."bureau_messages" add constraint "bureau_messages_body_length" CHECK ((char_length(body) <= 4000));
alter table "public"."bureau_messages" add constraint "bureau_messages_attachment_size" CHECK (((attachment_size IS NULL) OR ((attachment_size >= 0) AND (attachment_size <= 20971520))));
alter table "public"."bureau_messages" add constraint "bureau_messages_pkey" PRIMARY KEY (id);
alter table "public"."bureau_messages" add constraint "bureau_messages_has_content" CHECK (((char_length(btrim(body)) > 0) OR (attachment_path IS NOT NULL) OR (external_url IS NOT NULL)));
alter table "public"."bureau_typing" add constraint "bureau_typing_pkey" PRIMARY KEY (user_id);
alter table "public"."orders" add constraint "orders_status_check" CHECK ((status = ANY (ARRAY['a_commander'::text, 'en_cours'::text, 'livre'::text])));
alter table "public"."fabrication_plans" add constraint "fabrication_plans_quantity_check" CHECK ((quantity >= (0)::numeric));
alter table "public"."fabrication_plans" add constraint "fabrication_plans_pkey" PRIMARY KEY (recipe_id);
alter table "private"."bureau_read_state" add constraint "bureau_read_state_pkey" PRIMARY KEY (user_id);
alter table "public"."consultation_categories" add constraint "consultation_categories_pkey" PRIMARY KEY (id);
alter table "public"."consultation_categories" add constraint "consultation_categories_slug_key" UNIQUE (slug);
alter table "public"."consultation_templates" add constraint "consultation_templates_pkey" PRIMARY KEY (id);
alter table "public"."consultation_templates" add constraint "consultation_templates_category_id_title_key" UNIQUE (category_id, title);
alter table "public"."consultation_notebooks" add constraint "consultation_notebooks_pkey" PRIMARY KEY (owner_id);
alter table "public"."consultation_user_categories" add constraint "consultation_user_categories_pkey" PRIMARY KEY (id);
alter table "public"."consultation_user_templates" add constraint "consultation_user_templates_pkey" PRIMARY KEY (id);
alter table "public"."unpaid_debts" add constraint "unpaid_debts_last_name_check" CHECK (((char_length(TRIM(BOTH FROM last_name)) >= 1) AND (char_length(TRIM(BOTH FROM last_name)) <= 80)));
alter table "public"."unpaid_debts" add constraint "unpaid_debts_first_name_check" CHECK (((char_length(TRIM(BOTH FROM first_name)) >= 1) AND (char_length(TRIM(BOTH FROM first_name)) <= 80)));
alter table "public"."unpaid_debts" add constraint "unpaid_debts_telegram_check" CHECK ((char_length(telegram) <= 80));
alter table "public"."unpaid_debts" add constraint "unpaid_debts_amount_check" CHECK ((amount > (0)::numeric));
alter table "public"."unpaid_debts" add constraint "unpaid_debts_pkey" PRIMARY KEY (id);
alter table "public"."pharmacy_stock" add constraint "pharmacy_stock_quantity_check" CHECK ((quantity >= (0)::numeric));
alter table "public"."pharmacy_stock" add constraint "pharmacy_stock_pkey" PRIMARY KEY (product_resource_id);
alter table "public"."navigation_preferences" add constraint "navigation_preferences_id_check" CHECK ((id = 1));
alter table "public"."navigation_preferences" add constraint "navigation_preferences_pkey" PRIMARY KEY (id);
alter table "public"."recipes" add constraint "recipes_product_resource_id_fkey" FOREIGN KEY (product_resource_id) REFERENCES resources(id) ON DELETE RESTRICT;
alter table "public"."recipe_ingredients" add constraint "recipe_ingredients_recipe_id_fkey" FOREIGN KEY (recipe_id) REFERENCES recipes(id) ON DELETE CASCADE;
alter table "public"."recipe_ingredients" add constraint "recipe_ingredients_ingredient_resource_id_fkey" FOREIGN KEY (ingredient_resource_id) REFERENCES resources(id) ON DELETE RESTRICT;
alter table "public"."suppliers" add constraint "suppliers_resource_id_fkey" FOREIGN KEY (resource_id) REFERENCES resources(id) ON DELETE SET NULL;
alter table "public"."movements" add constraint "movements_resource_id_fkey" FOREIGN KEY (resource_id) REFERENCES resources(id) ON DELETE SET NULL;
alter table "public"."orders" add constraint "orders_resource_id_fkey" FOREIGN KEY (resource_id) REFERENCES resources(id);
alter table "public"."recipe_pricing" add constraint "recipe_pricing_product_resource_id_fkey" FOREIGN KEY (product_resource_id) REFERENCES resources(id) ON DELETE CASCADE;
alter table "public"."consultation_user_templates" add constraint "consultation_user_templates_source_template_id_fkey" FOREIGN KEY (source_template_id) REFERENCES consultation_templates(id) ON DELETE SET NULL;
alter table "public"."consultation_user_templates" add constraint "consultation_user_templates_category_id_fkey" FOREIGN KEY (category_id) REFERENCES consultation_user_categories(id) ON DELETE CASCADE;
alter table "public"."fabrication_plans" add constraint "fabrication_plans_updated_by_fkey" FOREIGN KEY (updated_by) REFERENCES auth.users(id) ON DELETE SET NULL;
alter table "public"."pharmacy_stock" add constraint "pharmacy_stock_updated_by_fkey" FOREIGN KEY (updated_by) REFERENCES auth.users(id) ON DELETE SET NULL;
alter table "public"."unpaid_debts" add constraint "unpaid_debts_created_by_fkey" FOREIGN KEY (created_by) REFERENCES auth.users(id) ON DELETE SET NULL;
alter table "public"."consultation_notebooks" add constraint "consultation_notebooks_owner_id_fkey" FOREIGN KEY (owner_id) REFERENCES auth.users(id) ON DELETE CASCADE;
alter table "public"."consultation_user_categories" add constraint "consultation_user_categories_owner_id_fkey" FOREIGN KEY (owner_id) REFERENCES auth.users(id) ON DELETE CASCADE;
alter table "public"."consultation_user_templates" add constraint "consultation_user_templates_owner_id_fkey" FOREIGN KEY (owner_id) REFERENCES auth.users(id) ON DELETE CASCADE;
alter table "public"."edit_locks" add constraint "edit_locks_user_id_fkey" FOREIGN KEY (user_id) REFERENCES profiles(id) ON DELETE CASCADE;
alter table "public"."orders" add constraint "orders_supplier_id_fkey" FOREIGN KEY (supplier_id) REFERENCES suppliers(id) ON DELETE SET NULL;
alter table "public"."fabrication_plans" add constraint "fabrication_plans_recipe_id_fkey" FOREIGN KEY (recipe_id) REFERENCES recipes(id) ON DELETE CASCADE;
alter table "private"."bureau_read_state" add constraint "bureau_read_state_user_id_fkey" FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;
alter table "public"."consultation_templates" add constraint "consultation_templates_category_id_fkey" FOREIGN KEY (category_id) REFERENCES consultation_categories(id) ON DELETE CASCADE;
alter table "public"."consultation_user_categories" add constraint "consultation_user_categories_source_category_id_fkey" FOREIGN KEY (source_category_id) REFERENCES consultation_categories(id) ON DELETE SET NULL;
alter table "public"."pharmacy_stock" add constraint "pharmacy_stock_product_resource_id_fkey" FOREIGN KEY (product_resource_id) REFERENCES resources(id) ON DELETE CASCADE;
alter table "public"."profiles" add constraint "profiles_id_fkey" FOREIGN KEY (id) REFERENCES auth.users(id) ON DELETE CASCADE;
alter table "public"."profiles" add constraint "profiles_approved_by_fkey" FOREIGN KEY (approved_by) REFERENCES auth.users(id) ON DELETE SET NULL;
alter table "public"."movements" add constraint "movements_created_by_fkey" FOREIGN KEY (created_by) REFERENCES auth.users(id) ON DELETE SET NULL;
alter table "public"."orders" add constraint "orders_created_by_fkey" FOREIGN KEY (created_by) REFERENCES auth.users(id) ON DELETE SET NULL;
alter table "public"."orders" add constraint "orders_delivered_by_fkey" FOREIGN KEY (delivered_by) REFERENCES auth.users(id) ON DELETE SET NULL;
alter table "public"."recipe_pricing" add constraint "recipe_pricing_updated_by_fkey" FOREIGN KEY (updated_by) REFERENCES auth.users(id) ON DELETE SET NULL;
CREATE INDEX edit_locks_user_id_idx ON public.edit_locks USING btree (user_id);
CREATE INDEX movements_created_at_idx ON public.movements USING btree (created_at DESC);
CREATE INDEX movements_resource_id_idx ON public.movements USING btree (resource_id);
CREATE INDEX recipe_ingredients_recipe_idx ON public.recipe_ingredients USING btree (recipe_id);
CREATE INDEX edit_locks_last_activity_idx ON public.edit_locks USING btree (last_activity);
CREATE INDEX orders_delivered_by_idx ON public.orders USING btree (delivered_by);
CREATE INDEX movements_created_by_idx ON public.movements USING btree (created_by);
CREATE INDEX recipe_ingredients_ingredient_idx ON public.recipe_ingredients USING btree (ingredient_resource_id);
CREATE INDEX suppliers_resource_id_idx ON public.suppliers USING btree (resource_id);
CREATE INDEX movements_effective_date_idx ON public.movements USING btree (effective_date DESC);
CREATE INDEX orders_resource_id_idx ON public.orders USING btree (resource_id);
CREATE INDEX orders_status_idx ON public.orders USING btree (status);
CREATE INDEX orders_created_at_idx ON public.orders USING btree (created_at DESC);
CREATE INDEX orders_created_by_idx ON public.orders USING btree (created_by);
CREATE INDEX recipe_pricing_updated_by_idx ON public.recipe_pricing USING btree (updated_by);
CREATE INDEX bureau_messages_created_at_idx ON public.bureau_messages USING btree (created_at DESC);
CREATE INDEX bureau_messages_author_id_idx ON public.bureau_messages USING btree (author_id);
CREATE INDEX orders_supplier_id_idx ON public.orders USING btree (supplier_id);
CREATE INDEX consultation_templates_category_sort_idx ON public.consultation_templates USING btree (category_id, sort_order, title);
CREATE UNIQUE INDEX consultation_user_categories_owner_source_uq ON public.consultation_user_categories USING btree (owner_id, source_category_id) WHERE (source_category_id IS NOT NULL);
CREATE INDEX consultation_user_categories_owner_idx ON public.consultation_user_categories USING btree (owner_id);
CREATE UNIQUE INDEX consultation_user_templates_owner_source_uq ON public.consultation_user_templates USING btree (owner_id, source_template_id) WHERE (source_template_id IS NOT NULL);
CREATE INDEX consultation_user_templates_owner_idx ON public.consultation_user_templates USING btree (owner_id);
CREATE INDEX consultation_user_templates_category_idx ON public.consultation_user_templates USING btree (category_id);
CREATE INDEX unpaid_debts_debt_datetime_idx ON public.unpaid_debts USING btree (debt_date, debt_time);
CREATE OR REPLACE FUNCTION public.admin_set_user_access(p_user_id uuid, p_status text)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
begin
  if not (select private.is_admin()) then
    raise exception 'Accès administrateur requis';
  end if;

  if p_status not in ('pending','approved','revoked') then
    raise exception 'Statut invalide';
  end if;

  if p_user_id = (select auth.uid()) and p_status <> 'approved' then
    raise exception 'Tu ne peux pas retirer ton propre accès administrateur';
  end if;

  update public.profiles
  set access_status = p_status,
      approved_at = case when p_status='approved' then now() else approved_at end,
      approved_by = case when p_status='approved' then (select auth.uid()) else approved_by end
  where id = p_user_id;

  if not found then
    raise exception 'Utilisateur introuvable';
  end if;
end;
$function$
;
revoke all on function "public"."admin_set_user_access"(p_user_id uuid, p_status text) from public,anon,authenticated;
grant execute on function "public"."admin_set_user_access"(p_user_id uuid, p_status text) to authenticated;
grant execute on function "public"."admin_set_user_access"(p_user_id uuid, p_status text) to service_role;
CREATE OR REPLACE FUNCTION public.get_orders()
 RETURNS TABLE(id uuid, resource_id uuid, resource_name text, quantity numeric, unit_price numeric, total_price numeric, delivery_fee numeric, status text, created_by uuid, created_at timestamp with time zone, delivered_by uuid, delivered_at timestamp with time zone, delivery_date date, delivery_time time without time zone)
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
begin
  if auth.uid() is null or not private.is_approved() then
    raise exception 'Accès non autorisé';
  end if;

  return query
  select
    o.id, o.resource_id, r.name::text, o.quantity, o.unit_price,
    o.total_price, o.delivery_fee, o.status, o.created_by, o.created_at,
    o.delivered_by, o.delivered_at, o.delivery_date, o.delivery_time
  from public.orders o
  join public.resources r on r.id = o.resource_id
  order by
    case o.status when 'a_commander' then 0 when 'en_cours' then 1 else 2 end,
    o.delivery_date asc nulls last,
    o.delivery_time asc nulls last,
    o.created_at desc;
end;
$function$
;
revoke all on function "public"."get_orders"() from public,anon,authenticated;
grant execute on function "public"."get_orders"() to authenticated;
grant execute on function "public"."get_orders"() to service_role;
CREATE OR REPLACE FUNCTION public.set_updated_at()
 RETURNS trigger
 LANGUAGE plpgsql
 SET search_path TO 'public'
AS $function$
begin
  new.updated_at = now();
  return new;
end;
$function$
;
revoke all on function "public"."set_updated_at"() from public,anon,authenticated;
grant execute on function "public"."set_updated_at"() to service_role;
CREATE OR REPLACE FUNCTION public.handle_new_user()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  v_name text := trim(coalesce(new.raw_user_meta_data->>'display_name',''));
begin
  if char_length(v_name) < 2 then
    v_name := split_part(coalesce(new.email,''), '@', 1);
  end if;

  insert into public.profiles(
    id, email, display_name, role, medical_grade, access_status
  )
  values (
    new.id,
    new.email,
    v_name,
    'medecin',
    'apprenti',
    'pending'
  )
  on conflict (id) do update
    set email = excluded.email,
        display_name = coalesce(public.profiles.display_name, excluded.display_name);
  return new;
end;
$function$
;
revoke all on function "public"."handle_new_user"() from public,anon,authenticated;
grant execute on function "public"."handle_new_user"() to service_role;
CREATE OR REPLACE FUNCTION public.touch_edit_lock(p_lock_key text)
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  v_uid uuid := auth.uid();
begin
  if v_uid is null or not private.is_approved() then
    return false;
  end if;

  update public.edit_locks
     set last_activity = now()
   where lock_key = p_lock_key
     and user_id = v_uid;

  return found;
end;
$function$
;
revoke all on function "public"."touch_edit_lock"(p_lock_key text) from public,anon,authenticated;
grant execute on function "public"."touch_edit_lock"(p_lock_key text) to authenticated;
grant execute on function "public"."touch_edit_lock"(p_lock_key text) to service_role;
CREATE OR REPLACE FUNCTION public.release_edit_lock(p_lock_key text)
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  v_uid uuid := auth.uid();
begin
  if v_uid is null then
    return false;
  end if;

  delete from public.edit_locks
   where lock_key = p_lock_key
     and user_id = v_uid;

  return found;
end;
$function$
;
revoke all on function "public"."release_edit_lock"(p_lock_key text) from public,anon,authenticated;
grant execute on function "public"."release_edit_lock"(p_lock_key text) to authenticated;
grant execute on function "public"."release_edit_lock"(p_lock_key text) to service_role;
CREATE OR REPLACE FUNCTION public.list_active_edit_locks()
 RETURNS TABLE(lock_key text, owner_id uuid, owner_name text, touched_at timestamp with time zone)
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
begin
  if auth.uid() is null or not private.is_approved() then
    raise exception 'Accès refusé';
  end if;

  delete from public.edit_locks
   where last_activity < now() - interval '60 seconds';

  return query
  select l.lock_key, l.user_id, l.display_name, l.last_activity
  from public.edit_locks l
  order by l.lock_key;
end;
$function$
;
revoke all on function "public"."list_active_edit_locks"() from public,anon,authenticated;
grant execute on function "public"."list_active_edit_locks"() to authenticated;
grant execute on function "public"."list_active_edit_locks"() to service_role;
CREATE OR REPLACE FUNCTION public.adjoint_list_apprentices()
 RETURNS TABLE(id uuid, display_name text)
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
begin
  if not (select private.is_medecin_adjoint()) then
    raise exception 'Accès médecin adjoint requis';
  end if;

  return query
  select p.id, p.display_name
  from public.profiles p
  where p.access_status = 'approved'
    and p.medical_grade = 'apprenti'
  order by lower(coalesce(p.display_name,''));
end;
$function$
;
revoke all on function "public"."adjoint_list_apprentices"() from public,anon,authenticated;
grant execute on function "public"."adjoint_list_apprentices"() to authenticated;
grant execute on function "public"."adjoint_list_apprentices"() to service_role;
CREATE OR REPLACE FUNCTION public.adjoint_promote_apprentice(p_user_id uuid)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
begin
  if not (select private.is_medecin_adjoint()) then
    raise exception 'Accès médecin adjoint requis';
  end if;

  update public.profiles
  set medical_grade = 'medecin',
      updated_at = now()
  where id = p_user_id
    and access_status = 'approved'
    and medical_grade = 'apprenti';

  if not found then
    raise exception 'Cet apprenti n’est plus disponible pour une promotion';
  end if;
end;
$function$
;
revoke all on function "public"."adjoint_promote_apprentice"(p_user_id uuid) from public,anon,authenticated;
grant execute on function "public"."adjoint_promote_apprentice"(p_user_id uuid) to authenticated;
grant execute on function "public"."adjoint_promote_apprentice"(p_user_id uuid) to service_role;
CREATE OR REPLACE FUNCTION private.is_admin()
 RETURNS boolean
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
  select exists (
    select 1
    from public.profiles p
    where p.id = (select auth.uid())
      and p.access_status = 'approved'
      and p.role = 'admin'
  );
$function$
;
revoke all on function "private"."is_admin"() from public,anon,authenticated;
grant execute on function "private"."is_admin"() to authenticated;
grant execute on function "private"."is_admin"() to service_role;
CREATE OR REPLACE FUNCTION private.is_approved()
 RETURNS boolean
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
  select exists (
    select 1
    from public.profiles p
    where p.id = (select auth.uid())
      and p.access_status = 'approved'
  );
$function$
;
revoke all on function "private"."is_approved"() from public,anon,authenticated;
grant execute on function "private"."is_approved"() to authenticated;
grant execute on function "private"."is_approved"() to service_role;
CREATE OR REPLACE FUNCTION public.apply_movement(p_resource_id uuid, p_quantity_delta numeric, p_unit_price numeric, p_cash_delta numeric, p_movement_type text, p_note text DEFAULT NULL::text, p_effective_date date DEFAULT CURRENT_DATE)
 RETURNS uuid
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  v_id uuid;
  v_stock numeric;
begin
  if auth.uid() is null or not (select private.is_approved()) then
    raise exception 'Accès non autorisé';
  end if;

  if p_movement_type = 'RETRAIT_STOCK' then
    if p_quantity_delta is null or p_quantity_delta >= 0 or p_quantity_delta <> trunc(p_quantity_delta) then
      raise exception 'Indiquez une quantité entière à retirer';
    end if;
    if coalesce(p_cash_delta,0) <> 0 or p_unit_price is not null then
      raise exception 'Un retrait de stock ne doit comporter aucun mouvement d’argent';
    end if;
    if not exists (
      select 1 from public.resources r join public.recipes rc on rc.product_resource_id=r.id
      where r.id=p_resource_id and r.active=true and rc.active=true
    ) then raise exception 'Le retrait est réservé aux articles des recettes'; end if;
  end if;

  if p_resource_id is not null then
    select stock into v_stock
    from public.resources
    where id = p_resource_id
    for update;

    if not found then
      raise exception 'Ressource introuvable';
    end if;

    if v_stock + coalesce(p_quantity_delta,0) < 0 then
      raise exception 'Stock insuffisant';
    end if;

    update public.resources
    set stock = stock + coalesce(p_quantity_delta,0),
        unit_price = case
          when p_unit_price is not null and p_unit_price >= 0 then p_unit_price
          else unit_price
        end
    where id = p_resource_id;
  end if;

  update public.cabinet_state
  set cash_balance = cash_balance + coalesce(p_cash_delta,0)
  where id = 1;

  insert into public.movements(
    movement_type, resource_id, quantity_delta, unit_price, cash_delta,
    note, created_by, effective_date
  )
  values (
    coalesce(nullif(trim(p_movement_type),''),'ajustement'),
    p_resource_id,
    coalesce(p_quantity_delta,0),
    p_unit_price,
    coalesce(p_cash_delta,0),
    p_note,
    auth.uid(),
    coalesce(p_effective_date,current_date)
  )
  returning id into v_id;

  return v_id;
end;
$function$
;
revoke all on function "public"."apply_movement"(p_resource_id uuid, p_quantity_delta numeric, p_unit_price numeric, p_cash_delta numeric, p_movement_type text, p_note text, p_effective_date date) from public,anon,authenticated;
grant execute on function "public"."apply_movement"(p_resource_id uuid, p_quantity_delta numeric, p_unit_price numeric, p_cash_delta numeric, p_movement_type text, p_note text, p_effective_date date) to authenticated;
grant execute on function "public"."apply_movement"(p_resource_id uuid, p_quantity_delta numeric, p_unit_price numeric, p_cash_delta numeric, p_movement_type text, p_note text, p_effective_date date) to service_role;
create or replace function public.reset_cabinet() returns void language plpgsql security definer set search_path='' as $f$
 begin
 if auth.uid() is null or not private.is_admin() then raise exception 'Accès administrateur requis'; end if;
 delete from public.orders; delete from public.fabrication_plans; delete from public.movements; delete from public.unpaid_debts;
 update public.resources set stock=0,unit_price=0;
 update public.pharmacy_stock set quantity=0;
 update public.recipe_pricing set pharmacy_price=null,recommended_price=0,cabinet_return=0,updated_by=auth.uid();
 update public.suppliers set unit_price=null;
 update public.cabinet_state set cash_balance=0 where id=1;
 end; $f$;;
revoke all on function "public"."reset_cabinet"() from public,anon,authenticated;
grant execute on function "public"."reset_cabinet"() to authenticated;
grant execute on function "public"."reset_cabinet"() to service_role;
CREATE OR REPLACE FUNCTION public.remove_ingredient(p_resource_id uuid)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
begin
  if auth.uid() is null or not (select private.is_approved()) then
    raise exception 'Accès non autorisé';
  end if;

  if not exists (
    select 1 from public.resources
    where id = p_resource_id and category = 'ingredient' and active = true
  ) then
    raise exception 'Ingrédient introuvable ou déjà retiré';
  end if;

  delete from public.recipe_ingredients
  where ingredient_resource_id = p_resource_id;

  update public.suppliers
  set active = false
  where resource_id = p_resource_id;

  update public.resources
  set active = false
  where id = p_resource_id;
end;
$function$
;
revoke all on function "public"."remove_ingredient"(p_resource_id uuid) from public,anon,authenticated;
grant execute on function "public"."remove_ingredient"(p_resource_id uuid) to authenticated;
grant execute on function "public"."remove_ingredient"(p_resource_id uuid) to service_role;
CREATE OR REPLACE FUNCTION public.admin_set_display_name(p_user_id uuid, p_display_name text)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  v_name text := trim(coalesce(p_display_name,''));
begin
  if not (select private.is_admin()) then
    raise exception 'Accès administrateur requis';
  end if;

  if char_length(v_name) < 2 then
    raise exception 'Le nom doit contenir au moins 2 caractères';
  end if;

  if char_length(v_name) > 60 then
    raise exception 'Le nom ne peut pas dépasser 60 caractères';
  end if;

  update public.profiles
  set display_name = v_name,
      updated_at = now()
  where id = p_user_id;

  if not found then
    raise exception 'Utilisateur introuvable';
  end if;
end;
$function$
;
revoke all on function "public"."admin_set_display_name"(p_user_id uuid, p_display_name text) from public,anon,authenticated;
grant execute on function "public"."admin_set_display_name"(p_user_id uuid, p_display_name text) to authenticated;
grant execute on function "public"."admin_set_display_name"(p_user_id uuid, p_display_name text) to service_role;
CREATE OR REPLACE FUNCTION public.get_movement_history()
 RETURNS TABLE(id uuid, movement_type text, resource_id uuid, quantity_delta numeric, unit_price numeric, cash_delta numeric, note text, details jsonb, created_by uuid, created_at timestamp with time zone, effective_date date, actor_name text)
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
begin
  if auth.uid() is null or not (select private.is_approved()) then
    raise exception 'Accès non autorisé';
  end if;

  return query
  select
    m.id,
    m.movement_type,
    m.resource_id,
    m.quantity_delta,
    m.unit_price,
    m.cash_delta,
    m.note,
    m.details,
    m.created_by,
    m.created_at,
    m.effective_date,
    coalesce(p.display_name, p.email, 'Utilisateur inconnu')::text as actor_name
  from public.movements m
  left join public.profiles p on p.id = m.created_by
  order by m.created_at asc;
end;
$function$
;
revoke all on function "public"."get_movement_history"() from public,anon,authenticated;
grant execute on function "public"."get_movement_history"() to authenticated;
grant execute on function "public"."get_movement_history"() to service_role;
CREATE OR REPLACE FUNCTION public.claim_edit_lock(p_lock_key text)
 RETURNS TABLE(acquired boolean, owner_id uuid, owner_name text, touched_at timestamp with time zone)
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  v_uid uuid := auth.uid();
  v_name text;
begin
  if v_uid is null or not private.is_approved() then
    raise exception 'Accès refusé';
  end if;

  if p_lock_key is null or length(trim(p_lock_key)) < 1 or length(p_lock_key) > 200 then
    raise exception 'Clé de verrou invalide';
  end if;

  select coalesce(nullif(trim(p.display_name), ''), split_part(coalesce(p.email,''), '@', 1), 'Utilisateur')
    into v_name
  from public.profiles p
  where p.id = v_uid;

  delete from public.edit_locks
   where lock_key = p_lock_key
     and last_activity < now() - interval '60 seconds';

  insert into public.edit_locks(lock_key, user_id, display_name, last_activity)
  values (p_lock_key, v_uid, coalesce(v_name,'Utilisateur'), now())
  on conflict (lock_key) do update
    set display_name = excluded.display_name,
        last_activity = now()
    where public.edit_locks.user_id = v_uid;

  return query
  select (l.user_id = v_uid),
         l.user_id,
         l.display_name,
         l.last_activity
  from public.edit_locks l
  where l.lock_key = p_lock_key;
end;
$function$
;
revoke all on function "public"."claim_edit_lock"(p_lock_key text) from public,anon,authenticated;
grant execute on function "public"."claim_edit_lock"(p_lock_key text) to authenticated;
grant execute on function "public"."claim_edit_lock"(p_lock_key text) to service_role;
CREATE OR REPLACE FUNCTION public.delete_order(p_order_id uuid)
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
begin
  if auth.uid() is null or not private.is_approved() then
    raise exception 'Accès non autorisé';
  end if;

  delete from public.orders
  where id = p_order_id;

  return found;
end;
$function$
;
revoke all on function "public"."delete_order"(p_order_id uuid) from public,anon,authenticated;
grant execute on function "public"."delete_order"(p_order_id uuid) to authenticated;
grant execute on function "public"."delete_order"(p_order_id uuid) to service_role;
CREATE OR REPLACE FUNCTION public.update_order_delivery_fee(p_order_id uuid, p_delivery_fee numeric)
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
begin
  if auth.uid() is null or not private.is_approved() then
    raise exception 'Accès non autorisé';
  end if;

  if p_delivery_fee is null or p_delivery_fee < 0 then
    raise exception 'Frais de livraison invalides';
  end if;

  update public.orders
  set delivery_fee = p_delivery_fee
  where id = p_order_id
    and status in ('a_commander','en_cours');

  return found;
end;
$function$
;
revoke all on function "public"."update_order_delivery_fee"(p_order_id uuid, p_delivery_fee numeric) from public,anon,authenticated;
grant execute on function "public"."update_order_delivery_fee"(p_order_id uuid, p_delivery_fee numeric) to authenticated;
grant execute on function "public"."update_order_delivery_fee"(p_order_id uuid, p_delivery_fee numeric) to service_role;
CREATE OR REPLACE FUNCTION public.create_order(p_resource_id uuid, p_quantity numeric, p_delivery_fee numeric DEFAULT 0, p_delivery_date date DEFAULT CURRENT_DATE, p_delivery_time time without time zone DEFAULT NULL::time without time zone)
 RETURNS uuid
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  v_id uuid;
  v_price numeric;
begin
  if auth.uid() is null or not private.is_approved() then
    raise exception 'Accès non autorisé';
  end if;

  if p_quantity is null or p_quantity <= 0 then
    raise exception 'Quantité invalide';
  end if;

  if coalesce(p_delivery_fee,0) < 0 then
    raise exception 'Frais de livraison invalides';
  end if;

  if p_delivery_date is null then
    raise exception 'Date de livraison requise';
  end if;

  if p_delivery_time is null then
    raise exception 'Heure de livraison requise';
  end if;

  select coalesce(
    (
      select s.unit_price
      from public.suppliers s
      where s.resource_id = r.id
        and s.active = true
        and s.unit_price is not null
      order by s.updated_at desc
      limit 1
    ),
    r.unit_price,
    0
  )
  into v_price
  from public.resources r
  where r.id = p_resource_id
    and r.active = true
    and r.category = 'ingredient';

  if not found then
    raise exception 'Ingrédient introuvable';
  end if;

  insert into public.orders(
    resource_id, quantity, unit_price, delivery_fee, status, created_by,
    delivery_date, delivery_time
  )
  values (
    p_resource_id, p_quantity, greatest(coalesce(v_price,0),0),
    coalesce(p_delivery_fee,0), 'en_cours', auth.uid(),
    p_delivery_date, p_delivery_time
  )
  returning id into v_id;

  return v_id;
end;
$function$
;
revoke all on function "public"."create_order"(p_resource_id uuid, p_quantity numeric, p_delivery_fee numeric, p_delivery_date date, p_delivery_time time without time zone) from public,anon,authenticated;
grant execute on function "public"."create_order"(p_resource_id uuid, p_quantity numeric, p_delivery_fee numeric, p_delivery_date date, p_delivery_time time without time zone) to authenticated;
grant execute on function "public"."create_order"(p_resource_id uuid, p_quantity numeric, p_delivery_fee numeric, p_delivery_date date, p_delivery_time time without time zone) to service_role;
CREATE OR REPLACE FUNCTION public.get_recipe_pricing()
 RETURNS TABLE(product_resource_id uuid, product_name text, pharmacy_price numeric, recommended_price numeric, cabinet_return numeric, pharmacy_sellable boolean)
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
begin
  if auth.uid() is null or not private.is_approved() then
    raise exception 'Accès non autorisé';
  end if;

  return query
  select
    r.id,
    r.name::text,
    case
      when coalesce(p.pharmacy_sellable, case when upper(r.name) in ('KIT DE SOIN','SERINGUE VIVIFIANTE') then false else true end)
        then coalesce(p.pharmacy_price, r.unit_price, 0)
      else null
    end,
    coalesce(p.recommended_price,0),
    coalesce(p.cabinet_return,0),
    coalesce(p.pharmacy_sellable, case when upper(r.name) in ('KIT DE SOIN','SERINGUE VIVIFIANTE') then false else true end)
  from public.recipes rc
  join public.resources r on r.id=rc.product_resource_id
  left join public.recipe_pricing p on p.product_resource_id=r.id
  where rc.active=true
  order by r.name;
end;
$function$
;
revoke all on function "public"."get_recipe_pricing"() from public,anon,authenticated;
grant execute on function "public"."get_recipe_pricing"() to authenticated;
grant execute on function "public"."get_recipe_pricing"() to service_role;
CREATE OR REPLACE FUNCTION public.admin_set_recipe_pricing(p_product_resource_id uuid, p_pharmacy_price numeric, p_recommended_price numeric, p_cabinet_return numeric)
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  v_name text;
  v_sellable boolean;
begin
  if auth.uid() is null or not private.is_admin() then
    raise exception 'Action réservée à l’administrateur';
  end if;

  select r.name,
         case when upper(r.name) in ('KIT DE SOIN','SERINGUE VIVIFIANTE') then false else true end
  into v_name, v_sellable
  from public.resources r
  join public.recipes rc on rc.product_resource_id=r.id and rc.active=true
  where r.id=p_product_resource_id;

  if not found then
    raise exception 'Recette introuvable';
  end if;

  if coalesce(p_recommended_price,0) < 0 or coalesce(p_cabinet_return,0) < 0 then
    raise exception 'Montant invalide';
  end if;

  if v_sellable and coalesce(p_pharmacy_price,0) < 0 then
    raise exception 'Prix pharmacie invalide';
  end if;

  insert into public.recipe_pricing(
    product_resource_id,
    pharmacy_price,
    recommended_price,
    cabinet_return,
    pharmacy_sellable,
    updated_at,
    updated_by
  )
  values (
    p_product_resource_id,
    case when v_sellable then coalesce(p_pharmacy_price,0) else null end,
    coalesce(p_recommended_price,0),
    coalesce(p_cabinet_return,0),
    v_sellable,
    now(),
    auth.uid()
  )
  on conflict (product_resource_id) do update
  set pharmacy_price=excluded.pharmacy_price,
      recommended_price=excluded.recommended_price,
      cabinet_return=excluded.cabinet_return,
      pharmacy_sellable=excluded.pharmacy_sellable,
      updated_at=now(),
      updated_by=auth.uid();

  return true;
end;
$function$
;
revoke all on function "public"."admin_set_recipe_pricing"(p_product_resource_id uuid, p_pharmacy_price numeric, p_recommended_price numeric, p_cabinet_return numeric) from public,anon,authenticated;
grant execute on function "public"."admin_set_recipe_pricing"(p_product_resource_id uuid, p_pharmacy_price numeric, p_recommended_price numeric, p_cabinet_return numeric) to authenticated;
grant execute on function "public"."admin_set_recipe_pricing"(p_product_resource_id uuid, p_pharmacy_price numeric, p_recommended_price numeric, p_cabinet_return numeric) to service_role;
CREATE OR REPLACE FUNCTION public.get_my_profile()
 RETURNS TABLE(id uuid, email text, display_name text, role text, medical_grade text, access_status text, created_at timestamp with time zone)
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
begin
  if auth.uid() is null then
    raise exception 'Authentification requise';
  end if;

  return query
  select p.id, p.email, p.display_name, p.role, p.medical_grade, p.access_status, p.created_at
  from public.profiles p
  where p.id = auth.uid();
end;
$function$
;
revoke all on function "public"."get_my_profile"() from public,anon,authenticated;
grant execute on function "public"."get_my_profile"() to authenticated;
grant execute on function "public"."get_my_profile"() to service_role;
CREATE OR REPLACE FUNCTION public.admin_list_profiles()
 RETURNS TABLE(id uuid, email text, display_name text, role text, medical_grade text, access_status text, created_at timestamp with time zone)
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
begin
  if not (select private.is_admin()) then
    raise exception 'Accès administrateur requis';
  end if;

  return query
  select p.id, p.email, p.display_name, p.role, p.medical_grade, p.access_status, p.created_at
  from public.profiles p
  order by p.created_at;
end;
$function$
;
revoke all on function "public"."admin_list_profiles"() from public,anon,authenticated;
grant execute on function "public"."admin_list_profiles"() to authenticated;
grant execute on function "public"."admin_list_profiles"() to service_role;
CREATE OR REPLACE FUNCTION public.admin_set_medical_grade(p_user_id uuid, p_grade text)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
begin
  if not (select private.is_admin()) then
    raise exception 'Accès administrateur requis';
  end if;

  if p_grade not in ('apprenti','medecin','medecin_adjoint') then
    raise exception 'Grade invalide';
  end if;

  update public.profiles
  set medical_grade = p_grade,
      updated_at = now()
  where id = p_user_id;

  if not found then
    raise exception 'Utilisateur introuvable';
  end if;
end;
$function$
;
revoke all on function "public"."admin_set_medical_grade"(p_user_id uuid, p_grade text) from public,anon,authenticated;
grant execute on function "public"."admin_set_medical_grade"(p_user_id uuid, p_grade text) to authenticated;
grant execute on function "public"."admin_set_medical_grade"(p_user_id uuid, p_grade text) to service_role;
CREATE OR REPLACE FUNCTION private.is_medecin_adjoint()
 RETURNS boolean
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
  select exists (
    select 1
    from public.profiles p
    where p.id = (select auth.uid())
      and p.access_status = 'approved'
      and p.medical_grade = 'medecin_adjoint'
  );
$function$
;
revoke all on function "private"."is_medecin_adjoint"() from public,anon,authenticated;
grant execute on function "private"."is_medecin_adjoint"() to authenticated;
grant execute on function "private"."is_medecin_adjoint"() to service_role;
CREATE OR REPLACE FUNCTION public.post_bureau_message(p_body text DEFAULT ''::text, p_attachment_path text DEFAULT NULL::text, p_attachment_name text DEFAULT NULL::text, p_attachment_type text DEFAULT NULL::text, p_attachment_size bigint DEFAULT NULL::bigint)
 RETURNS uuid
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  v_id uuid;
  v_body text := coalesce(p_body,'');
  v_path text := nullif(btrim(coalesce(p_attachment_path,'')),'');
begin
  if not (select private.is_approved()) then
    raise exception 'Accès au cabinet requis';
  end if;

  if char_length(v_body) > 4000 then
    raise exception 'Message trop long';
  end if;

  if char_length(btrim(v_body)) = 0 and v_path is null then
    raise exception 'Écris un message ou joins un fichier';
  end if;

  if p_attachment_size is not null and (p_attachment_size < 0 or p_attachment_size > 20971520) then
    raise exception 'Le fichier dépasse la limite de 20 Mo';
  end if;

  if v_path is not null and split_part(v_path,'/',1) <> (select auth.uid())::text then
    raise exception 'Chemin de fichier invalide';
  end if;

  insert into public.bureau_messages(
    author_id, body, attachment_path, attachment_name, attachment_type, attachment_size
  )
  values (
    (select auth.uid()),
    v_body,
    v_path,
    nullif(btrim(coalesce(p_attachment_name,'')),''),
    nullif(btrim(coalesce(p_attachment_type,'')),''),
    p_attachment_size
  )
  returning id into v_id;

  return v_id;
end;
$function$
;
revoke all on function "public"."post_bureau_message"(p_body text, p_attachment_path text, p_attachment_name text, p_attachment_type text, p_attachment_size bigint) from public,anon,authenticated;
grant execute on function "public"."post_bureau_message"(p_body text, p_attachment_path text, p_attachment_name text, p_attachment_type text, p_attachment_size bigint) to authenticated;
grant execute on function "public"."post_bureau_message"(p_body text, p_attachment_path text, p_attachment_name text, p_attachment_type text, p_attachment_size bigint) to service_role;
CREATE OR REPLACE FUNCTION public.delete_bureau_message(p_message_id uuid)
 RETURNS text
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  v_author uuid;
  v_path text;
begin
  if not (select private.is_approved()) then
    raise exception 'Accès au cabinet requis';
  end if;

  select m.author_id, m.attachment_path
  into v_author, v_path
  from public.bureau_messages m
  where m.id = p_message_id;

  if v_author is null then
    raise exception 'Message introuvable';
  end if;

  if v_author <> (select auth.uid()) and not (select private.is_admin()) then
    raise exception 'Tu ne peux supprimer que tes propres messages';
  end if;

  delete from public.bureau_messages where id = p_message_id;
  return v_path;
end;
$function$
;
revoke all on function "public"."delete_bureau_message"(p_message_id uuid) from public,anon,authenticated;
grant execute on function "public"."delete_bureau_message"(p_message_id uuid) to authenticated;
grant execute on function "public"."delete_bureau_message"(p_message_id uuid) to service_role;
CREATE OR REPLACE FUNCTION public.get_bureau_messages(p_limit integer DEFAULT 100)
 RETURNS TABLE(id uuid, author_id uuid, author_name text, author_grade text, body text, attachment_path text, attachment_name text, attachment_type text, attachment_size bigint, external_url text, external_page_url text, external_provider text, external_id text, created_at timestamp with time zone)
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
begin
  if not (select private.is_approved()) then
    raise exception 'Accès au cabinet requis';
  end if;

  return query
  select
    m.id,
    m.author_id,
    coalesce(p.display_name,'Personnel médical') as author_name,
    coalesce(p.medical_grade,'medecin') as author_grade,
    m.body,
    m.attachment_path,
    m.attachment_name,
    m.attachment_type,
    m.attachment_size,
    m.external_url,
    m.external_page_url,
    m.external_provider,
    m.external_id,
    m.created_at
  from public.bureau_messages m
  left join public.profiles p on p.id = m.author_id
  order by m.created_at desc
  limit greatest(1, least(coalesce(p_limit,100),200));
end;
$function$
;
revoke all on function "public"."get_bureau_messages"(p_limit integer) from public,anon,authenticated;
grant execute on function "public"."get_bureau_messages"(p_limit integer) to authenticated;
grant execute on function "public"."get_bureau_messages"(p_limit integer) to service_role;
CREATE OR REPLACE FUNCTION public.post_bureau_message_v2(p_body text DEFAULT ''::text, p_attachment_path text DEFAULT NULL::text, p_attachment_name text DEFAULT NULL::text, p_attachment_type text DEFAULT NULL::text, p_attachment_size bigint DEFAULT NULL::bigint, p_external_url text DEFAULT NULL::text, p_external_page_url text DEFAULT NULL::text, p_external_provider text DEFAULT NULL::text, p_external_id text DEFAULT NULL::text)
 RETURNS uuid
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  v_id uuid;
  v_body text := coalesce(p_body,'');
  v_path text := nullif(btrim(coalesce(p_attachment_path,'')),'');
  v_external text := nullif(btrim(coalesce(p_external_url,'')),'');
  v_page text := nullif(btrim(coalesce(p_external_page_url,'')),'');
  v_provider text := lower(nullif(btrim(coalesce(p_external_provider,'')),''));
begin
  if not (select private.is_approved()) then
    raise exception 'Accès au cabinet requis';
  end if;

  if char_length(v_body) > 4000 then
    raise exception 'Message trop long';
  end if;

  if char_length(btrim(v_body)) = 0 and v_path is null and v_external is null then
    raise exception 'Écris un message ou joins un fichier';
  end if;

  if p_attachment_size is not null and (p_attachment_size < 0 or p_attachment_size > 20971520) then
    raise exception 'Le fichier dépasse la limite de 20 Mo';
  end if;

  if v_path is not null and split_part(v_path,'/',1) <> (select auth.uid())::text then
    raise exception 'Chemin de fichier invalide';
  end if;

  if v_external is not null then
    if v_provider <> 'giphy' then
      raise exception 'Fournisseur GIF invalide';
    end if;

    if v_external !~* '^https://([a-z0-9-]+\.)*giphy\.com/' then
      raise exception 'Adresse GIF invalide';
    end if;

    if v_page is not null and v_page !~* '^https://([a-z0-9-]+\.)*giphy\.com/' then
      raise exception 'Adresse GIPHY invalide';
    end if;
  end if;

  insert into public.bureau_messages(
    author_id,
    body,
    attachment_path,
    attachment_name,
    attachment_type,
    attachment_size,
    external_url,
    external_page_url,
    external_provider,
    external_id
  )
  values (
    (select auth.uid()),
    v_body,
    v_path,
    nullif(btrim(coalesce(p_attachment_name,'')),''),
    nullif(btrim(coalesce(p_attachment_type,'')),''),
    p_attachment_size,
    v_external,
    v_page,
    v_provider,
    nullif(btrim(coalesce(p_external_id,'')),'')
  )
  returning id into v_id;

  return v_id;
end;
$function$
;
revoke all on function "public"."post_bureau_message_v2"(p_body text, p_attachment_path text, p_attachment_name text, p_attachment_type text, p_attachment_size bigint, p_external_url text, p_external_page_url text, p_external_provider text, p_external_id text) from public,anon,authenticated;
grant execute on function "public"."post_bureau_message_v2"(p_body text, p_attachment_path text, p_attachment_name text, p_attachment_type text, p_attachment_size bigint, p_external_url text, p_external_page_url text, p_external_provider text, p_external_id text) to authenticated;
grant execute on function "public"."post_bureau_message_v2"(p_body text, p_attachment_path text, p_attachment_name text, p_attachment_type text, p_attachment_size bigint, p_external_url text, p_external_page_url text, p_external_provider text, p_external_id text) to service_role;
CREATE OR REPLACE FUNCTION public.get_bureau_typing()
 RETURNS TABLE(user_id uuid, display_name text, medical_grade text, updated_at timestamp with time zone)
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
begin
  if not (select private.is_approved()) then
    raise exception 'Accès au cabinet requis';
  end if;

  delete from public.bureau_typing
  where updated_at < now() - interval '8 seconds';

  return query
  select
    t.user_id,
    coalesce(p.display_name,'Personnel médical'),
    coalesce(p.medical_grade,'medecin'),
    t.updated_at
  from public.bureau_typing t
  left join public.profiles p on p.id=t.user_id
  where t.updated_at >= now() - interval '5 seconds'
    and t.user_id <> (select auth.uid())
  order by t.updated_at desc;
end;
$function$
;
revoke all on function "public"."get_bureau_typing"() from public,anon,authenticated;
grant execute on function "public"."get_bureau_typing"() to authenticated;
grant execute on function "public"."get_bureau_typing"() to service_role;
CREATE OR REPLACE FUNCTION public.set_bureau_typing(p_is_typing boolean)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
begin
  if not (select private.is_approved()) then
    raise exception 'Accès au cabinet requis';
  end if;

  if coalesce(p_is_typing,false) then
    insert into public.bureau_typing(user_id,updated_at)
    values ((select auth.uid()), now())
    on conflict (user_id) do update
      set updated_at = excluded.updated_at;
  else
    delete from public.bureau_typing
    where user_id = (select auth.uid());
  end if;
end;
$function$
;
revoke all on function "public"."set_bureau_typing"(p_is_typing boolean) from public,anon,authenticated;
grant execute on function "public"."set_bureau_typing"(p_is_typing boolean) to authenticated;
grant execute on function "public"."set_bureau_typing"(p_is_typing boolean) to service_role;
CREATE OR REPLACE FUNCTION public.queue_recipe_missing(p_recipe_id uuid, p_quantity numeric)
 RETURNS numeric
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  v_item record;
  v_outstanding numeric;
  v_missing numeric;
  v_total_added numeric := 0;
  v_found boolean := false;
begin
  if auth.uid() is null or not private.is_approved() then
    raise exception 'Accès non autorisé';
  end if;

  if p_quantity is null or p_quantity <= 0 or p_quantity <> trunc(p_quantity) then
    raise exception 'Quantité de fabrication invalide';
  end if;

  if not exists (
    select 1
    from public.recipes r
    where r.id = p_recipe_id
      and r.active = true
  ) then
    raise exception 'Recette introuvable';
  end if;

  for v_item in
    select
      ri.ingredient_resource_id as resource_id,
      ri.quantity as quantity_per_item,
      coalesce(res.stock, 0) as stock
    from public.recipe_ingredients ri
    join public.resources res
      on res.id = ri.ingredient_resource_id
     and res.active = true
     and res.category = 'ingredient'
    where ri.recipe_id = p_recipe_id
      and ri.quantity > 0
    order by ri.ingredient_resource_id
  loop
    v_found := true;

    perform pg_catalog.pg_advisory_xact_lock(
      pg_catalog.hashtextextended(v_item.resource_id::text, 0)
    );

    select coalesce(sum(o.quantity), 0)
    into v_outstanding
    from public.orders o
    where o.resource_id = v_item.resource_id
      and o.status in ('a_commander', 'en_cours');

    v_missing := greatest(
      (v_item.quantity_per_item * p_quantity)
      - v_item.stock
      - v_outstanding,
      0
    );

    if v_missing > 0 then
      perform public.queue_order(v_item.resource_id, v_missing);
      v_total_added := v_total_added + v_missing;
    end if;
  end loop;

  if not v_found then
    raise exception 'Cette recette ne contient aucun ingrédient';
  end if;

  return v_total_added;
end;
$function$
;
revoke all on function "public"."queue_recipe_missing"(p_recipe_id uuid, p_quantity numeric) from public,anon,authenticated;
grant execute on function "public"."queue_recipe_missing"(p_recipe_id uuid, p_quantity numeric) to authenticated;
grant execute on function "public"."queue_recipe_missing"(p_recipe_id uuid, p_quantity numeric) to service_role;
CREATE OR REPLACE FUNCTION public.queue_order(p_resource_id uuid, p_quantity numeric)
 RETURNS uuid
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  v_id uuid;
  v_price numeric;
  v_pending_quantity numeric;
begin
  if auth.uid() is null or not private.is_approved() then
    raise exception 'Accès non autorisé';
  end if;

  if p_quantity is null or p_quantity <= 0 then
    raise exception 'Quantité invalide';
  end if;

  select coalesce(
    (
      select s.unit_price
      from public.suppliers s
      where s.resource_id = r.id
        and s.active = true
        and s.unit_price is not null
      order by s.updated_at desc
      limit 1
    ),
    r.unit_price,
    0
  )
  into v_price
  from public.resources r
  where r.id = p_resource_id
    and r.active = true
    and r.category = 'ingredient';

  if not found then
    raise exception 'Ingrédient introuvable';
  end if;

  perform pg_catalog.pg_advisory_xact_lock(
    pg_catalog.hashtextextended(p_resource_id::text, 0)
  );

  select o.id
  into v_id
  from public.orders o
  where o.resource_id = p_resource_id
    and o.status = 'a_commander'
  order by o.created_at, o.id
  limit 1
  for update;

  if found then
    select coalesce(sum(o.quantity), 0)
    into v_pending_quantity
    from public.orders o
    where o.resource_id = p_resource_id
      and o.status = 'a_commander';

    update public.orders
    set quantity = v_pending_quantity + p_quantity,
        unit_price = greatest(coalesce(v_price, 0), 0)
    where id = v_id;

    delete from public.orders
    where resource_id = p_resource_id
      and status = 'a_commander'
      and id <> v_id;
  else
    insert into public.orders(
      resource_id, quantity, unit_price, delivery_fee, status, created_by,
      delivery_date, delivery_time
    )
    values (
      p_resource_id, p_quantity, greatest(coalesce(v_price,0),0),
      0, 'a_commander', auth.uid(), null, null
    )
    returning id into v_id;
  end if;

  return v_id;
end;
$function$
;
revoke all on function "public"."queue_order"(p_resource_id uuid, p_quantity numeric) from public,anon,authenticated;
grant execute on function "public"."queue_order"(p_resource_id uuid, p_quantity numeric) to authenticated;
grant execute on function "public"."queue_order"(p_resource_id uuid, p_quantity numeric) to service_role;
CREATE OR REPLACE FUNCTION public.create_order_with_supplier(p_resource_id uuid, p_supplier_id uuid, p_quantity numeric, p_delivery_fee numeric DEFAULT 0, p_delivery_date date DEFAULT CURRENT_DATE, p_delivery_time time without time zone DEFAULT NULL::time without time zone)
 RETURNS uuid
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  v_id uuid;
  v_price numeric;
begin
  if auth.uid() is null or not private.is_approved() then
    raise exception 'Accès non autorisé';
  end if;
  if p_quantity is null or p_quantity <= 0 then
    raise exception 'Quantité invalide';
  end if;
  if coalesce(p_delivery_fee,0) < 0 then
    raise exception 'Frais de livraison invalides';
  end if;
  if p_delivery_date is null or p_delivery_time is null then
    raise exception 'Date et heure de livraison requises';
  end if;

  select greatest(coalesce(s.unit_price,r.unit_price,0),0)
    into v_price
  from public.resources r
  join public.suppliers s
    on s.resource_id=r.id
   and s.id=p_supplier_id
   and s.active=true
  where r.id=p_resource_id
    and r.active=true
    and r.category='ingredient';

  if not found then
    raise exception 'Fournisseur invalide pour cet ingrédient';
  end if;

  insert into public.orders(
    resource_id,supplier_id,quantity,unit_price,delivery_fee,status,created_by,
    delivery_date,delivery_time
  ) values (
    p_resource_id,p_supplier_id,p_quantity,v_price,coalesce(p_delivery_fee,0),
    'en_cours',auth.uid(),p_delivery_date,p_delivery_time
  )
  returning id into v_id;

  return v_id;
end;
$function$
;
revoke all on function "public"."create_order_with_supplier"(p_resource_id uuid, p_supplier_id uuid, p_quantity numeric, p_delivery_fee numeric, p_delivery_date date, p_delivery_time time without time zone) from public,anon,authenticated;
grant execute on function "public"."create_order_with_supplier"(p_resource_id uuid, p_supplier_id uuid, p_quantity numeric, p_delivery_fee numeric, p_delivery_date date, p_delivery_time time without time zone) to authenticated;
grant execute on function "public"."create_order_with_supplier"(p_resource_id uuid, p_supplier_id uuid, p_quantity numeric, p_delivery_fee numeric, p_delivery_date date, p_delivery_time time without time zone) to service_role;
CREATE OR REPLACE FUNCTION public.queue_order_with_supplier(p_resource_id uuid, p_supplier_id uuid, p_quantity numeric)
 RETURNS uuid
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  v_id uuid;
  v_price numeric;
  v_pending_quantity numeric;
begin
  if auth.uid() is null or not private.is_approved() then
    raise exception 'Accès non autorisé';
  end if;
  if p_quantity is null or p_quantity <= 0 then
    raise exception 'Quantité invalide';
  end if;

  select greatest(coalesce(s.unit_price,r.unit_price,0),0)
    into v_price
  from public.resources r
  join public.suppliers s
    on s.resource_id=r.id
   and s.id=p_supplier_id
   and s.active=true
  where r.id=p_resource_id
    and r.active=true
    and r.category='ingredient';

  if not found then
    raise exception 'Fournisseur invalide pour cet ingrédient';
  end if;

  perform pg_catalog.pg_advisory_xact_lock(
    pg_catalog.hashtextextended(p_resource_id::text || ':' || p_supplier_id::text,0)
  );

  select o.id into v_id
  from public.orders o
  where o.resource_id=p_resource_id
    and o.supplier_id=p_supplier_id
    and o.status='a_commander'
  order by o.created_at,o.id
  limit 1
  for update;

  if found then
    select coalesce(sum(o.quantity),0)
      into v_pending_quantity
    from public.orders o
    where o.resource_id=p_resource_id
      and o.supplier_id=p_supplier_id
      and o.status='a_commander';

    update public.orders
    set quantity=v_pending_quantity+p_quantity,
        unit_price=v_price
    where id=v_id;

    delete from public.orders
    where resource_id=p_resource_id
      and supplier_id=p_supplier_id
      and status='a_commander'
      and id<>v_id;
  else
    insert into public.orders(
      resource_id,supplier_id,quantity,unit_price,delivery_fee,status,created_by,
      delivery_date,delivery_time
    ) values (
      p_resource_id,p_supplier_id,p_quantity,v_price,0,'a_commander',auth.uid(),null,null
    )
    returning id into v_id;
  end if;

  return v_id;
end;
$function$
;
revoke all on function "public"."queue_order_with_supplier"(p_resource_id uuid, p_supplier_id uuid, p_quantity numeric) from public,anon,authenticated;
grant execute on function "public"."queue_order_with_supplier"(p_resource_id uuid, p_supplier_id uuid, p_quantity numeric) to authenticated;
grant execute on function "public"."queue_order_with_supplier"(p_resource_id uuid, p_supplier_id uuid, p_quantity numeric) to service_role;
CREATE OR REPLACE FUNCTION public.get_orders_v2()
 RETURNS TABLE(id uuid, resource_id uuid, resource_name text, supplier_id uuid, supplier_name text, supplier_telegram text, supplier_location text, quantity numeric, unit_price numeric, total_price numeric, delivery_fee numeric, status text, created_by uuid, created_at timestamp with time zone, delivered_by uuid, delivered_at timestamp with time zone, delivery_date date, delivery_time time without time zone)
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
begin
  if auth.uid() is null or not private.is_approved() then
    raise exception 'Accès non autorisé';
  end if;

  return query
  select
    o.id,
    o.resource_id,
    r.name::text,
    o.supplier_id,
    coalesce(s.supplier_name, s.location, '')::text,
    coalesce(s.telegram, '')::text,
    coalesce(s.location, '')::text,
    o.quantity,
    o.unit_price,
    o.total_price,
    o.delivery_fee,
    o.status,
    o.created_by,
    o.created_at,
    o.delivered_by,
    o.delivered_at,
    o.delivery_date,
    o.delivery_time
  from public.orders o
  join public.resources r on r.id=o.resource_id
  left join public.suppliers s on s.id=o.supplier_id
  order by
    case o.status when 'a_commander' then 0 when 'en_cours' then 1 else 2 end,
    o.delivery_date asc nulls last,
    o.delivery_time asc nulls last,
    o.created_at desc;
end;
$function$
;
revoke all on function "public"."get_orders_v2"() from public,anon,authenticated;
grant execute on function "public"."get_orders_v2"() to authenticated;
grant execute on function "public"."get_orders_v2"() to service_role;
CREATE OR REPLACE FUNCTION public.queue_order_v2(p_resource_id uuid, p_quantity numeric, p_supplier_id uuid)
 RETURNS uuid
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  v_id uuid;
  v_price numeric;
  v_pending_quantity numeric;
begin
  if auth.uid() is null or not private.is_approved() then
    raise exception 'Accès non autorisé';
  end if;

  if p_quantity is null or p_quantity <= 0 then
    raise exception 'Quantité invalide';
  end if;

  if p_supplier_id is null then
    raise exception 'Fournisseur requis';
  end if;

  select greatest(coalesce(s.unit_price, r.unit_price, 0), 0)
  into v_price
  from public.suppliers s
  join public.resources r on r.id = s.resource_id
  where s.id = p_supplier_id
    and s.resource_id = p_resource_id
    and s.active = true
    and r.active = true
    and r.category = 'ingredient';

  if not found then
    raise exception 'Fournisseur invalide pour cet ingrédient';
  end if;

  perform pg_catalog.pg_advisory_xact_lock(
    pg_catalog.hashtextextended(p_resource_id::text || ':' || p_supplier_id::text, 0)
  );

  select o.id
  into v_id
  from public.orders o
  where o.resource_id = p_resource_id
    and o.supplier_id = p_supplier_id
    and o.status = 'a_commander'
  order by o.created_at, o.id
  limit 1
  for update;

  if found then
    select coalesce(sum(o.quantity), 0)
    into v_pending_quantity
    from public.orders o
    where o.resource_id = p_resource_id
      and o.supplier_id = p_supplier_id
      and o.status = 'a_commander';

    update public.orders
    set quantity = v_pending_quantity + p_quantity,
        unit_price = v_price
    where id = v_id;

    delete from public.orders
    where resource_id = p_resource_id
      and supplier_id = p_supplier_id
      and status = 'a_commander'
      and id <> v_id;
  else
    insert into public.orders(
      resource_id, supplier_id, quantity, unit_price, delivery_fee, status,
      created_by, delivery_date, delivery_time
    )
    values(
      p_resource_id, p_supplier_id, p_quantity, v_price, 0, 'a_commander',
      auth.uid(), null, null
    )
    returning id into v_id;
  end if;

  return v_id;
end;
$function$
;
revoke all on function "public"."queue_order_v2"(p_resource_id uuid, p_quantity numeric, p_supplier_id uuid) from public,anon,authenticated;
grant execute on function "public"."queue_order_v2"(p_resource_id uuid, p_quantity numeric, p_supplier_id uuid) to authenticated;
grant execute on function "public"."queue_order_v2"(p_resource_id uuid, p_quantity numeric, p_supplier_id uuid) to service_role;
CREATE OR REPLACE FUNCTION public.get_fabrication_plans()
 RETURNS TABLE(recipe_id uuid, quantity numeric)
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
begin
  if auth.uid() is null or not private.is_approved() then
    raise exception 'Accès non autorisé';
  end if;

  return query
  select fp.recipe_id, fp.quantity
  from public.fabrication_plans fp
  where fp.quantity > 0
  order by fp.updated_at, fp.recipe_id;
end;
$function$
;
revoke all on function "public"."get_fabrication_plans"() from public,anon,authenticated;
grant execute on function "public"."get_fabrication_plans"() to authenticated;
grant execute on function "public"."get_fabrication_plans"() to service_role;
CREATE OR REPLACE FUNCTION public.admin_get_consultation_notebook_users()
 RETURNS TABLE(id uuid, display_name text, medical_grade text, role text, initialized boolean)
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
begin
  if auth.uid() is null
     or not private.is_admin() then
    raise exception 'Action réservée au Chef de cabinet';
  end if;

  return query
  select
    p.id,
    p.display_name,
    p.medical_grade,
    p.role,
    (n.owner_id is not null) as initialized
  from public.profiles p
  left join public.consultation_notebooks n on n.owner_id=p.id
  where p.access_status='approved'
  order by lower(coalesce(p.display_name,'')),p.id;
end;
$function$
;
revoke all on function "public"."admin_get_consultation_notebook_users"() from public,anon,authenticated;
grant execute on function "public"."admin_get_consultation_notebook_users"() to authenticated;
grant execute on function "public"."admin_get_consultation_notebook_users"() to service_role;
CREATE OR REPLACE FUNCTION public.craft_recipe(p_recipe_id uuid, p_quantity numeric)
 RETURNS uuid
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  v_product_id uuid;
  v_output_qty numeric;
  v_recipe_name text;
  v_batch_id uuid := gen_random_uuid();
  ing record;
  v_needed numeric;
  v_current numeric;
  v_after numeric;
begin
  if auth.uid() is null or not private.is_approved() then
    raise exception 'Accès non autorisé';
  end if;

  if p_quantity is null or p_quantity <= 0 or p_quantity <> trunc(p_quantity) then
    raise exception 'Quantité invalide';
  end if;

  perform pg_catalog.pg_advisory_xact_lock(pg_catalog.hashtextextended('fabrication-plans', 0));

  select product_resource_id, output_quantity, name
  into v_product_id, v_output_qty, v_recipe_name
  from public.recipes
  where id = p_recipe_id and active = true;

  if not found then
    raise exception 'Recette introuvable';
  end if;

  if coalesce(v_output_qty,0) <= 0 then
    raise exception 'Quantité produite invalide pour cette recette';
  end if;

  if exists (
    select 1
    from public.recipe_ingredients ri
    where ri.recipe_id = p_recipe_id
      and ri.ingredient_resource_id = v_product_id
  ) then
    raise exception 'Recette invalide : le produit fabriqué ne peut pas être utilisé comme ingrédient';
  end if;

  for ing in
    select ri.ingredient_resource_id, ri.quantity, r.name
    from public.recipe_ingredients ri
    join public.resources r
      on r.id = ri.ingredient_resource_id
     and r.active = true
     and r.category = 'ingredient'
    where ri.recipe_id = p_recipe_id
      and ri.quantity > 0
    order by r.name
  loop
    v_needed := ing.quantity * p_quantity;

    select coalesce(stock,0)
    into v_current
    from public.resources
    where id = ing.ingredient_resource_id
    for update;

    if v_current < v_needed then
      raise exception 'Stock insuffisant pour % : besoin %, stock %', ing.name, v_needed, v_current;
    end if;
  end loop;

  if not exists (
    select 1
    from public.recipe_ingredients ri
    join public.resources r
      on r.id = ri.ingredient_resource_id
     and r.active = true
     and r.category = 'ingredient'
    where ri.recipe_id = p_recipe_id
      and ri.quantity > 0
  ) then
    raise exception 'Cette recette ne contient aucun ingrédient valide';
  end if;

  for ing in
    select ri.ingredient_resource_id, ri.quantity, r.name
    from public.recipe_ingredients ri
    join public.resources r
      on r.id = ri.ingredient_resource_id
     and r.active = true
     and r.category = 'ingredient'
    where ri.recipe_id = p_recipe_id
      and ri.quantity > 0
    order by r.name
  loop
    v_needed := ing.quantity * p_quantity;

    select coalesce(stock,0)
    into v_current
    from public.resources
    where id = ing.ingredient_resource_id
    for update;

    update public.resources
    set stock = stock - v_needed
    where id = ing.ingredient_resource_id
      and stock >= v_needed
    returning stock into v_after;

    if not found or v_after <> v_current - v_needed then
      raise exception 'Erreur de déduction du stock pour %', ing.name;
    end if;

    insert into public.movements(
      movement_type, resource_id, quantity_delta, cash_delta, note, details,
      created_by, effective_date
    )
    values (
      'CONSOMMATION_FAB',
      ing.ingredient_resource_id,
      -v_needed,
      0,
      'Pour ' || p_quantity || ' × ' || v_recipe_name,
      jsonb_build_object('batch_id', v_batch_id, 'recipe_id', p_recipe_id, 'craft_quantity', p_quantity),
      auth.uid(),
      current_date
    );
  end loop;

  update public.resources
  set stock = stock + (v_output_qty * p_quantity)
  where id = v_product_id;

  insert into public.movements(
    id, movement_type, resource_id, quantity_delta, cash_delta, note, details,
    created_by, effective_date
  )
  values (
    v_batch_id,
    'FABRICATION',
    v_product_id,
    v_output_qty * p_quantity,
    0,
    'Fabrication terminée',
    jsonb_build_object('recipe_id', p_recipe_id, 'craft_quantity', p_quantity),
    auth.uid(),
    current_date
  );

  update public.fabrication_plans
  set quantity = greatest(quantity - p_quantity, 0),
      updated_by = auth.uid(),
      updated_at = now()
  where recipe_id = p_recipe_id;

  delete from public.fabrication_plans
  where recipe_id = p_recipe_id and quantity <= 0;

  return v_batch_id;
end;
$function$
;
revoke all on function "public"."craft_recipe"(p_recipe_id uuid, p_quantity numeric) from public,anon,authenticated;
grant execute on function "public"."craft_recipe"(p_recipe_id uuid, p_quantity numeric) to authenticated;
grant execute on function "public"."craft_recipe"(p_recipe_id uuid, p_quantity numeric) to service_role;
CREATE OR REPLACE FUNCTION public.mark_bureau_read()
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  v_uid uuid := auth.uid();
  v_seen timestamptz;
begin
  if v_uid is null or not private.is_approved() then
    raise exception 'Accès non autorisé';
  end if;

  select coalesce(max(m.created_at), now())
  into v_seen
  from public.bureau_messages m;

  insert into private.bureau_read_state(user_id,last_seen_at,updated_at)
  values (v_uid,v_seen,now())
  on conflict (user_id) do update
  set last_seen_at = greatest(private.bureau_read_state.last_seen_at, excluded.last_seen_at),
      updated_at = now();

  return true;
end;
$function$
;
revoke all on function "public"."mark_bureau_read"() from public,anon,authenticated;
grant execute on function "public"."mark_bureau_read"() to authenticated;
grant execute on function "public"."mark_bureau_read"() to service_role;
CREATE OR REPLACE FUNCTION public.get_bureau_unread_count()
 RETURNS integer
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  v_uid uuid := auth.uid();
  v_last_seen timestamptz;
  v_count integer := 0;
begin
  if v_uid is null or not private.is_approved() then
    raise exception 'Accès non autorisé';
  end if;

  select brs.last_seen_at
  into v_last_seen
  from private.bureau_read_state brs
  where brs.user_id = v_uid;

  if not found then
    select coalesce(max(m.created_at), now())
    into v_last_seen
    from public.bureau_messages m;

    insert into private.bureau_read_state(user_id,last_seen_at,updated_at)
    values (v_uid,v_last_seen,now())
    on conflict (user_id) do nothing;
  end if;

  select count(*)::integer
  into v_count
  from public.bureau_messages m
  where m.created_at > v_last_seen
    and m.author_id <> v_uid;

  return coalesce(v_count,0);
end;
$function$
;
revoke all on function "public"."get_bureau_unread_count"() from public,anon,authenticated;
grant execute on function "public"."get_bureau_unread_count"() to authenticated;
grant execute on function "public"."get_bureau_unread_count"() to service_role;
CREATE OR REPLACE FUNCTION public.start_order(p_order_id uuid, p_delivery_date date DEFAULT NULL::date, p_delivery_time time without time zone DEFAULT NULL::time without time zone)
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
begin
  if auth.uid() is null or not private.is_approved() then
    raise exception 'Accès non autorisé';
  end if;

  update public.orders
  set status = 'en_cours',
      delivery_date = p_delivery_date,
      delivery_time = p_delivery_time
  where id = p_order_id
    and status = 'a_commander';

  if not found then
    raise exception 'Cette commande ne peut pas passer en cours';
  end if;

  return true;
end;
$function$
;
revoke all on function "public"."start_order"(p_order_id uuid, p_delivery_date date, p_delivery_time time without time zone) from public,anon,authenticated;
grant execute on function "public"."start_order"(p_order_id uuid, p_delivery_date date, p_delivery_time time without time zone) to authenticated;
grant execute on function "public"."start_order"(p_order_id uuid, p_delivery_date date, p_delivery_time time without time zone) to service_role;
CREATE OR REPLACE FUNCTION public.reset_fabrication_plan(p_recipe_id uuid)
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
begin
  if auth.uid() is null or not private.is_admin() then
    raise exception 'Action réservée à l’administrateur';
  end if;

  delete from public.fabrication_plans
  where recipe_id = p_recipe_id;

  return true;
end;
$function$
;
revoke all on function "public"."reset_fabrication_plan"(p_recipe_id uuid) from public,anon,authenticated;
grant execute on function "public"."reset_fabrication_plan"(p_recipe_id uuid) to authenticated;
grant execute on function "public"."reset_fabrication_plan"(p_recipe_id uuid) to service_role;
CREATE OR REPLACE FUNCTION public.update_order_schedule(p_order_id uuid, p_delivery_date date DEFAULT NULL::date, p_delivery_time time without time zone DEFAULT NULL::time without time zone)
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
begin
  if auth.uid() is null or not private.is_approved() then
    raise exception 'Accès non autorisé';
  end if;

  update public.orders
  set delivery_date = p_delivery_date,
      delivery_time = p_delivery_time
  where id = p_order_id
    and status in ('a_commander','en_cours');

  return found;
end;
$function$
;
revoke all on function "public"."update_order_schedule"(p_order_id uuid, p_delivery_date date, p_delivery_time time without time zone) from public,anon,authenticated;
grant execute on function "public"."update_order_schedule"(p_order_id uuid, p_delivery_date date, p_delivery_time time without time zone) to authenticated;
grant execute on function "public"."update_order_schedule"(p_order_id uuid, p_delivery_date date, p_delivery_time time without time zone) to service_role;
CREATE OR REPLACE FUNCTION public.ensure_personal_consultation_notebook(p_owner_id uuid DEFAULT NULL::uuid)
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  v_uid uuid := auth.uid();
  v_owner uuid := coalesce(p_owner_id,auth.uid());
  v_created boolean := false;
  v_supervisor boolean := false;
begin
  if v_uid is null or not private.is_approved() then
    raise exception 'Accès non autorisé';
  end if;

  v_supervisor := private.is_admin();

  if v_owner is null then
    raise exception 'Utilisateur invalide';
  end if;

  if v_owner <> v_uid and not v_supervisor then
    raise exception 'Accès non autorisé à ce carnet';
  end if;

  if not exists (
    select 1
    from public.profiles p
    where p.id=v_owner and p.access_status='approved'
  ) then
    raise exception 'Utilisateur non autorisé';
  end if;

  insert into public.consultation_notebooks(owner_id,initialized_at,updated_at)
  values(v_owner,now(),now())
  on conflict(owner_id) do nothing;

  if found then
    v_created := true;

    insert into public.consultation_user_categories(
      owner_id,source_category_id,name,sort_order,color,created_at,updated_at
    )
    select
      v_owner,c.id,c.name,c.sort_order,c.color,now(),now()
    from public.consultation_categories c
    where c.active=true
    order by c.sort_order,c.name;

    insert into public.consultation_user_templates(
      owner_id,source_template_id,category_id,title,subcategory,body,sort_order,active,created_at,updated_at
    )
    select
      v_owner,t.id,uc.id,t.title,t.subcategory,t.body,t.sort_order,true,now(),now()
    from public.consultation_templates t
    join public.consultation_user_categories uc
      on uc.owner_id=v_owner
     and uc.source_category_id=t.category_id
    where t.active=true
    order by t.sort_order,t.title;
  end if;

  return v_created;
end;
$function$
;
revoke all on function "public"."ensure_personal_consultation_notebook"(p_owner_id uuid) from public,anon,authenticated;
grant execute on function "public"."ensure_personal_consultation_notebook"(p_owner_id uuid) to authenticated;
grant execute on function "public"."ensure_personal_consultation_notebook"(p_owner_id uuid) to service_role;
CREATE OR REPLACE FUNCTION public.deliver_order(p_order_id uuid, p_delivery_fee numeric DEFAULT NULL::numeric)
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  v_order public.orders%rowtype;
  v_name text;
  v_fee numeric;
begin
  if auth.uid() is null or not private.is_approved() then
    raise exception 'Accès non autorisé';
  end if;

  select *
  into v_order
  from public.orders
  where id = p_order_id
  for update;

  if not found then
    raise exception 'Commande introuvable';
  end if;

  if v_order.status = 'livre' then
    return true;
  end if;

  if v_order.status <> 'en_cours' then
    raise exception 'La commande doit d''abord passer en cours';
  end if;

  v_fee := coalesce(p_delivery_fee, v_order.delivery_fee, 0);
  if v_fee < 0 then
    raise exception 'Frais de livraison invalides';
  end if;

  select name into v_name
  from public.resources
  where id = v_order.resource_id
  for update;

  if not found then
    raise exception 'Ingrédient introuvable';
  end if;

  update public.resources
  set stock = stock + v_order.quantity,
      unit_price = v_order.unit_price,
      updated_at = now()
  where id = v_order.resource_id;

  update public.cabinet_state
  set cash_balance = cash_balance - v_order.total_price - v_fee,
      updated_at = now()
  where id = 1;

  insert into public.movements(
    movement_type, resource_id, quantity_delta, unit_price, cash_delta,
    note, details, created_by, effective_date
  )
  values (
    'ACHAT', v_order.resource_id, v_order.quantity, v_order.unit_price,
    -v_order.total_price, 'Commande livrée : ' || v_name,
    jsonb_build_object('order_id',v_order.id,'source','orders'),
    auth.uid(), current_date
  );

  if v_fee > 0 then
    insert into public.movements(
      movement_type, resource_id, quantity_delta, unit_price, cash_delta,
      note, details, created_by, effective_date
    )
    values (
      'FRAIS_LIVRAISON', v_order.resource_id, 0, null, -v_fee,
      'Frais de livraison pour ' || v_name,
      jsonb_build_object('order_id',v_order.id,'source','orders'),
      auth.uid(), current_date
    );
  end if;

  update public.orders
  set status = 'livre',
      delivery_fee = v_fee,
      delivered_by = auth.uid(),
      delivered_at = now()
  where id = v_order.id;

  return true;
end;
$function$
;
revoke all on function "public"."deliver_order"(p_order_id uuid, p_delivery_fee numeric) from public,anon,authenticated;
grant execute on function "public"."deliver_order"(p_order_id uuid, p_delivery_fee numeric) to authenticated;
grant execute on function "public"."deliver_order"(p_order_id uuid, p_delivery_fee numeric) to service_role;
CREATE OR REPLACE FUNCTION public.create_order_v2(p_resource_id uuid, p_quantity numeric, p_supplier_id uuid, p_delivery_fee numeric DEFAULT 0, p_delivery_date date DEFAULT NULL::date, p_delivery_time time without time zone DEFAULT NULL::time without time zone)
 RETURNS uuid
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  v_id uuid;
  v_price numeric;
begin
  if auth.uid() is null or not private.is_approved() then
    raise exception 'Accès non autorisé';
  end if;

  if p_quantity is null or p_quantity <= 0 then
    raise exception 'Quantité invalide';
  end if;

  if coalesce(p_delivery_fee,0) < 0 then
    raise exception 'Frais de livraison invalides';
  end if;

  select greatest(coalesce(s.unit_price, r.unit_price, 0),0)
  into v_price
  from public.suppliers s
  join public.resources r on r.id=s.resource_id
  where s.id=p_supplier_id
    and s.resource_id=p_resource_id
    and s.active=true
    and r.active=true
    and r.category='ingredient';

  if not found then
    raise exception 'Fournisseur invalide pour cet ingrédient';
  end if;

  insert into public.orders(
    resource_id, supplier_id, quantity, unit_price, delivery_fee, status, created_by,
    delivery_date, delivery_time
  )
  values(
    p_resource_id, p_supplier_id, p_quantity, v_price, coalesce(p_delivery_fee,0),
    'en_cours', auth.uid(), p_delivery_date, p_delivery_time
  )
  returning id into v_id;

  return v_id;
end;
$function$
;
revoke all on function "public"."create_order_v2"(p_resource_id uuid, p_quantity numeric, p_supplier_id uuid, p_delivery_fee numeric, p_delivery_date date, p_delivery_time time without time zone) from public,anon,authenticated;
grant execute on function "public"."create_order_v2"(p_resource_id uuid, p_quantity numeric, p_supplier_id uuid, p_delivery_fee numeric, p_delivery_date date, p_delivery_time time without time zone) to authenticated;
grant execute on function "public"."create_order_v2"(p_resource_id uuid, p_quantity numeric, p_supplier_id uuid, p_delivery_fee numeric, p_delivery_date date, p_delivery_time time without time zone) to service_role;
CREATE OR REPLACE FUNCTION public.get_bureau_read_snapshot()
 RETURNS TABLE(last_seen_at timestamp with time zone, unread_count integer)
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  v_uid uuid := auth.uid();
  v_last_seen timestamptz;
  v_count integer := 0;
begin
  if v_uid is null or not private.is_approved() then
    raise exception 'Accès non autorisé';
  end if;

  select brs.last_seen_at
  into v_last_seen
  from private.bureau_read_state brs
  where brs.user_id = v_uid;

  if not found then
    select coalesce(max(m.created_at), now())
    into v_last_seen
    from public.bureau_messages m;

    insert into private.bureau_read_state(user_id,last_seen_at,updated_at)
    values (v_uid,v_last_seen,now())
    on conflict (user_id) do nothing;
  end if;

  select count(*)::integer
  into v_count
  from public.bureau_messages m
  where m.created_at > v_last_seen
    and m.author_id <> v_uid;

  return query
  select v_last_seen, coalesce(v_count,0);
end;
$function$
;
revoke all on function "public"."get_bureau_read_snapshot"() from public,anon,authenticated;
grant execute on function "public"."get_bureau_read_snapshot"() to authenticated;
grant execute on function "public"."get_bureau_read_snapshot"() to service_role;
CREATE OR REPLACE FUNCTION public.get_pharmacy_inventory()
 RETURNS TABLE(product_resource_id uuid, product_name text, pharmacy_price numeric, pharmacy_sellable boolean, pharmacy_quantity numeric)
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
begin
  if auth.uid() is null or not private.is_approved() then
    raise exception 'Accès non autorisé';
  end if;

  return query
  select
    r.id,
    r.name::text,
    coalesce(p.pharmacy_price,r.unit_price,0),
    true,
    coalesce(s.quantity,0)
  from public.recipes rc
  join public.resources r on r.id=rc.product_resource_id
  left join public.recipe_pricing p on p.product_resource_id=r.id
  left join public.pharmacy_stock s on s.product_resource_id=r.id
  where rc.active=true
    and coalesce(
      p.pharmacy_sellable,
      case when upper(r.name) in ('KIT DE SOIN','SERINGUE VIVIFIANTE') then false else true end
    ) = true
  order by r.name;
end;
$function$
;
revoke all on function "public"."get_pharmacy_inventory"() from public,anon,authenticated;
grant execute on function "public"."get_pharmacy_inventory"() to authenticated;
grant execute on function "public"."get_pharmacy_inventory"() to service_role;
CREATE OR REPLACE FUNCTION public.set_pharmacy_quantity(p_product_resource_id uuid, p_quantity numeric)
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
begin
  if auth.uid() is null or not private.is_approved() then
    raise exception 'Accès non autorisé';
  end if;

  if p_quantity is null or p_quantity < 0 then
    raise exception 'Quantité invalide';
  end if;

  if not exists (
    select 1
    from public.recipes rc
    where rc.product_resource_id=p_product_resource_id
      and rc.active=true
  ) then
    raise exception 'Recette introuvable';
  end if;

  insert into public.pharmacy_stock(product_resource_id,quantity,updated_at,updated_by)
  values(p_product_resource_id,p_quantity,now(),auth.uid())
  on conflict(product_resource_id) do update
  set quantity=excluded.quantity,
      updated_at=now(),
      updated_by=auth.uid();

  return true;
end;
$function$
;
revoke all on function "public"."set_pharmacy_quantity"(p_product_resource_id uuid, p_quantity numeric) from public,anon,authenticated;
grant execute on function "public"."set_pharmacy_quantity"(p_product_resource_id uuid, p_quantity numeric) to authenticated;
grant execute on function "public"."set_pharmacy_quantity"(p_product_resource_id uuid, p_quantity numeric) to service_role;
CREATE OR REPLACE FUNCTION public.record_pharmacy_count(p_product_resource_id uuid, p_current_quantity numeric)
 RETURNS TABLE(sold_quantity numeric, revenue numeric, new_quantity numeric)
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  v_stored numeric;
  v_price numeric;
  v_sellable boolean;
  v_name text;
  v_sold numeric;
  v_revenue numeric;
begin
  if auth.uid() is null or not private.is_approved() then
    raise exception 'Accès non autorisé';
  end if;

  if p_current_quantity is null or p_current_quantity < 0 then
    raise exception 'Quantité actuelle invalide';
  end if;

  select
    r.name,
    case
      when coalesce(
        p.pharmacy_sellable,
        case when upper(r.name) in ('KIT DE SOIN','SERINGUE VIVIFIANTE') then false else true end
      )
      then coalesce(p.pharmacy_price,r.unit_price,0)
      else null
    end,
    coalesce(
      p.pharmacy_sellable,
      case when upper(r.name) in ('KIT DE SOIN','SERINGUE VIVIFIANTE') then false else true end
    )
  into v_name,v_price,v_sellable
  from public.recipes rc
  join public.resources r on r.id=rc.product_resource_id
  left join public.recipe_pricing p on p.product_resource_id=r.id
  where rc.product_resource_id=p_product_resource_id
    and rc.active=true;

  if not found then
    raise exception 'Recette introuvable';
  end if;

  if not v_sellable then
    raise exception 'Cette recette n’est pas vendue à la pharmacie';
  end if;

  insert into public.pharmacy_stock(product_resource_id,quantity,updated_at,updated_by)
  values(p_product_resource_id,0,now(),auth.uid())
  on conflict(product_resource_id) do nothing;

  select s.quantity
  into v_stored
  from public.pharmacy_stock s
  where s.product_resource_id=p_product_resource_id
  for update;

  if p_current_quantity > v_stored then
    raise exception 'La quantité actuelle dépasse la quantité enregistrée. Utilisez la case Quantité en pharmacie pour le réapprovisionnement.';
  end if;

  v_sold := v_stored - p_current_quantity;
  v_revenue := v_sold * coalesce(v_price,0);

  update public.pharmacy_stock
  set quantity=p_current_quantity,
      updated_at=now(),
      updated_by=auth.uid()
  where product_resource_id=p_product_resource_id;

  if v_sold > 0 then
    update public.resources
    set stock = greatest(0, coalesce(stock,0) - v_sold)
    where id=p_product_resource_id;

    update public.cabinet_state
    set cash_balance=cash_balance+v_revenue
    where id=1;

    insert into public.movements(
      movement_type,
      resource_id,
      quantity_delta,
      unit_price,
      cash_delta,
      note,
      created_by,
      effective_date
    )
    values(
      'PHARMACIE_VENTE',
      p_product_resource_id,
      -v_sold,
      v_price,
      v_revenue,
      'Vente enregistrée depuis la pharmacie',
      auth.uid(),
      current_date
    );
  end if;

  return query select v_sold,v_revenue,p_current_quantity;
end;
$function$
;
revoke all on function "public"."record_pharmacy_count"(p_product_resource_id uuid, p_current_quantity numeric) from public,anon,authenticated;
grant execute on function "public"."record_pharmacy_count"(p_product_resource_id uuid, p_current_quantity numeric) to authenticated;
grant execute on function "public"."record_pharmacy_count"(p_product_resource_id uuid, p_current_quantity numeric) to service_role;
CREATE OR REPLACE FUNCTION public.get_movement_history_with_balance()
 RETURNS jsonb
 LANGUAGE sql
 STABLE
 SET search_path TO ''
AS $function$
  with history as materialized (
    select * from public.get_movement_history()
  ), balances as (
    select h.*,
      (select c.cash_balance from public.cabinet_state c where c.id=1)
      - coalesce(sum(h.cash_delta) over (
        order by h.created_at desc, h.id desc
        rows between unbounded preceding and 1 preceding
      ),0) as cash_balance_after
    from history h
  )
  select coalesce(jsonb_agg(to_jsonb(b) order by b.created_at, b.id),'[]'::jsonb)
  from balances b;
$function$
;
revoke all on function "public"."get_movement_history_with_balance"() from public,anon,authenticated;
grant execute on function "public"."get_movement_history_with_balance"() to authenticated;
grant execute on function "public"."get_movement_history_with_balance"() to service_role;
CREATE OR REPLACE FUNCTION public.queue_recipe_missing_with_suppliers(p_recipe_id uuid, p_quantity numeric, p_supplier_choices jsonb DEFAULT '{}'::jsonb)
 RETURNS numeric
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  v_item record;
  v_stock numeric;
  v_outstanding numeric;
  v_total_required numeric;
  v_missing numeric;
  v_total_added numeric := 0;
  v_found boolean := false;
  v_supplier_count integer;
  v_supplier_id uuid;
  v_choice text;
begin
  if auth.uid() is null or not private.is_approved() then
    raise exception 'Accès non autorisé';
  end if;

  if p_quantity is null or p_quantity <= 0 or p_quantity <> trunc(p_quantity) then
    raise exception 'Quantité de fabrication invalide';
  end if;

  if not exists (
    select 1
    from public.recipes r
    where r.id = p_recipe_id and r.active = true
  ) then
    raise exception 'Recette introuvable';
  end if;

  perform pg_catalog.pg_advisory_xact_lock(
    pg_catalog.hashtextextended('fabrication-plans', 0)
  );

  insert into public.fabrication_plans(recipe_id, quantity, updated_by, updated_at)
  values (p_recipe_id, p_quantity, auth.uid(), now())
  on conflict (recipe_id) do update
  set quantity = excluded.quantity,
      updated_by = excluded.updated_by,
      updated_at = excluded.updated_at;

  for v_item in
    select ri.ingredient_resource_id as resource_id
    from public.recipe_ingredients ri
    join public.resources res
      on res.id = ri.ingredient_resource_id
     and res.active = true
     and res.category = 'ingredient'
    where ri.recipe_id = p_recipe_id
      and ri.quantity > 0
    order by ri.ingredient_resource_id
  loop
    v_found := true;

    perform pg_catalog.pg_advisory_xact_lock(
      pg_catalog.hashtextextended(v_item.resource_id::text, 0)
    );

    select coalesce(r.stock,0)
    into v_stock
    from public.resources r
    where r.id = v_item.resource_id
    for update;

    select coalesce(sum(ri.quantity * p_quantity),0)
    into v_total_required
    from public.recipe_ingredients ri
    where ri.recipe_id = p_recipe_id
      and ri.ingredient_resource_id = v_item.resource_id;

    select coalesce(sum(o.quantity),0)
    into v_outstanding
    from public.orders o
    where o.resource_id = v_item.resource_id
      and o.status in ('a_commander','en_cours');

    v_missing := greatest(v_total_required - v_stock - v_outstanding, 0);

    if v_missing > 0 then
      v_supplier_id := null;

      select count(*)
      into v_supplier_count
      from public.suppliers s
      where s.resource_id = v_item.resource_id
        and s.active = true;

      if v_supplier_count = 0 then
        raise exception 'Aucun fournisseur actif pour un ingrédient requis';
      end if;

      v_choice := p_supplier_choices ->> v_item.resource_id::text;

      if nullif(v_choice,'') is not null then
        begin
          v_supplier_id := v_choice::uuid;
        exception when invalid_text_representation then
          raise exception 'Choix de fournisseur invalide';
        end;

        if not exists (
          select 1
          from public.suppliers s
          where s.id = v_supplier_id
            and s.resource_id = v_item.resource_id
            and s.active = true
        ) then
          raise exception 'Fournisseur invalide pour un ingrédient requis';
        end if;
      elsif v_supplier_count > 1 then
        raise exception 'Choisissez un fournisseur pour chaque ingrédient proposé par plusieurs fournisseurs';
      else
        select s.id
        into v_supplier_id
        from public.suppliers s
        where s.resource_id = v_item.resource_id
          and s.active = true
        order by s.created_at nulls last, s.id
        limit 1;
      end if;

      perform public.queue_order_with_supplier(
        v_item.resource_id,
        v_supplier_id,
        v_missing
      );

      v_total_added := v_total_added + v_missing;
    end if;
  end loop;

  if not v_found then
    raise exception 'Cette recette ne contient aucun ingrédient';
  end if;

  return v_total_added;
end;
$function$
;
revoke all on function "public"."queue_recipe_missing_with_suppliers"(p_recipe_id uuid, p_quantity numeric, p_supplier_choices jsonb) from public,anon,authenticated;
grant execute on function "public"."queue_recipe_missing_with_suppliers"(p_recipe_id uuid, p_quantity numeric, p_supplier_choices jsonb) to authenticated;
grant execute on function "public"."queue_recipe_missing_with_suppliers"(p_recipe_id uuid, p_quantity numeric, p_supplier_choices jsonb) to service_role;
CREATE TRIGGER trg_profiles_updated_at BEFORE UPDATE ON public.profiles FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
CREATE TRIGGER trg_resources_updated_at BEFORE UPDATE ON public.resources FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
CREATE TRIGGER trg_recipes_updated_at BEFORE UPDATE ON public.recipes FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
CREATE TRIGGER trg_suppliers_updated_at BEFORE UPDATE ON public.suppliers FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
CREATE TRIGGER trg_cabinet_state_updated_at BEFORE UPDATE ON public.cabinet_state FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
CREATE TRIGGER on_auth_user_created AFTER INSERT ON auth.users FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();
create policy "profiles_select_self_or_admin" on "public"."profiles" as PERMISSIVE for SELECT to "authenticated" using (((id = ( SELECT auth.uid() AS uid)) OR ( SELECT private.is_admin() AS is_admin)));
create policy "profiles_admin_update" on "public"."profiles" as PERMISSIVE for UPDATE to "authenticated" using (( SELECT private.is_admin() AS is_admin)) with check (( SELECT private.is_admin() AS is_admin));
create policy "resources_approved_all" on "public"."resources" as PERMISSIVE for ALL to "authenticated" using (( SELECT private.is_approved() AS is_approved)) with check (( SELECT private.is_approved() AS is_approved));
create policy "suppliers_approved_all" on "public"."suppliers" as PERMISSIVE for ALL to "authenticated" using (( SELECT private.is_approved() AS is_approved)) with check (( SELECT private.is_approved() AS is_approved));
create policy "cabinet_state_approved_select" on "public"."cabinet_state" as PERMISSIVE for SELECT to "authenticated" using (( SELECT private.is_approved() AS is_approved));
create policy "movements_approved_select" on "public"."movements" as PERMISSIVE for SELECT to "authenticated" using (( SELECT private.is_approved() AS is_approved));
create policy "approved_users_can_view_edit_locks" on "public"."edit_locks" as PERMISSIVE for SELECT to "authenticated" using (private.is_approved());
create policy "approved_users_can_view_orders" on "public"."orders" as PERMISSIVE for SELECT to "authenticated" using (private.is_approved());
create policy "approved_users_can_view_recipe_pricing" on "public"."recipe_pricing" as PERMISSIVE for SELECT to "authenticated" using (private.is_approved());
create policy "bureau_messages_read_approved" on "public"."bureau_messages" as PERMISSIVE for SELECT to "authenticated" using (( SELECT private.is_approved() AS is_approved));
create policy "bureau_chat_read_approved" on "storage"."objects" as PERMISSIVE for SELECT to "authenticated" using (((bucket_id = 'bureau-chat'::text) AND ( SELECT private.is_approved() AS is_approved)));
create policy "bureau_chat_upload_approved" on "storage"."objects" as PERMISSIVE for INSERT to "authenticated" with check (((bucket_id = 'bureau-chat'::text) AND ( SELECT private.is_approved() AS is_approved) AND ((storage.foldername(name))[1] = (( SELECT auth.uid() AS uid))::text)));
create policy "bureau_chat_delete_own_or_admin" on "storage"."objects" as PERMISSIVE for DELETE to "authenticated" using (((bucket_id = 'bureau-chat'::text) AND ( SELECT private.is_approved() AS is_approved) AND (((storage.foldername(name))[1] = (( SELECT auth.uid() AS uid))::text) OR ( SELECT private.is_admin() AS is_admin))));
create policy "cabinet_state_admin_update" on "public"."cabinet_state" as PERMISSIVE for UPDATE to "authenticated" using (( SELECT private.is_admin() AS is_admin)) with check (( SELECT private.is_admin() AS is_admin));
create policy "bureau_typing_read_approved" on "public"."bureau_typing" as PERMISSIVE for SELECT to "authenticated" using (( SELECT private.is_approved() AS is_approved));
create policy "recipes_approved_select" on "public"."recipes" as PERMISSIVE for SELECT to "authenticated" using (( SELECT private.is_approved() AS is_approved));
create policy "recipes_admin_insert" on "public"."recipes" as PERMISSIVE for INSERT to "authenticated" with check (( SELECT private.is_admin() AS is_admin));
create policy "recipes_admin_update" on "public"."recipes" as PERMISSIVE for UPDATE to "authenticated" using (( SELECT private.is_admin() AS is_admin)) with check (( SELECT private.is_admin() AS is_admin));
create policy "recipes_admin_delete" on "public"."recipes" as PERMISSIVE for DELETE to "authenticated" using (( SELECT private.is_admin() AS is_admin));
create policy "consultation_templates_admin_delete" on "public"."consultation_templates" as PERMISSIVE for DELETE to "authenticated" using ((( SELECT private.is_admin() AS is_admin) AND true));
create policy "recipe_ingredients_approved_select" on "public"."recipe_ingredients" as PERMISSIVE for SELECT to "authenticated" using (( SELECT private.is_approved() AS is_approved));
create policy "recipe_ingredients_admin_insert" on "public"."recipe_ingredients" as PERMISSIVE for INSERT to "authenticated" with check (( SELECT private.is_admin() AS is_admin));
create policy "recipe_ingredients_admin_update" on "public"."recipe_ingredients" as PERMISSIVE for UPDATE to "authenticated" using (( SELECT private.is_admin() AS is_admin)) with check (( SELECT private.is_admin() AS is_admin));
create policy "recipe_ingredients_admin_delete" on "public"."recipe_ingredients" as PERMISSIVE for DELETE to "authenticated" using (( SELECT private.is_admin() AS is_admin));
create policy "consultation_categories_approved_select" on "public"."consultation_categories" as PERMISSIVE for SELECT to "authenticated" using (( SELECT private.is_approved() AS is_approved));
create policy "consultation_user_templates_delete" on "public"."consultation_user_templates" as PERMISSIVE for DELETE to "authenticated" using (((( SELECT auth.uid() AS uid) = owner_id) AND ( SELECT private.is_approved() AS is_approved)));
create policy "consultation_templates_approved_select" on "public"."consultation_templates" as PERMISSIVE for SELECT to "authenticated" using (( SELECT private.is_approved() AS is_approved));
create policy "consultation_categories_admin_insert" on "public"."consultation_categories" as PERMISSIVE for INSERT to "authenticated" with check ((( SELECT private.is_admin() AS is_admin) AND true));
create policy "consultation_categories_admin_update" on "public"."consultation_categories" as PERMISSIVE for UPDATE to "authenticated" using ((( SELECT private.is_admin() AS is_admin) AND true)) with check ((( SELECT private.is_admin() AS is_admin) AND true));
create policy "consultation_categories_admin_delete" on "public"."consultation_categories" as PERMISSIVE for DELETE to "authenticated" using ((( SELECT private.is_admin() AS is_admin) AND true));
create policy "consultation_templates_admin_insert" on "public"."consultation_templates" as PERMISSIVE for INSERT to "authenticated" with check ((( SELECT private.is_admin() AS is_admin) AND true));
create policy "consultation_templates_admin_update" on "public"."consultation_templates" as PERMISSIVE for UPDATE to "authenticated" using ((( SELECT private.is_admin() AS is_admin) AND true)) with check ((( SELECT private.is_admin() AS is_admin) AND true));
create policy "consultation_user_categories_insert" on "public"."consultation_user_categories" as PERMISSIVE for INSERT to "authenticated" with check (((( SELECT auth.uid() AS uid) = owner_id) AND ( SELECT private.is_approved() AS is_approved)));
create policy "consultation_user_categories_update" on "public"."consultation_user_categories" as PERMISSIVE for UPDATE to "authenticated" using (((( SELECT auth.uid() AS uid) = owner_id) AND ( SELECT private.is_approved() AS is_approved))) with check (((( SELECT auth.uid() AS uid) = owner_id) AND ( SELECT private.is_approved() AS is_approved)));
create policy "consultation_user_categories_delete" on "public"."consultation_user_categories" as PERMISSIVE for DELETE to "authenticated" using (((( SELECT auth.uid() AS uid) = owner_id) AND ( SELECT private.is_approved() AS is_approved)));
create policy "consultation_user_templates_insert" on "public"."consultation_user_templates" as PERMISSIVE for INSERT to "authenticated" with check (((( SELECT auth.uid() AS uid) = owner_id) AND ( SELECT private.is_approved() AS is_approved)));
create policy "consultation_user_templates_update" on "public"."consultation_user_templates" as PERMISSIVE for UPDATE to "authenticated" using (((( SELECT auth.uid() AS uid) = owner_id) AND ( SELECT private.is_approved() AS is_approved))) with check (((( SELECT auth.uid() AS uid) = owner_id) AND ( SELECT private.is_approved() AS is_approved)));
create policy "consultation_notebooks_select" on "public"."consultation_notebooks" as PERMISSIVE for SELECT to "authenticated" using (((( SELECT auth.uid() AS uid) = owner_id) OR (( SELECT private.is_admin() AS is_admin) AND true)));
create policy "consultation_user_categories_select" on "public"."consultation_user_categories" as PERMISSIVE for SELECT to "authenticated" using ((((( SELECT auth.uid() AS uid) = owner_id) AND ( SELECT private.is_approved() AS is_approved)) OR (( SELECT private.is_admin() AS is_admin) AND true)));
create policy "consultation_user_templates_select" on "public"."consultation_user_templates" as PERMISSIVE for SELECT to "authenticated" using ((((( SELECT auth.uid() AS uid) = owner_id) AND ( SELECT private.is_approved() AS is_approved)) OR (( SELECT private.is_admin() AS is_admin) AND true)));
create policy "unpaid_debts_select_approved" on "public"."unpaid_debts" as PERMISSIVE for SELECT to "authenticated" using (( SELECT private.is_approved() AS is_approved));
create policy "unpaid_debts_insert_approved" on "public"."unpaid_debts" as PERMISSIVE for INSERT to "authenticated" with check ((( SELECT private.is_approved() AS is_approved) AND (created_by = ( SELECT auth.uid() AS uid))));
create policy "unpaid_debts_delete_approved" on "public"."unpaid_debts" as PERMISSIVE for DELETE to "authenticated" using (( SELECT private.is_approved() AS is_approved));
create policy "navigation_read" on "public"."navigation_preferences" as PERMISSIVE for SELECT to "authenticated" using (( SELECT private.is_approved() AS is_approved));
create policy "navigation_admin_update" on "public"."navigation_preferences" as PERMISSIVE for UPDATE to "authenticated" using (( SELECT private.is_admin() AS is_admin)) with check (( SELECT private.is_admin() AS is_admin));
revoke all on table "public"."movements" from anon,authenticated;
grant all on table "public"."movements" to service_role;
grant select on table "public"."movements" to authenticated;
revoke all on table "public"."resources" from anon,authenticated;
grant all on table "public"."resources" to service_role;
grant select,insert,update,delete on table "public"."resources" to authenticated;
revoke all on table "public"."recipes" from anon,authenticated;
grant all on table "public"."recipes" to service_role;
grant select,insert,update,delete on table "public"."recipes" to authenticated;
revoke all on table "public"."recipe_ingredients" from anon,authenticated;
grant all on table "public"."recipe_ingredients" to service_role;
grant select,insert,update,delete on table "public"."recipe_ingredients" to authenticated;
revoke all on table "public"."suppliers" from anon,authenticated;
grant all on table "public"."suppliers" to service_role;
grant select,insert,update,delete on table "public"."suppliers" to authenticated;
revoke all on table "public"."orders" from anon,authenticated;
grant all on table "public"."orders" to service_role;
revoke all on table "public"."profiles" from anon,authenticated;
grant all on table "public"."profiles" to service_role;
grant select on table "public"."profiles" to authenticated;
revoke all on table "public"."edit_locks" from anon,authenticated;
grant all on table "public"."edit_locks" to service_role;
revoke all on table "public"."cabinet_state" from anon,authenticated;
grant all on table "public"."cabinet_state" to service_role;
grant select,update on table "public"."cabinet_state" to authenticated;
revoke all on table "public"."recipe_pricing" from anon,authenticated;
grant all on table "public"."recipe_pricing" to service_role;
revoke all on table "public"."bureau_messages" from anon,authenticated;
grant all on table "public"."bureau_messages" to service_role;
grant select on table "public"."bureau_messages" to authenticated;
revoke all on table "public"."bureau_typing" from anon,authenticated;
grant all on table "public"."bureau_typing" to service_role;
grant select on table "public"."bureau_typing" to authenticated;
revoke all on table "public"."fabrication_plans" from anon,authenticated;
grant all on table "public"."fabrication_plans" to service_role;
revoke all on table "private"."bureau_read_state" from anon,authenticated;
grant all on table "private"."bureau_read_state" to service_role;
revoke all on table "public"."consultation_categories" from anon,authenticated;
grant all on table "public"."consultation_categories" to service_role;
grant select,insert,update,delete on table "public"."consultation_categories" to authenticated;
revoke all on table "public"."consultation_templates" from anon,authenticated;
grant all on table "public"."consultation_templates" to service_role;
grant select,insert,update,delete on table "public"."consultation_templates" to authenticated;
revoke all on table "public"."navigation_preferences" from anon,authenticated;
grant all on table "public"."navigation_preferences" to service_role;
grant select,update on table "public"."navigation_preferences" to authenticated;
revoke all on table "public"."pharmacy_stock" from anon,authenticated;
grant all on table "public"."pharmacy_stock" to service_role;
revoke all on table "public"."unpaid_debts" from anon,authenticated;
grant all on table "public"."unpaid_debts" to service_role;
grant select,insert,delete on table "public"."unpaid_debts" to authenticated;
revoke all on table "public"."consultation_notebooks" from anon,authenticated;
grant all on table "public"."consultation_notebooks" to service_role;
grant select on table "public"."consultation_notebooks" to authenticated;
revoke all on table "public"."consultation_user_categories" from anon,authenticated;
grant all on table "public"."consultation_user_categories" to service_role;
grant select,insert,update,delete on table "public"."consultation_user_categories" to authenticated;
revoke all on table "public"."consultation_user_templates" from anon,authenticated;
grant all on table "public"."consultation_user_templates" to service_role;
grant select,insert,update,delete on table "public"."consultation_user_templates" to authenticated;
alter publication supabase_realtime add table "public"."bureau_messages";
alter publication supabase_realtime add table "public"."bureau_typing";
commit;
begin;
insert into public.cabinet_state(id,cabinet_name,place,telegram,cash_balance) values(1,'Cabinet Médical de Valentine','Valentine · New Hanover','',0);
insert into public.resources (id,name,stock,active,category,unit_price) select id,name,stock,active,category,unit_price from jsonb_populate_recordset(null::public.resources,'[{"id":"ad4a7f7b-eea0-4fa1-98ee-76f3daa2ed06","name":"ALCOOL","stock":0,"active":true,"category":"ingredient","unit_price":0},{"id":"edf743b4-69c9-4163-b63d-a79c31da5844","name":"SUCRE","stock":0,"active":true,"category":"ingredient","unit_price":0},{"id":"00a95ecd-24cf-4b98-bb57-83090a955659","name":"KIT DE SOIN","stock":0,"active":true,"category":"produit","unit_price":0},{"id":"6fb300f3-9409-40af-b830-0879f7f123a2","name":"SERINGUE VIVIFIANTE","stock":0,"active":true,"category":"produit","unit_price":0},{"id":"285bd1d7-8432-4439-a923-395dac7f7b78","name":"CAROTTE","stock":0,"active":true,"category":"ingredient","unit_price":0},{"id":"08475ae1-ff65-4dde-aa06-b4514577a32a","name":"REMEDE CHEVAL","stock":0,"active":true,"category":"produit","unit_price":0},{"id":"1190b446-0dd3-4021-8f7a-c32b39468a8e","name":"GRAISSE","stock":0,"active":true,"category":"ingredient","unit_price":0},{"id":"090155bd-c51c-4672-8065-c7fe206c77b9","name":"THYM","stock":0,"active":true,"category":"ingredient","unit_price":0},{"id":"40c7609c-9c5e-4a1d-954f-ba70d1481a8f","name":"BANDAGE","stock":0,"active":true,"category":"produit","unit_price":0},{"id":"f7170510-9b60-49f1-9688-8d777c559df2","name":"OEUF","stock":0,"active":true,"category":"ingredient","unit_price":0},{"id":"52aaae14-5027-4fc2-87ce-61700349580f","name":"TISSU","stock":0,"active":true,"category":"ingredient","unit_price":0},{"id":"018e11cc-73b3-47c6-a591-238d29035a19","name":"COTON","stock":0,"active":true,"category":"ingredient","unit_price":0},{"id":"07ce1b85-4f0c-48cf-8fe9-f1f622084492","name":"SOIN ANIMAL","stock":0,"active":true,"category":"produit","unit_price":0},{"id":"13c7ffdd-a24c-4715-a5fe-6f96dc2eec72","name":"TABAC","stock":0,"active":true,"category":"ingredient","unit_price":0},{"id":"629c182f-a985-41e5-ae94-e4e11cd0fabf","name":"MENTHE","stock":0,"active":true,"category":"ingredient","unit_price":0}]'::jsonb);
insert into public.recipes (id,name,active,output_quantity,product_resource_id) select id,name,active,output_quantity,product_resource_id from jsonb_populate_recordset(null::public.recipes,'[{"id":"c0ed660f-3c04-49f0-a88d-464ea93f8021","name":"BANDAGE","active":true,"output_quantity":1,"product_resource_id":"40c7609c-9c5e-4a1d-954f-ba70d1481a8f"},{"id":"1873a5ef-127a-4ea7-9625-cabeb8d0868e","name":"KIT DE SOIN","active":true,"output_quantity":1,"product_resource_id":"00a95ecd-24cf-4b98-bb57-83090a955659"},{"id":"70520a0b-c477-449a-b53d-2ea56bcc7fbd","name":"REMEDE CHEVAL","active":true,"output_quantity":1,"product_resource_id":"08475ae1-ff65-4dde-aa06-b4514577a32a"},{"id":"c4672c73-c7af-42db-bba5-b073d8b39c52","name":"SERINGUE VIVIFIANTE","active":true,"output_quantity":1,"product_resource_id":"6fb300f3-9409-40af-b830-0879f7f123a2"},{"id":"f8bebcc1-f501-4ea6-bfac-f6577e438d9d","name":"SOIN ANIMAL","active":true,"output_quantity":1,"product_resource_id":"07ce1b85-4f0c-48cf-8fe9-f1f622084492"}]'::jsonb);
insert into public.recipe_ingredients (quantity,recipe_id,ingredient_resource_id) select quantity,recipe_id,ingredient_resource_id from jsonb_populate_recordset(null::public.recipe_ingredients,'[{"quantity":3,"recipe_id":"70520a0b-c477-449a-b53d-2ea56bcc7fbd","ingredient_resource_id":"285bd1d7-8432-4439-a923-395dac7f7b78"},{"quantity":2,"recipe_id":"70520a0b-c477-449a-b53d-2ea56bcc7fbd","ingredient_resource_id":"edf743b4-69c9-4163-b63d-a79c31da5844"},{"quantity":1,"recipe_id":"c4672c73-c7af-42db-bba5-b073d8b39c52","ingredient_resource_id":"ad4a7f7b-eea0-4fa1-98ee-76f3daa2ed06"},{"quantity":6,"recipe_id":"c4672c73-c7af-42db-bba5-b073d8b39c52","ingredient_resource_id":"629c182f-a985-41e5-ae94-e4e11cd0fabf"},{"quantity":1,"recipe_id":"c4672c73-c7af-42db-bba5-b073d8b39c52","ingredient_resource_id":"13c7ffdd-a24c-4715-a5fe-6f96dc2eec72"},{"quantity":2,"recipe_id":"f8bebcc1-f501-4ea6-bfac-f6577e438d9d","ingredient_resource_id":"f7170510-9b60-49f1-9688-8d777c559df2"},{"quantity":2,"recipe_id":"f8bebcc1-f501-4ea6-bfac-f6577e438d9d","ingredient_resource_id":"edf743b4-69c9-4163-b63d-a79c31da5844"},{"quantity":1,"recipe_id":"1873a5ef-127a-4ea7-9625-cabeb8d0868e","ingredient_resource_id":"ad4a7f7b-eea0-4fa1-98ee-76f3daa2ed06"},{"quantity":1,"recipe_id":"1873a5ef-127a-4ea7-9625-cabeb8d0868e","ingredient_resource_id":"018e11cc-73b3-47c6-a591-238d29035a19"},{"quantity":1,"recipe_id":"1873a5ef-127a-4ea7-9625-cabeb8d0868e","ingredient_resource_id":"090155bd-c51c-4672-8065-c7fe206c77b9"},{"quantity":2,"recipe_id":"c0ed660f-3c04-49f0-a88d-464ea93f8021","ingredient_resource_id":"018e11cc-73b3-47c6-a591-238d29035a19"},{"quantity":2,"recipe_id":"c0ed660f-3c04-49f0-a88d-464ea93f8021","ingredient_resource_id":"1190b446-0dd3-4021-8f7a-c32b39468a8e"},{"quantity":1,"recipe_id":"c0ed660f-3c04-49f0-a88d-464ea93f8021","ingredient_resource_id":"52aaae14-5027-4fc2-87ce-61700349580f"}]'::jsonb);
insert into public.recipe_pricing (cabinet_return,pharmacy_price,pharmacy_sellable,recommended_price,product_resource_id) select cabinet_return,pharmacy_price,pharmacy_sellable,recommended_price,product_resource_id from jsonb_populate_recordset(null::public.recipe_pricing,'[{"cabinet_return":0,"pharmacy_price":null,"pharmacy_sellable":true,"recommended_price":0,"product_resource_id":"40c7609c-9c5e-4a1d-954f-ba70d1481a8f"},{"cabinet_return":0,"pharmacy_price":null,"pharmacy_sellable":false,"recommended_price":0,"product_resource_id":"00a95ecd-24cf-4b98-bb57-83090a955659"},{"cabinet_return":0,"pharmacy_price":null,"pharmacy_sellable":true,"recommended_price":0,"product_resource_id":"08475ae1-ff65-4dde-aa06-b4514577a32a"},{"cabinet_return":0,"pharmacy_price":null,"pharmacy_sellable":false,"recommended_price":0,"product_resource_id":"6fb300f3-9409-40af-b830-0879f7f123a2"},{"cabinet_return":0,"pharmacy_price":null,"pharmacy_sellable":true,"recommended_price":0,"product_resource_id":"07ce1b85-4f0c-48cf-8fe9-f1f622084492"}]'::jsonb);
insert into public.consultation_categories (id,name,slug,color,active,sort_order) select id,name,slug,color,active,sort_order from jsonb_populate_recordset(null::public.consultation_categories,'[{"id":"18c432a7-32d7-4255-a850-4407a60fc7a7","name":"Blessures par balle","slug":"blessures-par-balle","color":"#8d241c","active":true,"sort_order":10},{"id":"9fd79a1c-3df1-4ddc-aca5-cf0570e119ec","name":"Armes blanches et projectiles","slug":"armes-blanches-projectiles","color":"#72502c","active":true,"sort_order":20},{"id":"6f39f3d2-a1d5-4aaa-be13-ab099f4a9121","name":"Attaques animales","slug":"attaques-animales","color":"#49613f","active":true,"sort_order":30},{"id":"aea35853-506b-4fcc-83df-307cc6921bd1","name":"Traumatismes crâniens","slug":"traumatismes-craniens","color":"#5e4770","active":true,"sort_order":40},{"id":"6c0072bf-7e0d-433f-9924-a0169830c416","name":"Fractures et traumatismes osseux","slug":"fractures-os","color":"#466278","active":true,"sort_order":50},{"id":"0e45f7a7-d403-493c-be7e-70b57a15e689","name":"Coups, chutes et contusions","slug":"coups-chutes-contusions","color":"#8a5c2f","active":true,"sort_order":60},{"id":"4e1249db-15db-42d8-bd7e-6f44c656bbbd","name":"Malaises, intoxications et urgences","slug":"malaises-urgences","color":"#476b65","active":true,"sort_order":70},{"id":"4dcabc35-b781-4606-8340-b6797e0b07d2","name":"Brûlures","slug":"brulures","color":"#9a4b28","active":true,"sort_order":80},{"id":"0de40d86-5951-4e58-b6d2-d03b8b0ff6b7","name":"Suivi médical","slug":"suivi-medical","color":"#676767","active":true,"sort_order":90}]'::jsonb);
insert into public.consultation_templates (id,body,title,active,sort_order,category_id,subcategory) select id,body,title,active,sort_order,category_id,subcategory from jsonb_populate_recordset(null::public.consultation_templates,'[{"id":"89278d8a-6aed-4788-a474-d845beeb4b46","body":"Abrasion balistique\r\nCabinet Médical de Valentine\r\nRapport du Médecin\r\nDr Médecin\r\n────────────────────\r\n\r\nConstatations cliniques :\r\nAbrasion balistique au niveau du bras.\r\nLa balle a longé la surface de la peau, causant une brûlure cutanée par friction et une plaie superficielle sans pénétration ni atteinte musculaire profonde.\r\nAucune hémorragie importante ni atteinte osseuse n’a été relevée.\r\n\r\nTraitement administré :\r\n– Nettoyage soigneux et asepsie complète de la zone lésée.\r\n– Refroidissement local afin de limiter l’inflammation et la douleur.\r\n– Application d’un baume apaisant et cicatrisant.\r\n– Application d’un baume anti-infectieux en prévention de toute complication.\r\n– Pose d’un bandage léger de protection.\r\n\r\nRecommandations :\r\nLe patient devra maintenir la zone propre et sèche.\r\nUn contrôle au cabinet est recommandé dans un délai de vingt-quatre heures afin de vérifier l’évolution de la cicatrisation et l’absence d’infection.\r\nRepos du membre conseillé durant les premières heures.\r\n\r\nFait à Valentine,\r\nSignature : Dr Médecin","title":"Abrasion balistique","active":true,"sort_order":1,"category_id":"18c432a7-32d7-4255-a850-4407a60fc7a7","subcategory":"Frôlement"},{"id":"e993754d-d09d-47c1-ab2f-6c744e5b9925","body":"Blessure par balle – Bras droit\r\nCabinet Médical de Valentine\r\nRapport du Médecin\r\nDr Médecin\r\n────────────────────\r\n\r\nConstatations cliniques :\r\nPlaie par arme à feu au bras droit.\r\nLa balle a traversé les chairs, occasionnant une brûlure des tissus et une perte sanguine modérée. Aucun éclat d’os n’a été relevé lors de l’examen initial.\r\n\r\nTraitement administré :\r\n– Administration de quelques gouttes de laudanum diluées afin d’apaiser les douleurs. \r\n– Nettoyage rigoureux et asepsie complète de la plaie.\r\n– Retrait des chairs brûlées et inspection minutieuse à la recherche de tout corps étranger.\r\n– Présence de balle dans la plaie: \r\n– Nouvelle asepsie préalable à la suture.\r\n– Fermeture de la plaie par points de suture.\r\n– Asepsie post-suture.\r\n– Application d’un baume cicatrisant associé à un baume anti-infectieux.\r\n– Pose d’un bandage de protection destiné à maintenir la plaie propre et immobile.\r\n\r\nRecommandations :\r\nLe patient est tenu de se présenter de nouveau au cabinet dans un délai de vingt-quatre heures afin de vérifier la bonne cicatrisation.\r\nLe retrait des points sera effectué si l’évolution est jugée satisfaisante et en l’absence de signes d’infection.\r\n\r\nFait à Valentine,\r\nSignature : Dr Médecin","title":"Blessure par balle – Bras droit","active":true,"sort_order":3,"category_id":"18c432a7-32d7-4255-a850-4407a60fc7a7","subcategory":"Membre supérieur"},{"id":"0756d829-78f3-4760-8b2f-c179be41e583","body":"Blessure par balle – Bras gauche\r\nCabinet Médical de Valentine\r\nRapport du Médecin\r\nDr Médecin\r\n────────────────────\r\n\r\nConstatations cliniques :\r\nPlaie par arme à feu au bras gauche.\r\nLa balle a traversé les chairs, occasionnant une brûlure des tissus et une perte sanguine modérée. Aucun éclat d’os n’a été relevé lors de l’examen initial.\r\n\r\nTraitement administré :\r\n– Administration de quelques gouttes de laudanum diluées afin d’apaiser les douleurs. \r\n– Nettoyage rigoureux et asepsie complète de la plaie.\r\n– Retrait des chairs brûlées et inspection minutieuse à la recherche de tout corps étranger.\r\n– Présence de balle dans la plaie: \r\n– Nouvelle asepsie préalable à la suture.\r\n– Fermeture de la plaie par {{points}} points de suture.\r\n– Asepsie post-suture.\r\n– Application d’un baume cicatrisant associé à un baume anti-infectieux.\r\n– Pose d’un bandage de protection destiné à maintenir la plaie propre et immobile.\r\n\r\nRecommandations :\r\nLe patient est tenu de se présenter de nouveau au cabinet dans un délai de vingt-quatre heures afin de vérifier la bonne cicatrisation.\r\nLe retrait des points sera effectué si l’évolution est jugée satisfaisante et en l’absence de signes d’infection.\r\n\r\nFait à Valentine,\r\nSignature : Dr Médecin","title":"Blessure par balle – Bras gauche","active":true,"sort_order":4,"category_id":"18c432a7-32d7-4255-a850-4407a60fc7a7","subcategory":"Membre supérieur"},{"id":"5ba0e886-4e33-4a4d-9ed4-4698db22fd98","body":"Chute de cheval – Sans gravité apparente\r\nCabinet Médical de Valentine\r\nRapport du Médecin\r\nDr Médecin\r\n────────────────────\r\n\r\nConstatations cliniques :\r\nPerte de connaissance brève consécutive au choc.\r\nÀ l’examen, aucune fracture, plaie ouverte ou lésion grave n’a été constatée.\r\nPrésence de douleurs diffuses et de contusions légères sans complication apparente.\r\n\r\nTraitement administré :\r\n– Mise au repos immédiate.\r\n– Examen clinique complet par palpation et observation visuelle.\r\n– Surveillance du patient durant plusieurs minutes.\r\n\r\nRecommandations :\r\nL’état du patient est jugé stable et sans gravité immédiate.\r\nIl est conseillé d’éviter toute activité physique intense durant les prochaines heures.\r\nConsulter de nouveau en cas de douleur persistante, vertiges, nausées ou nouvelle perte de connaissance.\r\n\r\nFait à Valentine,\r\nSignature : Dr Médecin","title":"Chute de cheval – Sans gravité apparente","active":true,"sort_order":3,"category_id":"0e45f7a7-d403-493c-be7e-70b57a15e689","subcategory":"Chute"},{"id":"d3116740-53d7-4438-886d-201f44af200b","body":"Blessure par balle – Flanc droit\r\nCabinet Médical de Valentine\r\nRapport du Médecin\r\nDr Médecin\r\n────────────────────\r\n\r\nConstatations cliniques :\r\nPlaie par arme à feu au flanc droit.\r\nLa balle a traversé les chairs, occasionnant une brûlure des tissus et une perte sanguine modérée. Aucun signe d’atteinte des organes vitaux n’a été constaté lors de l’examen initial.\r\n\r\nTraitement administré :\r\n– Administration de quelques gouttes de laudanum diluées afin d’apaiser les douleurs.\r\n– Nettoyage rigoureux et asepsie complète de la plaie.\r\n– Retrait des chairs brûlées et inspection minutieuse à la recherche de tout corps étranger.\r\n– Présence de balle dans la plaie:\r\n– Nouvelle asepsie préalable à la suture.\r\n– Fermeture de la plaie par points de suture.\r\n– Asepsie post-suture.\r\n– Application d’un baume cicatrisant associé à un baume anti-infectieux.\r\n– Pose d’un bandage de protection destiné à maintenir la plaie propre et immobile.\r\n\r\nRecommandations :\r\nLe patient est tenu de se présenter de nouveau au cabinet dans un délai de vingt-quatre heures afin de vérifier la bonne cicatrisation.\r\nLe retrait des points sera effectué si l’évolution est jugée satisfaisante et en l’absence de signes d’infection.\r\n\r\nFait à Valentine,\r\nSignature : Dr Médecin\r\n\r\n","title":"Blessure par balle – Flanc droit","active":true,"sort_order":5,"category_id":"18c432a7-32d7-4255-a850-4407a60fc7a7","subcategory":"Tronc"},{"id":"e3a2d5e8-d65f-4d8b-a840-cf6bf3d0995c","body":"Blessure par balle – Jambe droite\r\nCabinet Médical de Valentine\r\nRapport du Médecin\r\nDr Médecin\r\n────────────────────\r\n\r\nConstatations cliniques :\r\nPlaie par arme à feu à la cuisse droite.\r\nLa balle a traversé les chairs, occasionnant une brûlure des tissus et une perte sanguine modérée. Aucun éclat d’os n’a été relevé lors de l’examen initial.\r\n\r\nTraitement administré :\r\n– Administration de quelques gouttes de laudanum diluées afin d’apaiser les douleurs. \r\n– Nettoyage rigoureux et asepsie complète de la plaie.\r\n– Retrait des chairs brûlées et inspection minutieuse à la recherche de tout corps étranger.\r\n– Présence de balle dans la plaie: \r\n– Nouvelle asepsie préalable à la suture.\r\n– Fermeture de la plaie par {{points}} points de suture.\r\n– Asepsie post-suture.\r\n– Application d’un baume cicatrisant associé à un baume anti-infectieux.\r\n– Pose d’un bandage de protection destiné à maintenir la plaie propre et immobile.\r\n\r\nRecommandations :\r\nLe patient est tenu de se présenter de nouveau au cabinet dans un délai de vingt-quatre heures afin de vérifier la bonne cicatrisation.\r\nLe retrait des points sera effectué si l’évolution est jugée satisfaisante et en l’absence de signes d’infection.\r\n\r\nFait à Valentine,\r\nSignature : Dr Médecin","title":"Blessure par balle – Jambe droite","active":true,"sort_order":7,"category_id":"18c432a7-32d7-4255-a850-4407a60fc7a7","subcategory":"Membre inférieur"},{"id":"89d2afc7-83fb-4070-a884-ddbc6c81a721","body":"Blessure par balle – Jambe gauche\r\nCabinet Médical de Valentine\r\nRapport du Médecin\r\nDr Médecin\r\n────────────────────\r\n\r\nConstatations cliniques :\r\nPlaie par arme à feu à la cuisse gauche.\r\nLa balle a traversé les chairs, occasionnant une brûlure des tissus et une perte sanguine modérée. Aucun éclat d’os n’a été relevé lors de l’examen initial.\r\n\r\nTraitement administré :\r\n– Administration de quelques gouttes de laudanum diluées afin d’apaiser les douleurs. \r\n– Nettoyage rigoureux et asepsie complète de la plaie.\r\n– Retrait des chairs brûlées et inspection minutieuse à la recherche de tout corps étranger.\r\n– Présence de balle dans la plaie: \r\n– Nouvelle asepsie préalable à la suture.\r\n– Fermeture de la plaie par {{points}} points de suture.\r\n– Asepsie post-suture.\r\n– Application d’un baume cicatrisant associé à un baume anti-infectieux.\r\n– Pose d’un bandage de protection destiné à maintenir la plaie propre et immobile.\r\n\r\nRecommandations :\r\nLe patient est tenu de se présenter de nouveau au cabinet dans un délai de vingt-quatre heures afin de vérifier la bonne cicatrisation.\r\nLe retrait des points sera effectué si l’évolution est jugée satisfaisante et en l’absence de signes d’infection.\r\n\r\nFait à Valentine,\r\nSignature : Dr Médecin","title":"Blessure par balle – Jambe gauche","active":true,"sort_order":8,"category_id":"18c432a7-32d7-4255-a850-4407a60fc7a7","subcategory":"Membre inférieur"},{"id":"e6e534e9-cc27-422b-b797-c38c92f3a31b","body":"Blessure légère par arme blanche – Bras droit\r\nCabinet Médical de Valentine\r\nRapport du Médecin\r\nDr Médecin\r\n────────────────────\r\n\r\nConstatations cliniques :\r\nPlaie superficielle localisée à la face externe du bras droit.\r\nL’incision est peu profonde, sans écartement important des berges.\r\nSaignement léger, rapidement maîtrisé par compression.\r\nAucune atteinte musculaire, osseuse ou nerveuse constatée à l’examen.\r\nMobilité et sensibilité du membre conservées.\r\n\r\nTraitement administré :\r\n– Nettoyage abondant de la plaie à l’eau claire.\r\n– Asepsie rigoureuse à la teinture d’iode.\r\n– Inspection minutieuse afin d’écarter tout corps étranger.\r\n– Application d’un onguent cicatrisant et anti-infectieux.\r\n– Pose d’un pansement compressif léger.\r\n\r\nRecommandations :\r\nMaintenir le pansement propre et sec.\r\nÉviter les mouvements brusques du bras durant les prochaines vingt-quatre heures.\r\nSurveiller tout signe d’infection (rougeur, chaleur, écoulement, fièvre).\r\nRetour au cabinet recommandé sous vingt-quatre heures pour contrôle.\r\n\r\nFait à Valentine,\r\nSignature : Dr Médecin","title":"Blessure légère par arme blanche – Bras droit","active":true,"sort_order":1,"category_id":"9fd79a1c-3df1-4ddc-aca5-cf0570e119ec","subcategory":"Membre supérieur"},{"id":"f0f217b9-a461-4f7f-9978-9e5860407740","body":"Blessure par arme blanche – Bras droit\r\nCabinet Médical de Valentine\r\nRapport du Médecin\r\nDr Médecin\r\n────────────────────\r\n\r\nConstatations cliniques :\r\nPlaie pénétrante localisée à la face externe du bras droit.\r\nSaignement modéré à l’arrivée, maîtrisé par compression.\r\nLes berges de la plaie sont nettes, compatibles avec une lame fine.\r\nAucune atteinte osseuse détectée à la palpation.\r\nMobilité des doigts conservée, sensibilité intacte, suggérant l’absence de lésion nerveuse majeure.\r\n\r\nTraitement administré :\r\n– Administration de quelques gouttes de laudanum diluées afin d’atténuer la douleur.\r\n– Compression initiale afin de contrôler le saignement.\r\n– Nettoyage abondant de la plaie à l’eau claire.\r\n– Asepsie rigoureuse à la teinture d’iode.\r\n– Inspection minutieuse de la profondeur de la plaie pour écarter tout corps étranger.\r\n– Parage léger des tissus endommagés.\r\n– Asepsie préalable à la suture.\r\n– Fermeture par {{points}} points de suture adaptés à la profondeur de l’incision.\r\n– Asepsie post-suture.\r\n– Application d’un onguent cicatrisant et anti-infectieux.\r\n– Pose d’un bandage de protection maintenant le membre au repos.\r\n\r\nRecommandations :\r\nRepos du bras droit et limitation des mouvements durant les prochaines quarante-huit heures.\r\nSurveillance des signes d’infection (rougeur excessive, chaleur, suppuration, fièvre).\r\nRetour au cabinet sous vingt-quatre heures pour contrôle de la cicatrisation.\r\nRetrait des points selon évolution favorable.\r\n\r\nFait à Valentine,\r\nSignature : Dr Médecin","title":"Blessure par arme blanche – Bras droit","active":true,"sort_order":2,"category_id":"9fd79a1c-3df1-4ddc-aca5-cf0570e119ec","subcategory":"Membre supérieur"},{"id":"cac0e349-137a-4554-881f-d65b2e267ee3","body":"Blessure par arme blanche – Cuisse gauche\r\nCabinet Médical de Valentine\r\nRapport du Médecin\r\nDr Médecin\r\n────────────────────\r\n\r\nConstatations cliniques :\r\nPlaie pénétrante localisée à la face externe de la cuisse gauche.\r\nSaignement modéré à l’arrivée, maîtrisé par compression.\r\nLes berges de la plaie sont nettes, compatibles avec une lame fine.\r\nAucune atteinte osseuse détectée à la palpation.\r\nMobilité du membre conservée, sensibilité intacte, suggérant l’absence de lésion nerveuse majeure.\r\nAbsence de signes cliniques évoquant une atteinte vasculaire profonde.\r\n\r\nTraitement administré :\r\n– Administration de quelques gouttes de laudanum diluées afin d’atténuer la douleur.\r\n– Compression initiale afin de contrôler le saignement.\r\n– Nettoyage abondant de la plaie à l’eau claire.\r\n– Asepsie rigoureuse à la teinture d’iode.\r\n– Inspection minutieuse de la profondeur de la plaie pour écarter tout corps étranger.\r\n– Parage léger des tissus endommagés.\r\n– Asepsie préalable à la suture.\r\n– Fermeture par points de suture adaptés à la profondeur de l’incision.\r\n– Asepsie post-suture.\r\n– Application d’un onguent cicatrisant et anti-infectieux.\r\n– Pose d’un bandage de protection maintenant le membre au repos.\r\n\r\nRecommandations :\r\nRepos de la jambe gauche et limitation des déplacements durant les prochaines quarante-huit heures.\r\nÉviter toute activité physique susceptible de solliciter la cuisse blessée.\r\nSurveillance des signes d’infection (rougeur excessive, chaleur, suppuration, fièvre).\r\nRetour au cabinet sous vingt-quatre heures pour contrôle de la cicatrisation.\r\nRetrait des points selon évolution favorable.\r\n\r\nFait à Valentine,\r\n\r\nSignature : Dr Médecin","title":"Blessure par arme blanche – Cuisse gauche","active":true,"sort_order":3,"category_id":"9fd79a1c-3df1-4ddc-aca5-cf0570e119ec","subcategory":"Membre inférieur"},{"id":"f0b493df-1265-4db4-901f-f3263f05c921","body":"Blessure par flèche – Épaule droite\r\nCabinet Médical de Valentine\r\nRapport du Médecin\r\nDr Médecin\r\n────────────────────\r\n\r\nConstatations cliniques :\r\nPrésence d’une flèche logée dans l’épaule droite, profondément enchâssée dans les masses musculaires.\r\nLa plaie est pénétrante, avec saignement modéré. Aucun signe d’atteinte osseuse ni articulaire n’a été constaté lors de l’examen.\r\n\r\nTraitement administré :\r\n– Administration de quelques gouttes de laudanum diluées afin d’apaiser les douleurs.\r\n– Nettoyage minutieux et asepsie complète de la plaie.\r\n– Extraction du corps étranger : la pointe de flèche a été sectionnée en plusieurs fragments (cinq parties) afin de permettre son retrait sans aggraver les lésions musculaires.\r\n– Nouvelle asepsie préalable à la suture.\r\n– Suture des plans internes par deux points profonds, suivie de la fermeture cutanée par quatre points.\r\n– Asepsie post-suture.\r\n– Application d’un baume cicatrisant associé à un onguent anti-infectieux.\r\n– Mise en place d’un bandage de protection destiné à maintenir la plaie propre et immobilisée.\r\n\r\nRecommandations :\r\nLe patient devra se présenter de nouveau au cabinet dans un délai de vingt-quatre heures afin de contrôler l’évolution de la cicatrisation.\r\nLe retrait des points sera effectué si l’état de la plaie est jugé satisfaisant et en l’absence de tout signe d’infection.\r\n\r\nFait à Valentine,\r\nSignature : Dr Médecin","title":"Blessure par flèche – Épaule droite","active":true,"sort_order":4,"category_id":"9fd79a1c-3df1-4ddc-aca5-cf0570e119ec","subcategory":"Flèche"},{"id":"ddff7e7d-c7d8-45f8-afc6-58e3f32a7ae5","body":"Attaque de cougar\r\nCabinet Médical de Valentine\r\nRapport du Médecin\r\nDr Médecin\r\n────────────────────\r\n\r\nConstatations cliniques :\r\nPrésence de profondes griffures dans le dos, causées par l’animal.\r\nLes plaies sont irrégulières, souillées et présentent un risque élevé d’infection. Aucune atteinte osseuse ou viscérale n’a été constatée lors de l’examen.\r\n\r\nTraitement administré :\r\n– Administration de quelques gouttes de laudanum diluées afin d’apaiser les douleurs. \r\n– Nettoyage approfondi et asepsie complète des plaies.\r\n– Retrait de divers débris et corps étrangers (terre, poils et tissus souillés).\r\n– Nouvelle asepsie préalable à la suture.\r\n– Fermeture partielle des plaies par 5 points de suture, afin de favoriser la cicatrisation tout en limitant le risque infectieux.\r\n– Asepsie post-suture.\r\n– Application d’un baume cicatrisant accompagné d’un onguent anti-infectieux.\r\n– Mise en place d’un bandage de protection couvrant la zone dorsale.\r\n\r\nRecommandations :\r\nLe patient devra se présenter de nouveau au cabinet dans un délai de vingt-quatre heures afin de contrôler l’évolution de la cicatrisation.\r\nLe retrait des points sera effectué si l’état de la plaie est jugé satisfaisant et exempt de toute infection.\r\n\r\nFait à Valentine,\r\nSignature : Dr Médecin","title":"Attaque de cougar","active":true,"sort_order":1,"category_id":"6f39f3d2-a1d5-4aaa-be13-ab099f4a9121","subcategory":"Cougar"},{"id":"b40b8ca7-844c-4bf5-8d64-9ee95e830600","body":"Attaque d’ours – Blessures avec sutures\r\nCabinet Médical de Valentine\r\nRapport du Médecin\r\nDr Médecin\r\n────────────────────\r\n\r\nConstatations cliniques :\r\nPrésence de profondes griffures dans le dos, causées par l’animal.\r\nLes plaies sont irrégulières, souillées et présentent un risque élevé d’infection. Aucune atteinte osseuse ou viscérale n’a été constatée lors de l’examen.\r\n\r\nTraitement administré :\r\n– Administration de quelques gouttes de laudanum diluées afin d’apaiser les douleurs.\r\n– Nettoyage approfondi et asepsie complète des plaies.\r\n– Retrait de divers débris et corps étrangers (terre, poils et tissus souillés).\r\n– Nouvelle asepsie préalable à la suture.\r\n– Fermeture partielle des plaies par 5 points de suture, afin de favoriser la cicatrisation tout en limitant le risque infectieux.\r\n– Asepsie post-suture.\r\n– Application d’un baume cicatrisant accompagné d’un onguent anti-infectieux.\r\n– Mise en place d’un bandage de protection couvrant la zone dorsale.\r\n\r\nRecommandations :\r\nLe patient devra se présenter de nouveau au cabinet dans un délai de vingt-quatre heures afin de contrôler l’évolution de la cicatrisation.\r\nLe retrait des points sera effectué si l’état de la plaie est jugé satisfaisant et exempt de toute infection.\r\n\r\nFait à Valentine,\r\nSignature : Dr Médecin","title":"Attaque d’ours – Blessures avec sutures","active":true,"sort_order":2,"category_id":"6f39f3d2-a1d5-4aaa-be13-ab099f4a9121","subcategory":"Ours"},{"id":"171759ba-7a8e-4feb-a9ce-32f6bf277771","body":"Attaque d’ours – Contusions et égratignures\r\nCabinet Médical de Valentine\r\nRapport du Médecin\r\nDr Médecin\r\n────────────────────\r\n\r\nConstatations cliniques :\r\nPrésence de contusions multiples et d’égratignures superficielles causées par les griffes de l’animal, principalement au niveau des membres et du tronc.\r\nAucune plaie ouverte profonde, aucune morsure ni atteinte osseuse n’ont été observées.\r\nL’examen ne révèle pas de lésion mettant en jeu le pronostic vital.\r\n\r\nTraitement administré :\r\n– Nettoyage soigneux et asepsie complète des zones atteintes.\r\n– Application d’un baume apaisant afin de limiter la douleur et l’inflammation.\r\n– Application d’un onguent anti-infectieux à titre préventif.\r\n– Pose de bandages légers sur les zones les plus sensibles.\r\n\r\nRecommandations :\r\nRepos conseillé durant les prochaines heures.\r\nSurveillance de l’état général et des zones lésées durant les prochaines vingt-quatre heures.\r\nRetour au cabinet recommandé en cas d’apparition de douleurs accrues, de fièvre ou de signes d’infection.\r\n\r\nFait à Valentine,\r\nSignature : Dr Médecin","title":"Attaque d’ours – Contusions et égratignures","active":true,"sort_order":3,"category_id":"6f39f3d2-a1d5-4aaa-be13-ab099f4a9121","subcategory":"Ours"},{"id":"7bab1cb0-ef94-4111-be0f-24cc07b19844","body":"Coup à la tête – Plaie avec suture\r\nCabinet Médical de Valentine\r\nRapport du Médecin\r\nDr Médecin\r\n────────────────────\r\n\r\nConstatations cliniques :\r\nPrésence d’une plaie ouverte au niveau du cuir chevelu avec saignement modéré.\r\nAucune fracture apparente du crâne n’a été détectée lors de l’examen visuel et de la palpation.\r\nL’état neurologique du patient est jugé stable.\r\n\r\nTraitement administré :\r\n– Nettoyage minutieux et asepsie complète de la plaie.\r\n– Inspection afin d’écarter la présence de corps étrangers.\r\n– Fermeture de la plaie par {{points}} points de suture.\r\n– Asepsie post-suture.\r\n– Application d’un baume cicatrisant associé à un baume anti-infectieux.\r\n– Pose d’un bandage de protection autour de la zone atteinte.\r\n\r\nRecommandations :\r\nLe patient devra se présenter de nouveau au cabinet dans un délai de vingt-quatre heures pour contrôle de la cicatrisation.\r\nLe retrait des points sera effectué si l’évolution est jugée satisfaisante.\r\n\r\nFait à Valentine,\r\nSignature : Dr Médecin","title":"Coup à la tête – Plaie avec suture","active":true,"sort_order":1,"category_id":"aea35853-506b-4fcc-83df-307cc6921bd1","subcategory":"Plaie ouverte"},{"id":"60918a62-0516-4680-b4e7-49663fc6304a","body":"Coup à la tête – Sans plaie ouverte\r\nCabinet Médical de Valentine\r\nRapport du Médecin\r\nDr Médecin\r\n────────────────────\r\n\r\nConstatations cliniques :\r\nPrésence d’une douleur localisée au niveau du crâne avec légère sensibilité à la palpation.\r\nAucune plaie ouverte, saignement ou fracture apparente n’a été constatée lors de l’examen.\r\nLe patient ne présente ni vertiges persistants, ni nausées, ni trouble de la vision.\r\n\r\nTraitement administré :\r\n– Mise au repos immédiate.\r\n– Application locale d’un baume apaisant afin de soulager la douleur.\r\n– Surveillance du patient durant plusieurs minutes.\r\n\r\nRecommandations :\r\nÉviter tout effort physique durant les prochaines heures.\r\nConsulter de nouveau en cas de maux de tête persistants, vertiges ou perte de connaissance.\r\n\r\nFait à Valentine,\r\nSignature : Dr Médecin","title":"Coup à la tête – Sans plaie ouverte","active":true,"sort_order":2,"category_id":"aea35853-506b-4fcc-83df-307cc6921bd1","subcategory":"Traumatisme fermé"},{"id":"203851cf-007d-4cf2-a397-6f85fa9a1492","body":"Hématome sous-dural\r\nCabinet Médical de Valentine\r\nRapport du Médecin\r\nDr Médecin\r\n────────────────────\r\n\r\nConstatations cliniques :\r\nPrésence d’un hématome au niveau du crâne, sur l’os pariétal.\r\nLes symptômes observés sont compatibles avec un hématome sous-dural, nécessitant une intervention chirurgicale immédiate.\r\n\r\nTraitement administré :\r\n– Anesthésie totale du patient par inhalation d’éther.\r\n– Rasage de la zone à opérer et mise en place d’un champ opératoire.\r\n– Asepsie rigoureuse de la zone crânienne.\r\n– Trépanation de la boîte crânienne à l’aide d’un trépan manuel afin d’accéder à l’hématome.\r\n– Drainage de l’hématome sous-dural.\r\n– Rebouchage de la cavité à l’aide d’une pâte d’ivoire.\r\n– Suture de la zone opérée par plusieurs points.\r\n– Pose d’un bandage de maintien autour du crâne.\r\n– Réveil progressif du patient sous surveillance médicale.\r\n\r\nRecommandations :\r\nIl est formellement conseillé au patient d’éviter toute consommation d’alcool ou de drogues durant les vingt-quatre prochaines heures.\r\nLimiter strictement les activités physiques et veiller à une hydratation abondante.\r\n\r\nAdministration recommandée d’une infusion composée de valériane, racine de bardane, ail sauvage et spiruline afin de favoriser le rétablissement.\r\n\r\nLe patient devra se présenter de nouveau dans un cabinet médical dans un délai de vingt-quatre heures afin de contrôler la cicatrisation.\r\nEn cas de rechute ou de récidive des symptômes, la cavité déjà pré-percée devra être rouverte.\r\n\r\nFait à Valentine,\r\nSignature : Dr Médecin","title":"Hématome sous-dural","active":true,"sort_order":3,"category_id":"aea35853-506b-4fcc-83df-307cc6921bd1","subcategory":"Urgence chirurgicale"},{"id":"298c47e4-3f13-4d9a-900f-0b0ca0d01272","body":"Fracture ouverte – Bras gauche\r\nCabinet Médical de Valentine\r\nRapport du Médecin\r\nDr Médecin\r\n────────────────────\r\n\r\nConstatations cliniques :\r\nDéformation évidente et douleur intense au niveau du bras gauche.\r\nLa palpation et l’examen visuel révèlent une fracture du membre supérieur gauche.\r\nPrésence d’une plaie associée, indiquant une fracture ouverte, sans atteinte apparente des vaisseaux majeurs.\r\n\r\nTraitement administré :\r\n– Administration orale de laudanum afin de soulager la douleur.\r\n– Nettoyage et asepsie rigoureuse de la plaie.\r\n– Examen de confirmation de la fracture effectué par palpation et observation visuelle.\r\n– Traitement de la fracture ouverte avec soins locaux afin de prévenir toute infection.\r\n– Fermeture des plaies par 7 points de suture.\r\n– Application d’un baume apaisant à base d’arnica.\r\n– Pose d’un cataplasme de consoude dans le but de favoriser la consolidation osseuse.\r\n– Mise en place d’une coque de maintien en argile destinée à immobiliser le membre atteint.\r\n\r\nRecommandations :\r\nLe patient devra se présenter de nouveau dans un cabinet médical dans un délai de vingt-quatre heures afin de contrôler l’évolution de la consolidation et l’état de la plaie.\r\nLe retrait des points sera envisagé si la cicatrisation est jugée satisfaisante.\r\nRepos strict du membre atteint et éviction de tout effort.\r\n\r\nFait à Valentine,\r\nSignature : Dr Médecin","title":"Fracture ouverte – Bras gauche","active":true,"sort_order":1,"category_id":"6c0072bf-7e0d-433f-9924-a0169830c416","subcategory":"Membre supérieur"},{"id":"7cf87e3a-1d8b-4ebe-84ac-d65d67c6c333","body":"Fracture des côtes\r\nCabinet Médical de Valentine\r\nRapport du Médecin\r\nDr Médecin\r\n────────────────────\r\n\r\nConstatations cliniques :\r\nDouleur vive à la palpation du gril costal.\r\nDéformation localisée et sensibilité marquée au niveau de la première fausse côte, laissant apparaître une fracture simple.\r\nAucun signe de perforation pulmonaire ni de détresse respiratoire n’a été constaté lors de l’examen clinique.\r\n\r\nTraitement administré :\r\n– Administration orale de laudanum afin de soulager la douleur.\r\n– Nettoyage et asepsie de la zone examinée par mesure de précaution.\r\n– Examen de détection de fracture effectué par palpation et observation visuelle.\r\n– Application d’un baume apaisant à base d’arnica.\r\n– Pose d’un cataplasme de consoude afin de favoriser la consolidation osseuse.\r\n– Mise en place d’une coque de maintien en argile, à défaut d’un corset thoracique, destinée à limiter les mouvements du gril costal.\r\n\r\nRecommandations :\r\nLe patient devra se présenter de nouveau dans un cabinet médical dans un délai de vingt-quatre heures afin de vérifier l’évolution de la consolidation.\r\nRepos strict conseillé, avec limitation des efforts et des mouvements brusques.\r\nUn nouvel examen clinique sera réalisé en cas d’aggravation de la douleur ou de gêne respiratoire.\r\n\r\nFait à Valentine,\r\nSignature : Dr Médecin","title":"Fracture des côtes","active":true,"sort_order":2,"category_id":"6c0072bf-7e0d-433f-9924-a0169830c416","subcategory":"Thorax"},{"id":"48b86e3f-99e8-42fd-ba28-1b56387b3a3a","body":"Bagarre\r\nCabinet Médical de Valentine\r\nRapport du Médecin\r\nDr Médecin\r\n────────────────────\r\n\r\nConstatations cliniques :\r\nPrésence d’un ou plusieurs hématomes consécutifs à des coups portés par objet contondant ou par les poings.\r\nAucune plaie ouverte, fracture apparente ni atteinte osseuse n’a été constatée lors de l’examen.\r\n\r\nTraitement administré :\r\n– Nettoyage et asepsie des zones touchées par mesure de précaution.\r\n– Application locale d’un baume apaisant à base d’arnica afin de soulager la douleur et limiter l’inflammation.\r\n– Pose d’un bandage de protection et de maintien.\r\n\r\nObservations particulières :\r\nL’état du patient ne présente pas de gravité immédiate. Une surveillance est toutefois conseillée dans les heures à venir en raison de la perte de connaissance constatée.\r\n\r\nFait à Valentine,\r\nSignature : Dr Médecin","title":"Bagarre","active":true,"sort_order":1,"category_id":"0e45f7a7-d403-493c-be7e-70b57a15e689","subcategory":"Violences"},{"id":"f438364e-1c7b-4056-a96a-b7d6dac2e259","body":"Hématome sur l’abdomen\r\nCabinet Médical de Valentine\r\nRapport du Médecin\r\nDr Médecin\r\n────────────────────\r\n\r\nConstatations cliniques :\r\nPrésence d’un hématome étendu sur toute la longueur de l’abdomen, accompagné d’une sensibilité marquée à la palpation.\r\nAucune plaie ouverte ni signe d’hémorragie externe n’a été observé lors de l’examen.\r\nLe patient présente une douleur modérée à intense selon les mouvements effectués.\r\nLes constantes vitales demeurent stables au moment de la consultation.\r\n\r\nTraitement administré :\r\n– Application locale de compresses froides afin de limiter l’inflammation et l’extension de l’hématome.\r\n– Administration d’antalgiques pour soulager la douleur.\r\n– Surveillance de l’évolution de l’état du patient durant l’examen.\r\n\r\nRecommandations :\r\nÉviter tout effort physique important durant les prochains jours.\r\nAppliquer du froid par intermittence au cours des premières 24 heures.\r\nConsulter à nouveau en cas d’augmentation de la douleur, de difficultés respiratoires, de malaise ou d’apparition de nouveaux symptômes.\r\n\r\nFait à Valentine,\r\n\r\nSignature : Dr Médecin","title":"Hématome sur l’abdomen","active":true,"sort_order":2,"category_id":"0e45f7a7-d403-493c-be7e-70b57a15e689","subcategory":"Tronc"},{"id":"18372c96-ffd6-4d05-849e-26a724a26835","body":"Coup de crosse – Sans gravité apparente\r\nCabinet Médical de Valentine\r\nRapport du Médecin\r\nDr Médecin\r\n────────────────────\r\n\r\nConstatations cliniques :\r\nPrésence d’une contusion localisée au point d’impact, avec douleur modérée à la palpation.\r\nAucune plaie ouverte, fracture ou trouble neurologique n’a été constaté lors de l’examen.\r\nLe patient ne présente ni perte de connaissance prolongée, ni vertiges persistants, ni nausées.\r\n\r\nTraitement administré :\r\n– Examen clinique par palpation et observation visuelle.\r\n– Mise au repos du patient.\r\n– Application locale d’un baume apaisant afin de soulager la douleur.\r\n\r\nRecommandations :\r\nL’état du patient est jugé stable et sans gravité immédiate.\r\nIl est recommandé d’éviter tout effort physique durant les prochaines heures.\r\nConsulter de nouveau en cas d’aggravation des douleurs ou d’apparition de nouveaux symptômes.\r\n\r\nFait à Valentine,\r\nSignature : Dr Médecin","title":"Coup de crosse – Sans gravité apparente","active":true,"sort_order":4,"category_id":"0e45f7a7-d403-493c-be7e-70b57a15e689","subcategory":"Violences"},{"id":"57c7605d-d5f6-47fc-801a-a5a2a0807620","body":"Morsure de serpent\r\nCabinet Médical de Valentine\r\nRapport du Médecin\r\nDr Médecin\r\n────────────────────\r\n\r\nConstatations cliniques :\r\nPrésence de deux points de morsure au niveau du pied droit, compatibles avec une morsure de serpent.\r\nInflammation locale modérée et douleur marquée à la palpation. Aucun signe immédiat de nécrose étendue n’a été constaté lors de l’examen.\r\n\r\nTraitement administré :\r\n– Injection d’un antivenin approprié afin de neutraliser les effets du poison.\r\n– Administration orale de quelques gouttes de laudanum diluées afin d’atténuer la douleur.\r\n– Nettoyage minutieux et asepsie complète de la zone atteinte.\r\n– Inspection de la plaie à la recherche de tout corps étranger.\r\n– Drainage superficiel des emplacements de la morsure afin de limiter la diffusion du venin résiduel.\r\n– Application d’un baume cicatrisant associé à un baume anti-infectieux.\r\n– Pose d’un bandage de protection destiné à maintenir la zone propre et surveillée.\r\n\r\nRecommandations :\r\nLe patient est tenu de se présenter de nouveau au cabinet en cas de complications.\r\nUne surveillance étroite est recommandée en cas d’aggravation de la douleur, de fièvre ou de gonflement excessif.\r\n\r\nFait à Valentine,\r\nSignature : Dr Médecin","title":"Morsure de serpent","active":true,"sort_order":2,"category_id":"4e1249db-15db-42d8-bd7e-6f44c656bbbd","subcategory":"Envenimation"},{"id":"2e61fd77-bd06-4587-8751-7c1ad95ce797","body":"Surdose\r\n-Cabinet de Valentine-\r\n-Rapport Médical- \r\n-Docteur Médecin-\r\n**********************\r\n*Substance consommée :\r\nConsommation excessive de : \r\n\r\n*Soins :\r\n-Surchauffe du corps pour transpirer les toxines\r\n-Patient amené dans un saloon pour un bain très chaud, avec l’aide des employés du saloon. \r\nBain de 10 min sous surveillance.\r\n-Infusion détox à base de chicorée pour le foie et le sang.\r\n\r\n**********************","title":"Surdose","active":true,"sort_order":3,"category_id":"4e1249db-15db-42d8-bd7e-6f44c656bbbd","subcategory":"Intoxication"},{"id":"d3981954-4207-402f-b850-88b4bac44538","body":"Strangulation\r\nCabinet Médical de Valentine\r\nRapport du Médecin\r\nDr Médecin\r\n────────────────────\r\n\r\nConstatations cliniques :\r\nPerte de connaissance consécutive à une strangulation.\r\nPrésence de rougeurs et de marques visibles autour du cou.\r\nAprès reprise de conscience, le patient ne présente ni maux de tête, ni vertiges, ni nausées.\r\n\r\nTraitement administré :\r\n– Mise au repos immédiate.\r\n– Surveillance attentive de l’état général du patient durant plusieurs minutes.\r\n\r\nRecommandations :\r\nAucune complication immédiate n’a été constatée à l’issue de la surveillance.\r\nIl est néanmoins conseillé d’éviter tout effort et de consulter de nouveau en cas de gêne respiratoire, de douleur persistante ou de nouvelle perte de connaissance.\r\n\r\nFait à Valentine,\r\nSignature : Dr Médecin","title":"Strangulation","active":true,"sort_order":4,"category_id":"4e1249db-15db-42d8-bd7e-6f44c656bbbd","subcategory":"Asphyxie"},{"id":"10aaf56d-02f7-42b2-8572-0e16a4945317","body":"Déshydratation\r\nCabinet Médical de Valentine\r\nRapport du Médecin\r\nDr Médecin\r\n────────────────────\r\n\r\nConstatations cliniques :\r\nÉtat de fatigue marqué et signes de déshydratation.\r\nLa perte de connaissance est compatible avec un manque prolongé d’apport en eau.\r\nAucun signe de traumatisme ni de pathologie associée n’a été constaté lors de l’examen.\r\n\r\nTraitement administré :\r\n– Administration progressive d’eau fraîche afin de réhydrater le patient.\r\n– Mise au repos et surveillance de l’état général durant plusieurs minutes.\r\n\r\nRecommandations :\r\nIl est recommandé au patient de boire régulièrement, en particulier par forte chaleur ou lors d’efforts prolongés.\r\nUne reprise progressive des activités est conseillée.\r\n\r\nFait à Valentine,\r\nSignature : Dr Médecin","title":"Déshydratation","active":true,"sort_order":5,"category_id":"4e1249db-15db-42d8-bd7e-6f44c656bbbd","subcategory":"Déshydratation"},{"id":"087bda5e-57f2-4ce9-8e72-0c183c0ffd56","body":"Brûlure – Avant-bras gauche\r\nCabinet Médical de Valentine\r\nRapport du Médecin\r\nDr Médecin\r\n────────────────────\r\n\r\nConstatations cliniques :\r\nBrûlure localisée au niveau de l’avant-bras gauche.\r\nLes tissus présentent des zones de chair brûlée avec rougeur marquée et douleur à la palpation.\r\nAucune atteinte profonde des structures sous-jacentes n’a été constatée lors de l’examen.\r\n\r\nTraitement administré :\r\n– Refroidissement immédiat de la zone brûlée à l’eau claire durant environ deux minutes.\r\n– Retrait soigneux des chairs brûlées et des tissus nécrosés.\r\n– Application locale d’un baume à base d’hamamélis et d’aloe vera afin d’apaiser la brûlure et favoriser la cicatrisation.\r\n– Pose d’un bandage de protection destiné à préserver la zone atteinte.\r\n\r\nRecommandations :\r\nLe patient devra se présenter de nouveau dans un cabinet médical dans un délai de vingt-quatre heures afin de contrôler l’évolution de la cicatrisation.\r\nL’application d’un baume à base d’aloe vera et d’hamamélis trois fois par jour est prescrite.\r\n\r\nFait à Valentine,\r\nSignature : Dr Médecin","title":"Brûlure – Avant-bras gauche","active":true,"sort_order":1,"category_id":"4dcabc35-b781-4606-8340-b6797e0b07d2","subcategory":"Membre supérieur"},{"id":"e82e4da1-303c-4e43-b3c7-6e997acec764","body":"Blessure par balle – Fesse\r\nCabinet Médical de Valentine\r\nRapport du Médecin\r\nDr Médecin\r\n────────────────────\r\n\r\nConstatations cliniques :\r\nPlaie par arme à feu au niveau de la fesse droite.\r\nLe projectile a pénétré les chairs sans traverser entièrement la zone, provoquant une brûlure des tissus et une perte sanguine modérée.\r\nAucune atteinte osseuse ni lésion des organes vitaux n’a été constatée lors de l’examen.\r\n\r\nTraitement administré :\r\n– Administration de quelques gouttes de laudanum diluées afin d’atténuer la douleur.\r\n– Nettoyage rigoureux et asepsie complète de la plaie.\r\n– Inspection minutieuse à la recherche de tout corps étranger.\r\n– Extraction du projectile lorsque cela a été possible sans aggraver les lésions.\r\n– Nouvelle asepsie préalable à la suture.\r\n– Fermeture de la plaie par points de suture.\r\n– Asepsie post-suture.\r\n– Application d’un baume cicatrisant associé à un baume anti-infectieux.\r\n– Pose d’un bandage de protection destiné à maintenir la plaie propre.\r\n\r\nRecommandations :\r\nLe patient devra se présenter de nouveau au cabinet dans un délai de vingt-quatre heures afin de contrôler l’évolution de la cicatrisation.\r\nLe retrait des points sera effectué si l’évolution est jugée satisfaisante et en l’absence de signes d’infection.\r\nRepos recommandé et limitation des déplacements durant la phase de guérison.\r\n\r\nFait à Valentine,\r\nSignature : Dr Médecin","title":"Blessure par balle – Fesse","active":true,"sort_order":2,"category_id":"18c432a7-32d7-4255-a850-4407a60fc7a7","subcategory":"Bassin"},{"id":"74fd6196-257b-44e1-8386-d3b127475e48","body":"Coup de sabot léger\r\nCabinet Médical de Valentine\r\nRapport du Médecin\r\nDr Médecin\r\n────────────────────\r\n\r\nConstatations cliniques :\r\nPrésence d’un hématome étendu au niveau de la cuisse, consécutif à un choc violent.\r\nAucune plaie ouverte, fracture ou atteinte osseuse n’a été constatée lors de l’examen.\r\n\r\nTraitement administré :\r\n– Nettoyage et asepsie de la zone atteinte par mesure de précaution.\r\n– Application locale d’un baume apaisant à base d’arnica afin de réduire la douleur et l’inflammation.\r\n– Mise en place d’un bandage de maintien et de protection.\r\n\r\nObservations particulières :\r\nL’état du patient ne présente pas de gravité immédiate. Une surveillance est néanmoins recommandée en cas d’aggravation de la douleur ou d’apparition de nouvelles complications.\r\n\r\nFait à Valentine,\r\nSignature : Dr Médecin","title":"Coup de sabot léger","active":true,"sort_order":5,"category_id":"0e45f7a7-d403-493c-be7e-70b57a15e689","subcategory":"Animal"},{"id":"43e1b2db-7fba-49fe-88a1-6145c5444ace","body":"Hypoglycémie\r\nCabinet Médical de Valentine\r\nRapport du Médecin\r\nDr Médecin\r\n────────────────────\r\n\r\nConstatations cliniques :\r\nPerte de connaissance consécutive à un malaise compatible avec un état d’hypoglycémie.\r\nÀ l’examen, le patient ne présente ni maux de tête, ni vertiges, ni nausées après reprise de conscience.\r\n\r\nTraitement administré :\r\n– Administration d’un repas sucré afin de rétablir un taux de sucre suffisant.\r\n– Mise au repos et surveillance du patient durant plusieurs minutes.\r\n\r\nRecommandations :\r\nAucune complication immédiate constatée.\r\nIl est recommandé au patient de s’alimenter régulièrement et d’éviter tout effort prolongé sans prise de nourriture.\r\n\r\nFait à Valentine,\r\nSignature : Dr Médecin","title":"Hypoglycémie","active":true,"sort_order":1,"category_id":"4e1249db-15db-42d8-bd7e-6f44c656bbbd","subcategory":"Métabolique"},{"id":"ec72614a-748c-4567-9e6d-5f08ca804da8","body":"Suivi médical et retrait des points\r\n\r\nCabinet Médical de Valentine\r\nDr Médecin\r\n────────────────────\r\n\r\nLors de la visite de contrôle, les soins suivants ont été effectués :\r\n\r\n– Nettoyage de la plaie à l’eau claire.\r\n– Retrait des points de suture.\r\n– Application locale d’un baume cicatrisant afin de favoriser la bonne fermeture des tissus.\r\n– Pose d’un bandage de protection.\r\n\r\nL’état de la plaie est jugé satisfaisant à l’issue de ce suivi.\r\n\r\nFait à Valentine,\r\nSignature : Dr Médecin","title":"Suivi médical et retrait des points","active":true,"sort_order":1,"category_id":"0de40d86-5951-4e58-b6d2-d03b8b0ff6b7","subcategory":"Contrôle"},{"id":"62360ae0-6d76-4e91-85f8-1fab3d9c74d5","body":"Blessure par balle – Flanc gauche\r\nCabinet Médical de Valentine\r\nRapport du Médecin\r\nDr Médecin\r\n────────────────────\r\n\r\nConstatations cliniques :\r\nPlaie par arme à feu au flanc gauche.\r\nLa balle a traversé les chairs, occasionnant une brûlure des tissus et une perte sanguine modérée. Aucun signe d’atteinte des organes vitaux n’a été constaté lors de l’examen initial.\r\n\r\nTraitement administré :\r\n– Administration de quelques gouttes de laudanum diluées afin d’apaiser les douleurs.\r\n– Nettoyage rigoureux et asepsie complète de la plaie.\r\n– Retrait des chairs brûlées et inspection minutieuse à la recherche de tout corps étranger.\r\n– Présence de balle dans la plaie:\r\n– Nouvelle asepsie préalable à la suture.\r\n– Fermeture de la plaie par points de suture.\r\n– Asepsie post-suture.\r\n– Application d’un baume cicatrisant associé à un baume anti-infectieux.\r\n– Pose d’un bandage de protection destiné à maintenir la plaie propre et immobile.\r\n\r\nRecommandations :\r\nLe patient est tenu de se présenter de nouveau au cabinet dans un délai de vingt-quatre heures afin de vérifier la bonne cicatrisation.\r\nLe retrait des points sera effectué si l’évolution est jugée satisfaisante et en l’absence de signes d’infection.\r\n\r\nFait à Valentine,\r\nSignature : Dr Médecin","title":"Blessure par balle – Flanc gauche","active":true,"sort_order":6,"category_id":"18c432a7-32d7-4255-a850-4407a60fc7a7","subcategory":"Tronc"}]'::jsonb);
insert into storage.buckets(id,name,public,file_size_limit,allowed_mime_types) values('bureau-chat','bureau-chat',false,20971520,null);
commit;