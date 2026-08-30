import os
import base64
import json
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
            or ""
        )
    )
    supabase_anon_key: str = Field(
        default_factory=lambda: (
            os.getenv("SUPABASE_ANON_KEY")
            or os.getenv("SUPABASE_PUBLISHABLE_KEY")
            or ""
        )
    )

    stripe_api_key: str = Field(
        default_factory=lambda: os.getenv("STRIPE_SECRET_KEY") or os.getenv("STRIPE_API_KEY") or ""
    )
    stripe_webhook_secret: str = Field(
        default_factory=lambda: os.getenv("STRIPE_WEBHOOK_SECRET", "")
    )
    jwt_secret_key: str = Field(default_factory=lambda: os.getenv("JWT_SECRET_KEY", ""))
    certificate_secret_key: str = Field(
        default_factory=lambda: os.getenv("CERTIFICATE_SECRET_KEY", "")
    )

    app_env: str = Field(default_factory=lambda: os.getenv("APP_ENV") or "development")
    public_web_url: str = Field(
        default_factory=lambda: os.getenv("PUBLIC_WEB_URL") or "http://localhost:18080"
    )
    payment_provider: str = Field(default_factory=lambda: os.getenv("PAYMENT_PROVIDER") or "stripe")

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

        if not self.public_web_url.startswith("https://"):
            public_origins = [
                origin for origin in self.allowed_origins if origin.startswith("https://")
            ]
            if len(public_origins) == 1:
                self.public_web_url = public_origins[0]

        required = {
            "SUPABASE_URL": self.supabase_url,
            "SUPABASE_SERVICE_ROLE_KEY": self.supabase_service_key,
            "SUPABASE_ANON_KEY": self.supabase_anon_key,
            "STRIPE_SECRET_KEY": self.stripe_api_key,
            "STRIPE_WEBHOOK_SECRET": self.stripe_webhook_secret,
            "JWT_SECRET_KEY": self.jwt_secret_key,
            "CERTIFICATE_SECRET_KEY": self.certificate_secret_key,
            "PUBLIC_WEB_URL": self.public_web_url,
        }
        invalid = [
            name
            for name, value in required.items()
            if not value.strip() or "placeholder" in value.lower() or "local_only" in value.lower()
        ]
        if invalid:
            raise ValueError("Missing or invalid production settings: " + ", ".join(invalid))
        if not self.supabase_url.startswith("https://"):
            raise ValueError("SUPABASE_URL must use HTTPS in production")
        if not self.public_web_url.startswith("https://"):
            raise ValueError("PUBLIC_WEB_URL must use HTTPS in production")
        if self.payment_provider != "stripe":
            raise ValueError("PAYMENT_PROVIDER must be stripe in production")
        if not self.allowed_origins or "*" in self.allowed_origins:
            raise ValueError("ALLOWED_ORIGINS must be explicit in production")
        if len(self.jwt_secret_key) < 32:
            raise ValueError("JWT_SECRET_KEY must contain at least 32 characters")
        if len(self.certificate_secret_key) < 32:
            raise ValueError(
                "CERTIFICATE_SECRET_KEY must contain at least 32 characters"
            )
        if not self.stripe_api_key.startswith("sk_live_"):
            raise ValueError("STRIPE_SECRET_KEY must be a live key in production")
        if not self.stripe_webhook_secret.startswith("whsec_"):
            raise ValueError("STRIPE_WEBHOOK_SECRET must be a Stripe webhook secret")
        if self.supabase_service_key == self.supabase_anon_key:
            raise ValueError("Supabase public and service role keys must be different")
        if _supabase_key_role(self.supabase_anon_key) == "service_role":
            raise ValueError("SUPABASE_ANON_KEY cannot contain a service role key")
        if self.supabase_anon_key.startswith("sb_secret_"):
            raise ValueError("SUPABASE_ANON_KEY cannot contain a secret key")
        if self.supabase_service_key.startswith("sb_publishable_"):
            raise ValueError(
                "SUPABASE_SERVICE_ROLE_KEY cannot contain a publishable key"
            )
        return self


def _supabase_key_role(key: str) -> str | None:
    """Read the role claim from legacy Supabase JWT keys without verifying it."""
    parts = key.split(".")
    if len(parts) != 3:
        return None
    try:
        padding = "=" * (-len(parts[1]) % 4)
        payload = json.loads(base64.urlsafe_b64decode(parts[1] + padding))
        role = payload.get("role") if isinstance(payload, dict) else None
        return role if isinstance(role, str) else None
    except (ValueError, json.JSONDecodeError):
        return None


# Instância única global de configurações
settings = Settings()
