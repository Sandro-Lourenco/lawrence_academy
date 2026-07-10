class DomainError(Exception):
    """Exceção base para todas as falhas de regra de negócio do domínio."""
    def __init__(self, message: str, code: str = "DOMAIN_ERROR"):
        self.message = message
        self.code = code
        super().__init__(self.message)

class ApplicationError(Exception):
    """Exceção base para falhas na camada de aplicação."""
    def __init__(self, message: str, code: str = "APPLICATION_ERROR"):
        self.message = message
        self.code = code
        super().__init__(self.message)

class InfrastructureError(Exception):
    """Exceção base para falhas na camada de infraestrutura (banco de dados, rede, etc.)."""
    def __init__(self, message: str, code: str = "INFRASTRUCTURE_ERROR"):
        self.message = message
        self.code = code
        super().__init__(self.message)

class NotFoundError(DomainError):
    """Exceção para recursos não encontrados."""
    def __init__(self, message: str = "Recurso não encontrado."):
        super().__init__(message, code="NOT_FOUND")

class AuthorizationError(DomainError):
    """Exceção para permissão de acesso insuficiente."""
    def __init__(self, message: str = "Acesso negado. Nível de permissão insuficiente."):
        super().__init__(message, code="ACCESS_DENIED")

class ValidationError(DomainError):
    """Exceção para falhas de validação de dados de entrada."""
    def __init__(self, message: str = "Dados fornecidos são inválidos."):
        super().__init__(message, code="VALIDATION_ERROR")

class ConflictError(DomainError):
    """Exceção para conflito de recursos ou violação de unicidade (ex: duplicado)."""
    def __init__(self, message: str = "Esta entidade ou evento já existe ou foi processado."):
        super().__init__(message, code="CONFLICT")
