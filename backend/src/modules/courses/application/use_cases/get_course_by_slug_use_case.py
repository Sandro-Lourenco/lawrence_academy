from src.modules.courses.domain.entities import Course
from src.modules.courses.domain.repositories import CourseRepository
from src.core.errors.errors import NotFoundError


class GetCourseBySlugUseCase:
    """Caso de Uso para obter detalhes de um curso pelo slug."""

    def __init__(self, repository: CourseRepository):
        self.repository = repository

    async def execute(self, slug: str) -> Course:
        course = await self.repository.get_by_slug(slug)
        if not course or course.status != "published":
            raise NotFoundError("Curso não encontrado.")
        return course
