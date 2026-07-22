-- Emergency rollback for the B2.24 permission and progress hardening migration.
-- Apply only after stopping canonical progress writes.

GRANT SELECT, INSERT, UPDATE ON public.lesson_progress TO authenticated;
GRANT SELECT, INSERT ON public.event_store TO authenticated;

CREATE POLICY "students_update_own_progress"
    ON public.lesson_progress FOR UPDATE
    TO authenticated
    USING ((SELECT auth.uid()) = student_id)
    WITH CHECK ((SELECT auth.uid()) = student_id);

CREATE POLICY "users_insert_own_events"
    ON public.event_store FOR INSERT
    TO authenticated
    WITH CHECK ((SELECT auth.uid()) = user_id);

CREATE POLICY "users_select_own_events"
    ON public.event_store FOR SELECT
    TO authenticated
    USING ((SELECT auth.uid()) = user_id);

-- The hardened functions are intentionally retained because reverting their data
-- validation would reintroduce invalid progress. Restore the prior function bodies
-- only from the preceding migration if application rollback requires it.
