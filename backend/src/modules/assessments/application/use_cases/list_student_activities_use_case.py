import asyncio
from datetime import datetime, timezone
from typing import Any

from src.modules.assessments.domain.repositories import AssessmentRepository
from src.modules.courses.domain.repositories import CourseRepository
from src.modules.profiles.domain.repositories import ProfileRepository


class ListStudentActivitiesUseCase:
    """Lista somente atividades de cursos aos quais o aluno ainda tem acesso."""

    def __init__(
        self,
        assessment_repository: AssessmentRepository,
        course_repository: CourseRepository,
        profile_repository: ProfileRepository,
    ):
        self.assessment_repository = assessment_repository
        self.course_repository = course_repository
        self.profile_repository = profile_repository

    async def execute(self, user_id: str) -> list[dict[str, Any]]:
        courses = await self.course_repository.list_published_versions()
        checks = await asyncio.gather(
            *(
                _has_student_access(self.course_repository, user_id, course)
                for course in courses
            )
        )
        accessible = [course for course, allowed in zip(courses, checks) if allowed]
        if not accessible:
            return []

        tasks = await self.assessment_repository.get_tasks_by_course_ids(
            [course.id for course in accessible]
        )
        submissions = await self.assessment_repository.get_user_submissions_for_tasks(
            user_id, [task.id for task in tasks]
        )
        course_by_id = {course.id: course for course in accessible}
        instructor_ids = {course.instructor_id for course in accessible}
        profiles = await asyncio.gather(
            *(self.profile_repository.get_by_id(profile_id) for profile_id in instructor_ids)
        )
        teacher_by_id = {
            profile_id: (profile.full_name if profile else "Lawrence Academy")
            for profile_id, profile in zip(instructor_ids, profiles)
        }

        result: list[dict[str, Any]] = []
        for task in tasks:
            course = course_by_id.get(task.course_id)
            if course is None:
                continue
            attempts = [item for item in submissions if item.task_id == task.id]
            attempts.sort(
                key=lambda item: item.submitted_at
                or item.graded_at
                or datetime.min.replace(tzinfo=timezone.utc),
                reverse=True,
            )
            latest = attempts[0] if attempts else None
            result.append(
                {
                    "id": task.id,
                    "course_id": task.course_id,
                    "lesson_id": task.lesson_id,
                    "title": task.title,
                    "description": task.description,
                    "task_type": task.task_type,
                    "options": task.options,
                    "max_attempts": task.max_attempts,
                    "passing_score": float(task.passing_score or 0),
                    "course_name": course.title,
                    "teacher_name": teacher_by_id.get(
                        course.instructor_id, "Lawrence Academy"
                    ),
                    "attempts_used": len(
                        [item for item in attempts if item.status != "draft"]
                    ),
                    "submission": None
                    if latest is None
                    else {
                        "id": latest.id,
                        "task_id": latest.task_id,
                        "selected_option": latest.selected_option,
                        "text_answer": latest.text_answer,
                        "score": float(latest.score)
                        if latest.score is not None
                        else None,
                        "status": latest.status,
                        "teacher_feedback": latest.teacher_feedback,
                        "submitted_at": latest.submitted_at,
                        "idempotency_key": latest.idempotency_key,
                        "correct_option": task.correct_option
                        if latest.status == "graded"
                        else None,
                        "is_correct": (
                            bool(
                                latest.selected_option
                                and task.correct_option
                                and latest.selected_option.casefold()
                                == task.correct_option.casefold()
                            )
                            if latest.status == "graded"
                            else None
                        ),
                    },
                }
            )
        return result


async def _has_student_access(
    repository: CourseRepository, user_id: str, course: Any
) -> bool:
    if course.monthly_price <= 0:
        return True
    return await repository.has_active_subscription(user_id, course.id)
