-- Phase 1 of the teacher authoring studio: structured course planning.
-- Additive defaults preserve every existing draft and published course.

ALTER TABLE public.courses
    ADD COLUMN course_type TEXT NOT NULL DEFAULT 'complete',
    ADD COLUMN subtitle VARCHAR(160) NOT NULL DEFAULT '',
    ADD COLUMN language VARCHAR(10) NOT NULL DEFAULT 'pt-BR',
    ADD COLUMN estimated_duration_minutes INTEGER,
    ADD COLUMN learning_objectives TEXT[] NOT NULL DEFAULT '{}',
    ADD COLUMN target_audience TEXT[] NOT NULL DEFAULT '{}',
    ADD COLUMN required_materials TEXT[] NOT NULL DEFAULT '{}',
    ADD COLUMN competencies TEXT[] NOT NULL DEFAULT '{}',
    ADD COLUMN expected_outcomes TEXT[] NOT NULL DEFAULT '{}';

ALTER TABLE public.courses
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
