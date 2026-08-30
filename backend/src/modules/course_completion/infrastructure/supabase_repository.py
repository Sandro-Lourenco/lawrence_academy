from datetime import datetime, timedelta, timezone
from decimal import Decimal
from typing import cast

from src.core.concurrency import run_sync_io
from supabase import Client

from ..domain.entities import CourseCompletion, CourseReview


class SupabaseCourseCompletionRepository:
    def __init__(self, client: Client):
        self.client = client

    async def _execute(self, query):
        return await run_sync_io(query.execute)

    async def has_access(self, student_id: str, course_id: str) -> bool:
        response = await self._execute(
            self.client.table("subscriptions")
            .select("status,current_period_end")
            .eq("student_id", student_id)
            .eq("course_id", course_id)
        )
        now = datetime.now(timezone.utc)
        for row in response.data or []:
            subscription = cast(dict, row)
            subscription_status = subscription.get("status")
            if subscription_status in {"active", "trialing"}:
                return True
            end = subscription.get("current_period_end")
            if (
                subscription_status == "past_due"
                and end
                and datetime.fromisoformat(str(end).replace("Z", "+00:00"))
                + timedelta(days=5)
                > now
            ):
                return True
        course_response = await self._execute(
            self.client.table("courses")
            .select("id,monthly_price,status")
            .eq("id", course_id)
            .eq("status", "published")
            .is_("deleted_at", "null")
        )
        if not course_response.data:
            return False
        course = cast(dict, course_response.data[0])
        return Decimal(str(course.get("monthly_price") or 0)) <= 0

    async def get_completion(self, student_id: str, course_id: str) -> CourseCompletion:
        lessons_response = await self._execute(
            self.client.table("lessons")
            .select("id,module_id,order_index,is_required")
            .eq("course_id", course_id)
            .eq("status", "published")
            .is_("deleted_at", "null")
        )
        lessons = [cast(dict, row) for row in lessons_response.data or [] if cast(dict, row).get("is_required", True)]
        lesson_ids = [str(row["id"]) for row in lessons]
        progress_rows: list[dict] = []
        if lesson_ids:
            response = await self._execute(
                self.client.table("lesson_progress")
                .select("lesson_id,completed")
                .eq("student_id", student_id)
                .eq("course_id", course_id)
                .in_("lesson_id", lesson_ids)
            )
            progress_rows = [cast(dict, row) for row in response.data or []]
        completed_lessons = {str(row["lesson_id"]) for row in progress_rows if row.get("completed") is True}

        blocks_response = await self._execute(
            self.client.table("lesson_blocks")
            .select("id,lesson_id")
            .eq("course_id", course_id)
            .eq("block_type", "learn_more")
            .eq("status", "ready")
            .is_("deleted_at", "null")
        )
        blocks = [cast(dict, row) for row in blocks_response.data or []]
        block_ids = [str(row["id"]) for row in blocks]
        completed_blocks: set[str] = set()
        if block_ids:
            response = await self._execute(
                self.client.table("lesson_block_progress")
                .select("block_id")
                .eq("student_id", student_id)
                .eq("course_id", course_id)
                .in_("block_id", block_ids)
            )
            completed_blocks = {str(cast(dict, row)["block_id"]) for row in response.data or []}

        tasks_response = await self._execute(
            self.client.table("tasks")
            .select("id,passing_score")
            .eq("course_id", course_id)
            .is_("deleted_at", "null")
        )
        tasks = [cast(dict, row) for row in tasks_response.data or []]
        task_ids = [str(row["id"]) for row in tasks]
        submissions: list[dict] = []
        if task_ids:
            response = await self._execute(
                self.client.table("task_submissions")
                .select("task_id,score,status")
                .eq("user_id", student_id)
                .in_("task_id", task_ids)
            )
            submissions = [cast(dict, row) for row in response.data or []]
        passed_tasks = {
            str(task["id"])
            for task in tasks
            if any(
                row.get("task_id") == str(task["id"])
                and row.get("status") == "graded"
                and row.get("score") is not None
                and Decimal(str(row["score"])) >= Decimal(str(task.get("passing_score") or 0))
                for row in submissions
            )
        }
        total = len(lesson_ids) + len(block_ids) + len(task_ids)
        done = len(completed_lessons) + len(completed_blocks) + len(passed_tasks)
        percentage = 0 if total == 0 else round(done * 100 / total)
        modules_response = await self._execute(
            self.client.table("modules")
            .select("id,order_index")
            .eq("course_id", course_id)
            .is_("deleted_at", "null")
        )
        module_order = {
            str(cast(dict, row)["id"]): int(cast(dict, row).get("order_index") or 0)
            for row in modules_response.data or []
        }
        final_lesson_id = (
            str(
                max(
                    lessons,
                    key=lambda row: (
                        module_order.get(str(row.get("module_id")), 0),
                        int(row.get("order_index") or 0),
                    ),
                )["id"]
            )
            if lessons
            else None
        )
        final_completed = final_lesson_id is not None and final_lesson_id in completed_lessons

        review_response = await self._execute(
            self.client.table("course_reviews")
            .select("id")
            .eq("student_id", student_id)
            .eq("course_id", course_id)
        )
        review_submitted = bool(review_response.data)
        fully_complete = percentage == 100 and final_completed
        return CourseCompletion(
            course_id=course_id,
            progress_percentage=100 if fully_complete else min(percentage, 99),
            lessons_completed=len(completed_lessons),
            lessons_required=len(lesson_ids),
            activities_completed=len(passed_tasks),
            activities_required=len(task_ids),
            learn_more_completed=len(completed_blocks),
            learn_more_required=len(block_ids),
            final_lesson_completed=final_completed,
            review_required=fully_complete and not review_submitted,
            review_submitted=review_submitted,
            certificate_eligible=fully_complete,
        )

    async def complete_learn_more(
        self, student_id: str, course_id: str, lesson_id: str, block_id: str
    ) -> CourseCompletion:
        block_response = await self._execute(
            self.client.table("lesson_blocks")
            .select("id")
            .eq("id", block_id)
            .eq("lesson_id", lesson_id)
            .eq("course_id", course_id)
            .eq("block_type", "learn_more")
            .eq("status", "ready")
        )
        if not block_response.data:
            raise ValueError("Conteúdo Saber mais inválido.")
        await self._execute(
            self.client.table("lesson_block_progress").upsert(
                {
                    "student_id": student_id,
                    "course_id": course_id,
                    "lesson_id": lesson_id,
                    "block_id": block_id,
                    "completed_at": datetime.now(timezone.utc).isoformat(),
                },
                on_conflict="student_id,block_id",
            )
        )
        return await self.get_completion(student_id, course_id)

    async def upsert_review(
        self, student_id: str, course_id: str, rating: int, title: str, comment: str
    ) -> CourseReview:
        response = await self._execute(
            self.client.table("course_reviews").upsert(
                {
                    "student_id": student_id,
                    "course_id": course_id,
                    "rating": rating,
                    "title": title,
                    "comment": comment,
                    "status": "published",
                },
                on_conflict="student_id,course_id",
            )
        )
        return await self._review_from_row(cast(dict, response.data[0]))

    async def _review_from_row(self, row: dict) -> CourseReview:
        profile_response = await self._execute(
            self.client.table("profiles")
            .select("full_name,avatar_url")
            .eq("id", row["student_id"])
        )
        profile = cast(dict, profile_response.data[0]) if profile_response.data else {}
        return CourseReview(
            **row,
            student_name=profile.get("full_name") or "Aluno Lawrence",
            student_avatar_url=profile.get("avatar_url"),
        )

    async def list_reviews(self, course_id: str | None = None) -> list[CourseReview]:
        query = self.client.table("course_reviews").select("*").eq("status", "published").order("created_at", desc=True)
        if course_id:
            query = query.eq("course_id", course_id)
        response = await self._execute(query)
        return [await self._review_from_row(cast(dict, row)) for row in response.data or []]
