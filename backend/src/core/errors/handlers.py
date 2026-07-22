from fastapi import FastAPI, Request, status
from fastapi.responses import JSONResponse
from src.core.errors.errors import DomainError, ApplicationError, InfrastructureError


def install_error_handlers(app: FastAPI) -> None:
    """Registra handlers de exceção globais no app FastAPI."""

    @app.exception_handler(DomainError)
    async def domain_error_handler(request: Request, exc: DomainError):
        status_code = status.HTTP_400_BAD_REQUEST
        if exc.code == "NOT_FOUND":
            status_code = status.HTTP_404_NOT_FOUND
        elif exc.code == "ACCESS_DENIED":
            status_code = status.HTTP_403_FORBIDDEN
        elif exc.code == "CONFLICT":
            status_code = status.HTTP_409_CONFLICT

        request_id = request.headers.get("X-Request-ID", "unknown")

        return JSONResponse(
            status_code=status_code,
            content={
                "status": "error",
                "error": {"code": exc.code, "message": exc.message},
                "meta": {"request_id": request_id},
            },
        )

    @app.exception_handler(ApplicationError)
    async def application_error_handler(request: Request, exc: ApplicationError):
        request_id = request.headers.get("X-Request-ID", "unknown")
        return JSONResponse(
            status_code=status.HTTP_400_BAD_REQUEST,
            content={
                "status": "error",
                "error": {"code": exc.code, "message": exc.message},
                "meta": {"request_id": request_id},
            },
        )

    @app.exception_handler(InfrastructureError)
    async def infrastructure_error_handler(request: Request, exc: InfrastructureError):
        from src.core.errors.errors import ExternalServiceError, ServiceUnavailableError

        request_id = request.headers.get("X-Request-ID", "unknown")

        if isinstance(exc, ExternalServiceError):
            return JSONResponse(
                status_code=status.HTTP_502_BAD_GATEWAY,
                content={
                    "status": "error",
                    "error": {
                        "code": exc.code,
                        "message": exc.message,
                    },
                    "provider": exc.provider,
                    "request_id": exc.request_id,
                    "meta": {"request_id": request_id},
                },
            )

        if isinstance(exc, ServiceUnavailableError):
            headers = {}
            if exc.retry_after:
                headers["Retry-After"] = str(exc.retry_after)
            return JSONResponse(
                status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
                headers=headers,
                content={
                    "status": "error",
                    "error": {
                        "code": exc.code,
                        "message": exc.message,
                    },
                    "meta": {"request_id": request_id},
                },
            )

        request_id = request.headers.get("X-Request-ID", "unknown")
        # Nunca expor erro técnico crú em produção
        return JSONResponse(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            content={
                "status": "error",
                "error": {
                    "code": "INTERNAL_SERVER_ERROR",
                    "message": "Ocorreu um erro interno de processamento de dados.",
                },
                "meta": {"request_id": request_id},
            },
        )
