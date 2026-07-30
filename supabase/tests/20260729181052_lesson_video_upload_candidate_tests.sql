BEGIN;

SELECT plan(4);

SELECT has_function(
  'public',
  'register_lesson_video_upload_job',
  ARRAY['uuid', 'uuid', 'uuid', 'text', 'text']::name[],
  'backend can atomically register the lesson video candidate'
);

SELECT function_privs_are(
  'public',
  'register_lesson_video_upload_job',
  ARRAY['uuid', 'uuid', 'uuid', 'text', 'text']::name[],
  'anon',
  ARRAY[]::text[],
  'anonymous users cannot register video jobs'
);

SELECT function_privs_are(
  'public',
  'register_lesson_video_upload_job',
  ARRAY['uuid', 'uuid', 'uuid', 'text', 'text']::name[],
  'authenticated',
  ARRAY[]::text[],
  'authenticated clients cannot bypass the backend upload authorization'
);

SELECT function_privs_are(
  'public',
  'register_lesson_video_upload_job',
  ARRAY['uuid', 'uuid', 'uuid', 'text', 'text']::name[],
  'service_role',
  ARRAY['EXECUTE']::text[],
  'service role can register the job and lesson candidate'
);

SELECT * FROM finish();
ROLLBACK;
