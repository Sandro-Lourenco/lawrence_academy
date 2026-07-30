from decimal import Decimal

from src.core.errors.errors import ValidationError
from src.modules.courses.domain.entities import Course


def validate_course_offer(course: Course) -> None:
    if course.monthly_price < Decimal("0"):
        raise ValidationError("O valor mensal não pode ser negativo.")

    promotional = course.promotional_monthly_price
    if promotional is not None:
        if course.monthly_price <= Decimal("0"):
            raise ValidationError("Curso gratuito não pode possuir promoção.")
        if promotional < Decimal("0") or promotional >= course.monthly_price:
            raise ValidationError("O preço promocional deve ser menor que o valor mensal.")
        if course.promotion_starts_at is None or course.promotion_ends_at is None:
            raise ValidationError("Informe o início e o fim da promoção.")

    if (course.promotion_starts_at is None) != (course.promotion_ends_at is None):
        raise ValidationError("Informe o início e o fim da promoção.")
    if (
        course.promotion_starts_at is not None
        and course.promotion_ends_at is not None
        and course.promotion_ends_at <= course.promotion_starts_at
    ):
        raise ValidationError("O fim da promoção deve ser posterior ao início.")

    if course.availability == "scheduled" and course.scheduled_publish_at is None:
        raise ValidationError("Informe a data de disponibilidade agendada.")
