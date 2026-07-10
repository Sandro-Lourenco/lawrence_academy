from src.modules.profiles.repositories.profile_repository import ProfileRepository
from src.core.entities.profile import Profile
from src.core.exceptions import EntityNotFoundException

class GetMyProfileUseCase:
    """Caso de Uso para buscar os dados de perfil do usuário atual de forma BOLA-safe."""

    @staticmethod
    def execute(user_id: str) -> Profile:
        profile = ProfileRepository.get_by_id(user_id)
        if not profile:
            raise EntityNotFoundException("Perfil não encontrado.")
        return profile
