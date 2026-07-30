from types import SimpleNamespace

import pytest

from src.modules.payments.application.process_webhook import (
    _stripe_subscription_price,
)


def test_extracts_price_from_current_stripe_subscription_items() -> None:
    subscription = SimpleNamespace(
        items=SimpleNamespace(
            data=[SimpleNamespace(price=SimpleNamespace(unit_amount=5990, currency="brl"))]
        ),
        plan=None,
    )

    assert _stripe_subscription_price(subscription) == (59.90, "BRL")


def test_supports_legacy_plan_payload() -> None:
    subscription = SimpleNamespace(
        items=None,
        plan=SimpleNamespace(amount=8990, currency="brl"),
    )

    assert _stripe_subscription_price(subscription) == (89.90, "BRL")


def test_rejects_subscription_without_price_instead_of_granting_wrong_plan() -> None:
    subscription = SimpleNamespace(items=None, plan=None)

    with pytest.raises(ValueError, match="recurring price"):
        _stripe_subscription_price(subscription)
