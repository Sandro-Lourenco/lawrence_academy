import uuid

from src.core.errors.errors import AuthorizationError, NotFoundError, ValidationError
from src.modules.courses.domain.entities import Lesson
from src.modules.courses.domain.external_video import parse_external_video_url
from src.modules.courses.domain.repositories import CourseRepository
from src.modules.courses.application.idempotency import (
    deterministic_resource_id,
    request_fingerprint,
)


class CreateLessonUseCase:
    """Cria aula garantindo curso, mÃ³dulo e proprietÃ¡rio corretos."""

    def __init__(self, repository: CourseRepository):
        self.repository = repository

    async def execute(
        self,
        course_id: str,
        module_id: str,
        lesson_data: dict,
        current_user_id: str,
        current_user_role: str,
        idempotency_key: str | None = None,
    ) -> Lesson:
        module = await self.repository.get_module_by_id_and_course_id(module_id, course_id)
        if not module:
            raise NotFoundError("MÃ³dulo nÃ£o encontrado neste curso.")
        instructor_id = await self.repository.get_instructor_id(course_id)
        if not instructor_id:
            raise NotFoundError("Curso nÃ£o encontrado.")
        if current_user_role != "super_admin" and instructor_id != current_user_id:
            raise AuthorizationError("Apenas o instrutor pode criar aulas neste curso.")

        external_video = None
        video_url = lesson_data.get("video_url")
        if video_url:
            external_video = parse_external_video_url(video_url)
            if not lesson_data.get("estimated_duration_minutes"):
                raise ValidationError(
                    "Informe a duração estimada para uma aula vinculada por link."
                )

        estimated_minutes = lesson_data.get("estimated_duration_minutes")
        lesson = Lesson(
            id=(
                deterministic_resource_id(f"lesson:{course_id}:{module_id}", idempotency_key)
                if idempotency_key
                else str(uuid.uuid4())
            ),
            module_id=module_id,
            course_id=course_id,
            title=lesson_data["title"].strip(),
            description=lesson_data.get("description"),
            order_index=lesson_data.get("order_index", 0),
            hls_storage_path=None,
            video_source_type=external_video.provider if external_video else "upload",
            external_video_id=external_video.video_id if external_video else None,
            duration_seconds=(estimated_minutes or 0) * 60 if external_video else 0,
            status=lesson_data.get("status", "draft"),
            estimated_duration_minutes=estimated_minutes,
            is_required=lesson_data.get("is_required", True),
        )
        if not idempotency_key:
            return await self.repository.create_lesson(lesson)
        return await self.repository.create_lesson(
            lesson,
            idempotency_key=idempotency_key,
            request_hash=request_fingerprint(lesson_data) if idempotency_key else None,
            actor_id=current_user_id,
        )
