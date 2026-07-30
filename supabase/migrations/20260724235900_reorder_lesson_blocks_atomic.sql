CREATE OR REPLACE FUNCTION public.reorder_lesson_blocks_atomic(
  p_course_id UUID,
  p_lesson_id UUID,
  p_actor_id UUID,
  p_block_ids UUID[],
  p_expected_revision BIGINT
)
RETURNS BIGINT
LANGUAGE plpgsql
SECURITY INVOKER
SET search_path = public
AS $$
DECLARE
  v_course public.courses%ROWTYPE;
  v_active_count INTEGER;
  v_distinct_count INTEGER;
  v_matching_count INTEGER;
  v_revision BIGINT;
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
    RAISE EXCEPTION 'actor cannot reorder this course' USING ERRCODE = '42501';
  END IF;
  IF v_course.authoring_revision IS DISTINCT FROM p_expected_revision THEN
    RAISE EXCEPTION 'authoring content changed; reload before reordering'
      USING ERRCODE = '40001';
  END IF;
  IF NOT EXISTS (
    SELECT 1 FROM public.lessons
    WHERE id = p_lesson_id
      AND course_id = p_course_id
      AND deleted_at IS NULL
  ) THEN
    RAISE EXCEPTION 'lesson not found in course' USING ERRCODE = 'P0002';
  END IF;

  SELECT count(*) INTO v_active_count
  FROM public.lesson_blocks
  WHERE lesson_id = p_lesson_id
    AND course_id = p_course_id
    AND deleted_at IS NULL;
  SELECT count(DISTINCT block_id) INTO v_distinct_count
  FROM unnest(COALESCE(p_block_ids, ARRAY[]::UUID[])) AS requested(block_id);
  SELECT count(*) INTO v_matching_count
  FROM public.lesson_blocks
  WHERE lesson_id = p_lesson_id
    AND course_id = p_course_id
    AND deleted_at IS NULL
    AND id = ANY(COALESCE(p_block_ids, ARRAY[]::UUID[]));

  IF cardinality(COALESCE(p_block_ids, ARRAY[]::UUID[])) <> v_active_count
     OR v_distinct_count <> v_active_count
     OR v_matching_count <> v_active_count THEN
    RAISE EXCEPTION 'block_ids must contain every active lesson block exactly once'
      USING ERRCODE = 'P0001';
  END IF;

  UPDATE public.lesson_blocks AS block
  SET order_index = requested.position - 1
  FROM unnest(p_block_ids) WITH ORDINALITY AS requested(block_id, position)
  WHERE block.id = requested.block_id
    AND block.lesson_id = p_lesson_id
    AND block.course_id = p_course_id
    AND block.deleted_at IS NULL;

  SELECT authoring_revision INTO v_revision
  FROM public.courses WHERE id = p_course_id;
  RETURN v_revision;
END;
$$;

REVOKE ALL ON FUNCTION public.reorder_lesson_blocks_atomic(
  UUID, UUID, UUID, UUID[], BIGINT
) FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.reorder_lesson_blocks_atomic(
  UUID, UUID, UUID, UUID[], BIGINT
) TO service_role;
