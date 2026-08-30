-- Course-completion prerequisites are relational objects, not free-form text.
-- General knowledge requirements remain in courses.requirements for compatibility.

CREATE TABLE public.course_prerequisites (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    course_id UUID NOT NULL
        REFERENCES public.courses(id) ON DELETE CASCADE,
    prerequisite_course_id UUID NOT NULL
        REFERENCES public.courses(id) ON DELETE RESTRICT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT course_prerequisites_unique_relation
        UNIQUE (course_id, prerequisite_course_id),
    CONSTRAINT course_prerequisites_no_self_reference
        CHECK (course_id <> prerequisite_course_id)
);

CREATE INDEX idx_course_prerequisites_required_course
    ON public.course_prerequisites (prerequisite_course_id, course_id);

CREATE TRIGGER trg_course_prerequisites_updated_at
BEFORE UPDATE ON public.course_prerequisites
FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

ALTER TABLE public.course_prerequisites ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public.course_prerequisites FROM PUBLIC, anon, authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.course_prerequisites TO service_role;

CREATE OR REPLACE FUNCTION public.set_course_prerequisites(
    p_course_id UUID,
    p_instructor_id UUID,
    p_prerequisite_ids UUID[] DEFAULT ARRAY[]::UUID[]
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY INVOKER
SET search_path = pg_catalog, public
AS $$
DECLARE
    v_ids UUID[] := COALESCE(p_prerequisite_ids, ARRAY[]::UUID[]);
    v_invalid_count INTEGER;
    v_result JSONB;
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM public.courses AS course
        WHERE course.id = p_course_id
          AND course.instructor_id = p_instructor_id
          AND course.deleted_at IS NULL
    ) THEN
        RAISE EXCEPTION 'course not found or instructor mismatch'
            USING ERRCODE = '42501';
    END IF;

    IF p_course_id = ANY(v_ids) THEN
        RAISE EXCEPTION 'a course cannot require itself'
            USING ERRCODE = '23514';
    END IF;

    IF CARDINALITY(v_ids) <> (
        SELECT COUNT(DISTINCT prerequisite_id)
        FROM UNNEST(v_ids) AS prerequisite_id
    ) THEN
        RAISE EXCEPTION 'duplicate prerequisite course'
            USING ERRCODE = '23505';
    END IF;

    SELECT COUNT(*)
    INTO v_invalid_count
    FROM UNNEST(v_ids) AS requested(prerequisite_id)
    LEFT JOIN public.courses AS prerequisite
      ON prerequisite.id = requested.prerequisite_id
     AND prerequisite.instructor_id = p_instructor_id
     AND prerequisite.deleted_at IS NULL
     AND prerequisite.status = 'published'
    WHERE prerequisite.id IS NULL;

    IF v_invalid_count > 0 THEN
        RAISE EXCEPTION 'prerequisite courses must exist, be published, and belong to the instructor'
            USING ERRCODE = '23503';
    END IF;

    IF EXISTS (
        WITH RECURSIVE dependency_path(course_id) AS (
            SELECT prerequisite_id
            FROM UNNEST(v_ids) AS prerequisite_id
            UNION
            SELECT relation.prerequisite_course_id
            FROM public.course_prerequisites AS relation
            JOIN dependency_path AS path
              ON relation.course_id = path.course_id
        )
        SELECT 1
        FROM dependency_path
        WHERE course_id = p_course_id
    ) THEN
        RAISE EXCEPTION 'course prerequisite cycle detected'
            USING ERRCODE = '23514';
    END IF;

    DELETE FROM public.course_prerequisites
    WHERE course_id = p_course_id
      AND prerequisite_course_id <> ALL(v_ids);

    INSERT INTO public.course_prerequisites (course_id, prerequisite_course_id)
    SELECT p_course_id, prerequisite_id
    FROM UNNEST(v_ids) AS prerequisite_id
    ON CONFLICT (course_id, prerequisite_course_id) DO NOTHING;

    SELECT COALESCE(
        JSONB_AGG(
            JSONB_BUILD_OBJECT(
                'id', prerequisite.id,
                'title', prerequisite.title,
                'slug', prerequisite.slug,
                'summary', prerequisite.summary,
                'category', prerequisite.category,
                'status', prerequisite.status,
                'thumbnail_url', prerequisite.thumbnail_url,
                'cover_image_path', prerequisite.cover_image_path
            )
            ORDER BY prerequisite.title
        ),
        '[]'::JSONB
    )
    INTO v_result
    FROM public.course_prerequisites AS relation
    JOIN public.courses AS prerequisite
      ON prerequisite.id = relation.prerequisite_course_id
    WHERE relation.course_id = p_course_id;

    RETURN v_result;
END;
$$;

REVOKE ALL ON FUNCTION public.set_course_prerequisites(UUID, UUID, UUID[])
    FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.set_course_prerequisites(UUID, UUID, UUID[])
    TO service_role;

-- Immutable versions receive the course objects before the snapshot is stored.
CREATE OR REPLACE FUNCTION public.enrich_course_version_prerequisites()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY INVOKER
SET search_path = pg_catalog, public
AS $$
DECLARE
    v_prerequisites JSONB;
BEGIN
    SELECT COALESCE(
        JSONB_AGG(
            JSONB_BUILD_OBJECT(
                'id', prerequisite.id,
                'title', prerequisite.title,
                'slug', prerequisite.slug,
                'summary', prerequisite.summary,
                'category', prerequisite.category,
                'status', prerequisite.status,
                'thumbnail_url', prerequisite.thumbnail_url,
                'cover_image_path', prerequisite.cover_image_path
            )
            ORDER BY prerequisite.title
        ),
        '[]'::JSONB
    )
    INTO v_prerequisites
    FROM public.course_prerequisites AS relation
    JOIN public.courses AS prerequisite
      ON prerequisite.id = relation.prerequisite_course_id
    WHERE relation.course_id = NEW.course_id;

    NEW.snapshot := JSONB_SET(
        NEW.snapshot,
        '{prerequisite_courses}',
        v_prerequisites,
        TRUE
    );
    RETURN NEW;
END;
$$;

REVOKE ALL ON FUNCTION public.enrich_course_version_prerequisites()
    FROM PUBLIC, anon, authenticated;

CREATE TRIGGER trg_enrich_course_version_prerequisites
BEFORE INSERT ON public.course_versions
FOR EACH ROW EXECUTE FUNCTION public.enrich_course_version_prerequisites();

-- Restoring a version also restores its prerequisite relations.
CREATE OR REPLACE FUNCTION public.restore_course_version_prerequisites()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY INVOKER
SET search_path = pg_catalog, public
AS $$
DECLARE
    v_instructor_id UUID;
    v_prerequisite_ids UUID[];
BEGIN
    SELECT course.instructor_id
    INTO v_instructor_id
    FROM public.courses AS course
    WHERE course.id = NEW.course_id;

    SELECT COALESCE(
        ARRAY_AGG((item->>'id')::UUID),
        ARRAY[]::UUID[]
    )
    INTO v_prerequisite_ids
    FROM public.course_versions AS version,
         JSONB_ARRAY_ELEMENTS(
             COALESCE(version.snapshot->'prerequisite_courses', '[]'::JSONB)
         ) AS item
    WHERE version.id = NEW.version_id;

    PERFORM public.set_course_prerequisites(
        NEW.course_id,
        v_instructor_id,
        v_prerequisite_ids
    );
    RETURN NEW;
END;
$$;

REVOKE ALL ON FUNCTION public.restore_course_version_prerequisites()
    FROM PUBLIC, anon, authenticated;

CREATE TRIGGER trg_restore_course_version_prerequisites
AFTER INSERT ON public.course_version_restores
FOR EACH ROW EXECUTE FUNCTION public.restore_course_version_prerequisites();

COMMENT ON TABLE public.course_prerequisites IS
    'Directed, cycle-free course completion prerequisites selected as course objects.';
