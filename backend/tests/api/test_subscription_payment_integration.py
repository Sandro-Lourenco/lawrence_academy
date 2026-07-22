from dataclasses import replace
from datetime import datetime, timedelta, timezone
from decimal import Decimal
from unittest.mock import MagicMock, patch

import pytest
from fastapi.testclient import TestClient

from src.core.errors.errors import NotFoundError
from src.core.security.security import CurrentUser, get_current_user
from src.main import app
from src.modules.subscriptions.domain.entities import CheckoutStatus, Subscription
from src.modules.subscriptions.interface.api.dependencies import (
    get_checkout_gateway,
    get_subscription_gateway,
    get_subscription_repository,
)
from src.modules.courses.domain.entities import Course
from src.modules.courses.interface.api.dependencies import get_course_repository


NOW = datetime(2026, 7, 13, tzinfo=timezone.utc)


def make_subscription(**changes: object) -> Subscription:
    subscription = Subscription(
        id="subscription-1",
        student_id="student-1",
        course_id="course-1",
        provider="stripe",
        provider_subscription_id="stripe-subscription-1",
        status="active",
        monthly_price=Decimal("89.90"),
        currency="BRL",
        current_period_start=NOW,
        current_period_end=NOW + timedelta(days=30),
        created_at=NOW,
        updated_at=NOW,
    )
    return replace(subscription, **changes)


class FakeSubscriptionRepository:
    def __init__(self, subscription: Subscription | None) -> None:
        self.subscription = subscription

    async def get_by_student_and_course(
        self, student_id: str, course_id: str
    ) -> list[Subscription]:
        if (
            self.subscription
            and self.subscription.student_id == student_id
            and self.subscription.course_id == course_id
        ):
            return [self.subscription]
        return []

    async def get_by_student(self, student_id: str) -> list[Subscription]:
        if self.subscription and self.subscription.student_id == student_id:
            return [self.subscription]
        return []

    async def get_by_id(self, subscription_id: str) -> Subscription | None:
        if self.subscription and self.subscription.id == subscription_id:
            return self.subscription
        return None

    async def mark_cancel_at_period_end(
        self, subscription_id: str, canceled_at: datetime
    ) -> Subscription:
        assert self.subscription is not None
        assert self.subscription.id == subscription_id
        self.subscription = replace(
            self.subscription,
            cancel_at_period_end=True,
            canceled_at=canceled_at,
            updated_at=canceled_at,
        )
        return self.subscription

    async def save(self, subscription: Subscription) -> Subscription:
        self.subscription = subscription
        return subscription


class FakeSubscriptionGateway:
    def __init__(self) -> None:
        self.cancelled_provider_ids: list[str] = []

    async def cancel_at_period_end(self, subscription: Subscription) -> None:
        assert subscription.provider_subscription_id is not None
        self.cancelled_provider_ids.append(subscription.provider_subscription_id)


class FakeCheckoutGateway:
    def __init__(
        self,
        status: str = "paid",
        owner_id: str = "student-1",
        missing: bool = False,
    ) -> None:
        self.status = status
        self.owner_id = owner_id
        self.missing = missing

    async def get_status(
        self, checkout_id: str, expected_owner_id: str
    ) -> CheckoutStatus:
        if self.missing:
            raise NotFoundError("Checkout não encontrado.")
        return CheckoutStatus(
            checkout_id=checkout_id,
            owner_id=self.owner_id,
            status=self.status,
            payment_status="paid" if self.status == "paid" else "unpaid",
            subscription_status="active" if self.status == "paid" else None,
            created_at=NOW,
            updated_at=NOW,
            checkout_url="https://checkout.stripe.test/session"
            if self.status == "pending"
            else None,
        )


class FakeCourseRepository:
    def __init__(self, monthly_price: Decimal, status: str = "published") -> None:
        self.course = Course(
            id="course-1",
            instructor_id="teacher-1",
            title="Curso de Costura",
            slug="curso-de-costura",
            summary="Curso publicado para testes",
            monthly_price=monthly_price,
            status=status,
        )

    async def get_by_id(self, course_id: str) -> Course | None:
        return self.course if course_id == self.course.id else None


async def current_user() -> CurrentUser:
    return CurrentUser(id="student-1", email="student@example.com", role="student")


client = TestClient(app)


def configure_dependencies(
    repository: FakeSubscriptionRepository | None = None,
    subscription_gateway: FakeSubscriptionGateway | None = None,
    checkout_gateway: FakeCheckoutGateway | None = None,
    course_repository: FakeCourseRepository | None = None,
) -> None:
    app.dependency_overrides[get_current_user] = current_user
    if repository is not None:
        app.dependency_overrides[get_subscription_repository] = lambda: repository
    if subscription_gateway is not None:
        app.dependency_overrides[get_subscription_gateway] = (
            lambda: subscription_gateway
        )
    if checkout_gateway is not None:
        app.dependency_overrides[get_checkout_gateway] = lambda: checkout_gateway
    if course_repository is not None:
        app.dependency_overrides[get_course_repository] = lambda: course_repository


def test_free_course_is_immediately_accessible_without_checkout() -> None:
    configure_dependencies(
        repository=FakeSubscriptionRepository(None),
        course_repository=FakeCourseRepository(Decimal("0.00")),
    )
    try:
        response = client.get(
            "/api/v1/payments/checkout/eligibility?course_id=course-1"
        )
    finally:
        app.dependency_overrides.clear()

    assert response.status_code == 200
    assert response.json() == {
        "can_purchase": False,
        "has_access": True,
        "reason_code": "FREE_COURSE",
        "message": "Este curso é gratuito e já está liberado para você.",
        "subscription_status": "free",
        "course_id": "course-1",
    }


def test_paid_published_course_is_eligible_for_checkout() -> None:
    configure_dependencies(
        repository=FakeSubscriptionRepository(None),
        course_repository=FakeCourseRepository(Decimal("59.90")),
    )
    try:
        response = client.get(
            "/api/v1/payments/checkout/eligibility?course_id=course-1"
        )
    finally:
        app.dependency_overrides.clear()

    assert response.status_code == 200
    assert response.json()["can_purchase"] is True
    assert response.json()["has_access"] is False


def test_checkout_uses_server_course_price_instead_of_client_price() -> None:
    configure_dependencies(
        repository=FakeSubscriptionRepository(None),
        course_repository=FakeCourseRepository(Decimal("59.90")),
    )
    session = MagicMock(id="checkout-1", url="https://checkout.stripe.test/1")
    try:
        with (
            patch(
                "src.modules.payments.interface.api.routes.settings.app_env",
                "development",
            ),
            patch(
                "src.modules.payments.interface.api.routes.settings.payment_provider",
                "stripe",
            ),
            patch(
                "src.modules.payments.interface.api.routes.stripe.checkout.Session.create",
                return_value=session,
            ) as create_session,
        ):
            response = client.post(
                "/api/v1/payments/checkout",
                headers={"Idempotency-Key": "checkout-attempt-1"},
                json={
                    "course_id": "course-1",
                    "success_url": "lawrence://payment/pending?session_id={CHECKOUT_SESSION_ID}",
                    "cancel_url": "lawrence://payment/cancel",
                },
            )
    finally:
        app.dependency_overrides.clear()

    assert response.status_code == 200
    call = create_session.call_args.kwargs
    assert call["line_items"][0]["price_data"]["unit_amount"] == 5990
    assert call["line_items"][0]["price_data"]["recurring"] == {
        "interval": "month"
    }
    assert call["idempotency_key"] == "checkout-attempt-1"


def test_cancel_subscription_returns_updated_state() -> None:
    repository = FakeSubscriptionRepository(make_subscription())
    gateway = FakeSubscriptionGateway()
    configure_dependencies(repository, gateway)
    try:
        response = client.patch(
            "/api/v1/subscriptions/subscription-1/cancel"
        )
    finally:
        app.dependency_overrides.clear()

    assert response.status_code == 200
    assert response.json()["cancel_at_period_end"] is True
    assert response.json()["has_access"] is True
    assert gateway.cancelled_provider_ids == ["stripe-subscription-1"]


def test_cancel_subscription_not_found() -> None:
    configure_dependencies(FakeSubscriptionRepository(None), FakeSubscriptionGateway())
    try:
        response = client.patch("/api/v1/subscriptions/missing/cancel")
    finally:
        app.dependency_overrides.clear()
    assert response.status_code == 404


def test_cancel_subscription_rejects_other_owner() -> None:
    repository = FakeSubscriptionRepository(
        make_subscription(student_id="student-2")
    )
    gateway = FakeSubscriptionGateway()
    configure_dependencies(repository, gateway)
    try:
        response = client.patch(
            "/api/v1/subscriptions/subscription-1/cancel"
        )
    finally:
        app.dependency_overrides.clear()
    assert response.status_code == 403
    assert gateway.cancelled_provider_ids == []


def test_cancel_subscription_rejects_duplicate() -> None:
    repository = FakeSubscriptionRepository(
        make_subscription(cancel_at_period_end=True, canceled_at=NOW)
    )
    gateway = FakeSubscriptionGateway()
    configure_dependencies(repository, gateway)
    try:
        response = client.patch(
            "/api/v1/subscriptions/subscription-1/cancel"
        )
    finally:
        app.dependency_overrides.clear()
    assert response.status_code == 409
    assert gateway.cancelled_provider_ids == []


@pytest.mark.parametrize(
    "checkout_status",
    ["pending", "processing", "paid", "expired", "failed", "cancelled"],
)
def test_checkout_status_contract_covers_canonical_states(
    checkout_status: str,
) -> None:
    configure_dependencies(checkout_gateway=FakeCheckoutGateway(checkout_status))
    try:
        response = client.get("/api/v1/payments/checkout/status/checkout-1")
    finally:
        app.dependency_overrides.clear()

    assert response.status_code == 200
    body = response.json()
    assert body["status"] == checkout_status
    assert body["payment_status"] in ("paid", "unpaid")
    assert body["created_at"]
    assert body["updated_at"]
    assert "checkout_url" in body


def test_checkout_status_rejects_other_owner() -> None:
    configure_dependencies(
        checkout_gateway=FakeCheckoutGateway(owner_id="student-2")
    )
    try:
        response = client.get("/api/v1/payments/checkout/status/checkout-1")
    finally:
        app.dependency_overrides.clear()
    assert response.status_code == 403


def test_checkout_status_not_found() -> None:
    configure_dependencies(checkout_gateway=FakeCheckoutGateway(missing=True))
    try:
        response = client.get("/api/v1/payments/checkout/status/missing")
    finally:
        app.dependency_overrides.clear()
    assert response.status_code == 404


@pytest.mark.parametrize(
    "path,method",
    [
        ("/api/v1/subscriptions/subscription-1/cancel", "patch"),
        ("/api/v1/payments/checkout/status/checkout-1", "get"),
    ],
)
def test_financial_endpoints_require_authentication(path: str, method: str) -> None:
    response = getattr(client, method)(path)
    assert response.status_code == 401
