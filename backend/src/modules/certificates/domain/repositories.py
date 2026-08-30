from typing import Optional, Protocol

from src.modules.certificates.domain.entities import (
    Certificate,
    CertificateEligibilityEvidence,
)


class CertificateRepository(Protocol):
    async def get_by_id(self, certificate_id: str) -> Optional[Certificate]: ...

    async def get_by_validation_code(self, code: str) -> Optional[Certificate]: ...

    async def get_by_student_and_course(
        self, student_id: str, course_id: str
    ) -> Optional[Certificate]: ...

    async def list_by_student(self, student_id: str) -> list[Certificate]: ...

    async def list_completion_candidate_course_ids(self, student_id: str) -> list[str]: ...

    async def get_eligibility_evidence(
        self, student_id: str, course_id: str
    ) -> CertificateEligibilityEvidence: ...

    async def create(
        self,
        student_id: str,
        course_id: str,
        validation_code: str,
        signature: str,
        signature_algorithm: str,
        signature_version: int,
        metadata: dict,
    ) -> Certificate: ...


class CertificateDocumentRenderer(Protocol):
    def render(self, certificate: Certificate, verification_url: str) -> bytes: ...
