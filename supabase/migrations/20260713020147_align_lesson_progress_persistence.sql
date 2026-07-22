-- B2 lesson progress persistence alignment.
-- Additive only: no existing column or row is removed.

UPDATE public.lesson_progress
SET
    watched_seconds = GREATEST(COALESCE(watched_seconds, 0), 0),
    progress_percentage = LEAST(
        GREATEST(COALESCE(progress_percentage, 0), 0),
        100
    ),
    completed = COALESCE(completed, FALSE),
    completed_at = CASE
        WHEN COALESCE(completed, FALSE)
            THEN COALESCE(completed_at, updated_at, NOW())
        ELSE NULL
    END,
    last_synced_at = COALESCE(last_synced_at, NOW()),
    created_at = COALESCE(created_at, NOW()),
    updated_at = COALESCE(updated_at, NOW());

ALTER TABLE public.lesson_progress
    ALTER COLUMN watched_seconds SET DEFAULT 0,
    ALTER COLUMN watched_seconds SET NOT NULL,
    ALTER COLUMN progress_percentage SET DEFAULT 0,
    ALTER COLUMN progress_percentage SET NOT NULL,
    ALTER COLUMN last_synced_at SET DEFAULT NOW(),
    ALTER COLUMN last_synced_at SET NOT NULL;

ALTER TABLE public.lesson_progress
    ADD CONSTRAINT lesson_progress_watched_seconds_nonnegative
        CHECK (watched_seconds >= 0) NOT VALID,
    ADD CONSTRAINT lesson_progress_percentage_range
        CHECK (progress_percentage >= 0 AND progress_percentage <= 100) NOT VALID,
    ADD CONSTRAINT lesson_progress_completion_consistent
        CHECK (
            (completed = FALSE AND completed_at IS NULL)
            OR
            (completed = TRUE AND completed_at IS NOT NULL AND progress_percentage = 100)
        ) NOT VALID;

ALTER TABLE public.lesson_progress
    VALIDATE CONSTRAINT lesson_progress_watched_seconds_nonnegative;
ALTER TABLE public.lesson_progress
    VALIDATE CONSTRAINT lesson_progress_percentage_range;
ALTER TABLE public.lesson_progress
    VALIDATE CONSTRAINT lesson_progress_completion_consistent;

CREATE INDEX IF NOT EXISTS idx_lesson_progress_lesson
    ON public.lesson_progress(lesson_id);

DROP TRIGGER IF EXISTS trg_lesson_progress_updated_at ON public.lesson_progress;
CREATE TRIGGER trg_lesson_progress_updated_at
    BEFORE UPDATE ON public.lesson_progress
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

DROP POLICY IF EXISTS "student_all_own_progress" ON public.lesson_progress;
DROP POLICY IF EXISTS "admin_all_progress" ON public.lesson_progress;

CREATE POLICY "students_select_own_progress"
    ON public.lesson_progress FOR SELECT
    TO authenticated
    USING ((SELECT auth.uid()) = student_id);

CREATE POLICY "students_insert_own_progress"
    ON public.lesson_progress FOR INSERT
    TO authenticated
    WITH CHECK ((SELECT auth.uid()) = student_id);

CREATE POLICY "students_update_own_progress"
    ON public.lesson_progress FOR UPDATE
    TO authenticated
    USING ((SELECT auth.uid()) = student_id)
    WITH CHECK ((SELECT auth.uid()) = student_id);

CREATE POLICY "admins_manage_lesson_progress"
    ON public.lesson_progress FOR ALL
    TO authenticated
    USING (public.is_admin((SELECT auth.uid())))
    WITH CHECK (public.is_admin((SELECT auth.uid())));

REVOKE ALL ON public.lesson_progress FROM anon;
GRANT SELECT, INSERT, UPDATE ON public.lesson_progress TO authenticated;

CREATE TABLE IF NOT EXISTS public.event_store (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    event_id TEXT NOT NULL UNIQUE,
    idempotency_key TEXT NOT NULL,
    correlation_id TEXT NOT NULL,
    request_id TEXT,
    device_id TEXT NOT NULL,
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    course_id UUID REFERENCES public.courses(id) ON DELETE CASCADE,
    lesson_id UUID REFERENCES public.lessons(id) ON DELETE CASCADE,
    event_type TEXT NOT NULL,
    payload JSONB NOT NULL,
    occurred_at TIMESTAMPTZ NOT NULL,
    recorded_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    origin TEXT NOT NULL,
    schema_version INTEGER NOT NULL DEFAULT 1,
    CONSTRAINT event_store_user_idempotency_unique
        UNIQUE (user_id, idempotency_key),
    CONSTRAINT event_store_schema_version_positive
        CHECK (schema_version > 0)
);

CREATE INDEX IF NOT EXISTS idx_event_store_user_device
    ON public.event_store(user_id, device_id);
CREATE INDEX IF NOT EXISTS idx_event_store_correlation
    ON public.event_store(correlation_id);
CREATE INDEX IF NOT EXISTS idx_event_store_user_occurred
    ON public.event_store(user_id, occurred_at DESC);

ALTER TABLE public.event_store ENABLE ROW LEVEL SECURITY;

CREATE POLICY "users_insert_own_events"
    ON public.event_store FOR INSERT
    TO authenticated
    WITH CHECK ((SELECT auth.uid()) = user_id);

CREATE POLICY "users_select_own_events"
    ON public.event_store FOR SELECT
    TO authenticated
    USING ((SELECT auth.uid()) = user_id);

REVOKE UPDATE, DELETE, TRUNCATE ON public.event_store
    FROM anon, authenticated;
GRANT SELECT, INSERT ON public.event_store TO authenticated;

CREATE OR REPLACE FUNCTION public.merge_lesson_progress_event(
    p_student_id UUID,
    p_course_id UUID,
    p_lesson_id UUID,
    p_watched_seconds INTEGER,
    p_progress_percentage NUMERIC,
    p_completed BOOLEAN,
    p_completed_at TIMESTAMPTZ,
    p_event_id TEXT,
    p_idempotency_key TEXT,
    p_correlation_id TEXT,
    p_device_id TEXT,
    p_occurred_at TIMESTAMPTZ,
    p_payload JSONB
)
RETURNS SETOF public.lesson_progress
LANGUAGE plpgsql
SECURITY INVOKER
SET search_path = ''
AS $$
DECLARE
    v_inserted_event UUID;
BEGIN
    IF p_watched_seconds < 0
        OR p_progress_percentage < 0
        OR p_progress_percentage > 100 THEN
        RAISE EXCEPTION 'INVALID_PROGRESS';
    END IF;

    INSERT INTO public.event_store (
        event_id,
        idempotency_key,
        correlation_id,
        device_id,
        user_id,
        course_id,
        lesson_id,
        event_type,
        payload,
        occurred_at,
        origin
    ) VALUES (
        p_event_id,
        p_idempotency_key,
        p_correlation_id,
        p_device_id,
        p_student_id,
        p_course_id,
        p_lesson_id,
        CASE WHEN p_completed THEN 'LESSON_COMPLETED' ELSE 'UPDATE_LESSON_PROGRESS' END,
        p_payload,
        p_occurred_at,
        'offline_sync'
    )
    ON CONFLICT DO NOTHING
    RETURNING id INTO v_inserted_event;

    IF v_inserted_event IS NOT NULL THEN
        INSERT INTO public.lesson_progress (
            student_id,
            course_id,
            lesson_id,
            watched_seconds,
            progress_percentage,
            completed,
            completed_at,
            last_synced_at
        ) VALUES (
            p_student_id,
            p_course_id,
            p_lesson_id,
            p_watched_seconds,
            CASE WHEN p_completed THEN 100 ELSE p_progress_percentage END,
            p_completed,
            CASE
                WHEN p_completed THEN COALESCE(p_completed_at, NOW())
                ELSE NULL
            END,
            NOW()
        )
        ON CONFLICT (student_id, lesson_id) DO UPDATE
        SET
            course_id = EXCLUDED.course_id,
            watched_seconds = GREATEST(
                public.lesson_progress.watched_seconds,
                EXCLUDED.watched_seconds
            ),
            progress_percentage = CASE
                WHEN public.lesson_progress.completed OR EXCLUDED.completed THEN 100
                ELSE GREATEST(
                    public.lesson_progress.progress_percentage,
                    EXCLUDED.progress_percentage
                )
            END,
            completed = public.lesson_progress.completed OR EXCLUDED.completed,
            completed_at = CASE
                WHEN public.lesson_progress.completed_at IS NOT NULL
                    THEN public.lesson_progress.completed_at
                WHEN EXCLUDED.completed
                    THEN COALESCE(EXCLUDED.completed_at, NOW())
                ELSE NULL
            END,
            last_synced_at = NOW(),
            updated_at = NOW();
    END IF;

    RETURN QUERY
    SELECT progress.*
    FROM public.lesson_progress AS progress
    WHERE progress.student_id = p_student_id
      AND progress.lesson_id = p_lesson_id;
END;
$$;

REVOKE ALL ON FUNCTION public.merge_lesson_progress_event(
    UUID, UUID, UUID, INTEGER, NUMERIC, BOOLEAN, TIMESTAMPTZ,
    TEXT, TEXT, TEXT, TEXT, TIMESTAMPTZ, JSONB
) FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.merge_lesson_progress_event(
    UUID, UUID, UUID, INTEGER, NUMERIC, BOOLEAN, TIMESTAMPTZ,
    TEXT, TEXT, TEXT, TEXT, TIMESTAMPTZ, JSONB
) TO service_role;
