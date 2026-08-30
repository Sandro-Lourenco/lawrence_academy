from src.core.errors.errors import AuthorizationError, NotFoundError, ValidationError
from src.modules.courses.domain.entities import Lesson
from src.modules.courses.domain.external_video import parse_external_video_url
from src.modules.courses.domain.repositories import CourseRepository


class UpdateLessonUseCase:
    """Atualiza uma aula somente dentro do curso pertencente ao professor."""

    def __init__(self, repository: CourseRepository):
        self.repository = repository

    async def execute(
        self,
        course_id: str,
        lesson_id: str,
        lesson_data: dict,
        current_user_id: str,
        current_user_role: str,
    ) -> Lesson:
        lesson = await self.repository.get_lesson_by_id(course_id, lesson_id)
        if not lesson:
            raise NotFoundError("Aula não encontrada neste curso.")

        if current_user_role != "super_admin":
            instructor_id = await self.repository.get_instructor_id(course_id)
            if instructor_id != current_user_id:
                raise AuthorizationError("Acesso negado. Você não é o instrutor deste curso.")

        target_module_id = lesson_data.get("module_id")
        if target_module_id and target_module_id != lesson.module_id:
            target_module = await self.repository.get_module_by_id_and_course_id(
                target_module_id, course_id
            )
            if not target_module:
                raise NotFoundError("Módulo de destino não encontrado neste curso.")

        requested = dict(lesson_data)
        video_url = requested.pop("video_url", None)
        remove_external_video = bool(requested.pop("remove_external_video", False))

        allowed = {
            "title",
            "description",
            "order_index",
            "status",
            "estimated_duration_minutes",
            "is_required",
            "module_id",
        }
        changes = {key: value for key, value in requested.items() if key in allowed}
        if video_url is not None:
            external_video = parse_external_video_url(video_url)
            estimated_minutes = requested.get(
                "estimated_duration_minutes", lesson.estimated_duration_minutes
            )
            if not estimated_minutes:
                raise ValidationError(
                    "Informe a duração estimada para uma aula vinculada por link."
                )
            changes.update(
                {
                    "video_source_type": external_video.provider,
                    "external_video_id": external_video.video_id,
                    "hls_storage_path": None,
                    "pending_upload_job_id": None,
                    "duration_seconds": estimated_minutes * 60,
                }
            )
        elif remove_external_video:
            changes.update(
                {
                    "video_source_type": "upload",
                    "external_video_id": None,
                    "hls_storage_path": None,
                    "pending_upload_job_id": None,
                    "duration_seconds": 0,
                }
            )
        elif lesson.video_source_type in {"youtube", "vimeo"} and (
            estimated_minutes := requested.get("estimated_duration_minutes")
        ):
            changes["duration_seconds"] = estimated_minutes * 60
        if not changes:
            return lesson
        return await self.repository.update_lesson(lesson_id, changes)
