from src.modules.courses.repositories.course_repository import CourseRepository
from src.core.entities.course import Course
from src.core.exceptions import EntityNotFoundException

class GetCourseBySlugUseCase:
    """Caso de Uso para recuperar detalhes completos de um curso pelo Slug."""

    @staticmethod
    def execute(slug: str) -> Course:
        course = CourseRepository.get_by_slug(slug)
        if not course:
            raise EntityNotFoundException("Curso não encontrado.")
        return course
