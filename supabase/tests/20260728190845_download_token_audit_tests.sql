BEGIN;

SELECT plan(6);

SELECT has_table('public', 'download_tokens', 'download token audit table exists');
SELECT ok(
  (SELECT relrowsecurity FROM pg_class WHERE oid = 'public.download_tokens'::regclass),
  'download token audit has RLS enabled'
);
SELECT ok(
  NOT has_table_privilege('authenticated', 'public.download_tokens', 'SELECT'),
  'authenticated clients cannot read token audit records'
);
SELECT ok(has_table_privilege('service_role', 'public.download_tokens', 'SELECT'), 'backend reads token state');
SELECT ok(has_table_privilege('service_role', 'public.download_tokens', 'INSERT'), 'backend registers tokens');
SELECT ok(has_table_privilege('service_role', 'public.download_tokens', 'UPDATE'), 'backend consumes tokens');

SELECT * FROM finish();
ROLLBACK;
