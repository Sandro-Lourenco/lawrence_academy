from src.shared import database
from src.core.exceptions import InvalidCredentialsException


class AuthService:
    """Serviço de aplicação para gerenciamento e validação de autenticação via Supabase."""

    @staticmethod
    def validate_jwt(token: str) -> dict:
        """Valida o token JWT seguro do Supabase Auth e decodifica os metadados do usuário."""
        try:
            res = database.auth_db.auth.get_user(token)
            if not res or not res.user:
                raise InvalidCredentialsException(
                    "Sessão expirada ou credenciais inválidas."
                )

            # Mapear claims do usuário decodificado do JWT do Supabase
            return {
                "id": res.user.id,
                "email": res.user.email,
                "role": res.user.app_metadata.get("role", "student"),
                "mfa_enabled": "mfa" in res.user.app_metadata.get("amr", []),
            }
        except Exception:
            # Mascarar erros internos de conexão do banco e reportar como falha de credencial
            raise InvalidCredentialsException(
                "Credenciais inválidas ou link de verificação expirado."
            )
