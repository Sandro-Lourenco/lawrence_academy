import pytest
from src.modules.certificates.application.dtos import GenerateCertificateRequest
from src.modules.certificates.application.usecases import (
    GenerateCertificateUseCase,
    VerifyCertificateUseCase,
)
from src.modules.certificates.domain.entities import Certificate
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
async def test_generate_certificate_idempotency():
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
    assert len(repo.db) == 1


@pytest.mark.asyncio
async def test_verify_certificate():
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
