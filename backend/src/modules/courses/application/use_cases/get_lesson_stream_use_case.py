from src.core.errors.errors import AuthorizationError, NotFoundError
from src.modules.courses.domain.repositories import CourseRepository


class GetLessonStreamUseCase:
    """Assina o HLS da fonte correta após validar propriedade ou assinatura."""

    def __init__(self, repository: CourseRepository):
        self.repository = repository

    async def execute(self, user_id: str, role: str, course_id: str, lesson_id: str) -> str:
        storage_path = await self.authorize_and_get_path(
            user_id,
            role,
            course_id,
            lesson_id,
        )
        return await self.repository.generate_signed_url(storage_path)

    async def authorize_and_get_path(
        self,
        user_id: str,
        role: str,
        course_id: str,
        lesson_id: str,
    ) -> str:
        if role in {"admin", "super_admin"}:
            storage_path = await self.repository.get_lesson_stream_path(course_id, lesson_id)
        elif role == "teacher":
            owner = await self.repository.get_instructor_id(course_id)
            if owner != user_id:
                raise AuthorizationError("Acesso negado ao vídeo desta aula.")
            storage_path = await self.repository.get_lesson_stream_path(course_id, lesson_id)
        else:
            course = await self.repository.get_published_by_id(course_id)
            if not course:
                raise NotFoundError("Curso publicado não encontrado.")
            if course.monthly_price > 0 and not await self.repository.has_active_subscription(
                user_id, course_id
            ):
                raise AuthorizationError("Acesso negado. Assinatura inativa para este curso.")
            storage_path = await self.repository.get_published_lesson_stream_path(
                course_id, lesson_id
            )

        if not storage_path:
            raise NotFoundError(f"Caminho HLS não encontrado para a aula {lesson_id}.")
        return storage_path
