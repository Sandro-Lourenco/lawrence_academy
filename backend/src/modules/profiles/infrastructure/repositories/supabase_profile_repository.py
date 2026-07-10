from typing import Optional
from supabase import Client
from src.modules.profiles.domain.entities import Profile
from src.modules.profiles.domain.repositories import ProfileRepository
from src.core.errors.errors import NotFoundError

class SupabaseProfileRepository(ProfileRepository):
    """Implementação Supabase para o repositório de perfis."""
    
    def __init__(self, client: Client):
        self.client = client
        
    async def get_by_id(self, user_id: str) -> Optional[Profile]:
        res = self.client.table("profiles") \
            .select("*") \
            .eq("id", user_id) \
            .maybe_single() \
            .execute()
            
        if not res.data:
            return None
            
        return Profile(
            id=res.data["id"],
            email=res.data["email"],
            full_name=res.data.get("full_name"),
            referred_by=res.data.get("referred_by"),
            role=res.data.get("role", "student")
        )
        
    async def update(self, user_id: str, full_name: Optional[str], referred_by: Optional[str]) -> Profile:
        update_data = {}
        if full_name is not None:
            update_data["full_name"] = full_name
        if referred_by is not None:
            update_data["referred_by"] = referred_by
            
        res = self.client.table("profiles") \
            .update(update_data) \
            .eq("id", user_id) \
            .execute()
            
        if not res.data:
            raise NotFoundError("Perfil não encontrado para atualização.")
            
        row = res.data[0]
        return Profile(
            id=row["id"],
            email=row["email"],
            full_name=row.get("full_name"),
            referred_by=row.get("referred_by"),
            role=row.get("role", "student")
        )
