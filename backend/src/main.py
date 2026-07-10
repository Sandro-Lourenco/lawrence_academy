from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

# Configuração global de inicializações do Stripe

# Configurações do app
from src.shared.config import settings

# Roteadores de cada módulo
from src.modules.profiles.interfaces.routes import router as profiles_router
from src.modules.courses.interfaces.routes import router as courses_router
from src.modules.assessments.interfaces.routes import router as assessments_router
from src.modules.payments.interfaces.routes import router as payments_router
from src.modules.courses.api.router import router as new_courses_router
from src.modules.students.api.router import router as new_students_router

from src.modules.profiles.interface.api.routes import router as profiles_v1_router
from src.modules.courses.interface.api.routes import router as courses_v1_router
from src.modules.assessments.interface.api.routes import router as assessments_v1_router
from src.modules.payments.interface.api.routes import router as payments_v1_router

from src.core.errors.handlers import install_error_handlers

app = FastAPI(title="Lawrence Academy API Portal", version="1.0.0")
install_error_handlers(app)

# Configuração de CORS para suporte ao Flutter Web
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.allowed_origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Acoplar Webhooks e Rotas dos módulos
app.include_router(payments_router)
app.include_router(profiles_router)
app.include_router(courses_router)
app.include_router(assessments_router)
app.include_router(new_courses_router)
app.include_router(new_students_router)

# Novas rotas v1 padronizadas
app.include_router(profiles_v1_router)
app.include_router(courses_v1_router)
app.include_router(assessments_v1_router)
app.include_router(payments_v1_router)


@app.get("/")
def read_root():
    """Rota raiz operacional da API."""
    return {"status": "API da Lawrence Academy Operacional"}


@app.get("/health")
def health_check():
    """Endpoint básico para verificação de saúde da API."""
    return {"status": "healthy"}
