import typing
from typing import Optional
from src.shared import database
from src.modules.profiles.domain.entities import Profile
from src.core.exceptions import EntityNotFoundException


class ProfileRepository:
    """Repositório encapsulando as operações no banco de dados para a entidade Profile."""

    @staticmethod
    def get_by_id(profile_id: str) -> Optional[Profile]:
        """Busca um perfil pelo seu identificador único (UUID)."""
        res = (
            database.db.table("profiles")
            .select("*")
            .eq("id", profile_id)
            .maybe_single()
            .execute()
        )

        if res is None or not res.data:
            return None

        return Profile(**typing.cast(dict[str, typing.Any], res.data))

    @staticmethod
    def update(profile_id: str, update_data: dict) -> Profile:
        """Atualiza campos específicos de um perfil e retorna a entidade atualizada."""
        if not update_data:
            raise ValueError("Dados de atualização não podem estar vazios.")

        res = (
            database.db.table("profiles")
            .update(typing.cast(typing.Any, update_data))
            .eq("id", profile_id)
            .execute()
        )

        if not res.data:
            raise EntityNotFoundException("Perfil não encontrado para atualização.")

        return Profile(**typing.cast(dict[str, typing.Any], res.data[0]))
