from src.core.database.database import get_admin_supabase_client
from src.modules.certificates.domain.repositories import CertificateRepository
from src.modules.certificates.infrastructure.repositories import (
    SupabaseCertificateRepository,
)


def get_certificate_repository() -> CertificateRepository:
    return SupabaseCertificateRepository(get_admin_supabase_client())
