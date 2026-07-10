from typing import List, Protocol
from src.modules.subscriptions.domain.entities import Subscription

class SubscriptionRepository(Protocol):
    """Interface (Protocol) de repositório de domínio para Assinaturas (Subscriptions)."""

    async def get_by_student_and_course(self, student_id: str, course_id: str) -> List[Subscription]:
        """Busca todas as assinaturas associadas a um estudante e curso."""
        ...

    async def save(self, subscription: Subscription) -> Subscription:
        """Salva ou atualiza os dados de uma assinatura (upsert)."""
        ...
