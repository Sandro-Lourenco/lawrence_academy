BEGIN;

SELECT plan(4);

SELECT has_function(
  'public',
  'claim_next_video_processing_job',
  ARRAY[]::name[],
  'video worker exposes an atomic claim function'
);

SELECT function_privs_are(
  'public',
  'claim_next_video_processing_job',
  ARRAY[]::name[],
  'anon',
  ARRAY[]::text[],
  'anonymous users cannot claim video jobs'
);

SELECT function_privs_are(
  'public',
  'claim_next_video_processing_job',
  ARRAY[]::name[],
  'authenticated',
  ARRAY[]::text[],
  'authenticated users cannot claim video jobs'
);

SELECT function_privs_are(
  'public',
  'claim_next_video_processing_job',
  ARRAY[]::name[],
  'service_role',
  ARRAY['EXECUTE']::text[],
  'only the backend worker role can claim video jobs'
);

SELECT * FROM finish();
ROLLBACK;
