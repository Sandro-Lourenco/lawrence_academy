import uuid
from src.modules.courses.domain.entities import Module
from src.modules.courses.domain.repositories import CourseRepository
from src.core.errors.errors import AuthorizationError, NotFoundError


class CreateModuleUseCase:
    """Caso de Uso para criação de novos módulos em um curso existente."""

    def __init__(self, repository: CourseRepository):
        self.repository = repository

    async def execute(
        self,
        course_id: str,
        module_data: dict,
        current_user_id: str,
        current_user_role: str,
    ) -> Module:
        # Verifica se o curso existe e quem é o dono
        instructor_id = await self.repository.get_instructor_id(course_id)
        if not instructor_id:
            raise NotFoundError("Curso não encontrado.")

        # Professores só podem criar módulos nos próprios cursos
        if current_user_role != "super_admin":
            if instructor_id != current_user_id:
                raise AuthorizationError(
                    "Acesso negado. Você não é o instrutor deste curso."
                )

        module = Module(
            id=module_data.get("id") or str(uuid.uuid4()),
            course_id=course_id,
            title=module_data["title"],
            order_index=module_data.get("order_index", 0),
        )
        return await self.repository.create_module(module)
