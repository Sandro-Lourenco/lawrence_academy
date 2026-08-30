-- Serialize finalized submissions per student/task so concurrent requests cannot
-- exceed the task's server-owned max_attempts rule.
CREATE OR REPLACE FUNCTION public.enforce_task_attempt_limit()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE
    v_max_attempts INTEGER;
    v_attempt_count INTEGER;
BEGIN
    IF NEW.status = 'draft' THEN
        RETURN NEW;
    END IF;

    -- A teacher grading an existing essay is not a new student attempt.
    IF TG_OP = 'UPDATE' AND OLD.status <> 'draft' THEN
        RETURN NEW;
    END IF;

    PERFORM pg_catalog.pg_advisory_xact_lock(
        pg_catalog.hashtextextended(
            NEW.user_id::TEXT || ':' || NEW.task_id::TEXT,
            0
        )
    );

    SELECT task.max_attempts
      INTO v_max_attempts
      FROM public.tasks AS task
     WHERE task.id = NEW.task_id
       AND task.deleted_at IS NULL;

    IF v_max_attempts IS NULL THEN
        RAISE EXCEPTION 'Task is unavailable'
            USING ERRCODE = '23503';
    END IF;

    SELECT COUNT(*)::INTEGER
      INTO v_attempt_count
      FROM public.task_submissions AS submission
     WHERE submission.user_id = NEW.user_id
       AND submission.task_id = NEW.task_id
       AND submission.status <> 'draft'
       AND (TG_OP <> 'UPDATE' OR submission.id <> NEW.id);

    IF v_attempt_count >= v_max_attempts THEN
        RAISE EXCEPTION 'Maximum task attempts exceeded'
            USING ERRCODE = '23514';
    END IF;

    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_enforce_task_attempt_limit
    ON public.task_submissions;
CREATE TRIGGER trg_enforce_task_attempt_limit
    BEFORE INSERT OR UPDATE OF status
    ON public.task_submissions
    FOR EACH ROW
    EXECUTE FUNCTION public.enforce_task_attempt_limit();

REVOKE ALL ON FUNCTION public.enforce_task_attempt_limit()
    FROM PUBLIC, anon, authenticated;
