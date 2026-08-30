from decimal import Decimal

from src.modules.courses.domain.entities import Course, Lesson, LessonBlock, Module
from src.modules.courses.interface.api.routes import PublicCourseResponseSchema


def test_public_course_contract_excludes_protected_lesson_payloads() -> None:
    course = Course(
        id="course-1",
        instructor_id="teacher-1",
        title="Alta Costura",
        slug="alta-costura",
        summary="Curso publicado",
        status="published",
        monthly_price=Decimal("59.90"),
        trailer_hls_path="private/trailer/master.m3u8",
        trailer_status="ready",
        modules=[
            Module(
                id="module-1",
                course_id="course-1",
                title="Fundamentos",
                status="published",
                lessons=[
                    Lesson(
                        id="lesson-1",
                        module_id="module-1",
                        course_id="course-1",
                        title="Modelagem",
                        hls_storage_path="private/lesson/master.m3u8",
                        material_pdf_url="private/material.pdf",
                        status="published",
                        blocks=[
                            LessonBlock(
                                id="block-1",
                                lesson_id="lesson-1",
                                course_id="course-1",
                                block_type="activity",
                                content={"correct_option": "B"},
                                status="ready",
                            )
                        ],
                    )
                ],
            )
        ],
    )

    payload = PublicCourseResponseSchema.model_validate(
        course, from_attributes=True
    ).model_dump()
    lesson = payload["modules"][0]["lessons"][0]

    assert "trailer_hls_path" not in payload
    assert "hls_storage_path" not in lesson
    assert "material_pdf_url" not in lesson
    assert "blocks" not in lesson
