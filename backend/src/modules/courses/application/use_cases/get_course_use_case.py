from src.modules.courses.domain.entities import Course
from src.modules.courses.domain.repositories import CourseRepository
from src.core.errors.errors import NotFoundError

class GetCourseUseCase:
    """Caso de Uso para obter detalhes de um curso pelo ID."""

    def __init__(self, repository: CourseRepository):
        self.repository = repository

    async def execute(self, course_id: str) -> Course:
        course = await self.repository.get_by_id(course_id)
        if not course:
            raise NotFoundError("Curso não encontrado.")
        return course
