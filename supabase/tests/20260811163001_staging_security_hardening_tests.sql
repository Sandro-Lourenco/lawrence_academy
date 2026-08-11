BEGIN;
SELECT plan(4);

SELECT function_privs_are('public', 'get_primary_role', ARRAY['uuid']::name[], 'anon', ARRAY[]::text[], 'anonymous users cannot call get_primary_role');
SELECT function_privs_are('public', 'get_primary_role', ARRAY['uuid']::name[], 'authenticated', ARRAY[]::text[], 'authenticated users cannot call get_primary_role');

SELECT is(
    (SELECT proconfig::text FROM pg_proc WHERE oid = 'public.set_updated_at()'::regprocedure),
    '{"search_path=pg_catalog, public"}',
    'set_updated_at has an immutable search_path'
);

SELECT has_index('public', 'courses', 'idx_courses_instructor_id', 'courses instructor foreign key is indexed');

SELECT * FROM finish();
ROLLBACK;
