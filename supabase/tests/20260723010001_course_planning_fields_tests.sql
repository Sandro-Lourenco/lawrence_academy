SELECT plan(1);

DO $$
DECLARE
    missing_columns TEXT[];
    rls_enabled BOOLEAN;
BEGIN
    SELECT ARRAY_AGG(required.column_name)
    INTO missing_columns
    FROM (
        VALUES
            ('course_type'),
            ('subtitle'),
            ('language'),
            ('estimated_duration_minutes'),
            ('learning_objectives'),
            ('target_audience'),
            ('required_materials'),
            ('competencies'),
            ('expected_outcomes')
    ) AS required(column_name)
    WHERE NOT EXISTS (
        SELECT 1
        FROM information_schema.columns existing
        WHERE existing.table_schema = 'public'
          AND existing.table_name = 'courses'
          AND existing.column_name = required.column_name
    );

    IF missing_columns IS NOT NULL THEN
        RAISE EXCEPTION 'Missing course planning columns: %', missing_columns;
    END IF;

    SELECT relrowsecurity
    INTO rls_enabled
    FROM pg_class
    WHERE oid = 'public.courses'::regclass;

    IF NOT rls_enabled THEN
        RAISE EXCEPTION 'RLS was disabled on public.courses';
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM pg_constraint
        WHERE conrelid = 'public.courses'::regclass
          AND conname = 'courses_course_type_check'
          AND contype = 'c'
    ) THEN
        RAISE EXCEPTION 'Course type constraint is missing';
    END IF;
END;
$$;

SELECT pass('Course planning fields, constraints, and RLS are present');

SELECT * FROM finish();
