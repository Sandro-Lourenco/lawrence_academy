BEGIN;
SELECT plan(6);
SELECT has_table('course_status_history');
SELECT has_column('course_status_history', 'actor_id');
SELECT has_index('course_status_history', 'idx_course_status_history_course_created');
SELECT has_function('public', 'transition_course_status', ARRAY['uuid','uuid','content_status','text']);
SELECT function_privs_are(
  'public', 'transition_course_status',
  ARRAY['uuid','uuid','content_status','text'],
  'service_role', ARRAY['EXECUTE']
);
SELECT function_privs_are(
  'public', 'transition_course_status',
  ARRAY['uuid','uuid','content_status','text'],
  'authenticated', ARRAY[]::text[]
);
SELECT * FROM finish();
ROLLBACK;
