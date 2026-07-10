from fastapi import Header, HTTPException, Depends
from src.core.security.security import get_current_user as core_get_current_user

async def get_current_user(authorization: str = Header(None)) -> dict:
    """Valida o cabeçalho Authorization e retorna os dados do usuário autenticado como dicionário."""
    user = await core_get_current_user(authorization)
    return user.model_dump()

def require_role(allowed_roles: list[str]):
    """Dependência para verificar se o usuário autenticado possui o papel necessário."""
    def dependency(user: dict = Depends(get_current_user)):
        if user["role"] not in allowed_roles:
            raise HTTPException(
                status_code=403,
                detail="Acesso negado. Nível de permissão insuficiente."
            )
        return user
    return dependency
