import pytest
from pydantic import ValidationError

from src.shared.config import Settings


def production_settings(**overrides: object) -> Settings:
    values: dict[str, object] = {
        "app_env": "production",
        "supabase_url": "https://project.supabase.co",
        "supabase_service_key": "service-role-value",
        "supabase_anon_key": "anon-value",
        "stripe_api_key": "stripe-secret-value",
        "stripe_webhook_secret": "webhook-secret-value",
        "allowed_origins": ["https://app.lawrence.example"],
    }
    values.update(overrides)
    return Settings(**values)


def test_production_configuration_accepts_complete_explicit_values() -> None:
    assert production_settings().app_env == "production"


@pytest.mark.parametrize(
    "field",
    [
        "supabase_url",
        "supabase_service_key",
        "supabase_anon_key",
        "stripe_api_key",
        "stripe_webhook_secret",
    ],
)
def test_production_configuration_rejects_missing_values(field: str) -> None:
    with pytest.raises(ValidationError):
        production_settings(**{field: ""})


def test_production_configuration_rejects_placeholders() -> None:
    with pytest.raises(ValidationError):
        production_settings(stripe_api_key="sk_test_placeholder")


def test_production_configuration_rejects_wildcard_cors() -> None:
    with pytest.raises(ValidationError):
        production_settings(allowed_origins=["*"])


def test_production_configuration_requires_https_supabase() -> None:
    with pytest.raises(ValidationError):
        production_settings(supabase_url="http://project.supabase.co")
