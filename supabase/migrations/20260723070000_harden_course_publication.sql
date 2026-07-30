ALTER TABLE public.courses
  ADD COLUMN IF NOT EXISTS publication_requested_at TIMESTAMPTZ,
  ADD COLUMN IF NOT EXISTS published_at TIMESTAMPTZ;
CREATE INDEX IF NOT EXISTS idx_courses_publication_status ON public.courses(status,published_at) WHERE deleted_at IS NULL;

CREATE OR REPLACE FUNCTION public.publish_course_content(p_course_id UUID)
RETURNS VOID
LANGUAGE plpgsql
SECURITY INVOKER
SET search_path = public
AS $$
BEGIN
  UPDATE public.modules SET status = 'ready', updated_at = now()
  WHERE course_id = p_course_id AND deleted_at IS NULL;
  UPDATE public.lessons SET status = 'published', updated_at = now()
  WHERE course_id = p_course_id AND deleted_at IS NULL;
  UPDATE public.lesson_blocks SET status = 'ready', updated_at = now()
  WHERE course_id = p_course_id AND deleted_at IS NULL;
  UPDATE public.courses
  SET status = 'published', publication_requested_at = now(),
      published_at = now(), updated_at = now()
  WHERE id = p_course_id AND deleted_at IS NULL;
  IF NOT FOUND THEN RAISE EXCEPTION 'course not found'; END IF;
END;
$$;

REVOKE ALL ON FUNCTION public.publish_course_content(UUID) FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.publish_course_content(UUID) TO service_role;
