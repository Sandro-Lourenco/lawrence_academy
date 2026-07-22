from datetime import datetime
from typing import List, Optional, Protocol
from src.modules.subscriptions.domain.entities import Subscription


class SubscriptionRepository(Protocol):
    """Interface (Protocol) de repositório de domínio para Assinaturas (Subscriptions)."""

    async def get_by_student_and_course(
        self, student_id: str, course_id: str
    ) -> List[Subscription]:
        """Busca todas as assinaturas associadas a um estudante e curso."""
        ...

    async def get_by_student(self, student_id: str) -> List[Subscription]:
        """Busca todas as assinaturas de um estudante."""
        ...

    async def get_by_id(self, subscription_id: str) -> Optional[Subscription]:
        """Busca uma assinatura por identificador para validação de ownership."""
        ...

    async def mark_cancel_at_period_end(
        self, subscription_id: str, canceled_at: datetime
    ) -> Subscription:
        """Persiste o cancelamento ao fim do período já pago."""
        ...

    async def save(self, subscription: Subscription) -> Subscription:
        """Salva ou atualiza os dados de uma assinatura (upsert)."""
        ...
