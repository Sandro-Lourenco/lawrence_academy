-- Close advisor findings that are relevant to the public Data API and add
-- covering indexes for every currently unindexed public foreign key.

ALTER FUNCTION public.set_updated_at()
    SET search_path = pg_catalog, public;

-- Role claims are emitted by custom_access_token_hook. This legacy helper is
-- not part of the client contract and must not be exposed as a Data API RPC.
REVOKE ALL ON FUNCTION public.get_primary_role(UUID)
    FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.get_primary_role(UUID) TO service_role;

CREATE INDEX IF NOT EXISTS idx_certificates_course_id ON public.certificates (course_id);
CREATE INDEX IF NOT EXISTS idx_course_publication_requests_course_version ON public.course_publication_requests (course_id, version_number);
CREATE INDEX IF NOT EXISTS idx_course_version_restores_version_id ON public.course_version_restores (version_id);
CREATE INDEX IF NOT EXISTS idx_courses_instructor_id ON public.courses (instructor_id);
CREATE INDEX IF NOT EXISTS idx_courses_trailer_upload_job_id ON public.courses (trailer_upload_job_id);
CREATE INDEX IF NOT EXISTS idx_download_tokens_lesson_id ON public.download_tokens (lesson_id);
CREATE INDEX IF NOT EXISTS idx_event_store_course_id ON public.event_store (course_id);
CREATE INDEX IF NOT EXISTS idx_event_store_lesson_id ON public.event_store (lesson_id);
CREATE INDEX IF NOT EXISTS idx_lesson_block_progress_block_id ON public.lesson_block_progress (block_id);
CREATE INDEX IF NOT EXISTS idx_lesson_block_progress_course_id ON public.lesson_block_progress (course_id);
CREATE INDEX IF NOT EXISTS idx_lesson_block_progress_lesson_id ON public.lesson_block_progress (lesson_id);
CREATE INDEX IF NOT EXISTS idx_lesson_progress_course_id ON public.lesson_progress (course_id);
CREATE INDEX IF NOT EXISTS idx_lessons_pending_upload_job_id ON public.lessons (pending_upload_job_id);
CREATE INDEX IF NOT EXISTS idx_notifications_user_id ON public.notifications (user_id);
CREATE INDEX IF NOT EXISTS idx_profiles_referred_by ON public.profiles (referred_by);
CREATE INDEX IF NOT EXISTS idx_role_permissions_permission_id ON public.role_permissions (permission_id);
CREATE INDEX IF NOT EXISTS idx_task_submissions_graded_by ON public.task_submissions (graded_by);
CREATE INDEX IF NOT EXISTS idx_tasks_course_id ON public.tasks (course_id);
CREATE INDEX IF NOT EXISTS idx_tasks_lesson_id ON public.tasks (lesson_id);
CREATE INDEX IF NOT EXISTS idx_user_roles_role_id ON public.user_roles (role_id);
