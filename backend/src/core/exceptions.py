class DomainException(Exception):
    """Exceção base para todas as falhas de regra de negócio do domínio."""
    def __init__(self, message: str, code: str = "DOMAIN_ERROR"):
        self.message = message
        self.code = code
        super().__init__(self.message)

class EntityNotFoundException(DomainException):
    """Exceção disparada quando uma entidade solicitada não existe."""
    def __init__(self, message: str = "Entidade não encontrada."):
        super().__init__(message, code="NOT_FOUND")

class AccessDeniedException(DomainException):
    """Exceção disparada quando o usuário não possui permissão de acesso (e.g., BOLA ou assinatura inativa)."""
    def __init__(self, message: str = "Acesso negado. Nível de permissão insuficiente."):
        super().__init__(message, code="ACCESS_DENIED")

class InvalidCredentialsException(DomainException):
    """Exceção disparada para falhas em autenticação ou tokens JWT inválidos/expirados."""
    def __init__(self, message: str = "Credenciais inválidas ou link de verificação expirado."):
        super().__init__(message, code="INVALID_CREDENTIALS")

class DuplicateEntityException(DomainException):
    """Exceção disparada para violações de unicidade (idempotência ou e-mail já cadastrado)."""
    def __init__(self, message: str = "Esta entidade ou evento já foi processado/cadastrado."):
        super().__init__(message, code="DUPLICATE_ENTITY")
