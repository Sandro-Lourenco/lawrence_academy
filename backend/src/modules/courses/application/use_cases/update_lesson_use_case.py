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
                raise AuthorizationError("Acesso negado. Você não é o instrutor deste curso.")

        target_module_id = lesson_data.get("module_id")
        if target_module_id and target_module_id != lesson.module_id:
            target_module = await self.repository.get_module_by_id_and_course_id(
                target_module_id, course_id
            )
            if not target_module:
                raise NotFoundError("Módulo de destino não encontrado neste curso.")

        allowed = {
            "title",
            "description",
            "order_index",
            "status",
            "estimated_duration_minutes",
            "is_required",
            "module_id",
        }
        changes = {key: value for key, value in lesson_data.items() if key in allowed}
        if not changes:
            return lesson
        return await self.repository.update_lesson(lesson_id, changes)
