import pytest
from unittest.mock import Mock, AsyncMock
import hashlib
import hmac
import json
from src.modules.certificates.application.usecases import (
    GenerateCertificateUseCase,
    VerifyCertificateUseCase,
)
from src.modules.certificates.domain.entities import Certificate, CertificateEligibilityEvidence
from src.modules.certificates.application.dtos import GenerateCertificateRequest
from datetime import datetime


@pytest.fixture
def mock_repo():
    repo = Mock()
    repo.get_by_student_and_course = AsyncMock(return_value=None)
    repo.get_by_validation_code = AsyncMock(return_value=None)
    repo.create = AsyncMock()
    repo.get_eligibility_evidence = AsyncMock(
        return_value=CertificateEligibilityEvidence(
            course_exists=True,
            course_published=True,
            certificate_enabled=True,
            student_name="Student Test",
            course_name="Course Test",
            workload_minutes=600,
            required_lesson_ids=["lesson-1"],
            completed_lesson_ids=["lesson-1"],
            required_task_ids=["task-1"],
            passed_task_ids=["task-1"],
            completion_date=datetime.now(),
        )
    )
    return repo


@pytest.fixture(autouse=True)
def certificate_secret(monkeypatch):
    monkeypatch.setenv("CERTIFICATE_SECRET_KEY", "test-certificate-secret-32-bytes")


def sign_metadata(metadata):
    canonical = json.dumps(metadata, separators=(",", ":"), sort_keys=True).encode()
    return hmac.new(
        b"test-certificate-secret-32-bytes", canonical, hashlib.sha256
    ).hexdigest()


@pytest.mark.asyncio
async def test_generate_certificate_idempotency(mock_repo):
    # Setup mock to return an existing certificate
    existing_cert = Certificate(
        id="cert-1",
        student_id="student-1",
        course_id="course-1",
        validation_code="LWA-12345",
        signature="abc",
        signature_algorithm="HMAC-SHA256",
        signature_version=1,
        metadata={},
        issued_at=datetime.now(),
    )
    mock_repo.get_by_student_and_course.return_value = existing_cert

    usecase = GenerateCertificateUseCase(mock_repo)
    request = GenerateCertificateRequest(course_id="course-1")

    response = await usecase.execute("student-1", request)

    # Should not call create
    mock_repo.create.assert_not_called()
    assert response.validation_code == "LWA-12345"


@pytest.mark.asyncio
async def test_generate_certificate_new(mock_repo):
    # Setup mock to return None (no existing cert)
    async def mock_create(**kwargs):
        return Certificate(id="new-cert-id", issued_at=datetime.now(), **kwargs)

    mock_repo.create.side_effect = mock_create

    usecase = GenerateCertificateUseCase(mock_repo)
    request = GenerateCertificateRequest(course_id="course-1")

    response = await usecase.execute("student-1", request)

    mock_repo.create.assert_called_once()
    assert response.student_id == "student-1"
    assert "signature" in response.model_dump()


@pytest.mark.asyncio
async def test_verify_certificate_valid(mock_repo):
    valid_cert = Certificate(
        id="cert-1",
        student_id="student-1",
        course_id="course-1",
        validation_code="LWA-VALID",
        signature=sign_metadata({"course_name": "Test Course"}),
        signature_algorithm="HMAC-SHA256",
        signature_version=1,
        metadata={"course_name": "Test Course"},
        issued_at=datetime.now(),
        revoked_at=None,
    )
    mock_repo.get_by_validation_code.return_value = valid_cert

    usecase = VerifyCertificateUseCase(mock_repo)
    response = await usecase.execute("LWA-VALID")

    assert response.is_valid is True
    # Ensure no sensitive data
    assert not hasattr(response.certificate, "student_id")
    assert response.certificate.validation_code == "LWA-VALID"
    assert response.certificate.is_revoked is False


@pytest.mark.asyncio
async def test_verify_certificate_revoked(mock_repo):
    revoked_cert = Certificate(
        id="cert-1",
        student_id="student-1",
        course_id="course-1",
        validation_code="LWA-REVOKED",
        signature=sign_metadata({"course_name": "Test Course"}),
        signature_algorithm="HMAC-SHA256",
        signature_version=1,
        metadata={"course_name": "Test Course"},
        issued_at=datetime.now(),
        revoked_at=datetime.now(),
        revocation_reason="Fraud",
    )
    mock_repo.get_by_validation_code.return_value = revoked_cert

    usecase = VerifyCertificateUseCase(mock_repo)
    response = await usecase.execute("LWA-REVOKED")

    # Validation should say it's invalid because it's revoked
    assert response.is_valid is False
    assert response.certificate.is_revoked is True
