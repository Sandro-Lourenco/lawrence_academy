from datetime import datetime, timezone
from unittest.mock import MagicMock

import pytest

from src.modules.subscriptions.infrastructure.repositories.supabase_subscription_repository import (
    SupabaseSubscriptionRepository,
)
from src.modules.subscriptions.infrastructure.stripe_gateway import (
    _canonical_checkout_status,
)


SUBSCRIPTION_ROW = {
    "id": "subscription-1",
    "student_id": "student-1",
    "course_id": "course-1",
    "provider": "stripe",
    "provider_subscription_id": "stripe-subscription-1",
    "status": "active",
    "monthly_price": "89.90",
    "currency": "BRL",
    "current_period_start": "2026-07-01T00:00:00+00:00",
    "current_period_end": "2026-08-01T00:00:00+00:00",
    "cancel_at_period_end": False,
    "created_at": "2026-07-01T00:00:00+00:00",
    "updated_at": "2026-07-01T00:00:00+00:00",
}


@pytest.mark.asyncio
async def test_repository_get_by_id_maps_subscription() -> None:
    client = MagicMock()
    response = MagicMock(data=SUBSCRIPTION_ROW)
    client.table.return_value.select.return_value.eq.return_value.maybe_single.return_value.execute.return_value = response
    repository = SupabaseSubscriptionRepository(client)

    subscription = await repository.get_by_id("subscription-1")

    assert subscription is not None
    assert subscription.student_id == "student-1"
    assert subscription.provider_subscription_id == "stripe-subscription-1"
    client.table.assert_called_once_with("subscriptions")


@pytest.mark.asyncio
async def test_repository_persists_period_end_cancellation() -> None:
    client = MagicMock()
    canceled_at = datetime(2026, 7, 13, tzinfo=timezone.utc)
    row = {
        **SUBSCRIPTION_ROW,
        "cancel_at_period_end": True,
        "canceled_at": canceled_at.isoformat(),
        "updated_at": canceled_at.isoformat(),
    }
    response = MagicMock(data=[row])
    update = client.table.return_value.update
    update.return_value.eq.return_value.execute.return_value = response
    repository = SupabaseSubscriptionRepository(client)

    subscription = await repository.mark_cancel_at_period_end(
        "subscription-1", canceled_at
    )

    assert subscription.cancel_at_period_end is True
    update.assert_called_once_with(
        {
            "cancel_at_period_end": True,
            "canceled_at": canceled_at.isoformat(),
            "updated_at": canceled_at.isoformat(),
        }
    )
    update.return_value.eq.assert_called_once_with("id", "subscription-1")


@pytest.mark.parametrize(
    "session_status,payment_status,subscription_status,expected",
    [
        ("open", "unpaid", None, "pending"),
        ("complete", "unpaid", "incomplete", "processing"),
        ("complete", "paid", "active", "paid"),
        ("expired", "unpaid", None, "expired"),
        ("complete", "unpaid", "incomplete_expired", "failed"),
        ("complete", "unpaid", "canceled", "cancelled"),
    ],
)
def test_stripe_states_are_mapped_to_canonical_contract(
    session_status: str,
    payment_status: str,
    subscription_status: str | None,
    expected: str,
) -> None:
    assert (
        _canonical_checkout_status(
            session_status, payment_status, subscription_status
        )
        == expected
    )
