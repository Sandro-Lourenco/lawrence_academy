from typing import List

from src.modules.courses.domain.entities import Course
from src.modules.courses.domain.repositories import CourseRepository


class ListTeacherCoursesUseCase:
    """Lista apenas os cursos que o professor autenticado pode administrar."""

    def __init__(self, repository: CourseRepository):
        self.repository = repository

    async def execute(self, user_id: str, role: str) -> List[Course]:
        if role == "super_admin":
            return await self.repository.list_all()
        return await self.repository.list_by_instructor(user_id)
