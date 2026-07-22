-- Course access is always scoped to the authenticated user. The function is
-- SECURITY DEFINER only because lesson RLS must inspect subscriptions without
-- recursively depending on the caller's subscription visibility.
CREATE OR REPLACE FUNCTION public.has_active_course_access(
    p_user_id UUID,
    p_course_id UUID
)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = pg_catalog, public
AS $$
    SELECT p_user_id IS NOT NULL
       AND p_course_id IS NOT NULL
       AND p_user_id = (SELECT auth.uid())
       AND (
            EXISTS (
                SELECT 1
                FROM public.courses AS c
                WHERE c.id = p_course_id
                  AND c.status = 'published'
                  AND c.deleted_at IS NULL
                  AND c.monthly_price <= 0
            )
            OR EXISTS (
                SELECT 1
                FROM public.subscriptions AS s
                WHERE s.student_id = p_user_id
                  AND s.course_id = p_course_id
                  AND s.deleted_at IS NULL
                  AND s.status IN ('active', 'trialing', 'past_due')
                  AND s.current_period_end + INTERVAL '5 days' > NOW()
            )
       );
$$;

REVOKE ALL ON FUNCTION public.has_active_course_access(UUID, UUID) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.has_active_course_access(UUID, UUID) FROM anon;
-- Lesson RLS is also evaluated for anonymous catalog previews. PostgreSQL may
-- evaluate this predicate before the preview branch, so anon needs EXECUTE.
-- The function remains safe for anon because it only returns true when the
-- supplied user id equals auth.uid(); auth.uid() is NULL for anonymous calls.
GRANT EXECUTE ON FUNCTION public.has_active_course_access(UUID, UUID)
    TO anon, authenticated;
