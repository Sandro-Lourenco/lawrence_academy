import uuid
from src.modules.courses.domain.entities import Module
from src.modules.courses.domain.repositories import CourseRepository
from src.core.errors.errors import AuthorizationError, NotFoundError, ValidationError
from src.modules.courses.application.idempotency import (
    deterministic_resource_id,
    request_fingerprint,
)


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
        idempotency_key: str | None = None,
    ) -> Module:
        # Verifica se o curso existe e quem é o dono
        instructor_id = await self.repository.get_instructor_id(course_id)
        if not instructor_id:
            raise NotFoundError("Curso não encontrado.")

        # Professores só podem criar módulos nos próprios cursos
        if current_user_role != "super_admin":
            if instructor_id != current_user_id:
                raise AuthorizationError("Acesso negado. Você não é o instrutor deste curso.")

        if await self.repository.get_course_type(course_id) == "quick":
            raise ValidationError(
                "Cursos rápidos não usam módulos. Adicione as aulas diretamente ao curso."
            )

        module = Module(
            id=module_data.get("id")
            or (
                deterministic_resource_id(f"module:{course_id}", idempotency_key)
                if idempotency_key
                else str(uuid.uuid4())
            ),
            course_id=course_id,
            title=module_data["title"],
            order_index=module_data.get("order_index", 0),
            description=module_data.get("description"),
            status=module_data.get("status", "draft"),
        )
        if not idempotency_key:
            return await self.repository.create_module(module)
        return await self.repository.create_module(
            module,
            idempotency_key=idempotency_key,
            request_hash=request_fingerprint(module_data) if idempotency_key else None,
            actor_id=current_user_id,
        )
