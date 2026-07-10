from src.modules.courses.repositories.course_repository import CourseRepository
from src.core.entities.course import Course
from src.core.exceptions import AccessDeniedException

class UpdateCourseUseCase:
    """Caso de Uso para atualizar um curso existente com verificação de autoridade do instrutor."""

    @staticmethod
    def execute(course_id: str, course_data: dict, current_user: dict) -> Course:
        # Professores só podem atualizar os próprios cursos
        if current_user["role"] == "teacher":
            instructor_id = CourseRepository.get_instructor_id(course_id)
            if instructor_id != current_user["id"]:
                raise AccessDeniedException("Acesso negado. Você não é o instrutor deste curso.")
                
        return CourseRepository.update(course_id, course_data)
