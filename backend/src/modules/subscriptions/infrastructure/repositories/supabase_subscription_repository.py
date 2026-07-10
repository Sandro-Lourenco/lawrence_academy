from typing import List
from decimal import Decimal
from datetime import datetime
from supabase import Client

from src.modules.subscriptions.domain.entities import Subscription
from src.modules.subscriptions.domain.repositories import SubscriptionRepository


class SupabaseSubscriptionRepository(SubscriptionRepository):
    """Implementação Supabase para repositório de Assinaturas."""

    def __init__(self, client: Client):
        self.client = client

    def _map_row(self, row: dict) -> Subscription:
        def _parse_dt(val) -> datetime | None:
            if not val:
                return None
            return datetime.fromisoformat(val.replace("Z", "+00:00"))

        return Subscription(
            id=row.get("id"),
            student_id=row.get("student_id", ""),
            course_id=row.get("course_id", ""),
            provider=row.get("provider", "stripe"),
            provider_customer_id=row.get("provider_customer_id"),
            provider_subscription_id=row.get("provider_subscription_id"),
            status=row.get("status", "trialing"),
            monthly_price=Decimal(str(row["monthly_price"])) if row.get("monthly_price") is not None else Decimal("0.00"),
            currency=row.get("currency", "BRL"),
            current_period_start=_parse_dt(row.get("current_period_start")) or datetime.utcnow(),
            current_period_end=_parse_dt(row.get("current_period_end")) or datetime.utcnow(),
            cancel_at_period_end=row.get("cancel_at_period_end", False),
            canceled_at=_parse_dt(row.get("canceled_at")),
            created_at=_parse_dt(row.get("created_at")),
            updated_at=_parse_dt(row.get("updated_at")),
            deleted_at=_parse_dt(row.get("deleted_at")),
        )

    async def get_by_student_and_course(self, student_id: str, course_id: str) -> List[Subscription]:
        res = (
            self.client.table("subscriptions")
            .select("*")
            .eq("student_id", student_id)
            .eq("course_id", course_id)
            .execute()
        )
        return [self._map_row(r) for r in (res.data or [])]

    async def save(self, subscription: Subscription) -> Subscription:
        data = {
            "student_id": subscription.student_id,
            "course_id": subscription.course_id,
            "provider": subscription.provider,
            "provider_customer_id": subscription.provider_customer_id,
            "provider_subscription_id": subscription.provider_subscription_id,
            "status": subscription.status,
            "monthly_price": float(subscription.monthly_price),
            "currency": subscription.currency,
            "current_period_start": subscription.current_period_start.isoformat(),
            "current_period_end": subscription.current_period_end.isoformat(),
            "cancel_at_period_end": subscription.cancel_at_period_end,
        }
        res = (
            self.client.table("subscriptions")
            .upsert(data, on_conflict="provider_subscription_id")
            .execute()
        )
        row = res.data[0] if isinstance(res.data, list) and res.data else data
        return self._map_row(row)
