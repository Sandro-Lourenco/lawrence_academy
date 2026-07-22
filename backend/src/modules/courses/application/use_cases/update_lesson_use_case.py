from src.core.errors.errors import AuthorizationError, NotFoundError
from src.modules.courses.domain.entities import Lesson
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
                raise AuthorizationError(
                    "Acesso negado. Você não é o instrutor deste curso."
                )

        allowed = {"title", "description", "order_index", "status"}
        changes = {key: value for key, value in lesson_data.items() if key in allowed}
        if not changes:
            return lesson
        return await self.repository.update_lesson(lesson_id, changes)
