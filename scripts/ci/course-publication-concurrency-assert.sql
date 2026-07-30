\set ON_ERROR_STOP on

DO $$
DECLARE
  v_versions INTEGER;
  v_current_versions INTEGER;
  v_requests INTEGER;
  v_history INTEGER;
  v_course_version INTEGER;
  v_request_version INTEGER;
BEGIN
  SELECT count(*), count(*) FILTER (WHERE is_current)
  INTO v_versions, v_current_versions
  FROM public.course_versions
  WHERE course_id = '90100000-0000-0000-0000-000000000001';

  SELECT count(*), min(version_number)
  INTO v_requests, v_request_version
  FROM public.course_publication_requests
  WHERE course_id = '90100000-0000-0000-0000-000000000001'
    AND actor_id = '90100000-0000-0000-0000-000000000002'
    AND idempotency_key = encode(
      digest('concurrent-publication-attempt-0001', 'sha256'),
      'hex'
    );

  SELECT count(*)
  INTO v_history
  FROM public.course_status_history
  WHERE course_id = '90100000-0000-0000-0000-000000000001'
    AND to_status = 'published';

  SELECT current_version_number
  INTO v_course_version
  FROM public.courses
  WHERE id = '90100000-0000-0000-0000-000000000001';

  IF v_versions <> 1 THEN
    RAISE EXCEPTION 'expected one version, found %', v_versions;
  END IF;
  IF v_current_versions <> 1 THEN
    RAISE EXCEPTION 'expected one current version, found %', v_current_versions;
  END IF;
  IF v_requests <> 1 THEN
    RAISE EXCEPTION 'expected one publication request, found %', v_requests;
  END IF;
  IF v_history <> 1 THEN
    RAISE EXCEPTION 'expected one publication history row, found %', v_history;
  END IF;
  IF v_course_version IS DISTINCT FROM v_request_version THEN
    RAISE EXCEPTION
      'course/request version mismatch: course %, request %',
      v_course_version,
      v_request_version;
  END IF;
END;
$$;
