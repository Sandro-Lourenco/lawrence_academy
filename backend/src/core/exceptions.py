from src.core.errors.errors import (
    DomainError,
    NotFoundError,
    AuthorizationError,
    ConflictError,
    ValidationError
)

# Aliases de compatibilidade para código legado
DomainException = DomainError
EntityNotFoundException = NotFoundError
AccessDeniedException = AuthorizationError
DuplicateEntityException = ConflictError

class InvalidCredentialsException(DomainError):
    """Exceção base de compatibilidade para erros de credencial."""
    def __init__(self, message: str = "Credenciais inválidas ou link de verificação expirado."):
        super().__init__(message, code="INVALID_CREDENTIALS")
