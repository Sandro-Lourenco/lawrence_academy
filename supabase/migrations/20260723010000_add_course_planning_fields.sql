-- Phase 1 of the teacher authoring studio: structured course planning.
-- Additive defaults preserve every existing draft and published course.

ALTER TABLE public.courses
    ADD COLUMN IF NOT EXISTS course_type TEXT NOT NULL DEFAULT 'complete',
    ADD COLUMN IF NOT EXISTS subtitle VARCHAR(160) NOT NULL DEFAULT '',
    ADD COLUMN IF NOT EXISTS language VARCHAR(10) NOT NULL DEFAULT 'pt-BR',
    ADD COLUMN IF NOT EXISTS estimated_duration_minutes INTEGER,
    ADD COLUMN IF NOT EXISTS learning_objectives TEXT[] NOT NULL DEFAULT '{}',
    ADD COLUMN IF NOT EXISTS target_audience TEXT[] NOT NULL DEFAULT '{}',
    ADD COLUMN IF NOT EXISTS required_materials TEXT[] NOT NULL DEFAULT '{}',
    ADD COLUMN IF NOT EXISTS competencies TEXT[] NOT NULL DEFAULT '{}',
    ADD COLUMN IF NOT EXISTS expected_outcomes TEXT[] NOT NULL DEFAULT '{}';

ALTER TABLE public.courses
    DROP CONSTRAINT IF EXISTS courses_course_type_check,
    DROP CONSTRAINT IF EXISTS courses_language_check,
    DROP CONSTRAINT IF EXISTS courses_estimated_duration_check,
    ADD CONSTRAINT courses_course_type_check
        CHECK (course_type IN ('complete', 'quick', 'workshop')),
    ADD CONSTRAINT courses_language_check
        CHECK (language IN ('pt-BR', 'en', 'es')),
    ADD CONSTRAINT courses_estimated_duration_check
        CHECK (
            estimated_duration_minutes IS NULL
            OR estimated_duration_minutes BETWEEN 1 AND 100000
        );

COMMENT ON COLUMN public.courses.course_type IS
    'Authoring format: complete, quick, or workshop.';
COMMENT ON COLUMN public.courses.estimated_duration_minutes IS
    'Teacher estimate; processed lesson media remains authoritative for real duration.';

-- UPDATE under RLS requires both row visibility and post-update ownership checks.
DROP POLICY IF EXISTS "Gerenciamento de cursos por instrutor ou admin"
    ON public.courses;
CREATE POLICY "Gerenciamento de cursos por instrutor ou admin"
    ON public.courses
    FOR ALL
    TO authenticated
    USING (
        instructor_id = (SELECT auth.uid())
        OR public.is_admin((SELECT auth.uid()))
    )
    WITH CHECK (
        instructor_id = (SELECT auth.uid())
        OR public.is_admin((SELECT auth.uid()))
    );
