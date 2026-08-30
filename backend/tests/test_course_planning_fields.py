from unittest.mock import AsyncMock

import pytest
from pydantic import ValidationError

from src.modules.courses.application.use_cases.create_course_use_case import (
    CreateCourseUseCase,
)
from src.modules.courses.interface.api.routes import CourseCreateInputSchema
from src.modules.courses.interface.api.teacher_routes import CourseUpdateInputSchema


def _payload() -> dict:
    return {
        "title": "Modelagem feminina",
        "slug": "modelagem-feminina",
        "summary": "Aprenda modelagem do básico ao primeiro vestido.",
        "description": "Aprenda modelagem do básico ao primeiro vestido com exercícios práticos.",
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


@pytest.mark.parametrize("category", ["bordado", "negocios", "outros"])
def test_planning_schema_accepts_categories_available_in_teacher_form(category: str) -> None:
    schema = CourseCreateInputSchema.model_validate(_payload() | {"category": category})

    assert schema.category == category


def test_course_update_rejects_conflicting_external_trailer_actions() -> None:
    with pytest.raises(ValidationError):
        CourseUpdateInputSchema.model_validate(
            {
                "expected_authoring_revision": 1,
                "trailer_video_url": "https://youtu.be/dQw4w9WgXcQ",
                "remove_external_trailer": True,
            }
        )


def test_planning_schema_accepts_course_object_prerequisite_ids() -> None:
    payload = _payload()
    payload["prerequisite_course_ids"] = ["aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa"]

    schema = CourseCreateInputSchema.model_validate(payload)

    assert schema.prerequisite_course_ids == ["aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa"]


def test_planning_schema_rejects_non_uuid_course_prerequisite() -> None:
    payload = _payload()
    payload["prerequisite_course_ids"] = ["curso-modelagem"]

    with pytest.raises(ValidationError):
        CourseCreateInputSchema.model_validate(payload)


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


@pytest.mark.asyncio
async def test_create_use_case_derives_technical_fields_from_simplified_form() -> None:
    repository = AsyncMock()
    repository.create.side_effect = lambda course: course

    course = await CreateCourseUseCase(repository).execute(
        {
            "title": "Costura rápida: barra perfeita",
            "description": "Aprenda a fazer uma barra limpa e resistente em poucos passos.",
            "category": "costura",
            "requirements": [],
            "required_materials": ["Máquina de costura"],
            "course_type": "quick",
            "monthly_price": 49.90,
        },
        "teacher-id",
    )

    assert course.slug.startswith("costura-rapida-barra-perfeita-")
    assert course.summary == course.description
    assert course.course_type == "quick"


@pytest.mark.asyncio
async def test_create_course_normalizes_external_trailer_without_storing_url() -> None:
    repository = AsyncMock()
    repository.create.side_effect = lambda course: course

    course = await CreateCourseUseCase(repository).execute(
        _payload() | {"trailer_video_url": "https://youtu.be/dQw4w9WgXcQ"},
        "teacher-id",
    )

    assert course.trailer_source_type == "youtube"
    assert course.trailer_external_video_id == "dQw4w9WgXcQ"
    assert course.trailer_hls_path is None
    assert course.trailer_status == "ready"


@pytest.mark.asyncio
async def test_create_use_case_persists_course_prerequisite_relations() -> None:
    repository = AsyncMock()
    repository.create.side_effect = lambda course: course
    repository.get_by_id.side_effect = lambda _course_id: repository.create.call_args.args[0]
    prerequisite_id = "aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa"
    payload = _payload() | {"prerequisite_course_ids": [prerequisite_id]}

    course = await CreateCourseUseCase(repository).execute(payload, "teacher-id")

    repository.replace_course_prerequisites.assert_awaited_once_with(
        course_id=course.id,
        instructor_id="teacher-id",
        prerequisite_course_ids=[prerequisite_id],
    )
