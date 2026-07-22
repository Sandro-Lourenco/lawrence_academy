from dataclasses import dataclass
from datetime import datetime, timezone
from typing import Optional

from src.modules.subscriptions.domain.repositories import SubscriptionRepository
from src.modules.courses.domain.repositories import CourseRepository
from src.core.errors.errors import NotFoundError


@dataclass
class CheckoutEligibilityResult:
    can_purchase: bool
    has_access: bool
    reason_code: Optional[str]
    message: Optional[str]
    subscription_status: Optional[str]
    course_id: str


class ValidateCheckoutEligibilityUseCase:
    """
    UseCase do contexto Payments: valida se o estudante pode iniciar um checkout.

    Consulta o repositório de Subscriptions (via interface) para verificar:
    - assinatura ativa ou em trialing => não elegível para compra, tem acesso
    - assinatura past_due dentro do grace period de 5 dias => não elegível para compra, tem acesso
    """

    def __init__(
        self,
        subscription_repository: SubscriptionRepository,
        course_repository: CourseRepository | None = None,
    ) -> None:
        self.repo = subscription_repository
        self.course_repo = course_repository

    async def execute(
        self, student_id: str, course_id: str
    ) -> CheckoutEligibilityResult:
        if self.course_repo is not None:
            course = await self.course_repo.get_by_id(course_id)
            if course is None or course.status != "published":
                raise NotFoundError("Curso publicado não encontrado.")
            if course.monthly_price <= 0:
                return CheckoutEligibilityResult(
                    can_purchase=False,
                    has_access=True,
                    reason_code="FREE_COURSE",
                    message="Este curso é gratuito e já está liberado para você.",
                    subscription_status="free",
                    course_id=course_id,
                )

        subs = await self.repo.get_by_student_and_course(student_id, course_id)

        # Consider the most relevant subscription if multiple exist (active over others)
        for sub in subs:
            if sub.status in ("active", "trialing"):
                return CheckoutEligibilityResult(
                    can_purchase=False,
                    has_access=True,
                    reason_code="ALREADY_ACTIVE",
                    message="Você já possui uma assinatura ativa para este curso.",
                    subscription_status=sub.status,
                    course_id=course_id,
                )

            if sub.status == "past_due" and sub.current_period_end:
                now = datetime.now(timezone.utc)
                period_end = sub.current_period_end
                if period_end.tzinfo is None:
                    period_end = period_end.replace(tzinfo=timezone.utc)
                diff = now - period_end
                if diff.days <= 5:  # Grace period: 5 dias após vencimento
                    return CheckoutEligibilityResult(
                        can_purchase=False,
                        has_access=True,
                        reason_code="GRACE_PERIOD",
                        message="Você possui uma assinatura em período de carência para este curso.",
                        subscription_status=sub.status,
                        course_id=course_id,
                    )
                else:
                    return CheckoutEligibilityResult(
                        can_purchase=True,
                        has_access=False,
                        reason_code="PAST_DUE_EXPIRED",
                        message="Sua assinatura está com pagamento pendente e o período de carência expirou.",
                        subscription_status=sub.status,
                        course_id=course_id,
                    )

        return CheckoutEligibilityResult(
            can_purchase=True,
            has_access=False,
            reason_code=None,
            message=None,
            subscription_status="none",
            course_id=course_id,
        )
