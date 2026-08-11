from src.modules.courses.domain.repositories import CourseRepository
from src.core.errors.errors import AuthorizationError


class DeleteModuleUseCase:
    """Caso de Uso para arquivar (deleção lógica) um módulo."""

    def __init__(self, repository: CourseRepository):
        self.repository = repository

    async def execute(
        self,
        course_id: str,
        module_id: str,
        current_user_id: str,
        current_user_role: str,
    ) -> bool:
        # Autoriza pelo curso antes de tratar a ausência como sucesso. Isso
        # mantém BOLA-safe e torna DELETE idempotente em retries/refreshes.
        if current_user_role != "super_admin":
            instructor_id = await self.repository.get_instructor_id(course_id)
            if instructor_id != current_user_id:
                raise AuthorizationError("Acesso negado. Você não é o instrutor deste curso.")

        module = await self.repository.get_module_by_id_and_course_id(module_id, course_id)
        if not module:
            return True

        return await self.repository.delete_module(module_id)
