import pytest
from pydantic import ValidationError

from src.shared.config import Settings


def production_settings(**overrides: object) -> Settings:
    values: dict[str, object] = {
        "supabase_url": "https://project.supabase.co",
        "supabase_service_key": "sb_secret_backend",
        "supabase_anon_key": "sb_publishable_frontend",
        "stripe_api_key": "sk_live_example",
        "stripe_webhook_secret": "whsec_example",
        "jwt_secret_key": "a" * 32,
        "certificate_secret_key": "c" * 32,
        "app_env": "production",
        "public_web_url": "https://lawrenceacademy.com",
        "payment_provider": "stripe",
        "allowed_origins": ["https://lawrenceacademy.com"],
    }
    values.update(overrides)
    return Settings(**values)


def test_production_accepts_distinct_publishable_and_secret_keys() -> None:
    settings = production_settings()

    assert settings.supabase_anon_key.startswith("sb_publishable_")
    assert settings.supabase_service_key.startswith("sb_secret_")


@pytest.mark.parametrize(
    ("overrides", "message"),
    [
        (
            {
                "supabase_service_key": "same-key",
                "supabase_anon_key": "same-key",
            },
            "must be different",
        ),
        (
            {"supabase_anon_key": "sb_secret_exposed"},
            "cannot contain a secret key",
        ),
        (
            {"supabase_service_key": "sb_publishable_wrong"},
            "cannot contain a publishable key",
        ),
        (
            {"payment_provider": "fake"},
            "PAYMENT_PROVIDER must be stripe",
        ),
    ],
)
def test_production_rejects_privileged_key_misconfiguration(
    overrides: dict[str, object], message: str
) -> None:
    with pytest.raises(ValidationError, match=message):
        production_settings(**overrides)
