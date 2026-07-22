import os
from pathlib import Path
from pydantic import BaseModel, Field, model_validator
from dotenv import load_dotenv

# Carregar variáveis do arquivo .env na inicialização
_backend_dir = Path(__file__).resolve().parents[2]
_workspace_dir = _backend_dir.parent
load_dotenv(_workspace_dir / ".env")
load_dotenv(_backend_dir / ".env")


class Settings(BaseModel):
    """Configurações da aplicação Lawrence Academy FastAPI.
    Carrega as variáveis de ambiente com defaults seguros e as valida via Pydantic.
    """

    supabase_url: str = Field(default_factory=lambda: os.getenv("SUPABASE_URL", ""))
    supabase_service_key: str = Field(
        default_factory=lambda: (
            os.getenv("SUPABASE_SERVICE_ROLE_KEY")
            or os.getenv("SUPABASE_SERVICE_KEY")
            or os.getenv("SUPABASE_KEY")
            or ""
        )
    )
    supabase_anon_key: str = Field(
        default_factory=lambda: (
            os.getenv("SUPABASE_ANON_KEY")
            or os.getenv("SUPABASE_KEY")
            or os.getenv("SUPABASE_SERVICE_KEY")
            or ""
        )
    )

    stripe_api_key: str = Field(
        default_factory=lambda: (
            os.getenv("STRIPE_SECRET_KEY") or os.getenv("STRIPE_API_KEY") or ""
        )
    )
    stripe_webhook_secret: str = Field(
        default_factory=lambda: os.getenv("STRIPE_WEBHOOK_SECRET", "")
    )

    app_env: str = Field(default_factory=lambda: os.getenv("APP_ENV") or "development")
    payment_provider: str = Field(
        default_factory=lambda: os.getenv("PAYMENT_PROVIDER") or "stripe"
    )

    # Lista de origens permitidas para o CORS
    allowed_origins: list[str] = Field(
        default_factory=lambda: [
            x.strip() for x in os.getenv("ALLOWED_ORIGINS", "*").split(",") if x.strip()
        ]
    )

    @model_validator(mode="after")
    def validate_environment(self) -> "Settings":
        allowed_environments = {"development", "test", "staging", "production"}
        if self.app_env not in allowed_environments:
            raise ValueError(f"APP_ENV must be one of {sorted(allowed_environments)}")
        if self.app_env != "production":
            return self

        required = {
            "SUPABASE_URL": self.supabase_url,
            "SUPABASE_SERVICE_ROLE_KEY": self.supabase_service_key,
            "SUPABASE_ANON_KEY": self.supabase_anon_key,
            "STRIPE_SECRET_KEY": self.stripe_api_key,
            "STRIPE_WEBHOOK_SECRET": self.stripe_webhook_secret,
        }
        invalid = [
            name
            for name, value in required.items()
            if not value.strip() or "placeholder" in value.lower()
        ]
        if invalid:
            raise ValueError(
                "Missing or invalid production settings: " + ", ".join(invalid)
            )
        if not self.supabase_url.startswith("https://"):
            raise ValueError("SUPABASE_URL must use HTTPS in production")
        if not self.allowed_origins or "*" in self.allowed_origins:
            raise ValueError("ALLOWED_ORIGINS must be explicit in production")
        return self


# Instância única global de configurações
settings = Settings()
