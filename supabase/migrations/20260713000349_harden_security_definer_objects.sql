-- Harden database objects reported by the Supabase Security Advisor.
-- This migration changes execution context and privileges only; it does not
-- modify application data or authorization predicates.

CREATE SCHEMA IF NOT EXISTS private;
REVOKE ALL ON SCHEMA private FROM PUBLIC;

CREATE OR REPLACE FUNCTION private.list_public_profiles()
RETURNS TABLE (
    id uuid,
    full_name varchar(255),
    avatar_url text,
    bio text,
    role public.user_role
)
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = pg_catalog, public
AS $$
    SELECT p.id, p.full_name, p.avatar_url, p.bio, p.role
    FROM public.profiles AS p
    WHERE p.role IN ('teacher', 'admin');
$$;

REVOKE ALL ON FUNCTION private.list_public_profiles() FROM PUBLIC;
GRANT USAGE ON SCHEMA private TO anon, authenticated, service_role;
GRANT EXECUTE ON FUNCTION private.list_public_profiles()
    TO anon, authenticated, service_role;

DROP VIEW IF EXISTS public.profile_public_view;
CREATE VIEW public.profile_public_view AS
SELECT id, full_name, avatar_url, bio, role
FROM private.list_public_profiles();

ALTER VIEW IF EXISTS public.profile_public_view
    SET (security_invoker = true);

GRANT SELECT ON public.profile_public_view TO anon, authenticated, service_role;

ALTER FUNCTION public.auto_grade_submission()
    SET search_path = pg_catalog, public;

ALTER FUNCTION public.check_progress_course_integrity()
    SET search_path = pg_catalog, public;

ALTER FUNCTION public.handle_new_user()
    SET search_path = pg_catalog, public;

ALTER FUNCTION public.handle_storage_video_upload()
    SET search_path = pg_catalog, public;

ALTER FUNCTION public.is_admin(uuid)
    SET search_path = pg_catalog, public;

ALTER FUNCTION public.is_teacher(uuid)
    SET search_path = pg_catalog, public;

-- Authorization helpers bypass profiles/user_roles RLS to avoid recursion,
-- but they may only inspect the current JWT subject. This prevents callers
-- from probing another user's role through the public function signature.
CREATE OR REPLACE FUNCTION public.is_admin(p_user_id uuid)
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = pg_catalog, public
AS $$
    SELECT p_user_id IS NOT NULL
       AND p_user_id = (SELECT auth.uid())
       AND EXISTS (
            SELECT 1
            FROM public.user_roles AS ur
            JOIN public.roles AS r ON r.id = ur.role_id
            WHERE ur.user_id = p_user_id
              AND r.name IN ('admin', 'super_admin')
       );
$$;

CREATE OR REPLACE FUNCTION public.is_teacher(p_user_id uuid)
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = pg_catalog, public
AS $$
    SELECT p_user_id IS NOT NULL
       AND p_user_id = (SELECT auth.uid())
       AND EXISTS (
            SELECT 1
            FROM public.user_roles AS ur
            JOIN public.roles AS r ON r.id = ur.role_id
            WHERE ur.user_id = p_user_id
              AND r.name = 'teacher'
       );
$$;

-- Trigger functions must not be callable as public RPC functions. Revoking
-- EXECUTE does not prevent PostgreSQL from invoking their existing triggers.
REVOKE ALL ON FUNCTION public.auto_grade_submission() FROM PUBLIC, anon, authenticated;
REVOKE ALL ON FUNCTION public.check_progress_course_integrity() FROM PUBLIC, anon, authenticated;
REVOKE ALL ON FUNCTION public.handle_new_user() FROM PUBLIC, anon, authenticated;
REVOKE ALL ON FUNCTION public.handle_storage_video_upload() FROM PUBLIC, anon, authenticated;

-- Public SELECT policies also evaluate these helpers for anonymous requests.
-- Execution is therefore explicit for API roles; the functions themselves
-- enforce that only the current JWT subject can be inspected.
REVOKE ALL ON FUNCTION public.is_admin(uuid) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.is_teacher(uuid) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.is_admin(uuid) TO anon, authenticated, service_role;
GRANT EXECUTE ON FUNCTION public.is_teacher(uuid) TO anon, authenticated, service_role;
