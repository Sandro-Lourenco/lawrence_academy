from src.modules.courses.repositories.course_repository import CourseRepository
from src.core.entities.course import Course

class CreateCourseUseCase:
    """Caso de Uso para criação de novos cursos por instrutores autorizados."""

    @staticmethod
    def execute(course_data: dict, instructor_id: str) -> Course:
        payload = {**course_data, "instructor_id": instructor_id}
        return CourseRepository.create(payload)
