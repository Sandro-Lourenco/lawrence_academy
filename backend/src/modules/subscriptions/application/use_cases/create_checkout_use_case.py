from datetime import datetime, timezone
from src.modules.subscriptions.domain.repositories import SubscriptionRepository
from src.core.errors.errors import ConflictError


class CreateCheckoutUseCase:
    """Valida se o estudante pode criar um checkout (sem assinatura ativa/grace period)."""

    def __init__(self, subscription_repository: SubscriptionRepository):
        self.repo = subscription_repository

    async def validate(self, student_id: str, course_id: str) -> None:
        """
        Levanta ConflictError se já existir assinatura ativa, trialing ou em grace period.
        Sem exceção = checkout pode prosseguir.
        """
        subs = await self.repo.get_by_student_and_course(student_id, course_id)
        for sub in subs:
            if sub.status in ("active", "trialing"):
                raise ConflictError("Você já possui uma assinatura ativa para este curso.")
            if sub.status == "past_due" and sub.current_period_end:
                diff = datetime.now(timezone.utc) - sub.current_period_end
                if diff.days <= 5:
                    raise ConflictError(
                        "Você já possui uma assinatura ativa (em período de carência) para este curso."
                    )
