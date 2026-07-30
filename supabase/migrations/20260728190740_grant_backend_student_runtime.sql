BEGIN;

GRANT SELECT, UPDATE ON public.profiles TO service_role;
GRANT SELECT ON public.lesson_progress TO service_role;
GRANT SELECT, INSERT ON public.event_store TO service_role;

GRANT SELECT, INSERT, UPDATE ON public.tasks TO service_role;
GRANT SELECT, INSERT, UPDATE ON public.task_submissions TO service_role;
GRANT SELECT, INSERT ON public.certificates TO service_role;

GRANT INSERT ON public.notifications TO service_role;
GRANT SELECT, INSERT, UPDATE ON public.payment_events TO service_role;

GRANT INSERT, UPDATE ON public.video_processing_jobs TO service_role;

COMMIT;
