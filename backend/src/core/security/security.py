from fastapi import Depends, Header, HTTPException, status, Cookie
import jwt
from pydantic import BaseModel

from src.core.concurrency import run_sync_io
from src.shared import database
from src.shared.config import settings


_APPLICATION_ROLES = {"student", "teacher", "admin", "super_admin"}


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

    claims = _decode_verified_token_claims(token)
    token_metadata = claims.get("app_metadata")
    fallback_metadata = res.user.app_metadata or {}
    app_metadata = token_metadata if isinstance(token_metadata, dict) else fallback_metadata
    claimed_role = app_metadata.get("role") or claims.get("user_role")
    role = claimed_role if claimed_role in _APPLICATION_ROLES else "student"
    amr = claims.get("amr")
    legacy_amr = fallback_metadata.get("amr", [])
    mfa_enabled = claims.get("aal") == "aal2" or _amr_contains_mfa(amr or legacy_amr)

    return CurrentUser(
        id=res.user.id,
        email=res.user.email or "",
        role=role,
        mfa_enabled=mfa_enabled,
    )


def _decode_verified_token_claims(token: str) -> dict:
    """Decode claims only after Supabase has verified the same bearer token."""
    try:
        payload = jwt.decode(
            token,
            options={"verify_signature": False, "verify_aud": False},
        )
        return payload if isinstance(payload, dict) else {}
    except jwt.PyJWTError:
        return {}


def _amr_contains_mfa(amr: object) -> bool:
    if not isinstance(amr, list):
        return False
    for item in amr:
        if item == "mfa":
            return True
        if isinstance(item, dict) and item.get("method") in {"mfa", "totp"}:
            return True
    return False


def require_role(allowed_roles: list[str]):
    """Dependência para verificar se o usuário autenticado possui o papel (role) necessário."""

    def dependency(user: CurrentUser = Depends(get_current_user)) -> CurrentUser:
        if user.role not in allowed_roles:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Acesso negado. Nível de permissão insuficiente.",
            )
        if (
            settings.app_env == "production"
            and user.role in {"admin", "super_admin"}
            and not user.mfa_enabled
        ):
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Acesso administrativo exige segundo fator de autenticação.",
            )
        return user

    return dependency
