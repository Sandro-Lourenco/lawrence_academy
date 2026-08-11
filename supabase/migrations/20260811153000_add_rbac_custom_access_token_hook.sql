-- Keep the JWT authorization claim aligned with the canonical RBAC tables.
-- The client and FastAPI read app_metadata.role; user_metadata is intentionally
-- never used for authorization because it is editable by the end user.

CREATE OR REPLACE FUNCTION public.custom_access_token_hook(event JSONB)
RETURNS JSONB
LANGUAGE plpgsql
STABLE
SET search_path = pg_catalog, public
AS $$
DECLARE
    v_claims JSONB;
    v_app_metadata JSONB;
    v_role TEXT;
BEGIN
    SELECT r.name
      INTO v_role
      FROM public.user_roles AS ur
      JOIN public.roles AS r ON r.id = ur.role_id
     WHERE ur.user_id = (event ->> 'user_id')::UUID
     ORDER BY CASE r.name
         WHEN 'super_admin' THEN 1
         WHEN 'admin' THEN 2
         WHEN 'teacher' THEN 3
         WHEN 'student' THEN 4
         ELSE 5
     END
     LIMIT 1;

    v_claims := COALESCE(event -> 'claims', '{}'::JSONB);
    v_app_metadata := COALESCE(v_claims -> 'app_metadata', '{}'::JSONB);
    v_app_metadata := jsonb_set(
        v_app_metadata,
        '{role}',
        to_jsonb(COALESCE(v_role, 'student')),
        true
    );
    v_claims := jsonb_set(v_claims, '{app_metadata}', v_app_metadata, true);

    RETURN jsonb_build_object('claims', v_claims);
END;
$$;

-- Auth alone may invoke the hook. It must not become a callable Data API RPC.
REVOKE ALL ON FUNCTION public.custom_access_token_hook(JSONB)
    FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.custom_access_token_hook(JSONB)
    TO supabase_auth_admin;
GRANT USAGE ON SCHEMA public TO supabase_auth_admin;

-- The hook runs as supabase_auth_admin. Grant only the two SELECT privileges
-- it needs and allow that role through RLS, instead of bypassing RLS with a
-- postgres-owned SECURITY DEFINER function.
GRANT SELECT ON TABLE public.user_roles, public.roles TO supabase_auth_admin;

DROP POLICY IF EXISTS "Auth hook reads canonical user roles" ON public.user_roles;
CREATE POLICY "Auth hook reads canonical user roles"
    ON public.user_roles
    FOR SELECT
    TO supabase_auth_admin
    USING (true);

DROP POLICY IF EXISTS "Auth hook reads role names" ON public.roles;
CREATE POLICY "Auth hook reads role names"
    ON public.roles
    FOR SELECT
    TO supabase_auth_admin
    USING (true);
