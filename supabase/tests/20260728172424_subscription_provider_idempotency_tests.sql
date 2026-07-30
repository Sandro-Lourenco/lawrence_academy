BEGIN;

SELECT plan(2);

SELECT isnt_empty(
  $$
    SELECT 1
    FROM pg_constraint
    WHERE conrelid = 'public.subscriptions'::regclass
      AND conname = 'subscriptions_provider_subscription_id_key'
      AND contype = 'u'
  $$,
  'provider subscription id is protected by a unique constraint'
);

SELECT ok(
  (
    SELECT NOT indexrel.indnullsnotdistinct
    FROM pg_constraint constraint_row
    JOIN pg_index indexrel
      ON indexrel.indexrelid = constraint_row.conindid
    WHERE constraint_row.conrelid = 'public.subscriptions'::regclass
      AND constraint_row.conname = 'subscriptions_provider_subscription_id_key'
  ),
  'unique provider subscription ids still allow multiple null values'
);

SELECT * FROM finish();
ROLLBACK;
