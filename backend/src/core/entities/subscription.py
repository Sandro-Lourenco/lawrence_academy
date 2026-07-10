from pydantic import BaseModel, ConfigDict, Field
from typing import Optional
from datetime import datetime

class Subscription(BaseModel):
    """Entidade do contexto de pagamentos representando uma assinatura ativa/inativa no Stripe."""
    model_config = ConfigDict(frozen=True, extra="forbid")

    id: Optional[str] = Field(None, description="UUID único da assinatura")
    user_id: str = Field(..., description="UUID do perfil associado (public.profiles)")
    stripe_customer_id: str = Field(..., description="ID único do cliente Stripe")
    stripe_subscription_id: str = Field(..., description="ID único da assinatura Stripe")
    status: str = Field("trialing", description="Status da assinatura (active, past_due, canceled, trialing)")
    current_period_start: datetime = Field(..., description="Início do período atual cobrado")
    current_period_end: datetime = Field(..., description="Fim do período atual cobrado")
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None
