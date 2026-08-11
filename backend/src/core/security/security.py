from fastapi import Depends, Header, HTTPException, status, Cookie
from pydantic import BaseModel

from src.core.concurrency import run_sync_io
from src.shared import database


class CurrentUser(BaseModel):
    """Modelo representando o usuário autenticado atual."""

    id: str
    email: str
    role: str
    mfa_enabled: bool = False


async def get_current_user(
    authorization: str | None = Header(None),
    sb_access_token: str | None = Cookie(None, alias="sb-access-token"),
    access_token: str | None = Cookie(None, alias="access_token"),
) -> CurrentUser:
    """Valida o cabeçalho Authorization ou cookies e retorna as informações do usuário autenticado."""
    token = None
    if authorization and authorization.startswith("Bearer "):
        token = authorization.split(" ")[1]
    elif sb_access_token:
        token = sb_access_token
    elif access_token:
        token = access_token

    if not token:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Token de autenticação ausente ou inválido.",
        )

    try:
        res = await run_sync_io(database.auth_db.auth.get_user, token)
    except Exception:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Credenciais inválidas ou link de verificação expirado.",
        ) from None

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
