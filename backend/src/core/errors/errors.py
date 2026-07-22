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

    def __init__(
        self, message: str = "Acesso negado. Nível de permissão insuficiente."
    ):
        super().__init__(message, code="ACCESS_DENIED")


class ValidationError(DomainError):
    """Exceção para falhas de validação de dados de entrada."""

    def __init__(self, message: str = "Dados fornecidos são inválidos."):
        super().__init__(message, code="VALIDATION_ERROR")


class ConflictError(DomainError):
    """Exceção para conflito de recursos ou violação de unicidade (ex: duplicado)."""

    def __init__(
        self, message: str = "Esta entidade ou evento já existe ou foi processado."
    ):
        super().__init__(message, code="CONFLICT")


# Alias genérico para uso externo
AppError = DomainError


class ExternalServiceError(InfrastructureError):
    """Exceção para falhas em serviços externos, mapeada para HTTP 502."""

    def __init__(
        self,
        message: str = "Falha de comunicação com serviço externo.",
        provider: str = "unknown",
        request_id: str = "unknown",
    ):
        super().__init__(message, code="EXTERNAL_SERVICE_ERROR")
        self.provider = provider
        self.request_id = request_id


class ServiceUnavailableError(InfrastructureError):
    """Exceção para indisponibilidade temporária de serviço, mapeada para HTTP 503."""

    def __init__(
        self,
        message: str = "Serviço temporariamente indisponível.",
        retry_after: int | None = None,
    ):
        super().__init__(message, code="SERVICE_UNAVAILABLE")
        self.retry_after = retry_after
