from typing import Optional
from src.modules.profiles.domain.entities import Profile
from src.modules.profiles.domain.repositories import ProfileRepository
from src.core.errors.errors import ValidationError

class UpdateMyProfileUseCase:
    """Caso de Uso para atualizar o perfil do próprio usuário de forma BOLA-safe."""

    def __init__(self, repository: ProfileRepository):
        self.repository = repository

    async def execute(self, user_id: str, full_name: Optional[str], referred_by: Optional[str]) -> Profile:
        if full_name is None and referred_by is None:
            raise ValidationError(
                message="Nenhum dado informado para atualização."
            )
        return await self.repository.update(user_id, full_name=full_name, referred_by=referred_by)
