from typing import List

from fastapi import APIRouter, Depends, Request
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
    VerifyCertificateUseCase,
)
from src.modules.certificates.domain.repositories import CertificateRepository
from src.modules.certificates.interface.api.dependencies import (
    get_certificate_repository,
)

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


@router.get("", response_model=List[CertificateResponseDTO])
async def list_certificates(
    current_user: CurrentUser = Depends(get_current_user),
    repository: CertificateRepository = Depends(get_certificate_repository),
):
    certificates = await repository.list_by_student(current_user.id)
    return [
        CertificateResponseDTO(**certificate.model_dump())
        for certificate in certificates
    ]


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
