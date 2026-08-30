import pytest
from pydantic import ValidationError

from src.modules.payments.interface.api.routes import CheckoutRequestSchema
from src.shared.config import settings


def checkout_payload(url: str) -> dict[str, str]:
    return {
        "course_id": "00000000-0000-0000-0000-000000000001",
        "success_url": url,
        "cancel_url": "https://lawrenceacademy.com/cancel",
    }


def test_production_checkout_accepts_only_the_configured_public_origin(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    monkeypatch.setattr(settings, "app_env", "production")
    monkeypatch.setattr(settings, "public_web_url", "https://lawrenceacademy.com")

    payload = CheckoutRequestSchema.model_validate(
        checkout_payload(
            "https://lawrenceacademy.com/payment/pending/{CHECKOUT_SESSION_ID}"
        )
    )

    assert payload.success_url.startswith("https://lawrenceacademy.com/")


def test_production_checkout_rejects_open_redirects(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    monkeypatch.setattr(settings, "app_env", "production")
    monkeypatch.setattr(settings, "public_web_url", "https://lawrenceacademy.com")

    with pytest.raises(ValidationError, match="domínio público configurado"):
        CheckoutRequestSchema.model_validate(
            checkout_payload("https://evil.example/payment/pending/session")
        )
