from supabase import Client
from typing import Optional, cast
from datetime import datetime
from decimal import Decimal

from src.modules.certificates.domain.entities import (
    Certificate,
    CertificateEligibilityEvidence,
)


class SupabaseCertificateRepository:
    def __init__(self, client: Client):
        self.client = client
        self.table = "certificates"

    async def get_by_id(self, certificate_id: str) -> Optional[Certificate]:
        response = (
            self.client.table(self.table).select("*").eq("id", certificate_id).execute()
        )
        if response.data:
            return Certificate(**cast(dict, response.data[0]))
        return None

    async def get_by_validation_code(self, code: str) -> Optional[Certificate]:
        response = (
            self.client.table(self.table)
            .select("*")
            .eq("validation_code", code)
            .execute()
        )
        if response.data:
            return Certificate(**cast(dict, response.data[0]))
        return None

    async def get_by_student_and_course(
        self, student_id: str, course_id: str
    ) -> Optional[Certificate]:
        response = (
            self.client.table(self.table)
            .select("*")
            .eq("student_id", student_id)
            .eq("course_id", course_id)
            .execute()
        )
        if response.data:
            return Certificate(**cast(dict, response.data[0]))
        return None

    async def list_by_student(self, student_id: str) -> list[Certificate]:
        response = (
            self.client.table(self.table)
            .select("*")
            .eq("student_id", student_id)
            .execute()
        )
        return [Certificate(**cast(dict, item)) for item in response.data]

    async def list_completion_candidate_course_ids(
        self, student_id: str
    ) -> list[str]:
        response = (
            self.client.table("lesson_progress")
            .select("course_id")
            .eq("student_id", student_id)
            .eq("completed", True)
            .execute()
        )
        return sorted(
            {
                str(cast(dict, item)["course_id"])
                for item in response.data or []
                if cast(dict, item).get("course_id")
            }
        )

    async def get_eligibility_evidence(
        self, student_id: str, course_id: str
    ) -> CertificateEligibilityEvidence:
        course_response = (
            self.client.table("courses")
            .select("id,title,status,certificate_enabled")
            .eq("id", course_id)
            .is_("deleted_at", "null")
            .execute()
        )
        if not course_response.data:
            return CertificateEligibilityEvidence(course_exists=False)

        course = cast(dict, course_response.data[0])
        profile_response = (
            self.client.table("profiles")
            .select("full_name,certificate_name")
            .eq("id", student_id)
            .execute()
        )
        profile = cast(dict, profile_response.data[0]) if profile_response.data else {}

        lessons_response = (
            self.client.table("lessons")
            .select("id,duration_seconds,estimated_duration_minutes,is_required")
            .eq("course_id", course_id)
            .eq("status", "published")
            .is_("deleted_at", "null")
            .execute()
        )
        required_lessons = [
            cast(dict, row)
            for row in lessons_response.data or []
            if cast(dict, row).get("is_required", True)
        ]
        required_lesson_ids = [str(row["id"]) for row in required_lessons]

        progress_rows: list[dict] = []
        if required_lesson_ids:
            progress_response = (
                self.client.table("lesson_progress")
                .select("lesson_id,completed,completed_at")
                .eq("student_id", student_id)
                .eq("course_id", course_id)
                .in_("lesson_id", required_lesson_ids)
                .execute()
            )
            progress_rows = [cast(dict, row) for row in progress_response.data or []]
        completed_rows = [row for row in progress_rows if row.get("completed") is True]

        tasks_response = (
            self.client.table("tasks")
            .select("id,passing_score")
            .eq("course_id", course_id)
            .is_("deleted_at", "null")
            .execute()
        )
        task_rows = [cast(dict, row) for row in tasks_response.data or []]
        task_ids = [str(row["id"]) for row in task_rows]
        submissions: list[dict] = []
        if task_ids:
            submissions_response = (
                self.client.table("task_submissions")
                .select("task_id,score,status")
                .eq("user_id", student_id)
                .in_("task_id", task_ids)
                .execute()
            )
            submissions = [cast(dict, row) for row in submissions_response.data or []]

        passed_task_ids: list[str] = []
        for task in task_rows:
            task_id = str(task["id"])
            threshold = Decimal(str(task.get("passing_score") or 0))
            if any(
                row.get("task_id") == task_id
                and row.get("status") == "graded"
                and row.get("score") is not None
                and Decimal(str(row["score"])) >= threshold
                for row in submissions
            ):
                passed_task_ids.append(task_id)

        learn_more_response = (
            self.client.table("lesson_blocks")
            .select("id")
            .eq("course_id", course_id)
            .eq("block_type", "learn_more")
            .eq("status", "ready")
            .is_("deleted_at", "null")
            .execute()
        )
        required_learn_more_ids = [
            str(cast(dict, row)["id"]) for row in learn_more_response.data or []
        ]
        completed_learn_more_ids: list[str] = []
        if required_learn_more_ids:
            block_progress = (
                self.client.table("lesson_block_progress")
                .select("block_id")
                .eq("student_id", student_id)
                .eq("course_id", course_id)
                .in_("block_id", required_learn_more_ids)
                .execute()
            )
            completed_learn_more_ids = [
                str(cast(dict, row)["block_id"])
                for row in block_progress.data or []
            ]
        review_response = (
            self.client.table("course_reviews")
            .select("id")
            .eq("student_id", student_id)
            .eq("course_id", course_id)
            .eq("status", "published")
            .execute()
        )

        completion_dates = [
            datetime.fromisoformat(str(row["completed_at"]).replace("Z", "+00:00"))
            for row in completed_rows
            if row.get("completed_at")
        ]
        workload_minutes = sum(
            int(row.get("estimated_duration_minutes") or 0)
            or ((int(row.get("duration_seconds") or 0) + 59) // 60)
            for row in required_lessons
        )

        return CertificateEligibilityEvidence(
            course_exists=True,
            course_published=course.get("status") == "published",
            certificate_enabled=bool(course.get("certificate_enabled", False)),
            student_name=(profile.get("certificate_name") or profile.get("full_name")),
            course_name=course.get("title"),
            workload_minutes=workload_minutes,
            required_lesson_ids=required_lesson_ids,
            completed_lesson_ids=[str(row["lesson_id"]) for row in completed_rows],
            required_task_ids=task_ids,
            passed_task_ids=passed_task_ids,
            required_learn_more_ids=required_learn_more_ids,
            completed_learn_more_ids=completed_learn_more_ids,
            review_submitted=bool(review_response.data),
            completion_date=max(completion_dates) if completion_dates else None,
        )

    async def create(
        self,
        student_id: str,
        course_id: str,
        validation_code: str,
        signature: str,
        signature_algorithm: str,
        signature_version: int,
        metadata: dict,
    ) -> Certificate:
        data = {
            "student_id": student_id,
            "course_id": course_id,
            "validation_code": validation_code,
            "signature": signature,
            "signature_algorithm": signature_algorithm,
            "signature_version": signature_version,
            "metadata": metadata,
        }
        response = self.client.table(self.table).insert(cast(dict, data)).execute()
        return Certificate(**cast(dict, response.data[0]))
