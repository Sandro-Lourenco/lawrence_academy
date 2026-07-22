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
from datetime import datetime

logger = logging.getLogger(__name__)


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

        # 1. Verificar se já existe um certificado para evitar duplicação (Idempotência natural)
        existing = await self.repository.get_by_student_and_course(
            user_id, request.course_id
        )
        if existing:
            logger.info(
                f"Certificate already exists. Returning existing. correlation_id={correlation_id} certificate_id={existing.id}"
            )
            return CertificateResponseDTO(**existing.model_dump())

        # 2. Validar Elegibilidade via CertificateEligibilityService -> LessonProgressService
        # Para o MVP simulamos a chamada:
        # eligibility_service = CertificateEligibilityService(lesson_progress_service, assessment_service)
        # if not await eligibility_service.is_eligible(user_id, request.course_id):
        #     logger.warning(f"Eligibility failed. correlation_id={correlation_id}")
        #     raise DomainError("Student has not completed the requirements for this course.")

        # 3. Gerar um Validation Code Único
        validation_code = f"LWA-{str(uuid.uuid4())[:8].upper()}"

        # 4. Criar Certificado com Payload Canônico e Assinatura
        metadata = {
            "schema_version": 1,
            "student_name": "Nome",  # Mock for now until repository resolves
            "course_name": "Curso",  # Mock for now
            "course_workload_hours": 40,
            "completion_date": datetime.now().strftime("%Y-%m-%d"),
            "issuer_name": "Lawrence Academy",
        }

        canonical_payload = json.dumps(metadata, separators=(",", ":"), sort_keys=True)
        secret_key = os.environ.get("CERTIFICATE_SECRET_KEY", "dev-secret").encode(
            "utf-8"
        )
        signature = hmac.new(
            secret_key, canonical_payload.encode("utf-8"), hashlib.sha256
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

        logger.info(
            f"Verification successful. correlation_id={correlation_id} certificate_id={certificate.id}"
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
            is_valid=not public_cert.is_revoked, certificate=public_cert
        )
