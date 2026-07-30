CREATE TABLE IF NOT EXISTS public.course_version_restores (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  course_id UUID NOT NULL REFERENCES public.courses(id) ON DELETE CASCADE,
  version_id UUID NOT NULL REFERENCES public.course_versions(id) ON DELETE RESTRICT,
  actor_id UUID NOT NULL,
  reason TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_course_version_restores_course_created
  ON public.course_version_restores(course_id, created_at DESC);

ALTER TABLE public.course_version_restores ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public.course_version_restores FROM PUBLIC, anon, authenticated;
GRANT SELECT, INSERT ON public.course_version_restores TO service_role;

CREATE OR REPLACE FUNCTION public.restore_course_version_to_authoring(
  p_course_id UUID,
  p_version_id UUID,
  p_actor_id UUID,
  p_expected_updated_at TIMESTAMPTZ,
  p_reason TEXT DEFAULT NULL
)
RETURNS TIMESTAMPTZ
LANGUAGE plpgsql
SECURITY INVOKER
SET search_path = public
AS $$
DECLARE
  v_course public.courses%ROWTYPE;
  v_snapshot JSONB;
  v_module JSONB;
  v_lesson JSONB;
  v_block JSONB;
  v_restored_at TIMESTAMPTZ := clock_timestamp();
BEGIN
  SELECT * INTO v_course
  FROM public.courses
  WHERE id = p_course_id AND deleted_at IS NULL
  FOR UPDATE;

  IF NOT FOUND THEN RAISE EXCEPTION 'course not found' USING ERRCODE = 'P0002'; END IF;
  IF v_course.status = 'archived' THEN
    RAISE EXCEPTION 'archived course cannot restore a version' USING ERRCODE = 'P0001';
  END IF;
  IF v_course.updated_at IS DISTINCT FROM p_expected_updated_at THEN
    RAISE EXCEPTION 'authoring content changed; reload before restoring'
      USING ERRCODE = '40001';
  END IF;

  SELECT snapshot INTO v_snapshot
  FROM public.course_versions
  WHERE id = p_version_id AND course_id = p_course_id;
  IF v_snapshot IS NULL THEN
    RAISE EXCEPTION 'course version not found' USING ERRCODE = 'P0002';
  END IF;

  UPDATE public.courses SET
    title = v_snapshot->>'title',
    slug = v_snapshot->>'slug',
    summary = v_snapshot->>'summary',
    course_type = COALESCE(v_snapshot->>'course_type', course_type),
    subtitle = COALESCE(v_snapshot->>'subtitle', ''),
    language = COALESCE(v_snapshot->>'language', language),
    estimated_duration_minutes = (v_snapshot->>'estimated_duration_minutes')::INTEGER,
    category = (v_snapshot->>'category')::public.course_category,
    level = (v_snapshot->>'level')::public.course_level,
    description = v_snapshot->>'description',
    requirements = ARRAY(SELECT jsonb_array_elements_text(
      CASE WHEN jsonb_typeof(v_snapshot->'requirements') = 'array' THEN v_snapshot->'requirements' ELSE '[]' END)),
    learning_objectives = ARRAY(SELECT jsonb_array_elements_text(
      CASE WHEN jsonb_typeof(v_snapshot->'learning_objectives') = 'array' THEN v_snapshot->'learning_objectives' ELSE '[]' END)),
    target_audience = ARRAY(SELECT jsonb_array_elements_text(
      CASE WHEN jsonb_typeof(v_snapshot->'target_audience') = 'array' THEN v_snapshot->'target_audience' ELSE '[]' END)),
    required_materials = ARRAY(SELECT jsonb_array_elements_text(
      CASE WHEN jsonb_typeof(v_snapshot->'required_materials') = 'array' THEN v_snapshot->'required_materials' ELSE '[]' END)),
    competencies = ARRAY(SELECT jsonb_array_elements_text(
      CASE WHEN jsonb_typeof(v_snapshot->'competencies') = 'array' THEN v_snapshot->'competencies' ELSE '[]' END)),
    expected_outcomes = ARRAY(SELECT jsonb_array_elements_text(
      CASE WHEN jsonb_typeof(v_snapshot->'expected_outcomes') = 'array' THEN v_snapshot->'expected_outcomes' ELSE '[]' END)),
    thumbnail_url = v_snapshot->>'thumbnail_url',
    trailer_hls_path = v_snapshot->>'trailer_hls_path',
    cover_image_path = v_snapshot->>'cover_image_path',
    cover_alt_text = v_snapshot->>'cover_alt_text',
    cover_focal_x = COALESCE((v_snapshot->>'cover_focal_x')::NUMERIC, 0.5),
    cover_focal_y = COALESCE((v_snapshot->>'cover_focal_y')::NUMERIC, 0.5),
    cover_status = COALESCE(v_snapshot->>'cover_status', 'empty'),
    trailer_status = COALESCE(v_snapshot->>'trailer_status', 'empty'),
    monthly_price = COALESCE((v_snapshot->>'monthly_price')::NUMERIC, 0),
    promotional_monthly_price = (v_snapshot->>'promotional_monthly_price')::NUMERIC,
    promotion_starts_at = (v_snapshot->>'promotion_starts_at')::TIMESTAMPTZ,
    promotion_ends_at = (v_snapshot->>'promotion_ends_at')::TIMESTAMPTZ,
    certificate_enabled = COALESCE((v_snapshot->>'certificate_enabled')::BOOLEAN, TRUE),
    reviews_enabled = COALESCE((v_snapshot->>'reviews_enabled')::BOOLEAN, TRUE),
    comments_enabled = COALESCE((v_snapshot->>'comments_enabled')::BOOLEAN, TRUE),
    visibility = COALESCE(v_snapshot->>'visibility', 'public'),
    availability = COALESCE(v_snapshot->>'availability', 'immediate'),
    scheduled_publish_at = (v_snapshot->>'scheduled_publish_at')::TIMESTAMPTZ,
    updated_at = v_restored_at
  WHERE id = p_course_id;

  UPDATE public.lesson_blocks SET deleted_at = v_restored_at, updated_at = v_restored_at
  WHERE course_id = p_course_id AND deleted_at IS NULL;
  UPDATE public.lessons SET deleted_at = v_restored_at, updated_at = v_restored_at
  WHERE course_id = p_course_id AND deleted_at IS NULL;
  UPDATE public.modules SET deleted_at = v_restored_at, updated_at = v_restored_at
  WHERE course_id = p_course_id AND deleted_at IS NULL;

  FOR v_module IN SELECT value FROM jsonb_array_elements(COALESCE(v_snapshot->'modules', '[]'))
  LOOP
    INSERT INTO public.modules(id, course_id, title, order_index, description, status, deleted_at, updated_at)
    VALUES (
      (v_module->>'id')::UUID, p_course_id, v_module->>'title',
      COALESCE((v_module->>'order_index')::INTEGER, 0), v_module->>'description',
      COALESCE(v_module->>'status', 'draft'), NULL, v_restored_at
    )
    ON CONFLICT (id) DO UPDATE SET
      course_id = EXCLUDED.course_id, title = EXCLUDED.title,
      order_index = EXCLUDED.order_index, description = EXCLUDED.description,
      status = EXCLUDED.status, deleted_at = NULL, updated_at = v_restored_at;

    FOR v_lesson IN SELECT value FROM jsonb_array_elements(COALESCE(v_module->'lessons', '[]'))
    LOOP
      INSERT INTO public.lessons(
        id, module_id, course_id, title, description, order_index, duration_seconds,
        estimated_duration_minutes, is_required, hls_storage_path, material_pdf_url,
        status, deleted_at, updated_at
      ) VALUES (
        (v_lesson->>'id')::UUID, (v_module->>'id')::UUID, p_course_id,
        v_lesson->>'title', v_lesson->>'description',
        COALESCE((v_lesson->>'order_index')::INTEGER, 0),
        COALESCE((v_lesson->>'duration_seconds')::INTEGER, 0),
        (v_lesson->>'estimated_duration_minutes')::INTEGER,
        COALESCE((v_lesson->>'is_required')::BOOLEAN, TRUE),
        v_lesson->>'hls_storage_path', v_lesson->>'material_pdf_url',
        COALESCE((v_lesson->>'status')::public.content_status, 'draft'),
        NULL, v_restored_at
      )
      ON CONFLICT (id) DO UPDATE SET
        module_id = EXCLUDED.module_id, course_id = EXCLUDED.course_id,
        title = EXCLUDED.title, description = EXCLUDED.description,
        order_index = EXCLUDED.order_index, duration_seconds = EXCLUDED.duration_seconds,
        estimated_duration_minutes = EXCLUDED.estimated_duration_minutes,
        is_required = EXCLUDED.is_required, hls_storage_path = EXCLUDED.hls_storage_path,
        material_pdf_url = EXCLUDED.material_pdf_url, status = EXCLUDED.status,
        deleted_at = NULL, updated_at = v_restored_at;

      FOR v_block IN SELECT value FROM jsonb_array_elements(COALESCE(v_lesson->'lesson_blocks', '[]'))
      LOOP
        INSERT INTO public.lesson_blocks(
          id, lesson_id, course_id, block_type, content, order_index, status,
          deleted_at, updated_at
        ) VALUES (
          (v_block->>'id')::UUID, (v_lesson->>'id')::UUID, p_course_id,
          v_block->>'block_type', COALESCE(v_block->'content', '{}'::jsonb),
          COALESCE((v_block->>'order_index')::INTEGER, 0),
          COALESCE(v_block->>'status', 'draft'), NULL, v_restored_at
        )
        ON CONFLICT (id) DO UPDATE SET
          lesson_id = EXCLUDED.lesson_id, course_id = EXCLUDED.course_id,
          block_type = EXCLUDED.block_type, content = EXCLUDED.content,
          order_index = EXCLUDED.order_index, status = EXCLUDED.status,
          deleted_at = NULL, updated_at = v_restored_at;
      END LOOP;
    END LOOP;
  END LOOP;

  INSERT INTO public.course_version_restores(course_id, version_id, actor_id, reason)
  VALUES (p_course_id, p_version_id, p_actor_id, NULLIF(trim(p_reason), ''));

  RETURN v_restored_at;
END;
$$;

REVOKE ALL ON FUNCTION public.restore_course_version_to_authoring(
  UUID, UUID, UUID, TIMESTAMPTZ, TEXT
) FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.restore_course_version_to_authoring(
  UUID, UUID, UUID, TIMESTAMPTZ, TEXT
) TO service_role;
