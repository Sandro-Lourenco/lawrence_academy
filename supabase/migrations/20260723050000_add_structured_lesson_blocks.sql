CREATE TABLE IF NOT EXISTS public.lesson_blocks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  lesson_id UUID NOT NULL REFERENCES public.lessons(id) ON DELETE CASCADE,
  course_id UUID NOT NULL REFERENCES public.courses(id) ON DELETE CASCADE,
  block_type TEXT NOT NULL,
  content JSONB NOT NULL DEFAULT '{}'::jsonb,
  order_index INTEGER NOT NULL DEFAULT 0,
  status TEXT NOT NULL DEFAULT 'draft',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at TIMESTAMPTZ,
  CONSTRAINT lesson_blocks_type_check CHECK (block_type IN (
    'video','text','heading','pdf','image','gallery','download','audio',
    'material','notice','tip','summary','learn_more','activity'
  )),
  CONSTRAINT lesson_blocks_order_check CHECK (order_index >= 0),
  CONSTRAINT lesson_blocks_status_check CHECK (status IN ('draft','ready')),
  CONSTRAINT lesson_blocks_content_object_check CHECK (jsonb_typeof(content) = 'object')
);

CREATE INDEX IF NOT EXISTS idx_lesson_blocks_lesson_order_active
  ON public.lesson_blocks(lesson_id, order_index) WHERE deleted_at IS NULL;
CREATE INDEX IF NOT EXISTS idx_lesson_blocks_course ON public.lesson_blocks(course_id);

ALTER TABLE public.lesson_blocks ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public.lesson_blocks FROM anon, authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.lesson_blocks TO service_role;

DROP POLICY IF EXISTS lesson_blocks_teacher_select ON public.lesson_blocks;
CREATE POLICY lesson_blocks_teacher_select ON public.lesson_blocks FOR SELECT TO authenticated
USING (EXISTS (
  SELECT 1 FROM public.courses c
  WHERE c.id = lesson_blocks.course_id AND c.instructor_id = (SELECT auth.uid())
));
DROP POLICY IF EXISTS lesson_blocks_teacher_insert ON public.lesson_blocks;
CREATE POLICY lesson_blocks_teacher_insert ON public.lesson_blocks FOR INSERT TO authenticated
WITH CHECK (EXISTS (
  SELECT 1 FROM public.courses c
  WHERE c.id = lesson_blocks.course_id AND c.instructor_id = (SELECT auth.uid())
) AND EXISTS (
  SELECT 1 FROM public.lessons l
  WHERE l.id = lesson_blocks.lesson_id AND l.course_id = lesson_blocks.course_id
));
DROP POLICY IF EXISTS lesson_blocks_teacher_update ON public.lesson_blocks;
CREATE POLICY lesson_blocks_teacher_update ON public.lesson_blocks FOR UPDATE TO authenticated
USING (EXISTS (SELECT 1 FROM public.courses c WHERE c.id=lesson_blocks.course_id AND c.instructor_id=(SELECT auth.uid())))
WITH CHECK (EXISTS (SELECT 1 FROM public.courses c WHERE c.id=lesson_blocks.course_id AND c.instructor_id=(SELECT auth.uid()))
  AND EXISTS (SELECT 1 FROM public.lessons l WHERE l.id=lesson_blocks.lesson_id AND l.course_id=lesson_blocks.course_id));
DROP POLICY IF EXISTS lesson_blocks_teacher_delete ON public.lesson_blocks;
CREATE POLICY lesson_blocks_teacher_delete ON public.lesson_blocks FOR DELETE TO authenticated
USING (EXISTS (SELECT 1 FROM public.courses c WHERE c.id=lesson_blocks.course_id AND c.instructor_id=(SELECT auth.uid())));

DROP TRIGGER IF EXISTS set_lesson_blocks_updated_at ON public.lesson_blocks;
CREATE TRIGGER set_lesson_blocks_updated_at BEFORE UPDATE ON public.lesson_blocks
FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

