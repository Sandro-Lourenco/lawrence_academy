BEGIN;
SELECT plan(8);
SELECT has_table('course_versions');
SELECT has_column('course_versions', 'snapshot');
SELECT has_column('courses', 'current_version_number');
SELECT has_index('course_versions', 'idx_course_versions_one_current');
SELECT has_index('course_versions', 'idx_course_versions_current_slug');
SELECT has_function(
  'public', 'publish_course_content', ARRAY['uuid','uuid','text']
);
SELECT function_privs_are(
  'public', 'publish_course_content', ARRAY['uuid','uuid','text'],
  'service_role', ARRAY['EXECUTE']
);
SELECT function_privs_are(
  'public', 'publish_course_content', ARRAY['uuid','uuid','text'],
  'authenticated', ARRAY[]::text[]
);
SELECT * FROM finish();
ROLLBACK;
