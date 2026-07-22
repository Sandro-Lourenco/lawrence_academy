import uuid

from src.core.errors.errors import AuthorizationError, NotFoundError
from src.modules.courses.domain.entities import Lesson
from src.modules.courses.domain.repositories import CourseRepository


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
    ) -> Lesson:
        module = await self.repository.get_module_by_id_and_course_id(
            module_id, course_id
        )
        if not module:
            raise NotFoundError("MÃ³dulo nÃ£o encontrado neste curso.")
        instructor_id = await self.repository.get_instructor_id(course_id)
        if not instructor_id:
            raise NotFoundError("Curso nÃ£o encontrado.")
        if current_user_role != "super_admin" and instructor_id != current_user_id:
            raise AuthorizationError("Apenas o instrutor pode criar aulas neste curso.")

        lesson = Lesson(
            id=str(uuid.uuid4()),
            module_id=module_id,
            course_id=course_id,
            title=lesson_data["title"].strip(),
            description=lesson_data.get("description"),
            order_index=lesson_data.get("order_index", 0),
            hls_storage_path=None,
            status=lesson_data.get("status", "draft"),
        )
        return await self.repository.create_lesson(lesson)
