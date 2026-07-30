BEGIN;

DO $$
BEGIN
  IF EXISTS (
    SELECT provider_subscription_id
    FROM public.subscriptions
    WHERE provider_subscription_id IS NOT NULL
    GROUP BY provider_subscription_id
    HAVING COUNT(*) > 1
  ) THEN
    RAISE EXCEPTION
      'Cannot enforce provider subscription id uniqueness while duplicates exist';
  END IF;
END
$$;

DROP INDEX IF EXISTS public.idx_subscriptions_provider_subscription_id;

ALTER TABLE public.subscriptions
  ADD CONSTRAINT subscriptions_provider_subscription_id_key
  UNIQUE (provider_subscription_id);

COMMIT;
