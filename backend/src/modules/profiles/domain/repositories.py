from typing import Protocol, Optional
from src.modules.profiles.domain.entities import Profile


class ProfileRepository(Protocol):
    """Interface (Protocol) de repositório de domínio para perfis."""

    async def get_by_id(self, user_id: str) -> Optional[Profile]:
        """Busca o perfil pelo ID do usuário."""
        ...

    async def update(
        self, user_id: str, full_name: Optional[str], referred_by: Optional[str]
    ) -> Profile:
        """Atualiza os dados de perfil do usuário."""
        ...
