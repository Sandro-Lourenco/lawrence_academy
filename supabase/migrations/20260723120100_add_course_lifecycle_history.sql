CREATE TABLE IF NOT EXISTS public.course_status_history (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  course_id UUID NOT NULL REFERENCES public.courses(id) ON DELETE CASCADE,
  actor_id UUID NOT NULL,
  from_status public.content_status NOT NULL,
  to_status public.content_status NOT NULL,
  reason TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_course_status_history_course_created
  ON public.course_status_history(course_id, created_at DESC);

ALTER TABLE public.course_status_history ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public.course_status_history FROM PUBLIC, anon, authenticated;
GRANT SELECT, INSERT ON public.course_status_history TO service_role;

CREATE OR REPLACE FUNCTION public.transition_course_status(
  p_course_id UUID,
  p_actor_id UUID,
  p_target_status public.content_status,
  p_reason TEXT DEFAULT NULL
)
RETURNS public.content_status
LANGUAGE plpgsql
SECURITY INVOKER
SET search_path = public
AS $$
DECLARE
  v_current public.content_status;
BEGIN
  SELECT status INTO v_current
  FROM public.courses
  WHERE id = p_course_id
  FOR UPDATE;
  IF v_current IS NULL THEN RAISE EXCEPTION 'course not found'; END IF;

  IF NOT (
    (v_current = 'published' AND p_target_status IN ('unpublished', 'archived')) OR
    (v_current = 'unpublished' AND p_target_status IN ('archived', 'draft')) OR
    (v_current IN ('draft', 'reviewing') AND p_target_status = 'archived') OR
    (v_current = 'archived' AND p_target_status = 'unpublished')
  ) THEN
    RAISE EXCEPTION 'invalid course status transition: % -> %', v_current, p_target_status;
  END IF;

  UPDATE public.courses
  SET status = p_target_status,
      deleted_at = CASE WHEN p_target_status = 'archived' THEN now() ELSE NULL END,
      updated_at = now()
  WHERE id = p_course_id;

  INSERT INTO public.course_status_history(
    course_id, actor_id, from_status, to_status, reason
  ) VALUES (
    p_course_id, p_actor_id, v_current, p_target_status, NULLIF(trim(p_reason), '')
  );
  RETURN p_target_status;
END;
$$;

REVOKE ALL ON FUNCTION public.transition_course_status(
  UUID, UUID, public.content_status, TEXT
) FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.transition_course_status(
  UUID, UUID, public.content_status, TEXT
) TO service_role;

CREATE OR REPLACE FUNCTION public.publish_course_content(
  p_course_id UUID,
  p_actor_id UUID
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY INVOKER
SET search_path = public
AS $$
DECLARE
  v_current public.content_status;
BEGIN
  SELECT status INTO v_current
  FROM public.courses
  WHERE id = p_course_id AND deleted_at IS NULL
  FOR UPDATE;
  IF v_current IS NULL THEN RAISE EXCEPTION 'course not found'; END IF;

  UPDATE public.modules SET status = 'ready', updated_at = now()
  WHERE course_id = p_course_id AND deleted_at IS NULL;
  UPDATE public.lessons SET status = 'published', updated_at = now()
  WHERE course_id = p_course_id AND deleted_at IS NULL;
  UPDATE public.lesson_blocks SET status = 'ready', updated_at = now()
  WHERE course_id = p_course_id AND deleted_at IS NULL;
  UPDATE public.courses
  SET status = 'published', publication_requested_at = now(),
      published_at = now(), updated_at = now()
  WHERE id = p_course_id;

  IF v_current <> 'published' THEN
    INSERT INTO public.course_status_history(
      course_id, actor_id, from_status, to_status, reason
    ) VALUES (p_course_id, p_actor_id, v_current, 'published', 'Publicação aprovada');
  END IF;
END;
$$;

REVOKE ALL ON FUNCTION public.publish_course_content(UUID) FROM service_role;
DROP FUNCTION IF EXISTS public.publish_course_content(UUID);
REVOKE ALL ON FUNCTION public.publish_course_content(UUID, UUID)
  FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.publish_course_content(UUID, UUID)
  TO service_role;
