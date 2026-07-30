BEGIN;
SELECT plan(21);

SELECT table_privs_are('public', 'courses', 'service_role',
  ARRAY['SELECT','INSERT','UPDATE']);
SELECT table_privs_are('public', 'modules', 'service_role',
  ARRAY['SELECT','INSERT','UPDATE']);
SELECT table_privs_are('public', 'lessons', 'service_role',
  ARRAY['SELECT','INSERT','UPDATE']);
SELECT table_privs_are('public', 'lesson_blocks', 'service_role',
  ARRAY['SELECT','INSERT','UPDATE']);
SELECT ok(has_table_privilege('service_role', 'public.courses', 'SELECT'));
SELECT ok(has_table_privilege('service_role', 'public.courses', 'INSERT'));
SELECT ok(has_table_privilege('service_role', 'public.courses', 'UPDATE'));
SELECT ok(NOT has_table_privilege('service_role', 'public.courses', 'DELETE'));
SELECT ok(has_table_privilege('service_role', 'public.modules', 'SELECT,INSERT,UPDATE'));
SELECT ok(NOT has_table_privilege('service_role', 'public.modules', 'DELETE'));
SELECT ok(has_table_privilege('service_role', 'public.lessons', 'SELECT,INSERT,UPDATE'));
SELECT ok(NOT has_table_privilege('service_role', 'public.lessons', 'DELETE'));
SELECT ok(has_table_privilege('service_role', 'public.lesson_blocks', 'SELECT,INSERT,UPDATE'));
SELECT ok(NOT has_table_privilege('service_role', 'public.lesson_blocks', 'DELETE'));
SELECT ok(NOT has_table_privilege('anon', 'public.lesson_blocks', 'INSERT,UPDATE,DELETE'));
SELECT ok(NOT has_table_privilege('authenticated', 'public.lesson_blocks', 'INSERT,UPDATE,DELETE'));
SELECT table_privs_are('public', 'video_processing_jobs', 'service_role',
  ARRAY['SELECT','INSERT','UPDATE']);
SELECT ok(has_table_privilege('service_role', 'public.video_processing_jobs', 'SELECT'));
SELECT ok(has_table_privilege('service_role', 'public.video_processing_jobs', 'INSERT'));
SELECT ok(has_table_privilege('service_role', 'public.video_processing_jobs', 'UPDATE'));
SELECT ok(NOT has_table_privilege('service_role', 'public.video_processing_jobs', 'DELETE'));

SELECT * FROM finish();
ROLLBACK;
