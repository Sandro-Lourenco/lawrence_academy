from typing import List
from src.modules.courses.domain.entities import Course
from src.modules.courses.domain.repositories import CourseRepository


class ListCoursesUseCase:
    """Caso de Uso para listar todos os cursos publicados ativos."""

    def __init__(self, repository: CourseRepository):
        self.repository = repository

    async def execute(self, *, limit: int = 50) -> List[Course]:
        safe_limit = max(1, min(limit, 50))
        return await self.repository.list_published_versions(limit=safe_limit)
