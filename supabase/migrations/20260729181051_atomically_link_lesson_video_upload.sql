CREATE OR REPLACE FUNCTION public.register_lesson_video_upload_job(
  p_lesson_id UUID,
  p_course_id UUID,
  p_initiated_by UUID,
  p_idempotency_key TEXT,
  p_raw_video_path TEXT
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY INVOKER
SET search_path = ''
AS $$
DECLARE
  v_job public.video_processing_jobs%ROWTYPE;
  v_lesson_updated INTEGER;
BEGIN
  INSERT INTO public.video_processing_jobs (
    lesson_id,
    course_id,
    initiated_by,
    idempotency_key,
    raw_video_path,
    status
  )
  VALUES (
    p_lesson_id,
    p_course_id,
    p_initiated_by,
    p_idempotency_key,
    p_raw_video_path,
    'upload_pending'
  )
  ON CONFLICT (idempotency_key) DO NOTHING
  RETURNING * INTO v_job;

  IF v_job.id IS NULL THEN
    SELECT *
      INTO v_job
      FROM public.video_processing_jobs
     WHERE idempotency_key = p_idempotency_key;

    IF v_job.id IS NULL
       OR v_job.lesson_id IS DISTINCT FROM p_lesson_id
       OR v_job.course_id IS DISTINCT FROM p_course_id
       OR v_job.initiated_by IS DISTINCT FROM p_initiated_by
       OR v_job.raw_video_path IS DISTINCT FROM p_raw_video_path THEN
      RAISE EXCEPTION 'Idempotency key belongs to another video upload'
        USING ERRCODE = '23505';
    END IF;
  END IF;

  UPDATE public.lessons
     SET pending_upload_job_id = v_job.id,
         pending_raw_video_path = v_job.raw_video_path,
         updated_at = now()
   WHERE id = p_lesson_id
     AND course_id = p_course_id
     AND deleted_at IS NULL;
  GET DIAGNOSTICS v_lesson_updated = ROW_COUNT;

  IF v_lesson_updated <> 1 THEN
    RAISE EXCEPTION 'Lesson not found for video upload'
      USING ERRCODE = 'P0002';
  END IF;

  RETURN v_job.id;
END;
$$;

REVOKE ALL ON FUNCTION public.register_lesson_video_upload_job(
  UUID, UUID, UUID, TEXT, TEXT
) FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.register_lesson_video_upload_job(
  UUID, UUID, UUID, TEXT, TEXT
) TO service_role;

-- Repair the current candidate link for the latest unfinished upload of each
-- lesson. This is intentionally scoped to a NULL candidate so it never
-- replaces a newer upload selected by the application.
WITH latest_unfinished AS (
  SELECT DISTINCT ON (job.lesson_id)
         job.lesson_id,
         job.id,
         job.raw_video_path
    FROM public.video_processing_jobs AS job
   WHERE job.lesson_id IS NOT NULL
     AND job.asset_kind = 'lesson_video'
     AND job.status <> 'completed'
   ORDER BY job.lesson_id, job.created_at DESC
)
UPDATE public.lessons AS lesson
   SET pending_upload_job_id = latest_unfinished.id,
       pending_raw_video_path = latest_unfinished.raw_video_path,
       updated_at = now()
  FROM latest_unfinished
 WHERE lesson.id = latest_unfinished.lesson_id
   AND lesson.pending_upload_job_id IS NULL
   AND lesson.deleted_at IS NULL;
