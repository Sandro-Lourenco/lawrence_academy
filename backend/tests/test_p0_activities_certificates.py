import hashlib
import hmac
import json
from datetime import datetime, timezone
from decimal import Decimal
from unittest.mock import AsyncMock, Mock

import pytest

from src.core.errors.errors import AuthorizationError, ServiceUnavailableError, ValidationError
from src.modules.assessments.application.use_cases.submit_task_use_case import SubmitTaskUseCase
from src.modules.assessments.domain.entities import Task, TaskSubmission
from src.modules.certificates.application.dtos import GenerateCertificateRequest
from src.modules.certificates.application.usecases import (
    GenerateCertificateUseCase,
    VerifyCertificateUseCase,
)
from src.modules.certificates.domain.entities import (
    Certificate,
    CertificateEligibilityEvidence,
)


@pytest.mark.asyncio
async def test_submission_retry_returns_same_result_without_new_attempt():
    existing = TaskSubmission(
        id="submission-1",
        task_id="task-1",
        user_id="student-1",
        status="graded",
        idempotency_key="request-1",
    )
    repository = Mock()
    repository.get_submission_by_idempotency_key = AsyncMock(return_value=existing)
    repository.save = AsyncMock()
    course_repository = Mock()

    result = await SubmitTaskUseCase(repository, course_repository).execute(
        "task-1", "student-1", selected_option="A", idempotency_key="request-1"
    )

    assert result is existing
    repository.save.assert_not_awaited()


@pytest.mark.asyncio
async def test_submission_fails_closed_without_course_access():
    repository = Mock()
    repository.get_submission_by_idempotency_key = AsyncMock(return_value=None)
    repository.get_task_by_id = AsyncMock(
        return_value=Task(
            id="task-1",
            course_id="course-1",
            lesson_id="lesson-1",
            title="Prova",
            task_type="multiple_choice",
        )
    )
    course_repository = Mock()
    course_repository.has_active_subscription = AsyncMock(return_value=False)

    with pytest.raises(AuthorizationError):
        await SubmitTaskUseCase(repository, course_repository).execute(
            "task-1", "student-1", selected_option="A", idempotency_key="request-1"
        )


@pytest.mark.asyncio
@pytest.mark.parametrize(("answer", "expected_score"), [("B", Decimal("10")), ("A", Decimal("0"))])
async def test_multiple_choice_is_graded_against_correct_option(answer, expected_score):
    task = Task(
        id="task-1",
        course_id="course-1",
        lesson_id="lesson-1",
        title="Prova",
        task_type="multiple_choice",
        options={"A": "Errada", "B": "Correta"},
        correct_option="B",
        max_attempts=3,
    )
    repository = Mock()
    repository.get_submission_by_idempotency_key = AsyncMock(return_value=None)
    repository.get_task_by_id = AsyncMock(return_value=task)
    repository.get_user_submissions_for_tasks = AsyncMock(return_value=[])
    repository.save = AsyncMock(side_effect=lambda submission: submission)
    course_repository = Mock()
    course_repository.has_active_subscription = AsyncMock(return_value=True)

    result = await SubmitTaskUseCase(repository, course_repository).execute(
        "task-1",
        "student-1",
        selected_option=answer,
        idempotency_key=f"request-{answer}",
    )

    assert result.status == "graded"
    assert result.score == expected_score


def _eligible() -> CertificateEligibilityEvidence:
    return CertificateEligibilityEvidence(
        course_exists=True,
        course_published=True,
        certificate_enabled=True,
        student_name="Maria da Silva",
        course_name="Alta Costura",
        workload_minutes=600,
        required_lesson_ids=["lesson-1"],
        completed_lesson_ids=["lesson-1"],
        required_task_ids=["task-1"],
        passed_task_ids=["task-1"],
        review_submitted=False,
        completion_date=datetime(2026, 8, 10, tzinfo=timezone.utc),
    )


@pytest.mark.asyncio
async def test_certificate_denies_incomplete_student(monkeypatch):
    monkeypatch.setenv("CERTIFICATE_SECRET_KEY", "0123456789abcdef")
    repository = Mock()
    repository.get_by_student_and_course = AsyncMock(return_value=None)
    repository.get_eligibility_evidence = AsyncMock(
        return_value=_eligible().model_copy(update={"passed_task_ids": []})
    )

    with pytest.raises(ValidationError):
        await GenerateCertificateUseCase(repository).execute(
            "student-1", GenerateCertificateRequest(course_id="course-1")
        )


@pytest.mark.asyncio
async def test_certificate_requires_secret(monkeypatch):
    monkeypatch.delenv("CERTIFICATE_SECRET_KEY", raising=False)
    repository = Mock()
    repository.get_by_student_and_course = AsyncMock(return_value=None)
    repository.get_eligibility_evidence = AsyncMock(return_value=_eligible())

    with pytest.raises(ServiceUnavailableError):
        await GenerateCertificateUseCase(repository).execute(
            "student-1", GenerateCertificateRequest(course_id="course-1")
        )


@pytest.mark.asyncio
async def test_certificate_verification_rejects_tampered_metadata(monkeypatch):
    secret = "0123456789abcdef"
    monkeypatch.setenv("CERTIFICATE_SECRET_KEY", secret)
    original = {"student_name": "Maria", "course_name": "Alta Costura"}
    signature = hmac.new(
        secret.encode(),
        json.dumps(original, separators=(",", ":"), sort_keys=True).encode(),
        hashlib.sha256,
    ).hexdigest()
    certificate = Certificate(
        id="cert-1",
        student_id="student-1",
        course_id="course-1",
        validation_code="LWA-VALID",
        signature=signature,
        signature_algorithm="HMAC-SHA256",
        signature_version=1,
        metadata={**original, "course_name": "Curso adulterado"},
        issued_at=datetime.now(timezone.utc),
    )
    repository = Mock()
    repository.get_by_validation_code = AsyncMock(return_value=certificate)

    result = await VerifyCertificateUseCase(repository).execute("LWA-VALID")

    assert result.is_valid is False
