from typing import List
from src.modules.courses.domain.entities import Course
from src.modules.courses.domain.repositories import CourseRepository


class ListCoursesUseCase:
    """Caso de Uso para listar todos os cursos publicados ativos."""

    def __init__(self, repository: CourseRepository):
        self.repository = repository

    async def execute(self) -> List[Course]:
        courses = await self.repository.list_all()
        return [course for course in courses if course.status == "published"]
