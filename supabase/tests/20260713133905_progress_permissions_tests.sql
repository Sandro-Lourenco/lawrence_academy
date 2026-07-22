SELECT plan(1);

BEGIN;

DO $$
BEGIN
    IF NOT has_table_privilege('anon', 'public.modules', 'SELECT')
       OR NOT has_table_privilege('anon', 'public.lessons', 'SELECT') THEN
        RAISE EXCEPTION 'Public catalog read grants are missing';
    END IF;
    IF has_table_privilege('anon', 'public.modules', 'INSERT')
       OR has_table_privilege('anon', 'public.lessons', 'UPDATE') THEN
        RAISE EXCEPTION 'Anonymous catalog grants are excessive';
    END IF;
    IF NOT has_table_privilege('authenticated', 'public.lesson_progress', 'SELECT')
       OR NOT has_table_privilege('authenticated', 'public.lesson_progress', 'INSERT')
       OR has_table_privilege('authenticated', 'public.lesson_progress', 'UPDATE') THEN
        RAISE EXCEPTION 'Lesson progress grants do not match the canonical contract';
    END IF;
    IF has_table_privilege('authenticated', 'public.event_store', 'SELECT')
       OR has_table_privilege('authenticated', 'public.event_store', 'INSERT') THEN
        RAISE EXCEPTION 'Event store is exposed to authenticated clients';
    END IF;
    IF has_function_privilege(
        'authenticated',
        'public.merge_lesson_progress_event(uuid,uuid,uuid,integer,numeric,boolean,timestamptz,text,text,text,text,timestamptz,jsonb)',
        'EXECUTE'
    ) THEN
        RAISE EXCEPTION 'Canonical progress RPC is exposed to authenticated clients';
    END IF;
    IF NOT has_function_privilege(
        'service_role',
        'public.merge_lesson_progress_event(uuid,uuid,uuid,integer,numeric,boolean,timestamptz,text,text,text,text,timestamptz,jsonb)',
        'EXECUTE'
    ) THEN
        RAISE EXCEPTION 'Service role cannot execute canonical progress RPC';
    END IF;
END;
$$;

INSERT INTO auth.users (id, email, raw_user_meta_data)
VALUES
    ('81000000-0000-0000-0000-000000000001', 'b224-teacher@example.com', '{}'),
    ('81000000-0000-0000-0000-000000000002', 'b224-student@example.com', '{}');

INSERT INTO public.courses (
    id, instructor_id, title, slug, category, level, summary, status
) VALUES (
    '82000000-0000-0000-0000-000000000001',
    '81000000-0000-0000-0000-000000000001',
    'B2.24 Course', 'b224-course', 'modelagem', 'iniciante',
    'Progress permission test', 'published'
);

INSERT INTO public.modules (id, course_id, title, order_index)
VALUES (
    '83000000-0000-0000-0000-000000000001',
    '82000000-0000-0000-0000-000000000001',
    'B2.24 Module', 1
);

INSERT INTO public.lessons (
    id, module_id, course_id, title, duration_seconds, status
) VALUES (
    '84000000-0000-0000-0000-000000000001',
    '83000000-0000-0000-0000-000000000001',
    '82000000-0000-0000-0000-000000000001',
    'B2.24 Lesson', 1000, 'published'
);

SELECT public.merge_lesson_progress_event(
    '81000000-0000-0000-0000-000000000002',
    '82000000-0000-0000-0000-000000000001',
    '84000000-0000-0000-0000-000000000001',
    250, 25, FALSE, NULL,
    'b224-event-1', 'b224-key-1', 'b224-correlation-1', 'b224-device-1',
    NOW(), '{"progress_percentage":99}'::JSONB
);

DO $$
DECLARE
    v_percentage NUMERIC;
    v_audit_percentage NUMERIC;
BEGIN
    SELECT progress_percentage INTO v_percentage
    FROM public.lesson_progress
    WHERE student_id = '81000000-0000-0000-0000-000000000002';

    SELECT (payload ->> 'progress_percentage')::NUMERIC
    INTO v_audit_percentage
    FROM public.event_store
    WHERE event_id = 'b224-event-1';

    IF v_percentage <> 25 OR v_audit_percentage <> 25 THEN
        RAISE EXCEPTION 'Server-calculated percentage was not persisted consistently';
    END IF;
END;
$$;

DO $$
BEGIN
    BEGIN
        PERFORM public.merge_lesson_progress_event(
            '81000000-0000-0000-0000-000000000002',
            '82000000-0000-0000-0000-000000000001',
            '84000000-0000-0000-0000-000000000001',
            250, 50, FALSE, NULL,
            'b224-event-2', 'b224-key-2', 'b224-correlation-2', 'b224-device-1',
            NOW(), '{}'::JSONB
        );
        RAISE EXCEPTION 'Inconsistent client percentage was accepted';
    EXCEPTION WHEN check_violation THEN
        NULL;
    END;

    BEGIN
        PERFORM public.merge_lesson_progress_event(
            '81000000-0000-0000-0000-000000000002',
            '82000000-0000-0000-0000-000000000001',
            '84000000-0000-0000-0000-000000000001',
            1001, 100, FALSE, NULL,
            'b224-event-3', 'b224-key-3', 'b224-correlation-3', 'b224-device-1',
            NOW(), '{}'::JSONB
        );
        RAISE EXCEPTION 'Watched seconds above duration were accepted';
    EXCEPTION WHEN check_violation THEN
        NULL;
    END;
END;
$$;

ROLLBACK;

SELECT pass('All assertions completed');
SELECT * FROM finish();
