-- Jobs recovered from the thumbnail defect could exhaust their retries before
-- the missing lesson candidate link was repaired. Requeue only the job that is
-- now explicitly selected by its lesson and failed with that known stale-link
-- error; unrelated dead letters remain terminal.
UPDATE public.video_processing_jobs AS job
   SET status = 'processing_pending',
       retry_count = 0,
       next_retry_at = now(),
       error_message = NULL,
       last_error = NULL,
       claimed_by = NULL,
       lease_expires_at = NULL,
       updated_at = now()
  FROM public.lessons AS lesson
 WHERE lesson.pending_upload_job_id = job.id
   AND job.status = 'dead_letter'
   AND job.asset_kind = 'lesson_video'
   AND (
     COALESCE(job.error_message, '') ILIKE '%não aceita mais o job%'
     OR COALESCE(job.last_error, '') ILIKE '%não aceita mais o job%'
   );
