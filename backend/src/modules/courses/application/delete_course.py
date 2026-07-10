from src.modules.courses.repositories.course_repository import CourseRepository
from src.core.entities.course import Course
from src.core.exceptions import AccessDeniedException

class DeleteCourseUseCase:
    """Caso de Uso para realizar a exclusão lógica (soft delete) de um curso."""

    @staticmethod
    def execute(course_id: str, current_user: dict) -> Course:
        # Professores só podem deletar os próprios cursos
        if current_user["role"] == "teacher":
            instructor_id = CourseRepository.get_instructor_id(course_id)
            if instructor_id != current_user["id"]:
                raise AccessDeniedException("Acesso negado. Você não é o instrutor deste curso.")
                
        return CourseRepository.soft_delete(course_id)
