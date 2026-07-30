BEGIN;

CREATE OR REPLACE FUNCTION public.claim_next_video_processing_job()
RETURNS SETOF public.video_processing_jobs
LANGUAGE sql
SECURITY INVOKER
SET search_path = public, pg_temp
AS $$
  WITH candidate AS (
    SELECT id
    FROM public.video_processing_jobs
    WHERE status = 'uploaded'
       OR (
         status = 'processing_pending'
         AND COALESCE(next_retry_at, '-infinity'::timestamptz) <= now()
       )
    ORDER BY created_at, id
    FOR UPDATE SKIP LOCKED
    LIMIT 1
  )
  UPDATE public.video_processing_jobs AS job
  SET status = 'processing',
      processing_started_at = now(),
      updated_at = now(),
      error_message = NULL
  FROM candidate
  WHERE job.id = candidate.id
  RETURNING job.*;
$$;

REVOKE ALL ON FUNCTION public.claim_next_video_processing_job() FROM PUBLIC;
REVOKE ALL ON FUNCTION public.claim_next_video_processing_job() FROM anon;
REVOKE ALL ON FUNCTION public.claim_next_video_processing_job() FROM authenticated;
GRANT EXECUTE ON FUNCTION public.claim_next_video_processing_job() TO service_role;

COMMIT;
