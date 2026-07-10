from src.modules.courses.repositories.course_repository import CourseRepository
from src.core.entities.course import Course
from src.core.exceptions import EntityNotFoundException

class GetCourseUseCase:
    """Caso de Uso para recuperar detalhes completos de um curso pelo ID."""

    @staticmethod
    def execute(course_id: str) -> Course:
        course = CourseRepository.get_by_id(course_id)
        if not course:
            raise EntityNotFoundException("Curso não encontrado.")
        return course
