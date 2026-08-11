CREATE TABLE IF NOT EXISTS public.lesson_block_progress (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  student_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  course_id uuid NOT NULL REFERENCES public.courses(id) ON DELETE CASCADE,
  lesson_id uuid NOT NULL REFERENCES public.lessons(id) ON DELETE CASCADE,
  block_id uuid NOT NULL REFERENCES public.lesson_blocks(id) ON DELETE CASCADE,
  completed_at timestamptz NOT NULL DEFAULT now(),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT lesson_block_progress_student_block_unique UNIQUE (student_id, block_id)
);

CREATE INDEX IF NOT EXISTS idx_lesson_block_progress_student_course
  ON public.lesson_block_progress(student_id, course_id);

ALTER TABLE public.lesson_block_progress ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public.lesson_block_progress FROM anon, authenticated;
GRANT SELECT, INSERT, UPDATE ON public.lesson_block_progress TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.lesson_block_progress TO service_role;

CREATE POLICY lesson_block_progress_select_own
  ON public.lesson_block_progress FOR SELECT TO authenticated
  USING ((SELECT auth.uid()) = student_id);
CREATE POLICY lesson_block_progress_insert_own
  ON public.lesson_block_progress FOR INSERT TO authenticated
  WITH CHECK ((SELECT auth.uid()) = student_id);
CREATE POLICY lesson_block_progress_update_own
  ON public.lesson_block_progress FOR UPDATE TO authenticated
  USING ((SELECT auth.uid()) = student_id)
  WITH CHECK ((SELECT auth.uid()) = student_id);

CREATE TABLE IF NOT EXISTS public.course_reviews (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  course_id uuid NOT NULL REFERENCES public.courses(id) ON DELETE CASCADE,
  student_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  rating smallint NOT NULL CHECK (rating BETWEEN 1 AND 5),
  title text NOT NULL CHECK (char_length(trim(title)) BETWEEN 2 AND 100),
  comment text NOT NULL CHECK (char_length(trim(comment)) BETWEEN 10 AND 2000),
  status text NOT NULL DEFAULT 'published'
    CHECK (status IN ('published', 'hidden', 'flagged')),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT course_reviews_student_course_unique UNIQUE (student_id, course_id)
);

CREATE INDEX IF NOT EXISTS idx_course_reviews_course_published
  ON public.course_reviews(course_id, created_at DESC)
  WHERE status = 'published';

ALTER TABLE public.course_reviews ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public.course_reviews FROM anon, authenticated;
GRANT SELECT, INSERT, UPDATE ON public.course_reviews TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.course_reviews TO service_role;

CREATE POLICY course_reviews_read_published_or_own
  ON public.course_reviews FOR SELECT TO authenticated
  USING (status = 'published' OR (SELECT auth.uid()) = student_id);
CREATE POLICY course_reviews_insert_own
  ON public.course_reviews FOR INSERT TO authenticated
  WITH CHECK ((SELECT auth.uid()) = student_id AND status = 'published');
CREATE POLICY course_reviews_update_own
  ON public.course_reviews FOR UPDATE TO authenticated
  USING ((SELECT auth.uid()) = student_id)
  WITH CHECK ((SELECT auth.uid()) = student_id AND status = 'published');

DROP TRIGGER IF EXISTS set_lesson_block_progress_updated_at ON public.lesson_block_progress;
CREATE TRIGGER set_lesson_block_progress_updated_at
  BEFORE UPDATE ON public.lesson_block_progress
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
DROP TRIGGER IF EXISTS set_course_reviews_updated_at ON public.course_reviews;
CREATE TRIGGER set_course_reviews_updated_at
  BEFORE UPDATE ON public.course_reviews
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
