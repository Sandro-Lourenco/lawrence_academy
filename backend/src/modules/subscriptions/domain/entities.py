from dataclasses import dataclass
from typing import Optional
from decimal import Decimal
from datetime import datetime

@dataclass(frozen=True)
class Subscription:
    """Entidade de Domínio Puro para Assinaturas."""
    student_id: str
    course_id: str
    provider: str
    status: str
    current_period_start: datetime
    current_period_end: datetime
    id: Optional[str] = None
    provider_customer_id: Optional[str] = None
    provider_subscription_id: Optional[str] = None
    monthly_price: Decimal = Decimal("0.00")
    currency: str = "BRL"
    cancel_at_period_end: bool = False
    canceled_at: Optional[datetime] = None
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None
    deleted_at: Optional[datetime] = None
