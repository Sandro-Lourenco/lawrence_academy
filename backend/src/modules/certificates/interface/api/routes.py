from typing import List

from fastapi import APIRouter, Depends, Request, Response
from slowapi import Limiter  # type: ignore # slowapi does not provide type stubs
from slowapi.util import get_remote_address  # type: ignore # slowapi does not provide type stubs

from src.core.security.security import CurrentUser, get_current_user
from src.modules.certificates.application.dtos import (
    CertificateResponseDTO,
    GenerateCertificateRequest,
    VerifyCertificateResponseDTO,
)
from src.modules.certificates.application.usecases import (
    GenerateCertificateUseCase,
    DownloadCertificatePdfUseCase,
    ReconcileCertificatesUseCase,
    VerifyCertificateUseCase,
)
from src.modules.certificates.domain.repositories import (
    CertificateDocumentRenderer,
    CertificateRepository,
)
from src.modules.certificates.interface.api.dependencies import (
    get_certificate_document_renderer,
    get_certificate_repository,
)
from src.shared.config import settings

limiter = Limiter(key_func=get_remote_address)
router = APIRouter(prefix="/api/v1/certificates", tags=["Certificates"])
legacy_router = APIRouter(prefix="/certificates", tags=["Certificates"])


@router.post("/generate", response_model=CertificateResponseDTO)
async def generate_certificate(
    request: GenerateCertificateRequest,
    current_user: CurrentUser = Depends(get_current_user),
    repository: CertificateRepository = Depends(get_certificate_repository),
):
    use_case = GenerateCertificateUseCase(repository)
    return await use_case.execute(current_user.id, request)


@router.get("/{code}/verify", response_model=VerifyCertificateResponseDTO)
@limiter.limit("5/minute")
async def verify_certificate(
    request: Request,
    code: str,
    repository: CertificateRepository = Depends(get_certificate_repository),
):
    use_case = VerifyCertificateUseCase(repository)
    return await use_case.execute(code)


@router.get("/{certificate_id}/pdf")
async def download_certificate_pdf(
    certificate_id: str,
    current_user: CurrentUser = Depends(get_current_user),
    repository: CertificateRepository = Depends(get_certificate_repository),
    renderer: CertificateDocumentRenderer = Depends(get_certificate_document_renderer),
):
    content = await DownloadCertificatePdfUseCase(
        repository,
        renderer,
        settings.public_web_url,
    ).execute(current_user.id, certificate_id)
    return Response(
        content=content,
        media_type="application/pdf",
        headers={
            "Content-Disposition": (
                f'attachment; filename="lawrence-certificate-{certificate_id}.pdf"'
            ),
            "Cache-Control": "private, no-store",
            "X-Content-Type-Options": "nosniff",
        },
    )


@router.get("", response_model=List[CertificateResponseDTO])
async def list_certificates(
    current_user: CurrentUser = Depends(get_current_user),
    repository: CertificateRepository = Depends(get_certificate_repository),
):
    certificates = await repository.list_by_student(current_user.id)
    return [CertificateResponseDTO(**certificate.model_dump()) for certificate in certificates]


@router.post("/reconcile", response_model=List[CertificateResponseDTO])
async def reconcile_certificates(
    current_user: CurrentUser = Depends(get_current_user),
    repository: CertificateRepository = Depends(get_certificate_repository),
):
    return await ReconcileCertificatesUseCase(repository).execute(current_user.id)


legacy_router.add_api_route(
    "/generate",
    generate_certificate,
    methods=["POST"],
    response_model=CertificateResponseDTO,
    deprecated=True,
)
legacy_router.add_api_route(
    "/{code}/verify",
    verify_certificate,
    methods=["GET"],
    response_model=VerifyCertificateResponseDTO,
    deprecated=True,
)
legacy_router.add_api_route(
    "",
    list_certificates,
    methods=["GET"],
    response_model=List[CertificateResponseDTO],
    deprecated=True,
)
