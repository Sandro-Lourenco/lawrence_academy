from fastapi import APIRouter, Depends
from pydantic import BaseModel, Field

from src.core.database.database import get_admin_supabase_client
from src.core.security.security import CurrentUser, get_current_user

from ...application.use_cases import (
    CompleteLearnMoreUseCase,
    GetCourseCompletionUseCase,
    SubmitCourseReviewUseCase,
)
from ...infrastructure.supabase_repository import SupabaseCourseCompletionRepository

router = APIRouter(prefix="/api/v1", tags=["Course completion"])


def repository() -> SupabaseCourseCompletionRepository:
    return SupabaseCourseCompletionRepository(get_admin_supabase_client())


class ReviewInput(BaseModel):
    rating: int = Field(ge=1, le=5)
    title: str = Field(min_length=2, max_length=100)
    comment: str = Field(min_length=10, max_length=2000)


@router.get("/courses/{course_id}/completion")
async def completion(
    course_id: str,
    user: CurrentUser = Depends(get_current_user),
    repo: SupabaseCourseCompletionRepository = Depends(repository),
):
    return await GetCourseCompletionUseCase(repo).execute(user.id, course_id)


@router.post("/courses/{course_id}/lessons/{lesson_id}/learn-more/{block_id}/complete")
async def complete_learn_more(
    course_id: str,
    lesson_id: str,
    block_id: str,
    user: CurrentUser = Depends(get_current_user),
    repo: SupabaseCourseCompletionRepository = Depends(repository),
):
    return await CompleteLearnMoreUseCase(repo).execute(
        user.id, course_id, lesson_id, block_id
    )


@router.post("/courses/{course_id}/reviews")
async def submit_review(
    course_id: str,
    payload: ReviewInput,
    user: CurrentUser = Depends(get_current_user),
    repo: SupabaseCourseCompletionRepository = Depends(repository),
):
    return await SubmitCourseReviewUseCase(repo).execute(
        user.id, course_id, payload.rating, payload.title, payload.comment
    )


@router.get("/feedbacks")
async def feedbacks(
    course_id: str | None = None,
    _: CurrentUser = Depends(get_current_user),
    repo: SupabaseCourseCompletionRepository = Depends(repository),
):
    return await repo.list_reviews(course_id)
