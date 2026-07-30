BEGIN;

SELECT plan(3);

SELECT ok(
  has_table_privilege('service_role', 'public.subscriptions', 'SELECT'),
  'backend service role can read subscriptions'
);

SELECT ok(
  has_table_privilege('service_role', 'public.subscriptions', 'INSERT'),
  'backend service role can create subscriptions after payment'
);

SELECT ok(
  has_table_privilege('service_role', 'public.subscriptions', 'UPDATE'),
  'backend service role can update subscription lifecycle'
);

SELECT * FROM finish();
ROLLBACK;
