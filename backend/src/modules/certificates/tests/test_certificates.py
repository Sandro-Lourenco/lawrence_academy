import pytest
from src.modules.certificates.application.dtos import GenerateCertificateRequest
from src.modules.certificates.application.usecases import (
    DownloadCertificatePdfUseCase,
    GenerateCertificateUseCase,
    ReconcileCertificatesUseCase,
    VerifyCertificateUseCase,
)
from src.modules.certificates.domain.entities import Certificate, CertificateEligibilityEvidence
import uuid
from datetime import datetime


class MockRepository:
    def __init__(self):
        self.db = []

    async def get_by_validation_code(self, code):
        for c in self.db:
            if c.validation_code == code:
                return c
        return None

    async def get_by_student_and_course(self, student_id, course_id):
        for c in self.db:
            if c.student_id == student_id and c.course_id == course_id:
                return c
        return None

    async def get_by_id(self, certificate_id):
        return next((c for c in self.db if c.id == certificate_id), None)

    async def list_by_student(self, student_id):
        return [certificate for certificate in self.db if certificate.student_id == student_id]

    async def list_completion_candidate_course_ids(self, student_id):
        return ["c1"]

    async def get_eligibility_evidence(self, student_id, course_id):
        return CertificateEligibilityEvidence(
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

    async def create(self, student_id, course_id, validation_code, metadata, **kwargs):
        cert = Certificate(
            id=str(uuid.uuid4()),
            student_id=student_id,
            course_id=course_id,
            validation_code=validation_code,
            metadata=metadata,
            issued_at=datetime.now(),
            **kwargs,
        )
        self.db.append(cert)
        return cert


@pytest.mark.asyncio
async def test_generate_certificate_idempotency(monkeypatch):
    monkeypatch.setenv("CERTIFICATE_SECRET_KEY", "test-certificate-secret-32-bytes")
    repo = MockRepository()
    usecase = GenerateCertificateUseCase(repo)

    # Generate first time
    req = GenerateCertificateRequest(course_id="c1")
    cert1 = await usecase.execute("s1", req)

    # Generate second time
    cert2 = await usecase.execute("s1", req)

    # Should be identical
    assert cert1.id == cert2.id
    assert cert1.validation_code == cert2.validation_code
    assert cert1.metadata["student_name"] == "Student Test"
    assert cert1.metadata["course_name"] == "Course Test"
    assert cert1.metadata["completed_lesson_count"] == 1
    assert cert1.metadata["course_workload_hours"] == 10.0
    assert len(repo.db) == 1


@pytest.mark.asyncio
async def test_verify_certificate(monkeypatch):
    monkeypatch.setenv("CERTIFICATE_SECRET_KEY", "test-certificate-secret-32-bytes")
    repo = MockRepository()
    usecase = GenerateCertificateUseCase(repo)
    verify_usecase = VerifyCertificateUseCase(repo)

    cert = await usecase.execute("s1", GenerateCertificateRequest(course_id="c1"))

    # Verify success
    res = await verify_usecase.execute(cert.validation_code)
    assert res.is_valid is True
    assert res.certificate.validation_code == cert.validation_code

    # Verify fail
    res2 = await verify_usecase.execute("INVALID-CODE")
    assert res2.is_valid is False
    assert res2.certificate is None


@pytest.mark.asyncio
async def test_course_without_tasks_can_issue_certificate(monkeypatch):
    monkeypatch.setenv("CERTIFICATE_SECRET_KEY", "test-certificate-secret-32-bytes")
    repo = MockRepository()

    async def evidence_without_tasks(student_id, course_id):
        return CertificateEligibilityEvidence(
            course_exists=True,
            course_published=True,
            certificate_enabled=True,
            student_name="Student Test",
            course_name="Course Test",
            workload_minutes=60,
            required_lesson_ids=["lesson-1"],
            completed_lesson_ids=["lesson-1"],
            required_task_ids=[],
            passed_task_ids=[],
            completion_date=datetime.now(),
        )

    repo.get_eligibility_evidence = evidence_without_tasks
    certificate = await GenerateCertificateUseCase(repo).execute(
        "s1", GenerateCertificateRequest(course_id="c1")
    )
    assert certificate.course_id == "c1"


@pytest.mark.asyncio
async def test_reconcile_is_idempotent(monkeypatch):
    monkeypatch.setenv("CERTIFICATE_SECRET_KEY", "test-certificate-secret-32-bytes")
    repo = MockRepository()
    usecase = ReconcileCertificatesUseCase(repo)
    first = await usecase.execute("s1")
    second = await usecase.execute("s1")
    assert len(first) == 1
    assert len(second) == 1
    assert first[0].id == second[0].id


@pytest.mark.asyncio
async def test_pdf_download_requires_certificate_ownership(monkeypatch):
    monkeypatch.setenv("CERTIFICATE_SECRET_KEY", "test-certificate-secret-32-bytes")
    repo = MockRepository()
    certificate = await GenerateCertificateUseCase(repo).execute(
        "s1", GenerateCertificateRequest(course_id="c1")
    )

    class Renderer:
        def render(self, item, verification_url):
            assert item.id == certificate.id
            assert verification_url.endswith(f"?code={certificate.validation_code}")
            return b"%PDF-1.4\nfixture"

    use_case = DownloadCertificatePdfUseCase(repo, Renderer(), "https://academy.example")
    assert await use_case.execute("s1", certificate.id) == b"%PDF-1.4\nfixture"

    from src.core.errors.errors import NotFoundError

    with pytest.raises(NotFoundError):
        await use_case.execute("another-student", certificate.id)
