from src.modules.courses.domain.entities import Lesson
from src.modules.courses.domain.repositories import CourseRepository
from src.core.errors.errors import NotFoundError

class GetLessonUseCase:
    """Caso de Uso para obter detalhes de uma aula específica."""

    def __init__(self, repository: CourseRepository):
        self.repository = repository

    async def execute(self, course_id: str, lesson_id: str) -> Lesson:
        lesson = await self.repository.get_lesson_by_id(course_id, lesson_id)
        if not lesson:
            raise NotFoundError(f"Aula com ID {lesson_id} não encontrada para o curso {course_id}.")
        return lesson
