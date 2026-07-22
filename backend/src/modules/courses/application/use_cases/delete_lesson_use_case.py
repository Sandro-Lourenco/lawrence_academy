from src.core.errors.errors import AuthorizationError, NotFoundError
from src.modules.courses.domain.repositories import CourseRepository


class DeleteLessonUseCase:
    """Arquiva uma aula individual sem afetar seu módulo ou outras aulas."""

    def __init__(self, repository: CourseRepository):
        self.repository = repository

    async def execute(
        self,
        course_id: str,
        lesson_id: str,
        current_user_id: str,
        current_user_role: str,
    ) -> bool:
        lesson = await self.repository.get_lesson_by_id(course_id, lesson_id)
        if not lesson:
            raise NotFoundError("Aula não encontrada neste curso.")

        if current_user_role != "super_admin":
            instructor_id = await self.repository.get_instructor_id(course_id)
            if instructor_id != current_user_id:
                raise AuthorizationError(
                    "Acesso negado. Você não é o instrutor deste curso."
                )

        return await self.repository.delete_lesson(lesson_id)
