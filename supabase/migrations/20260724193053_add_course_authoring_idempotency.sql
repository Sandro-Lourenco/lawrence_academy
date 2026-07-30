ALTER TABLE public.courses
  ADD COLUMN IF NOT EXISTS authoring_revision BIGINT NOT NULL DEFAULT 0;

CREATE TABLE public.course_authoring_idempotency_requests (
  actor_id UUID NOT NULL,
  operation_scope TEXT NOT NULL,
  idempotency_key TEXT NOT NULL,
  request_hash TEXT NOT NULL,
  resource_id UUID NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  PRIMARY KEY (actor_id, operation_scope, idempotency_key)
);
ALTER TABLE public.course_authoring_idempotency_requests ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public.course_authoring_idempotency_requests
  FROM PUBLIC, anon, authenticated;
GRANT SELECT, INSERT ON public.course_authoring_idempotency_requests TO service_role;

CREATE OR REPLACE FUNCTION public.register_course_authoring_request(
  p_actor_id UUID,
  p_operation_scope TEXT,
  p_idempotency_key TEXT,
  p_request_hash TEXT,
  p_resource_id UUID
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY INVOKER
SET search_path = public
AS $$
DECLARE
  v_request public.course_authoring_idempotency_requests%ROWTYPE;
BEGIN
  INSERT INTO public.course_authoring_idempotency_requests(
    actor_id, operation_scope, idempotency_key, request_hash, resource_id
  ) VALUES (
    p_actor_id, p_operation_scope, p_idempotency_key, p_request_hash, p_resource_id
  )
  ON CONFLICT (actor_id, operation_scope, idempotency_key) DO NOTHING;

  SELECT * INTO STRICT v_request
  FROM public.course_authoring_idempotency_requests
  WHERE actor_id = p_actor_id
    AND operation_scope = p_operation_scope
    AND idempotency_key = p_idempotency_key;

  IF v_request.request_hash IS DISTINCT FROM p_request_hash THEN
    RAISE EXCEPTION 'Idempotency-Key was reused with a different request'
      USING ERRCODE = 'P0001';
  END IF;
  RETURN v_request.resource_id;
END;
$$;
REVOKE ALL ON FUNCTION public.register_course_authoring_request(
  UUID, TEXT, TEXT, TEXT, UUID
) FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.register_course_authoring_request(
  UUID, TEXT, TEXT, TEXT, UUID
) TO service_role;

CREATE OR REPLACE FUNCTION public.bump_course_authoring_revision()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY INVOKER
SET search_path = public
AS $$
DECLARE
  v_course_id UUID := COALESCE(NEW.course_id, OLD.course_id);
BEGIN
  UPDATE public.courses
  SET authoring_revision = authoring_revision + 1,
      updated_at = clock_timestamp()
  WHERE id = v_course_id;
  RETURN COALESCE(NEW, OLD);
END;
$$;

CREATE TRIGGER bump_course_revision_from_modules
AFTER INSERT OR UPDATE OR DELETE ON public.modules
FOR EACH ROW EXECUTE FUNCTION public.bump_course_authoring_revision();
CREATE TRIGGER bump_course_revision_from_lessons
AFTER INSERT OR UPDATE OR DELETE ON public.lessons
FOR EACH ROW EXECUTE FUNCTION public.bump_course_authoring_revision();
CREATE TRIGGER bump_course_revision_from_lesson_blocks
AFTER INSERT OR UPDATE OR DELETE ON public.lesson_blocks
FOR EACH ROW EXECUTE FUNCTION public.bump_course_authoring_revision();

CREATE TABLE public.course_publication_requests (
  course_id UUID NOT NULL REFERENCES public.courses(id) ON DELETE CASCADE,
  actor_id UUID NOT NULL,
  idempotency_key TEXT NOT NULL,
  request_hash TEXT NOT NULL,
  version_number INTEGER NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  PRIMARY KEY (course_id, actor_id, idempotency_key),
  FOREIGN KEY (course_id, version_number)
    REFERENCES public.course_versions(course_id, version_number) ON DELETE RESTRICT
);

ALTER TABLE public.course_publication_requests ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public.course_publication_requests FROM PUBLIC, anon, authenticated;
GRANT SELECT, INSERT ON public.course_publication_requests TO service_role;

CREATE OR REPLACE FUNCTION public.publish_course_idempotent(
  p_course_id UUID,
  p_actor_id UUID,
  p_change_summary TEXT DEFAULT NULL,
  p_idempotency_key TEXT DEFAULT NULL,
  p_request_hash TEXT DEFAULT NULL,
  p_expected_updated_at TIMESTAMPTZ DEFAULT NULL
)
RETURNS INTEGER
LANGUAGE plpgsql
SECURITY INVOKER
SET search_path = public
AS $$
DECLARE
  v_course public.courses%ROWTYPE;
  v_replayed_version INTEGER;
  v_version INTEGER;
BEGIN
  SELECT * INTO v_course
  FROM public.courses
  WHERE id = p_course_id AND deleted_at IS NULL
  FOR UPDATE;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'course not found' USING ERRCODE = 'P0002';
  END IF;
  IF p_actor_id IS DISTINCT FROM v_course.instructor_id
     AND NOT public.is_admin(p_actor_id) THEN
    RAISE EXCEPTION 'actor cannot publish this course' USING ERRCODE = '42501';
  END IF;

  IF p_idempotency_key IS NOT NULL THEN
    SELECT version_number INTO v_replayed_version
    FROM public.course_publication_requests
    WHERE course_id = p_course_id
      AND actor_id = p_actor_id
      AND idempotency_key = p_idempotency_key;
    IF FOUND THEN
      IF (SELECT request_hash FROM public.course_publication_requests
          WHERE course_id = p_course_id AND actor_id = p_actor_id
            AND idempotency_key = p_idempotency_key)
         IS DISTINCT FROM p_request_hash THEN
        RAISE EXCEPTION 'Idempotency-Key was reused with a different request'
          USING ERRCODE = 'P0001';
      END IF;
      RETURN v_replayed_version;
    END IF;
  END IF;

  IF p_expected_updated_at IS NOT NULL
     AND v_course.updated_at IS DISTINCT FROM p_expected_updated_at THEN
    RAISE EXCEPTION 'authoring content changed; reload before publishing'
      USING ERRCODE = '40001';
  END IF;

  v_version := public.publish_course_content(
    p_course_id, p_actor_id, p_change_summary
  );

  IF p_idempotency_key IS NOT NULL THEN
    INSERT INTO public.course_publication_requests(
      course_id, idempotency_key, actor_id, request_hash, version_number
    ) VALUES (
      p_course_id, p_idempotency_key, p_actor_id, p_request_hash, v_version
    );
  END IF;

  RETURN v_version;
END;
$$;

REVOKE ALL ON FUNCTION public.publish_course_idempotent(
  UUID, UUID, TEXT, TEXT, TEXT, TIMESTAMPTZ
) FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.publish_course_idempotent(
  UUID, UUID, TEXT, TEXT, TEXT, TIMESTAMPTZ
) TO service_role;
