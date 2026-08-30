BEGIN;

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

  -- A newer upload replaces the previous candidate. Terminalize queued jobs
  -- that can no longer be activated before spending CPU on transcoding them.
  UPDATE public.video_processing_jobs AS job
  SET status = 'failed',
      lease_expires_at = NULL,
      claimed_by = NULL,
      next_retry_at = NULL,
      updated_at = NOW(),
      error_message = 'Upload substituído por uma versão mais recente.',
      last_error = 'Upload substituído por uma versão mais recente.'
  WHERE job.status IN ('uploaded', 'processing_pending')
    AND NOT (
      (
        job.asset_kind = 'lesson_video'
        AND EXISTS (
          SELECT 1
          FROM public.lessons AS lesson
          WHERE lesson.id = job.lesson_id
            AND lesson.pending_upload_job_id = job.id
        )
      )
      OR (
        job.asset_kind = 'course_trailer'
        AND EXISTS (
          SELECT 1
          FROM public.courses AS course
          WHERE course.id = job.course_id
            AND course.trailer_upload_job_id = job.id
            AND course.deleted_at IS NULL
        )
      )
    );

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
    WHERE (
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
    )
    AND (
      (
        job.asset_kind = 'lesson_video'
        AND EXISTS (
          SELECT 1
          FROM public.lessons AS lesson
          WHERE lesson.id = job.lesson_id
            AND lesson.pending_upload_job_id = job.id
        )
      )
      OR (
        job.asset_kind = 'course_trailer'
        AND EXISTS (
          SELECT 1
          FROM public.courses AS course
          WHERE course.id = job.course_id
            AND course.trailer_upload_job_id = job.id
            AND course.deleted_at IS NULL
        )
      )
    )
    ORDER BY job.created_at, job.id
    FOR UPDATE OF job SKIP LOCKED
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

CREATE OR REPLACE FUNCTION public.claim_next_video_processing_job()
RETURNS SETOF public.video_processing_jobs
LANGUAGE sql
SECURITY INVOKER
SET search_path = public, pg_temp
AS $$
  SELECT *
  FROM public.claim_next_video_processing_job('legacy-video-worker', 1800);
$$;

REVOKE ALL ON FUNCTION public.claim_next_video_processing_job(TEXT, INTEGER)
  FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.claim_next_video_processing_job(TEXT, INTEGER)
  TO service_role;

REVOKE ALL ON FUNCTION public.claim_next_video_processing_job()
  FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.claim_next_video_processing_job()
  TO service_role;

COMMIT;
