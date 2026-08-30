from dataclasses import dataclass

from src.core.errors.errors import AuthorizationError, NotFoundError
from src.modules.courses.domain.repositories import CourseRepository
from src.modules.courses.domain.external_video import external_video_url


@dataclass(frozen=True)
class LessonPlaybackSource:
    source_type: str
    hls_storage_path: str | None = None
    provider: str | None = None
    external_url: str | None = None


class GetLessonStreamUseCase:
    """Assina o HLS da fonte correta após validar propriedade ou assinatura."""

    def __init__(self, repository: CourseRepository):
        self.repository = repository

    async def execute(self, user_id: str, role: str, course_id: str, lesson_id: str) -> str:
        source = await self.authorize_and_get_source(
            user_id,
            role,
            course_id,
            lesson_id,
        )
        if source.external_url:
            return source.external_url
        return await self.repository.generate_signed_url(source.hls_storage_path or "")

    async def authorize_and_get_source(
        self,
        user_id: str,
        role: str,
        course_id: str,
        lesson_id: str,
    ) -> LessonPlaybackSource:
        if role in {"admin", "super_admin"}:
            lesson = await self.repository.get_lesson_by_id(course_id, lesson_id)
        elif role == "teacher":
            owner = await self.repository.get_instructor_id(course_id)
            if owner != user_id:
                raise AuthorizationError("Acesso negado ao vídeo desta aula.")
            lesson = await self.repository.get_lesson_by_id(course_id, lesson_id)
        else:
            course = await self.repository.get_published_by_id(course_id)
            if not course:
                raise NotFoundError("Curso publicado não encontrado.")
            if course.monthly_price > 0 and not await self.repository.has_active_subscription(
                user_id, course_id
            ):
                raise AuthorizationError("Acesso negado. Assinatura inativa para este curso.")
            lesson = await self.repository.get_published_lesson(course_id, lesson_id)

        if lesson is None:
            raise NotFoundError("Aula não encontrada.")
        provider = getattr(lesson, "video_source_type", None)
        external_id = getattr(lesson, "external_video_id", None)
        if (
            isinstance(provider, str)
            and provider in {"youtube", "vimeo"}
            and isinstance(external_id, str)
        ):
            return LessonPlaybackSource(
                source_type="external",
                provider=provider,
                external_url=external_video_url(
                    provider,
                    external_id,
                ),
            )
        storage_path = getattr(lesson, "hls_storage_path", None)
        if not isinstance(storage_path, str) or not storage_path:
            storage_path = (
                await self.repository.get_published_lesson_stream_path(course_id, lesson_id)
                if role not in {"admin", "super_admin", "teacher"}
                else await self.repository.get_lesson_stream_path(course_id, lesson_id)
            )
        if storage_path:
            return LessonPlaybackSource(
                source_type="hls",
                hls_storage_path=storage_path,
            )
        raise NotFoundError(f"Vídeo não encontrado para a aula {lesson_id}.")

    async def authorize_and_get_path(
        self,
        user_id: str,
        role: str,
        course_id: str,
        lesson_id: str,
    ) -> str:
        source = await self.authorize_and_get_source(
            user_id,
            role,
            course_id,
            lesson_id,
        )
        if not source.hls_storage_path:
            raise NotFoundError(f"Caminho HLS não encontrado para a aula {lesson_id}.")
        return source.hls_storage_path
