from unittest.mock import AsyncMock

import pytest
from fastapi import HTTPException

from src.modules.course_completion.application.use_cases import (
    GetCourseCompletionUseCase,
    SubmitCourseReviewUseCase,
)
from src.modules.course_completion.domain.entities import CourseCompletion


def completion(progress: int, *, final: bool, reviewed: bool = False):
    return CourseCompletion(
        course_id="course-1",
        progress_percentage=progress,
        lessons_completed=1 if final else 0,
        lessons_required=1,
        activities_completed=1 if progress == 100 else 0,
        activities_required=1,
        learn_more_completed=1 if progress == 100 else 0,
        learn_more_required=1,
        final_lesson_completed=final,
        review_required=progress == 100 and final and not reviewed,
        review_submitted=reviewed,
        certificate_eligible=progress == 100 and final and reviewed,
    )


@pytest.mark.asyncio
async def test_completion_denies_student_without_course_access():
    repository = AsyncMock()
    repository.has_access.return_value = False
    with pytest.raises(HTTPException) as error:
        await GetCourseCompletionUseCase(repository).execute("student-1", "course-1")
    assert error.value.status_code == 403


@pytest.mark.asyncio
async def test_review_is_blocked_before_all_requirements_and_final_lesson():
    repository = AsyncMock()
    repository.has_access.return_value = True
    repository.get_completion.return_value = completion(99, final=False)
    with pytest.raises(HTTPException) as error:
        await SubmitCourseReviewUseCase(repository).execute(
            "student-1", "course-1", 5, "Excelente", "Aprendizado completo."
        )
    assert error.value.status_code == 409
    repository.upsert_review.assert_not_awaited()


@pytest.mark.asyncio
async def test_review_is_saved_after_course_reaches_one_hundred_percent():
    repository = AsyncMock()
    repository.has_access.return_value = True
    repository.get_completion.return_value = completion(100, final=True)
    repository.upsert_review.return_value = {"id": "review-1"}
    result = await SubmitCourseReviewUseCase(repository).execute(
        "student-1", "course-1", 5, "Excelente", "Aprendizado completo."
    )
    assert result == {"id": "review-1"}
    repository.upsert_review.assert_awaited_once()
