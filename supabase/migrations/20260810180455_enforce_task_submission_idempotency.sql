-- Persist retries as the same logical submission and make draft grading safe.
ALTER TABLE public.task_submissions
    ADD COLUMN IF NOT EXISTS idempotency_key TEXT;

UPDATE public.task_submissions
SET idempotency_key = 'legacy:' || id::text
WHERE idempotency_key IS NULL;

ALTER TABLE public.task_submissions
    ALTER COLUMN idempotency_key SET NOT NULL;

CREATE UNIQUE INDEX IF NOT EXISTS idx_task_submissions_user_idempotency
    ON public.task_submissions(user_id, idempotency_key);

CREATE OR REPLACE FUNCTION public.auto_grade_submission()
RETURNS TRIGGER
LANGUAGE plpgsql
SET search_path = pg_catalog, public
AS $$
DECLARE
    v_task_type public.assessment_type;
    v_correct_opt VARCHAR(10);
BEGIN
    IF NEW.status = 'draft' THEN
        NEW.score := NULL;
        NEW.graded_at := NULL;
        RETURN NEW;
    END IF;

    SELECT task_type, correct_option INTO v_task_type, v_correct_opt
    FROM public.tasks WHERE id = NEW.task_id;

    IF v_task_type IN ('multiple_choice', 'true_false') THEN
        IF lower(NEW.selected_option) = lower(v_correct_opt) THEN
            NEW.score := 10.00;
            NEW.teacher_feedback := 'Correção automática: Resposta correta.';
        ELSE
            NEW.score := 0.00;
            NEW.teacher_feedback := 'Correção automática: Resposta incorreta.';
        END IF;
        NEW.status := 'graded';
        NEW.graded_at := NOW();
    ELSE
        NEW.status := 'pending_review';
    END IF;
    RETURN NEW;
END;
$$;

REVOKE ALL ON FUNCTION public.auto_grade_submission() FROM PUBLIC, anon, authenticated;
GRANT SELECT, INSERT, UPDATE ON public.task_submissions TO service_role;
