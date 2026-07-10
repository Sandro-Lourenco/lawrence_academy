from typing import List
from src.modules.courses.repositories.course_repository import CourseRepository
from src.core.entities.course import Course

class ListCoursesUseCase:
    """Caso de Uso para listar todos os cursos publicados e não deletados."""

    @staticmethod
    def execute() -> List[Course]:
        return CourseRepository.get_published()
