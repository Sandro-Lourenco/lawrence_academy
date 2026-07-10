from src.modules.profiles.domain.entities import Profile
from src.modules.profiles.domain.repositories import ProfileRepository
from src.core.errors.errors import NotFoundError


class GetMyProfileUseCase:
    """Caso de Uso para buscar os dados de perfil do usuário atual de forma BOLA-safe."""

    def __init__(self, repository: ProfileRepository):
        self.repository = repository

    async def execute(self, user_id: str) -> Profile:
        profile = await self.repository.get_by_id(user_id)
        if not profile:
            raise NotFoundError("Perfil não encontrado.")
        return profile
