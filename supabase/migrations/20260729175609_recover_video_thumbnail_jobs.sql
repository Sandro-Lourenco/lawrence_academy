-- Recover only jobs stranded by the known ffmpeg multi-output frame specifier
-- defect. Genuine validation/transcoding failures remain terminal.
WITH recovered AS (
  UPDATE public.video_processing_jobs
  SET status = 'processing_pending',
      retry_count = 0,
      next_retry_at = now(),
      error_message = NULL,
      last_error = NULL,
      claimed_by = NULL,
      lease_expires_at = NULL,
      updated_at = now()
  WHERE status = 'dead_letter'
    AND (
      COALESCE(error_message, '') ILIKE '%poster de pré-visualização%'
      OR COALESCE(error_message, '') ILIKE '%frames:v:1%'
      OR COALESCE(last_error, '') ILIKE '%frames:v:1%'
    )
  RETURNING id, course_id, asset_kind
)
UPDATE public.courses AS course
SET trailer_status = 'uploaded',
    updated_at = now()
FROM recovered
WHERE recovered.asset_kind = 'course_trailer'
  AND course.id = recovered.course_id
  AND course.trailer_upload_job_id = recovered.id;
