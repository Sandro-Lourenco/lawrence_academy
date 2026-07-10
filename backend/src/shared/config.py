import os
from pydantic import BaseModel, Field
from dotenv import load_dotenv

# Carregar variáveis do arquivo .env na inicialização
load_dotenv()


class Settings(BaseModel):
    """Configurações da aplicação Lawrence Academy FastAPI.
    Carrega as variáveis de ambiente com defaults seguros e as valida via Pydantic.
    """

    supabase_url: str = Field(
        default_factory=lambda: (
            os.getenv("SUPABASE_URL") or "https://placeholder-url.supabase.co"
        )
    )
    supabase_service_key: str = Field(
        default_factory=lambda: os.getenv("SUPABASE_SERVICE_KEY") or "placeholder-key"
    )
    supabase_anon_key: str = Field(
        default_factory=lambda: (
            os.getenv("SUPABASE_ANON_KEY")
            or os.getenv("SUPABASE_SERVICE_KEY")
            or "placeholder-key"
        )
    )

    stripe_api_key: str = Field(
        default_factory=lambda: os.getenv("STRIPE_API_KEY") or "sk_test_placeholder"
    )
    stripe_webhook_secret: str = Field(
        default_factory=lambda: (
            os.getenv("STRIPE_WEBHOOK_SECRET") or "whsec_placeholder"
        )
    )

    app_env: str = Field(default_factory=lambda: os.getenv("APP_ENV") or "production")
    payment_provider: str = Field(
        default_factory=lambda: os.getenv("PAYMENT_PROVIDER") or "stripe"
    )

    # Lista de origens permitidas para o CORS
    allowed_origins: list[str] = Field(
        default_factory=lambda: [
            x.strip() for x in os.getenv("ALLOWED_ORIGINS", "*").split(",") if x.strip()
        ]
    )


# Instância única global de configurações
settings = Settings()
