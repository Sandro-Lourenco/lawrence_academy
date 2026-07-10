from src.modules.courses.domain.repositories import CourseRepository
from src.core.errors.errors import AuthorizationError, NotFoundError

class DeleteCourseUseCase:
    """Caso de Uso para realizar a exclusão lógica (soft delete) de um curso."""

    def __init__(self, repository: CourseRepository):
        self.repository = repository

    async def execute(self, course_id: str, current_user_id: str, current_user_role: str) -> bool:
        # Professores só podem deletar os próprios cursos
        if current_user_role == "teacher":
            instructor_id = await self.repository.get_instructor_id(course_id)
            if not instructor_id:
                raise NotFoundError("Curso não encontrado.")
            if instructor_id != current_user_id:
                raise AuthorizationError("Acesso negado. Você não é o instrutor deste curso.")
                
        return await self.repository.delete(course_id)
