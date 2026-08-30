BEGIN;

SELECT plan(3);

SELECT has_function(
  'public',
  'enforce_task_attempt_limit',
  ARRAY[]::TEXT[],
  'task attempt enforcement function exists'
);

SELECT trigger_is(
  'public',
  'task_submissions',
  'trg_enforce_task_attempt_limit',
  'public',
  'enforce_task_attempt_limit',
  'attempt enforcement runs on task submissions'
);

SELECT function_privs_are(
  'public',
  'enforce_task_attempt_limit',
  ARRAY[]::TEXT[],
  'anon',
  ARRAY[]::TEXT[],
  'anonymous users cannot execute the trigger function directly'
);

SELECT * FROM finish();
ROLLBACK;
