from pydantic import BaseModel
from datetime import datetime
from typing import Dict, Any, Optional


class GenerateCertificateRequest(BaseModel):
    course_id: str


class CertificateResponseDTO(BaseModel):
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


class PublicCertificateDTO(BaseModel):
    validation_code: str
    metadata: Dict[str, Any]
    issued_at: datetime
    is_revoked: bool
    signature_algorithm: str
    signature_version: int


class VerifyCertificateResponseDTO(BaseModel):
    is_valid: bool
    certificate: Optional[PublicCertificateDTO] = None
