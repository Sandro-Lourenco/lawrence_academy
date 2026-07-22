-- Emergency rollback for 20260713020147.
-- Run only after confirming event_store did not predate this migration.

DROP FUNCTION IF EXISTS public.merge_lesson_progress_event(
    UUID, UUID, UUID, INTEGER, NUMERIC, BOOLEAN, TIMESTAMPTZ,
    TEXT, TEXT, TEXT, TEXT, TIMESTAMPTZ, JSONB
);
DROP TABLE IF EXISTS public.event_store;

DROP TRIGGER IF EXISTS trg_lesson_progress_updated_at
    ON public.lesson_progress;
DROP INDEX IF EXISTS public.idx_lesson_progress_lesson;

ALTER TABLE public.lesson_progress
    DROP CONSTRAINT IF EXISTS lesson_progress_watched_seconds_nonnegative,
    DROP CONSTRAINT IF EXISTS lesson_progress_percentage_range,
    DROP CONSTRAINT IF EXISTS lesson_progress_completion_consistent;

DROP POLICY IF EXISTS "students_select_own_progress" ON public.lesson_progress;
DROP POLICY IF EXISTS "students_insert_own_progress" ON public.lesson_progress;
DROP POLICY IF EXISTS "students_update_own_progress" ON public.lesson_progress;
DROP POLICY IF EXISTS "admins_manage_lesson_progress" ON public.lesson_progress;

CREATE POLICY "student_all_own_progress" ON public.lesson_progress
    FOR ALL USING (auth.uid() = student_id);
CREATE POLICY "admin_all_progress" ON public.lesson_progress
    FOR ALL USING (public.is_admin(auth.uid()));

REVOKE INSERT, UPDATE ON public.lesson_progress FROM authenticated;
