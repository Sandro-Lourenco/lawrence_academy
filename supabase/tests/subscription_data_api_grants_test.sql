BEGIN;
SELECT plan(4);

SELECT ok(
  (SELECT relrowsecurity
   FROM pg_class
   WHERE oid = 'public.subscriptions'::regclass),
  'subscriptions keeps RLS enabled'
);
SELECT ok(
  has_table_privilege('authenticated', 'public.subscriptions', 'SELECT'),
  'authenticated can query subscriptions through the Data API'
);
SELECT ok(
  NOT has_table_privilege('anon', 'public.subscriptions', 'SELECT'),
  'anonymous clients cannot query subscriptions'
);
SELECT ok(
  NOT has_table_privilege('authenticated', 'public.subscriptions', 'INSERT')
  AND NOT has_table_privilege('authenticated', 'public.subscriptions', 'UPDATE')
  AND NOT has_table_privilege('authenticated', 'public.subscriptions', 'DELETE'),
  'authenticated clients cannot mutate financial subscription state'
);

SELECT * FROM finish();
ROLLBACK;
