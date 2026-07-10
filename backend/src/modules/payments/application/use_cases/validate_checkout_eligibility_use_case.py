from datetime import datetime, timezone

from src.core.errors.errors import ConflictError
from src.modules.subscriptions.domain.repositories import SubscriptionRepository


class ValidateCheckoutEligibilityUseCase:
    """
    UseCase do contexto Payments: valida se o estudante pode iniciar um checkout.

    Consulta o repositório de Subscriptions (via interface) para verificar:
    - assinatura ativa ou em trialing => ConflictError
    - assinatura past_due dentro do grace period de 5 dias => ConflictError

    A lógica de acesso/ciclo/cancelamento/expiração pertence ao contexto
    Subscriptions; este UseCase apenas consulta o contrato de domínio.
    """

    def __init__(self, subscription_repository: SubscriptionRepository) -> None:
        self.repo = subscription_repository

    async def execute(self, student_id: str, course_id: str) -> None:
        """
        Levanta ConflictError se já existir assinatura bloqueante.
        Retorna None (sem exceção) quando o checkout pode prosseguir.
        """
        subs = await self.repo.get_by_student_and_course(student_id, course_id)
        for sub in subs:
            if sub.status in ("active", "trialing"):
                raise ConflictError(
                    "Você já possui uma assinatura ativa para este curso."
                )
            if sub.status == "past_due" and sub.current_period_end:
                now = datetime.now(timezone.utc)
                period_end = sub.current_period_end
                # Garantir que ambos têm timezone info para comparação
                if period_end.tzinfo is None:
                    period_end = period_end.replace(tzinfo=timezone.utc)
                diff = now - period_end
                if diff.days <= 5:  # Grace period: 5 dias após vencimento
                    raise ConflictError(
                        "Você já possui uma assinatura ativa (em período de carência de 5 dias) para este curso."
                    )
