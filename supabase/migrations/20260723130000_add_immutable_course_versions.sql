CREATE TABLE IF NOT EXISTS public.course_versions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  course_id UUID NOT NULL REFERENCES public.courses(id) ON DELETE CASCADE,
  slug TEXT NOT NULL,
  version_number INTEGER NOT NULL CHECK (version_number > 0),
  snapshot JSONB NOT NULL,
  published_by UUID NOT NULL,
  change_summary TEXT,
  is_current BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (course_id, version_number)
);

CREATE UNIQUE INDEX IF NOT EXISTS idx_course_versions_one_current
  ON public.course_versions(course_id) WHERE is_current;
CREATE INDEX IF NOT EXISTS idx_course_versions_course_created
  ON public.course_versions(course_id, created_at DESC);
CREATE UNIQUE INDEX IF NOT EXISTS idx_course_versions_current_slug
  ON public.course_versions(slug) WHERE is_current;

ALTER TABLE public.course_versions ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public.course_versions FROM PUBLIC, anon, authenticated;
GRANT SELECT, INSERT, UPDATE ON public.course_versions TO service_role;

ALTER TABLE public.courses
  ADD COLUMN IF NOT EXISTS current_version_number INTEGER;

CREATE OR REPLACE FUNCTION public.publish_course_content(
  p_course_id UUID,
  p_actor_id UUID,
  p_change_summary TEXT DEFAULT NULL
)
RETURNS INTEGER
LANGUAGE plpgsql
SECURITY INVOKER
SET search_path = public
AS $$
DECLARE
  v_current public.content_status;
  v_version INTEGER;
  v_snapshot JSONB;
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

  SELECT
    (to_jsonb(c) - 'deleted_at') ||
    jsonb_build_object(
      'modules',
      COALESCE((
        SELECT jsonb_agg(
          (to_jsonb(m) - 'deleted_at') ||
          jsonb_build_object(
            'lessons',
            COALESCE((
              SELECT jsonb_agg(
                (to_jsonb(l) - 'deleted_at') ||
                jsonb_build_object(
                  'lesson_blocks',
                  COALESCE((
                    SELECT jsonb_agg(to_jsonb(b) - 'deleted_at' ORDER BY b.order_index)
                    FROM public.lesson_blocks b
                    WHERE b.lesson_id = l.id AND b.deleted_at IS NULL
                  ), '[]'::jsonb)
                )
                ORDER BY l.order_index
              )
              FROM public.lessons l
              WHERE l.module_id = m.id AND l.deleted_at IS NULL
            ), '[]'::jsonb)
          )
          ORDER BY m.order_index
        )
        FROM public.modules m
        WHERE m.course_id = c.id AND m.deleted_at IS NULL
      ), '[]'::jsonb)
    )
  INTO v_snapshot
  FROM public.courses c
  WHERE c.id = p_course_id;

  SELECT COALESCE(MAX(version_number), 0) + 1
  INTO v_version
  FROM public.course_versions
  WHERE course_id = p_course_id;

  UPDATE public.course_versions
  SET is_current = FALSE
  WHERE course_id = p_course_id AND is_current;

  v_snapshot := jsonb_set(v_snapshot, '{status}', '"published"'::jsonb);

  INSERT INTO public.course_versions(
    course_id, slug, version_number, snapshot, published_by, change_summary, is_current
  ) VALUES (
    p_course_id, v_snapshot->>'slug', v_version, v_snapshot, p_actor_id,
    NULLIF(trim(p_change_summary), ''), TRUE
  );

  UPDATE public.courses
  SET status = 'published',
      publication_requested_at = now(),
      published_at = COALESCE(published_at, now()),
      current_version_number = v_version,
      updated_at = now()
  WHERE id = p_course_id;

  IF v_current <> 'published' THEN
    INSERT INTO public.course_status_history(
      course_id, actor_id, from_status, to_status, reason
    ) VALUES (
      p_course_id, p_actor_id, v_current, 'published',
      COALESCE(NULLIF(trim(p_change_summary), ''), 'Publicação aprovada')
    );
  END IF;
  RETURN v_version;
END;
$$;

REVOKE ALL ON FUNCTION public.publish_course_content(UUID, UUID) FROM service_role;
DROP FUNCTION IF EXISTS public.publish_course_content(UUID, UUID);
REVOKE ALL ON FUNCTION public.publish_course_content(UUID, UUID, TEXT)
  FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.publish_course_content(UUID, UUID, TEXT)
  TO service_role;

DO $$
DECLARE
  v_course RECORD;
BEGIN
  FOR v_course IN
    SELECT c.id, c.instructor_id
    FROM public.courses c
    WHERE c.status = 'published'
      AND c.deleted_at IS NULL
      AND NOT EXISTS (
        SELECT 1
        FROM public.course_versions cv
        WHERE cv.course_id = c.id AND cv.is_current
      )
  LOOP
    PERFORM public.publish_course_content(
      v_course.id,
      v_course.instructor_id,
      'Versão inicial migrada'
    );
  END LOOP;
END;
$$;
