-- B2.24 progress hardening and least-privilege Data API permissions.

REVOKE ALL ON public.courses FROM anon, authenticated;
GRANT SELECT ON public.courses TO anon, authenticated;

GRANT SELECT ON public.profiles TO authenticated;
GRANT SELECT ON public.profile_public_view TO anon, authenticated;

REVOKE ALL ON public.modules FROM anon, authenticated;
GRANT SELECT ON public.modules TO anon, authenticated;

REVOKE ALL ON public.lessons FROM anon, authenticated;
GRANT SELECT ON public.lessons TO anon, authenticated;

REVOKE ALL ON public.lesson_progress FROM anon, authenticated;
GRANT SELECT, INSERT ON public.lesson_progress TO authenticated;
DROP POLICY IF EXISTS "students_update_own_progress" ON public.lesson_progress;

REVOKE ALL ON public.event_store FROM anon, authenticated;
DROP POLICY IF EXISTS "users_insert_own_events" ON public.event_store;
DROP POLICY IF EXISTS "users_select_own_events" ON public.event_store;

CREATE OR REPLACE FUNCTION public.check_progress_course_integrity()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY INVOKER
SET search_path = pg_catalog, public
AS $$
DECLARE
    v_lesson_course_id UUID;
    v_duration_seconds INTEGER;
BEGIN
    SELECT lesson.course_id, lesson.duration_seconds
    INTO v_lesson_course_id, v_duration_seconds
    FROM public.lessons AS lesson
    WHERE lesson.id = NEW.lesson_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION USING ERRCODE = '23503', MESSAGE = 'LESSON_NOT_FOUND';
    END IF;
    IF NEW.course_id <> v_lesson_course_id THEN
        RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'LESSON_COURSE_MISMATCH';
    END IF;
    IF v_duration_seconds IS NULL OR v_duration_seconds <= 0 THEN
        RAISE EXCEPTION USING
            ERRCODE = '23514', MESSAGE = 'LESSON_DURATION_UNAVAILABLE';
    END IF;
    IF NEW.watched_seconds < 0 OR NEW.watched_seconds > v_duration_seconds THEN
        RAISE EXCEPTION USING
            ERRCODE = '23514', MESSAGE = 'WATCHED_SECONDS_OUT_OF_RANGE';
    END IF;
    IF NEW.completed AND NEW.watched_seconds < v_duration_seconds THEN
        RAISE EXCEPTION USING
            ERRCODE = '23514', MESSAGE = 'COMPLETION_REQUIRES_FULL_DURATION';
    END IF;

    NEW.progress_percentage := ROUND(
        NEW.watched_seconds::NUMERIC * 100 / v_duration_seconds,
        2
    );
    IF NEW.completed THEN
        NEW.progress_percentage := 100;
        IF TG_OP = 'UPDATE' THEN
            NEW.completed_at := COALESCE(OLD.completed_at, NEW.completed_at, NOW());
        ELSE
            NEW.completed_at := COALESCE(NEW.completed_at, NOW());
        END IF;
    END IF;
    RETURN NEW;
END;
$$;

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
    v_lesson_course_id UUID;
    v_duration_seconds INTEGER;
    v_progress_percentage NUMERIC(5, 2);
BEGIN
    SELECT lesson.course_id, lesson.duration_seconds
    INTO v_lesson_course_id, v_duration_seconds
    FROM public.lessons AS lesson
    WHERE lesson.id = p_lesson_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION USING ERRCODE = '23503', MESSAGE = 'LESSON_NOT_FOUND';
    END IF;
    IF p_course_id <> v_lesson_course_id THEN
        RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'LESSON_COURSE_MISMATCH';
    END IF;
    IF v_duration_seconds IS NULL OR v_duration_seconds <= 0 THEN
        RAISE EXCEPTION USING
            ERRCODE = '23514', MESSAGE = 'LESSON_DURATION_UNAVAILABLE';
    END IF;
    IF p_watched_seconds < 0 OR p_watched_seconds > v_duration_seconds THEN
        RAISE EXCEPTION USING
            ERRCODE = '23514', MESSAGE = 'WATCHED_SECONDS_OUT_OF_RANGE';
    END IF;
    IF p_completed AND p_watched_seconds < v_duration_seconds THEN
        RAISE EXCEPTION USING
            ERRCODE = '23514', MESSAGE = 'COMPLETION_REQUIRES_FULL_DURATION';
    END IF;

    v_progress_percentage := ROUND(
        p_watched_seconds::NUMERIC * 100 / v_duration_seconds,
        2
    );
    IF p_progress_percentage IS NOT NULL
       AND ABS(p_progress_percentage - v_progress_percentage) > 0.01 THEN
        RAISE EXCEPTION USING
            ERRCODE = '23514', MESSAGE = 'PROGRESS_PERCENTAGE_INCONSISTENT';
    END IF;

    INSERT INTO public.event_store (
        event_id, idempotency_key, correlation_id, device_id, user_id,
        course_id, lesson_id, event_type, payload, occurred_at, origin
    ) VALUES (
        p_event_id, p_idempotency_key, p_correlation_id, p_device_id,
        p_student_id, p_course_id, p_lesson_id,
        CASE WHEN p_completed THEN 'LESSON_COMPLETED' ELSE 'UPDATE_LESSON_PROGRESS' END,
        COALESCE(p_payload, '{}'::JSONB) || JSONB_BUILD_OBJECT(
            'watched_seconds', p_watched_seconds,
            'progress_percentage', v_progress_percentage
        ),
        p_occurred_at, 'offline_sync'
    )
    ON CONFLICT DO NOTHING
    RETURNING id INTO v_inserted_event;

    IF v_inserted_event IS NOT NULL THEN
        INSERT INTO public.lesson_progress (
            student_id, course_id, lesson_id, watched_seconds,
            progress_percentage, completed, completed_at, last_synced_at
        ) VALUES (
            p_student_id, p_course_id, p_lesson_id, p_watched_seconds,
            v_progress_percentage, p_completed,
            CASE WHEN p_completed THEN COALESCE(p_completed_at, NOW()) END,
            NOW()
        )
        ON CONFLICT (student_id, lesson_id) DO UPDATE
        SET
            course_id = EXCLUDED.course_id,
            watched_seconds = GREATEST(
                public.lesson_progress.watched_seconds,
                EXCLUDED.watched_seconds
            ),
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

REVOKE ALL ON FUNCTION public.check_progress_course_integrity() FROM PUBLIC;
REVOKE ALL ON FUNCTION public.merge_lesson_progress_event(
    UUID, UUID, UUID, INTEGER, NUMERIC, BOOLEAN, TIMESTAMPTZ,
    TEXT, TEXT, TEXT, TEXT, TIMESTAMPTZ, JSONB
) FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.merge_lesson_progress_event(
    UUID, UUID, UUID, INTEGER, NUMERIC, BOOLEAN, TIMESTAMPTZ,
    TEXT, TEXT, TEXT, TEXT, TIMESTAMPTZ, JSONB
) TO service_role;
