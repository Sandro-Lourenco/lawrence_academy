BEGIN;
SELECT plan(19);

SELECT has_table('public', 'course_prerequisites', 'course prerequisite relation exists');
SELECT has_pk('public', 'course_prerequisites', 'relation has UUID primary key');
SELECT has_column('public', 'course_prerequisites', 'course_id', 'relation has course id');
SELECT has_column(
    'public', 'course_prerequisites', 'prerequisite_course_id',
    'relation has prerequisite course id'
);
SELECT col_is_fk('public', 'course_prerequisites', 'course_id', 'course id is a foreign key');
SELECT col_is_fk(
    'public', 'course_prerequisites', 'prerequisite_course_id',
    'prerequisite course id is a foreign key'
);
SELECT has_index(
    'public', 'course_prerequisites', 'idx_course_prerequisites_required_course',
    'reverse prerequisite lookups are indexed'
);
SELECT has_trigger(
    'public', 'course_versions', 'trg_enrich_course_version_prerequisites',
    'published snapshots contain prerequisite objects'
);
SELECT has_trigger(
    'public', 'course_version_restores', 'trg_restore_course_version_prerequisites',
    'restoring a snapshot restores prerequisites'
);
SELECT function_privs_are(
    'public', 'set_course_prerequisites', ARRAY['uuid', 'uuid', 'uuid[]'],
    'anon', ARRAY[]::TEXT[], 'anonymous users cannot mutate prerequisite relations'
);
SELECT function_privs_are(
    'public', 'set_course_prerequisites', ARRAY['uuid', 'uuid', 'uuid[]'],
    'authenticated', ARRAY[]::TEXT[], 'authenticated clients cannot bypass the backend'
);

SELECT results_eq(
    $$
      SELECT relrowsecurity
      FROM pg_class
      WHERE oid = 'public.course_prerequisites'::regclass
    $$,
    ARRAY[TRUE],
    'RLS is enabled on the exposed relation table'
);

SELECT table_privs_are(
    'public', 'course_prerequisites', 'authenticated', ARRAY[]::TEXT[],
    'authenticated clients have no direct table privileges'
);

INSERT INTO auth.users(id, email, raw_user_meta_data)
VALUES (
    '7a000000-0000-4000-8000-000000000001',
    'prerequisite-teacher@example.test',
    '{}'::JSONB
);
UPDATE public.profiles
SET role = 'teacher', full_name = 'Prerequisite Teacher'
WHERE id = '7a000000-0000-4000-8000-000000000001';

INSERT INTO public.courses(
    id, instructor_id, title, slug, category, level, summary, status, monthly_price
)
VALUES
    (
        '7a000000-0000-4000-8000-000000000011',
        '7a000000-0000-4000-8000-000000000001',
        'Curso avançado', 'curso-avancado-prerequisite-test', 'costura',
        'avancado', 'Curso avançado para teste relacional', 'published', 10
    ),
    (
        '7a000000-0000-4000-8000-000000000012',
        '7a000000-0000-4000-8000-000000000001',
        'Curso intermediário', 'curso-intermediario-prerequisite-test', 'costura',
        'intermediario', 'Curso intermediário para teste relacional', 'published', 10
    ),
    (
        '7a000000-0000-4000-8000-000000000013',
        '7a000000-0000-4000-8000-000000000001',
        'Curso básico', 'curso-basico-prerequisite-test', 'costura',
        'iniciante', 'Curso básico para teste relacional', 'published', 10
    );

SELECT lives_ok(
    $$SELECT public.set_course_prerequisites(
        '7a000000-0000-4000-8000-000000000011',
        '7a000000-0000-4000-8000-000000000001',
        ARRAY['7a000000-0000-4000-8000-000000000012']::UUID[]
    )$$,
    'a published course object can be selected as prerequisite'
);

SELECT results_eq(
    $$SELECT prerequisite_course_id
      FROM public.course_prerequisites
      WHERE course_id = '7a000000-0000-4000-8000-000000000011'$$,
    ARRAY['7a000000-0000-4000-8000-000000000012'::UUID],
    'the prerequisite is persisted by course id'
);

SELECT throws_ok(
    $$SELECT public.set_course_prerequisites(
        '7a000000-0000-4000-8000-000000000011',
        '7a000000-0000-4000-8000-000000000001',
        ARRAY['7a000000-0000-4000-8000-000000000011']::UUID[]
    )$$,
    '23514', 'a course cannot require itself',
    'a course cannot be its own prerequisite'
);

SELECT lives_ok(
    $$SELECT public.set_course_prerequisites(
        '7a000000-0000-4000-8000-000000000012',
        '7a000000-0000-4000-8000-000000000001',
        ARRAY['7a000000-0000-4000-8000-000000000013']::UUID[]
    )$$,
    'a second dependency edge can be created'
);

SELECT throws_ok(
    $$SELECT public.set_course_prerequisites(
        '7a000000-0000-4000-8000-000000000013',
        '7a000000-0000-4000-8000-000000000001',
        ARRAY['7a000000-0000-4000-8000-000000000011']::UUID[]
    )$$,
    '23514', 'course prerequisite cycle detected',
    'dependency cycles are rejected'
);

INSERT INTO public.course_versions(
    course_id, slug, version_number, snapshot, published_by, is_current
)
VALUES (
    '7a000000-0000-4000-8000-000000000011',
    'curso-avancado-prerequisite-test', 1, '{}'::JSONB,
    '7a000000-0000-4000-8000-000000000001', TRUE
);

SELECT is(
    (
        SELECT snapshot->'prerequisite_courses'->0->>'title'
        FROM public.course_versions
        WHERE course_id = '7a000000-0000-4000-8000-000000000011'
        ORDER BY version_number DESC
        LIMIT 1
    ),
    'Curso intermediário',
    'immutable snapshots contain the prerequisite course object'
);

SELECT * FROM finish();
ROLLBACK;
