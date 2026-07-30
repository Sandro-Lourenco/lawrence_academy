BEGIN;

-- The FastAPI subscription repository uses the service role after enforcing
-- ownership in its use cases. RLS remains enabled for direct client access.
REVOKE ALL ON TABLE public.subscriptions FROM service_role;
GRANT SELECT, INSERT, UPDATE ON TABLE public.subscriptions TO service_role;

COMMIT;
