from fastapi import Header, HTTPException, Depends, status
from pydantic import BaseModel
from src.shared import database


class CurrentUser(BaseModel):
    """Modelo representando o usuário autenticado atual."""

    id: str
    email: str
    role: str
    mfa_enabled: bool = False


async def get_current_user(authorization: str = Header(None)) -> CurrentUser:
    """Valida o cabeçalho Authorization e retorna as informações do usuário autenticado."""
    if not authorization or not authorization.startswith("Bearer "):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Token de autenticação ausente ou inválido.",
        )

    token = authorization.split(" ")[1]

    try:
        res = database.auth_db.auth.get_user(token)
        if not res or not res.user:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Sessão expirada ou credenciais inválidas.",
            )

        return CurrentUser(
            id=res.user.id,
            email=res.user.email or "",
            role=res.user.app_metadata.get("role", "student"),
            mfa_enabled="mfa" in res.user.app_metadata.get("amr", []),
        )
    except Exception:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Credenciais inválidas ou link de verificação expirado.",
        )


def require_role(allowed_roles: list[str]):
    """Dependência para verificar se o usuário autenticado possui o papel (role) necessário."""

    def dependency(user: CurrentUser = Depends(get_current_user)) -> CurrentUser:
        if user.role not in allowed_roles:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Acesso negado. Nível de permissão insuficiente.",
            )
        return user

    return dependency
