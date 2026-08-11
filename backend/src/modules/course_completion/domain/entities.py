from datetime import datetime
from pydantic import BaseModel, Field


class CourseCompletion(BaseModel):
    course_id: str
    progress_percentage: int = Field(ge=0, le=100)
    lessons_completed: int
    lessons_required: int
    activities_completed: int
    activities_required: int
    learn_more_completed: int
    learn_more_required: int
    final_lesson_completed: bool
    review_required: bool
    review_submitted: bool
    certificate_eligible: bool


class CourseReview(BaseModel):
    id: str
    course_id: str
    student_id: str
    student_name: str
    student_avatar_url: str | None = None
    rating: int = Field(ge=1, le=5)
    title: str
    comment: str
    created_at: datetime
