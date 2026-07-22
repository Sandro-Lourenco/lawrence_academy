from typing import Optional, Protocol

from src.modules.certificates.domain.entities import Certificate


class CertificateRepository(Protocol):
    async def get_by_id(self, certificate_id: str) -> Optional[Certificate]: ...

    async def get_by_validation_code(self, code: str) -> Optional[Certificate]: ...

    async def get_by_student_and_course(
        self, student_id: str, course_id: str
    ) -> Optional[Certificate]: ...

    async def list_by_student(self, student_id: str) -> list[Certificate]: ...

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
