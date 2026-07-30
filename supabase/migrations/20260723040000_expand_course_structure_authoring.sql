CREATE OR REPLACE FUNCTION public.set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

ALTER TABLE public.modules
  ADD COLUMN IF NOT EXISTS description TEXT,
  ADD COLUMN IF NOT EXISTS status TEXT NOT NULL DEFAULT 'draft',
  ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ NOT NULL DEFAULT now();

ALTER TABLE public.modules DROP CONSTRAINT IF EXISTS modules_title_length_check;
ALTER TABLE public.modules ADD CONSTRAINT modules_title_length_check
  CHECK (char_length(btrim(title)) BETWEEN 3 AND 160);
ALTER TABLE public.modules DROP CONSTRAINT IF EXISTS modules_description_length_check;
ALTER TABLE public.modules ADD CONSTRAINT modules_description_length_check
  CHECK (description IS NULL OR char_length(description) <= 1000);
ALTER TABLE public.modules DROP CONSTRAINT IF EXISTS modules_status_check;
ALTER TABLE public.modules ADD CONSTRAINT modules_status_check
  CHECK (status IN ('draft','ready'));
ALTER TABLE public.modules DROP CONSTRAINT IF EXISTS modules_order_index_check;
ALTER TABLE public.modules ADD CONSTRAINT modules_order_index_check CHECK (order_index >= 0);

ALTER TABLE public.lessons
  ADD COLUMN IF NOT EXISTS estimated_duration_minutes INTEGER,
  ADD COLUMN IF NOT EXISTS is_required BOOLEAN NOT NULL DEFAULT true;
ALTER TABLE public.lessons DROP CONSTRAINT IF EXISTS lessons_estimated_duration_check;
ALTER TABLE public.lessons ADD CONSTRAINT lessons_estimated_duration_check
  CHECK (estimated_duration_minutes IS NULL OR estimated_duration_minutes BETWEEN 1 AND 1440);
ALTER TABLE public.lessons DROP CONSTRAINT IF EXISTS lessons_order_index_check;
ALTER TABLE public.lessons ADD CONSTRAINT lessons_order_index_check CHECK (order_index >= 0);

CREATE INDEX IF NOT EXISTS idx_modules_course_order_active
  ON public.modules(course_id, order_index) WHERE deleted_at IS NULL;
CREATE INDEX IF NOT EXISTS idx_lessons_module_order_active
  ON public.lessons(module_id, order_index) WHERE deleted_at IS NULL;

DROP TRIGGER IF EXISTS set_modules_updated_at ON public.modules;
CREATE TRIGGER set_modules_updated_at BEFORE UPDATE ON public.modules
FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

