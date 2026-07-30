-- Monotonic successor of 20260728120000_claim_video_processing_jobs.sql.
-- Adds lease-based recovery and worker fencing to the PostgreSQL-backed queue.

BEGIN;

ALTER TABLE public.video_processing_jobs
  ADD COLUMN IF NOT EXISTS claimed_by TEXT,
  ADD COLUMN IF NOT EXISTS lease_expires_at TIMESTAMPTZ,
  ADD COLUMN IF NOT EXISTS claim_attempts INTEGER NOT NULL DEFAULT 0;

ALTER TABLE public.video_processing_jobs
  DROP CONSTRAINT IF EXISTS video_processing_jobs_claim_attempts_nonnegative,
  ADD CONSTRAINT video_processing_jobs_claim_attempts_nonnegative
    CHECK (claim_attempts >= 0);

DROP INDEX IF EXISTS public.idx_vpj_claim_eligible;
CREATE INDEX idx_vpj_claim_eligible
  ON public.video_processing_jobs (
    status,
    next_retry_at,
    lease_expires_at,
    created_at,
    id
  )
  WHERE status IN (
    'uploaded',
    'processing_pending',
    'processing',
    'validating',
    'transcoding',
    'generating_hls',
    'generating_thumbnail'
  );

CREATE OR REPLACE FUNCTION public.claim_next_video_processing_job(
  p_worker_id TEXT,
  p_lease_seconds INTEGER DEFAULT 1800
)
RETURNS SETOF public.video_processing_jobs
LANGUAGE plpgsql
SECURITY INVOKER
SET search_path = public, pg_temp
AS $$
BEGIN
  IF NULLIF(BTRIM(p_worker_id), '') IS NULL THEN
    RAISE EXCEPTION 'worker_id is required' USING ERRCODE = '22023';
  END IF;
  IF p_lease_seconds < 60 OR p_lease_seconds > 3600 THEN
    RAISE EXCEPTION 'lease_seconds must be between 60 and 3600'
      USING ERRCODE = '22023';
  END IF;

  -- Exhausted jobs are terminalized before another worker can claim them.
  UPDATE public.video_processing_jobs
  SET status = 'dead_letter',
      lease_expires_at = NULL,
      claimed_by = NULL,
      updated_at = NOW(),
      error_message = COALESCE(
        error_message,
        'Processing lease expired after maximum retry attempts'
      )
  WHERE status IN (
      'processing',
      'validating',
      'transcoding',
      'generating_hls',
      'generating_thumbnail'
    )
    AND COALESCE(
      lease_expires_at,
      processing_started_at + MAKE_INTERVAL(secs => p_lease_seconds),
      updated_at + MAKE_INTERVAL(secs => p_lease_seconds)
    ) <= NOW()
    AND retry_count >= max_retries;

  RETURN QUERY
  WITH candidate AS (
    SELECT job.id, job.status AS previous_status
    FROM public.video_processing_jobs AS job
    WHERE
      job.status = 'uploaded'
      OR (
        job.status = 'processing_pending'
        AND COALESCE(job.next_retry_at, '-infinity'::TIMESTAMPTZ) <= NOW()
      )
      OR (
        job.status IN (
          'processing',
          'validating',
          'transcoding',
          'generating_hls',
          'generating_thumbnail'
        )
        AND COALESCE(
          job.lease_expires_at,
          job.processing_started_at + MAKE_INTERVAL(secs => p_lease_seconds),
          job.updated_at + MAKE_INTERVAL(secs => p_lease_seconds)
        ) <= NOW()
        AND job.retry_count < job.max_retries
      )
    ORDER BY job.created_at, job.id
    FOR UPDATE SKIP LOCKED
    LIMIT 1
  )
  UPDATE public.video_processing_jobs AS job
  SET status = 'processing',
      processing_started_at = NOW(),
      updated_at = NOW(),
      error_message = NULL,
      next_retry_at = NULL,
      claimed_by = BTRIM(p_worker_id),
      lease_expires_at = NOW() + MAKE_INTERVAL(secs => p_lease_seconds),
      claim_attempts = job.claim_attempts + 1,
      retry_count = job.retry_count + CASE
        WHEN candidate.previous_status IN (
          'processing',
          'validating',
          'transcoding',
          'generating_hls',
          'generating_thumbnail'
        ) THEN 1
        ELSE 0
      END
  FROM candidate
  WHERE job.id = candidate.id
  RETURNING job.*;
END;
$$;

-- Compatibility wrapper for older deployed workers during rolling updates.
CREATE OR REPLACE FUNCTION public.claim_next_video_processing_job()
RETURNS SETOF public.video_processing_jobs
LANGUAGE sql
SECURITY INVOKER
SET search_path = public, pg_temp
AS $$
  SELECT *
  FROM public.claim_next_video_processing_job('legacy-video-worker', 1800);
$$;

CREATE OR REPLACE FUNCTION public.renew_video_processing_job_lease(
  p_job_id UUID,
  p_worker_id TEXT,
  p_lease_seconds INTEGER DEFAULT 1800
)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY INVOKER
SET search_path = public, pg_temp
AS $$
DECLARE
  v_renewed UUID;
BEGIN
  IF NULLIF(BTRIM(p_worker_id), '') IS NULL THEN
    RAISE EXCEPTION 'worker_id is required' USING ERRCODE = '22023';
  END IF;
  IF p_lease_seconds < 60 OR p_lease_seconds > 3600 THEN
    RAISE EXCEPTION 'lease_seconds must be between 60 and 3600'
      USING ERRCODE = '22023';
  END IF;

  UPDATE public.video_processing_jobs
  SET lease_expires_at = NOW() + MAKE_INTERVAL(secs => p_lease_seconds),
      updated_at = NOW()
  WHERE id = p_job_id
    AND claimed_by = BTRIM(p_worker_id)
    AND status IN (
      'processing',
      'validating',
      'transcoding',
      'generating_hls',
      'generating_thumbnail'
    )
  RETURNING id INTO v_renewed;

  RETURN v_renewed IS NOT NULL;
END;
$$;

REVOKE ALL ON FUNCTION public.claim_next_video_processing_job(TEXT, INTEGER)
  FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.claim_next_video_processing_job(TEXT, INTEGER)
  TO service_role;

REVOKE ALL ON FUNCTION public.claim_next_video_processing_job()
  FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.claim_next_video_processing_job()
  TO service_role;

REVOKE ALL ON FUNCTION public.renew_video_processing_job_lease(UUID, TEXT, INTEGER)
  FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.renew_video_processing_job_lease(UUID, TEXT, INTEGER)
  TO service_role;

COMMIT;
