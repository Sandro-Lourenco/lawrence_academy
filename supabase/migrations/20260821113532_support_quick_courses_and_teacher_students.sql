-- Quick courses keep lessons in one internal module so the existing lesson,
-- progress and certificate foreign keys remain stable while the product does
-- not expose a module concept to teachers or students.

ALTER TABLE public.modules
    ADD COLUMN IF NOT EXISTS is_system BOOLEAN NOT NULL DEFAULT FALSE;

CREATE UNIQUE INDEX IF NOT EXISTS idx_modules_one_active_system_per_course
    ON public.modules (course_id)
    WHERE is_system = TRUE AND deleted_at IS NULL;

CREATE INDEX IF NOT EXISTS idx_subscriptions_course_active_students
    ON public.subscriptions (course_id, created_at DESC, student_id)
    WHERE deleted_at IS NULL;

CREATE OR REPLACE FUNCTION public.sync_quick_course_system_module()
RETURNS TRIGGER
LANGUAGE plpgsql
SET search_path = pg_catalog, public
AS $$
BEGIN
    IF TG_OP = 'UPDATE'
       AND OLD.course_type IS DISTINCT FROM NEW.course_type
       AND EXISTS (
           SELECT 1
             FROM public.modules AS m
            WHERE m.course_id = NEW.id
              AND m.deleted_at IS NULL
              AND (
                  m.is_system = FALSE
                  OR EXISTS (
                      SELECT 1
                        FROM public.lessons AS l
                       WHERE l.module_id = m.id
                         AND l.deleted_at IS NULL
                  )
              )
       ) THEN
        RAISE EXCEPTION 'O tipo do curso não pode mudar depois da criação de conteúdo.'
            USING ERRCODE = '23514';
    END IF;

    IF NEW.course_type = 'quick' THEN
        INSERT INTO public.modules (
            id,
            course_id,
            title,
            order_index,
            description,
            status,
            is_system
        )
        SELECT
            gen_random_uuid(),
            NEW.id,
            'Conteúdo do curso rápido',
            0,
            'Módulo interno; não exibido na experiência do curso rápido.',
            'draft',
            TRUE
        WHERE NOT EXISTS (
            SELECT 1
              FROM public.modules AS existing
             WHERE existing.course_id = NEW.id
               AND existing.is_system = TRUE
               AND existing.deleted_at IS NULL
        );
    ELSIF TG_OP = 'UPDATE' AND OLD.course_type = 'quick' THEN
        UPDATE public.modules
           SET deleted_at = NOW()
         WHERE course_id = NEW.id
           AND is_system = TRUE
           AND deleted_at IS NULL;
    END IF;

    RETURN NEW;
END;
$$;

REVOKE ALL ON FUNCTION public.sync_quick_course_system_module() FROM PUBLIC, anon, authenticated;

DROP TRIGGER IF EXISTS trg_sync_quick_course_system_module ON public.courses;
CREATE TRIGGER trg_sync_quick_course_system_module
AFTER INSERT OR UPDATE OF course_type ON public.courses
FOR EACH ROW
EXECUTE FUNCTION public.sync_quick_course_system_module();

INSERT INTO public.modules (
    id,
    course_id,
    title,
    order_index,
    description,
    status,
    is_system
)
SELECT
    gen_random_uuid(),
    c.id,
    'Conteúdo do curso rápido',
    0,
    'Módulo interno; não exibido na experiência do curso rápido.',
    'draft',
    TRUE
FROM public.courses AS c
WHERE c.course_type = 'quick'
  AND c.deleted_at IS NULL
  AND NOT EXISTS (
      SELECT 1
      FROM public.modules AS m
      WHERE m.course_id = c.id
        AND m.is_system = TRUE
        AND m.deleted_at IS NULL
  );

COMMENT ON COLUMN public.modules.is_system IS
    'True only for the internal lesson container of a quick course; hidden from product UI.';
