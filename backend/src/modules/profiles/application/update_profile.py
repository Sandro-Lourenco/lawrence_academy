from typing import Optional
from src.modules.profiles.repositories.profile_repository import ProfileRepository
from src.core.entities.profile import Profile
from src.core.exceptions import DomainException

class UpdateMyProfileUseCase:
    """Caso de Uso para atualizar o perfil do próprio usuário de forma BOLA-safe."""

    @staticmethod
    def execute(user_id: str, full_name: Optional[str], referred_by: Optional[str]) -> Profile:
        update_payload = {}
        if full_name is not None:
            update_payload["full_name"] = full_name
        if referred_by is not None:
            update_payload["referred_by"] = referred_by

        if not update_payload:
            raise DomainException(
                message="Nenhum dado informado para atualização.", 
                code="INVALID_UPDATE"
            )

        return ProfileRepository.update(user_id, update_payload)
