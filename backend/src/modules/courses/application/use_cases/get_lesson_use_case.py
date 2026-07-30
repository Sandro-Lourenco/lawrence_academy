from src.core.errors.errors import AuthorizationError, NotFoundError
from src.modules.courses.domain.entities import Lesson
from src.modules.courses.domain.repositories import CourseRepository


class GetLessonUseCase:
    """Obtém a fonte de autoria para gestores e a versão vigente para alunos."""

    def __init__(self, repository: CourseRepository):
        self.repository = repository

    async def execute(self, user_id: str, role: str, course_id: str, lesson_id: str) -> Lesson:
        if role in {"teacher", "admin", "super_admin"}:
            owner = await self.repository.get_instructor_id(course_id)
            if role not in {"admin", "super_admin"} and owner != user_id:
                raise AuthorizationError("Acesso negado a esta aula.")
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

        if not lesson:
            raise NotFoundError(f"Aula com ID {lesson_id} não encontrada para o curso {course_id}.")
        return lesson
