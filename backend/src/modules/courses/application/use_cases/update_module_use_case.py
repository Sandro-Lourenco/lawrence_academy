from src.modules.courses.domain.entities import Module
from src.modules.courses.domain.repositories import CourseRepository
from src.core.errors.errors import AuthorizationError, NotFoundError


class UpdateModuleUseCase:
    """Caso de Uso para atualizar um módulo existente de um curso."""

    def __init__(self, repository: CourseRepository):
        self.repository = repository

    async def execute(
        self,
        course_id: str,
        module_id: str,
        module_data: dict,
        current_user_id: str,
        current_user_role: str,
    ) -> Module:
        # BOLA-safe check and existence
        module = await self.repository.get_module_by_id_and_course_id(
            module_id, course_id
        )
        if not module:
            raise NotFoundError("Módulo não encontrado para o curso especificado.")

        # Verifica dono do curso
        if current_user_role != "super_admin":
            instructor_id = await self.repository.get_instructor_id(course_id)
            if instructor_id != current_user_id:
                raise AuthorizationError(
                    "Acesso negado. Você não é o instrutor deste curso."
                )

        updated_data = {
            "title": module_data.get("title", module.title),
            "order_index": module_data.get("order_index", module.order_index),
        }
        return await self.repository.update_module(module_id, updated_data)
