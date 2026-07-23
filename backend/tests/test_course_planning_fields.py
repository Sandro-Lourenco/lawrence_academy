from unittest.mock import AsyncMock

import pytest
from pydantic import ValidationError

from src.modules.courses.application.use_cases.create_course_use_case import (
    CreateCourseUseCase,
)
from src.modules.courses.interface.api.routes import CourseCreateInputSchema


def _payload() -> dict:
    return {
        "title": "Modelagem feminina",
        "slug": "modelagem-feminina",
        "summary": "Aprenda modelagem do básico ao primeiro vestido.",
        "course_type": "complete",
        "subtitle": "Da tomada de medidas à construção de bases",
        "language": "pt-BR",
        "estimated_duration_minutes": 720,
        "category": "modelagem",
        "level": "iniciante",
        "monthly_price": 0,
        "learning_objectives": ["Tirar medidas com precisão"],
        "target_audience": ["Pessoas iniciantes em modelagem"],
        "requirements": ["Não exige experiência anterior"],
        "required_materials": ["Fita métrica", "Papel kraft"],
        "competencies": ["Construção de bases"],
        "expected_outcomes": ["Criar moldes básicos com autonomia"],
    }


def test_planning_schema_accepts_structured_phase_one_payload() -> None:
    schema = CourseCreateInputSchema.model_validate(_payload())

    assert schema.course_type == "complete"
    assert schema.estimated_duration_minutes == 720
    assert schema.learning_objectives == ["Tirar medidas com precisão"]


@pytest.mark.parametrize(
    ("field", "value"),
    [
        ("course_type", "unknown"),
        ("language", "invalid"),
        ("estimated_duration_minutes", 0),
        ("learning_objectives", [f"Objetivo {index}" for index in range(21)]),
    ],
)
def test_planning_schema_rejects_invalid_domain_values(field: str, value: object) -> None:
    payload = _payload()
    payload[field] = value

    with pytest.raises(ValidationError):
        CourseCreateInputSchema.model_validate(payload)


@pytest.mark.asyncio
async def test_create_use_case_preserves_structured_planning_fields() -> None:
    repository = AsyncMock()
    repository.create.side_effect = lambda course: course

    course = await CreateCourseUseCase(repository).execute(_payload(), "teacher-id")

    assert course.instructor_id == "teacher-id"
    assert course.course_type == "complete"
    assert course.learning_objectives == ["Tirar medidas com precisão"]
    assert course.target_audience == ["Pessoas iniciantes em modelagem"]
    repository.create.assert_awaited_once()
