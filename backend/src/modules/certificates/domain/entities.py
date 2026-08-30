from pydantic import BaseModel
from typing import Optional, Dict, Any
from datetime import datetime


class Certificate(BaseModel):
    id: str
    student_id: str
    course_id: str
    validation_code: str
    signature: str
    signature_algorithm: str
    signature_version: int
    revoked_at: Optional[datetime] = None
    revocation_reason: Optional[str] = None
    metadata: Dict[str, Any]
    issued_at: datetime


class CertificateEligibilityEvidence(BaseModel):
    """Dados persistidos usados para decidir uma emissão, sem valores fictícios."""

    course_exists: bool
    course_published: bool = False
    certificate_enabled: bool = False
    student_name: Optional[str] = None
    course_name: Optional[str] = None
    workload_minutes: int = 0
    required_lesson_ids: list[str] = []
    completed_lesson_ids: list[str] = []
    required_task_ids: list[str] = []
    passed_task_ids: list[str] = []
    completion_date: Optional[datetime] = None
    required_learn_more_ids: list[str] = []
    completed_learn_more_ids: list[str] = []
    review_submitted: bool = False

    @property
    def is_eligible(self) -> bool:
        return (
            self.course_exists
            and self.course_published
            and self.certificate_enabled
            and bool(self.student_name and self.student_name.strip())
            and bool(self.course_name and self.course_name.strip())
            and bool(self.required_lesson_ids)
            and set(self.required_lesson_ids).issubset(self.completed_lesson_ids)
            and set(self.required_task_ids).issubset(self.passed_task_ids)
            and set(self.required_learn_more_ids).issubset(
                self.completed_learn_more_ids
            )
            and self.completion_date is not None
        )
