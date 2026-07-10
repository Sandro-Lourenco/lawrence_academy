from fastapi import Header, HTTPException, Depends, status
from src.modules.auth.application.auth_service import AuthService
from src.core.exceptions import InvalidCredentialsException

async def get_current_user(authorization: str = Header(None)) -> dict:
    """Valida o cabeçalho Authorization e retorna os dados do usuário autenticado.
    Evita Broken Access Control (BOLA).
    """
    if not authorization or not authorization.startswith("Bearer "):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Token de autenticação ausente ou inválido."
        )
        
    token = authorization.split(" ")[1]
    
    try:
        user_data = AuthService.validate_jwt(token)
        return user_data
    except InvalidCredentialsException as e:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail=e.message
        )
    except Exception:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Credenciais inválidas ou link de verificação expirado."
        )

def require_role(allowed_roles: list[str]):
    """Dependência para verificar se o usuário autenticado possui o papel (role) necessário."""
    def dependency(user: dict = Depends(get_current_user)):
        if user["role"] not in allowed_roles:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Acesso negado. Nível de permissão insuficiente."
            )
        return user
    return dependency
