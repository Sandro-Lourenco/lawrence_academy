from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from urllib.error import URLError
from urllib.request import Request as UrlRequest, urlopen

# Configuração global de inicializações do Stripe

# Configurações do app
from src.shared.config import settings

# Roteadores de cada módulo
from src.modules.profiles.interfaces.routes import router as profiles_router
from src.modules.courses.interfaces.routes import router as courses_router
from src.modules.assessments.interfaces.routes import router as assessments_router
from src.modules.courses.api.router import router as new_courses_router
from src.modules.students.api.router import router as new_students_router

from src.modules.profiles.interface.api.routes import router as profiles_v1_router
from src.modules.courses.interface.api.routes import router as courses_v1_router
from src.modules.courses.interface.api.teacher_routes import (
    router as teacher_courses_v1_router,
)
from src.modules.assessments.interface.api.routes import router as assessments_v1_router
from src.modules.payments.interface.api.routes import (
    router as payments_v1_router,
    legacy_router as payments_legacy_router,
)
from src.modules.subscriptions.interface.api.routes import (
    router as subscriptions_v1_router,
)
from src.modules.sync.interface.api.routes import router as sync_v1_router
from src.modules.certificates.interface.api.routes import (
    router as certificates_v1_router,
    legacy_router as certificates_legacy_router,
)
from src.modules.lives.interface.api.routes import (
    router as live_events_v1_router,
    teacher_router as teacher_live_events_v1_router,
)
from src.modules.invoices.interface.api.routes import router as invoices_v1_router
from src.modules.course_completion.interface.api.routes import (
    router as course_completion_v1_router,
)


from src.core.errors.handlers import install_error_handlers
from slowapi import _rate_limit_exceeded_handler  # type: ignore # slowapi does not provide type stubs
from slowapi.errors import RateLimitExceeded  # type: ignore # slowapi does not provide type stubs
from src.modules.certificates.interface.api.routes import limiter


DEVELOPMENT_ORIGINS = [
    "http://localhost",
    "http://localhost:3000",
    "http://localhost:8080",
    "http://localhost:18080",
    "http://127.0.0.1",
    "http://127.0.0.1:3000",
    "http://127.0.0.1:8080",
    "http://127.0.0.1:18080",
    "http://192.168.137.149",
    "http://192.168.137.149:8000",
    "http://192.168.137.149:3000",
    "http://10.0.2.2",
]


def resolve_cors_origins(configured: list[str], app_env: str) -> list[str]:
    """Return explicit browser origins; wildcard + credentials is not portable."""
    if "*" not in configured and configured:
        return configured
    return DEVELOPMENT_ORIGINS if app_env != "production" else []


app = FastAPI(title="Lawrence Academy API Portal", version="1.0.0")
app.state.limiter = limiter
app.add_exception_handler(RateLimitExceeded, _rate_limit_exceeded_handler)  # type: ignore
install_error_handlers(app)

# Configuração de CORS para suporte ao Flutter Web
origins = resolve_cors_origins(settings.allowed_origins, settings.app_env)

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Acoplar Webhooks e Rotas dos módulos
app.include_router(payments_legacy_router, deprecated=True)
app.include_router(certificates_legacy_router, deprecated=True)
app.include_router(profiles_router, deprecated=True)
app.include_router(courses_router, deprecated=True)
app.include_router(assessments_router, deprecated=True)
app.include_router(new_courses_router, deprecated=True)
app.include_router(new_students_router, deprecated=True)

# Novas rotas v1 padronizadas
app.include_router(profiles_v1_router)
app.include_router(courses_v1_router)
app.include_router(teacher_courses_v1_router)
app.include_router(assessments_v1_router)
app.include_router(payments_v1_router)
app.include_router(subscriptions_v1_router)
app.include_router(sync_v1_router)
app.include_router(certificates_v1_router)
app.include_router(invoices_v1_router)
app.include_router(course_completion_v1_router)
app.include_router(live_events_v1_router)
app.include_router(teacher_live_events_v1_router)


@app.get("/")
def read_root():
    """Rota raiz operacional da API."""
    return {"status": "API da Lawrence Academy Operacional"}


@app.get("/health")
def health_check():
    """Endpoint básico para verificação de saúde da API."""
    return {"status": "healthy"}


@app.get("/live")
def liveness_check():
    """Confirms that the API process can still serve requests."""
    return {"status": "healthy"}


@app.get("/ready")
def readiness_check():
    """Fail closed when the critical authentication upstream is unreachable."""
    if not settings.supabase_url or not settings.supabase_anon_key:
        raise HTTPException(status_code=503, detail="Supabase is not configured.")
    request = UrlRequest(
        f"{settings.supabase_url.rstrip('/')}/auth/v1/health",
        headers={"apikey": settings.supabase_anon_key},
        method="GET",
    )
    try:
        with urlopen(request, timeout=2) as response:
            if not 200 <= response.status < 300:
                raise HTTPException(
                    status_code=503,
                    detail="Authentication service is unavailable.",
                )
    except (OSError, URLError) as exc:
        raise HTTPException(
            status_code=503,
            detail="Authentication service is unavailable.",
        ) from exc
    return {"status": "ready"}
