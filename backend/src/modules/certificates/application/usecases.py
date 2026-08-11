import uuid
import hmac
import hashlib
import json
import os
from src.modules.certificates.application.dtos import (
    GenerateCertificateRequest,
    CertificateResponseDTO,
    VerifyCertificateResponseDTO,
    PublicCertificateDTO,
)
from src.modules.certificates.domain.repositories import CertificateRepository
import logging
from src.core.errors.errors import ServiceUnavailableError, ValidationError

logger = logging.getLogger(__name__)


def _required_secret() -> bytes:
    value = os.environ.get("CERTIFICATE_SECRET_KEY", "").strip()
    if len(value) < 16 or value == "dev-secret":
        raise ServiceUnavailableError(
            "Emissão e validação de certificados indisponíveis.",
        )
    return value.encode("utf-8")


def _canonical_metadata(metadata: dict) -> bytes:
    return json.dumps(metadata, separators=(",", ":"), sort_keys=True).encode("utf-8")


class GenerateCertificateUseCase:
    def __init__(self, repository: CertificateRepository):
        self.repository = repository

    async def execute(
        self, user_id: str, request: GenerateCertificateRequest
    ) -> CertificateResponseDTO:
        correlation_id = str(uuid.uuid4())
        logger.info(
            f"Initiating certificate generation. correlation_id={correlation_id} student_id={user_id} course_id={request.course_id}"
        )

        # Certificados existentes são a resposta idempotente e não são reemitidos.
        existing = await self.repository.get_by_student_and_course(
            user_id, request.course_id
        )
        if existing:
            logger.info(
                f"Certificate already exists. Returning existing. correlation_id={correlation_id} certificate_id={existing.id}"
            )
            return CertificateResponseDTO(**existing.model_dump())

        evidence = await self.repository.get_eligibility_evidence(
            user_id, request.course_id
        )
        if not evidence.is_eligible:
            logger.warning("Certificate eligibility denied. correlation_id=%s", correlation_id)
            raise ValidationError(
                "O certificado exige curso publicado, aulas obrigatórias concluídas e atividades aprovadas."
            )

        secret_key = _required_secret()

        # 3. Gerar um Validation Code Único
        validation_code = f"LWA-{str(uuid.uuid4())[:8].upper()}"

        # 4. Criar Certificado com Payload Canônico e Assinatura
        metadata = {
            "schema_version": 1,
            "student_name": evidence.student_name,
            "course_name": evidence.course_name,
            "course_workload_hours": round(evidence.workload_minutes / 60, 2),
            "completion_date": evidence.completion_date.date().isoformat(),
            "issuer_name": "Lawrence Academy",
        }

        signature = hmac.new(
            secret_key, _canonical_metadata(metadata), hashlib.sha256
        ).hexdigest()

        certificate = await self.repository.create(
            student_id=user_id,
            course_id=request.course_id,
            validation_code=validation_code,
            signature=signature,
            signature_algorithm="HMAC-SHA256",
            signature_version=1,
            metadata=metadata,
        )

        logger.info(
            f"Certificate successfully generated. correlation_id={correlation_id} certificate_id={certificate.id}"
        )
        return CertificateResponseDTO(**certificate.model_dump())


class VerifyCertificateUseCase:
    def __init__(self, repository: CertificateRepository):
        self.repository = repository

    async def execute(self, code: str) -> VerifyCertificateResponseDTO:
        correlation_id = str(uuid.uuid4())
        logger.info(
            f"Public verification requested. correlation_id={correlation_id} validation_code={code}"
        )

        certificate = await self.repository.get_by_validation_code(code)
        if not certificate:
            logger.warning(
                f"Verification failed: Invalid code. correlation_id={correlation_id}"
            )
            return VerifyCertificateResponseDTO(is_valid=False)

        signature_valid = False
        if (
            certificate.signature_algorithm == "HMAC-SHA256"
            and certificate.signature_version == 1
        ):
            expected = hmac.new(
                _required_secret(),
                _canonical_metadata(certificate.metadata),
                hashlib.sha256,
            ).hexdigest()
            signature_valid = hmac.compare_digest(expected, certificate.signature)
        if not signature_valid:
            logger.warning(
                "Verification failed: invalid signature. correlation_id=%s", correlation_id
            )
        # Returns only non-sensitive data
        public_cert = PublicCertificateDTO(
            validation_code=certificate.validation_code,
            metadata=certificate.metadata,
            issued_at=certificate.issued_at,
            is_revoked=certificate.revoked_at is not None,
            signature_algorithm=certificate.signature_algorithm,
            signature_version=certificate.signature_version,
        )

        return VerifyCertificateResponseDTO(
            is_valid=signature_valid and not public_cert.is_revoked,
            certificate=public_cert,
        )
