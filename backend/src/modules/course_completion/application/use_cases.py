from fastapi import HTTPException, status

from ..domain.entities import CourseCompletion, CourseReview
from ..domain.repositories import CourseCompletionRepository


class GetCourseCompletionUseCase:
    def __init__(self, repository: CourseCompletionRepository):
        self.repository = repository

    async def execute(self, student_id: str, course_id: str) -> CourseCompletion:
        if not await self.repository.has_access(student_id, course_id):
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Curso não disponível para esta conta.",
            )
        return await self.repository.get_completion(student_id, course_id)


class CompleteLearnMoreUseCase:
    def __init__(self, repository: CourseCompletionRepository):
        self.repository = repository

    async def execute(
        self, student_id: str, course_id: str, lesson_id: str, block_id: str
    ) -> CourseCompletion:
        if not await self.repository.has_access(student_id, course_id):
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Curso não disponível para esta conta.",
            )
        return await self.repository.complete_learn_more(
            student_id, course_id, lesson_id, block_id
        )


class SubmitCourseReviewUseCase:
    def __init__(self, repository: CourseCompletionRepository):
        self.repository = repository

    async def execute(
        self, student_id: str, course_id: str, rating: int, title: str, comment: str
    ) -> CourseReview:
        if not await self.repository.has_access(student_id, course_id):
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Curso não disponível para esta conta.",
            )
        completion = await self.repository.get_completion(student_id, course_id)
        if completion.progress_percentage != 100 or not completion.final_lesson_completed:
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail="Conclua aulas, atividades e conteúdos Saber mais antes de avaliar.",
            )
        return await self.repository.upsert_review(
            student_id, course_id, rating, title.strip(), comment.strip()
        )
