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
from src.modules.certificates.domain.repositories import (
    CertificateDocumentRenderer,
    CertificateRepository,
)
import logging
from src.core.errors.errors import NotFoundError, ServiceUnavailableError, ValidationError

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
        existing = await self.repository.get_by_student_and_course(user_id, request.course_id)
        if existing:
            logger.info(
                f"Certificate already exists. Returning existing. correlation_id={correlation_id} certificate_id={existing.id}"
            )
            return CertificateResponseDTO(**existing.model_dump())

        evidence = await self.repository.get_eligibility_evidence(user_id, request.course_id)
        if not evidence.is_eligible:
            logger.warning("Certificate eligibility denied. correlation_id=%s", correlation_id)
            raise ValidationError(
                "O certificado exige curso publicado, aulas obrigatórias concluídas e atividades aprovadas."
            )

        secret_key = _required_secret()
        completion_date = evidence.completion_date
        if completion_date is None:
            # Defensive guard for custom repository implementations. The
            # canonical eligibility object already rejects this condition.
            raise ValidationError("A data de conclusão do curso não foi registrada.")

        # 3. Gerar um Validation Code Único
        validation_code = f"LWA-{str(uuid.uuid4())[:8].upper()}"

        # 4. Criar Certificado com Payload Canônico e Assinatura
        metadata = {
            "schema_version": 1,
            "student_name": evidence.student_name,
            "course_name": evidence.course_name,
            "course_workload_hours": round(evidence.workload_minutes / 60, 2),
            "completed_lesson_count": len(evidence.required_lesson_ids),
            "completion_date": completion_date.date().isoformat(),
            "issuer_name": "Lawrence Academy",
        }

        signature = hmac.new(secret_key, _canonical_metadata(metadata), hashlib.sha256).hexdigest()

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


class ReconcileCertificatesUseCase:
    """Emite, de forma idempotente, certificados de conclusões já sincronizadas."""

    def __init__(self, repository: CertificateRepository):
        self.repository = repository

    async def execute(self, user_id: str) -> list[CertificateResponseDTO]:
        generator = GenerateCertificateUseCase(self.repository)
        for course_id in await self.repository.list_completion_candidate_course_ids(user_id):
            try:
                await generator.execute(user_id, GenerateCertificateRequest(course_id=course_id))
            except ValidationError:
                # Uma aula concluída não implica, sozinha, que todos os requisitos
                # do curso foram atendidos. Os demais candidatos continuam sendo
                # reconciliados sem reduzir a regra de elegibilidade.
                continue
        return [
            CertificateResponseDTO(**certificate.model_dump())
            for certificate in await self.repository.list_by_student(user_id)
        ]


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
            logger.warning(f"Verification failed: Invalid code. correlation_id={correlation_id}")
            return VerifyCertificateResponseDTO(is_valid=False)

        signature_valid = False
        if certificate.signature_algorithm == "HMAC-SHA256" and certificate.signature_version == 1:
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


class DownloadCertificatePdfUseCase:
    def __init__(
        self,
        repository: CertificateRepository,
        renderer: CertificateDocumentRenderer,
        public_web_url: str,
    ):
        self.repository = repository
        self.renderer = renderer
        self.public_web_url = public_web_url.rstrip("/")

    async def execute(self, user_id: str, certificate_id: str) -> bytes:
        certificate = await self.repository.get_by_id(certificate_id)
        # A mesma resposta para inexistente e não pertencente evita enumeração.
        if certificate is None or certificate.student_id != user_id:
            raise NotFoundError("Certificado não encontrado.")
        if certificate.revoked_at is not None:
            raise ValidationError("Este certificado foi revogado e não pode ser baixado.")
        verification_url = (
            f"{self.public_web_url}/verify-certificate?code={certificate.validation_code}"
        )
        return self.renderer.render(certificate, verification_url)
