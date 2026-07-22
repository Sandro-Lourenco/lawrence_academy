SELECT plan(1);

BEGIN;

INSERT INTO auth.users (id, email, raw_user_meta_data)
VALUES
    ('71000000-0000-0000-0000-000000000001', 'progress-teacher@example.com', '{}'),
    ('71000000-0000-0000-0000-000000000002', 'progress-student@example.com', '{}'),
    ('71000000-0000-0000-0000-000000000003', 'progress-other@example.com', '{}');

UPDATE public.profiles
SET role = 'teacher'
WHERE id = '71000000-0000-0000-0000-000000000001';

INSERT INTO public.courses (
    id, instructor_id, title, slug, category, level, summary, status
) VALUES (
    '72000000-0000-0000-0000-000000000001',
    '71000000-0000-0000-0000-000000000001',
    'Progress Test Course', 'progress-test-course', 'modelagem',
    'iniciante', 'Progress test', 'published'
);

INSERT INTO public.modules (id, course_id, title, order_index)
VALUES (
    '73000000-0000-0000-0000-000000000001',
    '72000000-0000-0000-0000-000000000001',
    'Progress Module', 1
);

INSERT INTO public.lessons (
    id, module_id, course_id, title, duration_seconds, status, hls_storage_path
) VALUES (
    '74000000-0000-0000-0000-000000000001',
    '73000000-0000-0000-0000-000000000001',
    '72000000-0000-0000-0000-000000000001',
    'Progress Lesson', 1000, 'published', 'progress/master.m3u8'
);

SELECT public.merge_lesson_progress_event(
    '71000000-0000-0000-0000-000000000002',
    '72000000-0000-0000-0000-000000000001',
    '74000000-0000-0000-0000-000000000001',
    800, 80, FALSE, NULL,
    'event-high', 'key-high', 'correlation-high', 'device-a',
    NOW() - INTERVAL '1 minute',
    '{"source":"test-high"}'::jsonb
);

SELECT public.merge_lesson_progress_event(
    '71000000-0000-0000-0000-000000000002',
    '72000000-0000-0000-0000-000000000001',
    '74000000-0000-0000-0000-000000000001',
    200, 20, FALSE, NULL,
    'event-stale', 'key-stale', 'correlation-stale', 'device-b',
    NOW() - INTERVAL '5 minutes',
    '{"source":"test-stale"}'::jsonb
);

DO $$
DECLARE
    state public.lesson_progress%ROWTYPE;
BEGIN
    SELECT * INTO state
    FROM public.lesson_progress
    WHERE student_id = '71000000-0000-0000-0000-000000000002'
      AND lesson_id = '74000000-0000-0000-0000-000000000001';
    IF state.watched_seconds <> 800 OR state.progress_percentage <> 80 THEN
        RAISE EXCEPTION 'Out-of-order event decreased progress';
    END IF;
END $$;

-- A replay with the same key cannot mutate state.
SELECT public.merge_lesson_progress_event(
    '71000000-0000-0000-0000-000000000002',
    '72000000-0000-0000-0000-000000000001',
    '74000000-0000-0000-0000-000000000001',
    900, 90, FALSE, NULL,
    'event-replay', 'key-high', 'correlation-replay', 'device-a', NOW(),
    '{"source":"test-replay"}'::jsonb
);

DO $$
DECLARE
    percentage numeric;
    event_count integer;
BEGIN
    SELECT progress_percentage INTO percentage
    FROM public.lesson_progress
    WHERE student_id = '71000000-0000-0000-0000-000000000002';
    SELECT COUNT(*) INTO event_count
    FROM public.event_store
    WHERE user_id = '71000000-0000-0000-0000-000000000002';
    IF percentage <> 80 OR event_count <> 2 THEN
        RAISE EXCEPTION 'Idempotency replay changed state or audit count';
    END IF;
END $$;

SELECT public.merge_lesson_progress_event(
    '71000000-0000-0000-0000-000000000002',
    '72000000-0000-0000-0000-000000000001',
    '74000000-0000-0000-0000-000000000001',
    1000, 100, TRUE, NOW(),
    'event-complete', 'key-complete', 'correlation-complete', 'device-b', NOW(),
    '{"source":"test-complete"}'::jsonb
);

DO $$
DECLARE
    state public.lesson_progress%ROWTYPE;
BEGIN
    SELECT * INTO state FROM public.lesson_progress
    WHERE student_id = '71000000-0000-0000-0000-000000000002';
    IF NOT state.completed OR state.progress_percentage <> 100
       OR state.completed_at IS NULL THEN
        RAISE EXCEPTION 'Completion invariant was not enforced';
    END IF;
END $$;

SET LOCAL request.jwt.claim.sub = '71000000-0000-0000-0000-000000000003';
SET LOCAL role = 'authenticated';

DO $$
DECLARE
    visible_count integer;
BEGIN
    SELECT COUNT(*) INTO visible_count FROM public.lesson_progress;
    IF visible_count <> 0 THEN
        RAISE EXCEPTION 'RLS exposed another student progress';
    END IF;
END $$;

SET LOCAL role = 'postgres';

DO $$
BEGIN
    BEGIN
        INSERT INTO public.lesson_progress (
            student_id, course_id, lesson_id, watched_seconds,
            progress_percentage, completed
        ) VALUES (
            '71000000-0000-0000-0000-000000000003',
            '72000000-0000-0000-0000-000000000001',
            '74000000-0000-0000-0000-000000000001',
            -1, 101, FALSE
        );
        RAISE EXCEPTION 'Invalid progress constraints were bypassed';
    EXCEPTION WHEN check_violation THEN
        NULL;
    END;
END $$;

ROLLBACK;

SELECT pass('All assertions completed');
SELECT * FROM finish();
