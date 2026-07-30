from dataclasses import replace
from datetime import datetime, timedelta, timezone
from decimal import Decimal

import pytest

from src.core.errors.errors import ValidationError
from src.modules.courses.domain.entities import Course
from src.modules.courses.domain.offer_rules import validate_course_offer


def _course(**changes: object) -> Course:
    course = Course(
        id="course-id",
        instructor_id="teacher-id",
        title="Modelagem",
        slug="modelagem",
        summary="Curso completo de modelagem.",
        monthly_price=Decimal("59.90"),
    )
    return replace(course, **changes)


def test_paid_course_accepts_valid_promotion_period() -> None:
    starts_at = datetime.now(timezone.utc)
    course = _course(
        promotional_monthly_price=Decimal("39.90"),
        promotion_starts_at=starts_at,
        promotion_ends_at=starts_at + timedelta(days=7),
    )

    validate_course_offer(course)


@pytest.mark.parametrize(
    "course",
    [
        _course(monthly_price=Decimal("0"), promotional_monthly_price=Decimal("0")),
        _course(promotional_monthly_price=Decimal("59.90")),
        _course(availability="scheduled", scheduled_publish_at=None),
    ],
)
def test_invalid_financial_or_schedule_rules_are_rejected(course: Course) -> None:
    with pytest.raises(ValidationError):
        validate_course_offer(course)
