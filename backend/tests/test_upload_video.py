"""
Tests para TASK-5D-003: Geração de URL pré-assinada de upload de vídeo.

Cenários cobertos:
- teacher owner → success
- teacher não owner → AuthorizationError
- student → AuthorizationError
- admin/super_admin → success (sem verificar ownership)
- curso inexistente (instructor_id=None) → NotFoundError
- aula inexistente → NotFoundError
- content_type inválido → ValidationError
- size_bytes > 2GB → ValidationError
- path traversal no filename → ValidationError
- idempotency_key já existente → nova URL, job reutilizado
- bucket privado (signed_url nunca tem URL pública permanente)
- path gerado corretamente: uploads/{course_id}/{uuid}/{lesson_id}.mp4
- lesson publicada NÃO é alterada ao gerar URL (reset_lesson_for_upload NÃO é chamado)
- job registrado com status upload_pending antes de retornar URL
- expires_in = 7200 (2 horas, padrão Supabase)
"""

import asyncio
import re
import pytest
from typing import Optional

from src.modules.courses.application.use_cases.generate_lesson_upload_url_use_case import (
    GenerateLessonUploadUrlUseCase,
    MAX_FILE_SIZE_BYTES,
    UPLOAD_URL_EXPIRES_IN,
)
from src.core.errors.errors import (
    AuthorizationError,
    NotFoundError,
    ValidationError,
    ExternalServiceError,
)


# ============================================================
# Mocks
# ============================================================


class MockCourseRepository:
    """Mock do CourseRepository para testes unitários."""

    def __init__(self):
        self.instructor_id: Optional[str] = "teacher-owner-id"
        self.lesson: Optional[dict] = {
            "id": "lesson-uuid-1234",
            "course_id": "course-uuid-5678",
            "title": "Aula de Teste",
            "status": "published",  # lição está publicada
        }
        self.reset_called = False  # para verificar que reset NÃO foi chamado

    async def get_instructor_id(self, course_id: str) -> Optional[str]:
        return self.instructor_id

    async def get_lesson_by_id(self, course_id: str, lesson_id: str) -> Optional[dict]:
        return self.lesson

    # Garantir que reset_lesson_for_upload não existe mais no fluxo normal
    # Se chamado, falha o teste (não deveria ser invocado)
    async def reset_lesson_for_upload(self, course_id: str, lesson_id: str) -> None:
        self.reset_called = True
        raise AssertionError(
            "reset_lesson_for_upload NÃO deve ser chamado ao gerar URL de upload. "
            "A lição publicada não deve ser alterada."
        )


class MockStorageRepository:
    """Mock do SupabaseStorageRepository para testes unitários."""

    def __init__(self):
        self.generated_urls: list = []
        self.created_jobs: list = []
        self.existing_job: Optional[dict] = None  # para simular idempotência
        self.signed_url = "https://example.supabase.co/storage/v1/object/sign/raw-videos/uploads/course/uuid/lesson.mp4?token=MOCK_TOKEN"
        self.fail_generate_url = False

    async def generate_signed_upload_url(self, storage_path: str) -> str:
        if self.fail_generate_url:
            raise ExternalServiceError(
                "Falha simulada ao gerar URL de upload.",
                provider="supabase-storage",
                request_id=storage_path,
            )
        self.generated_urls.append(storage_path)
        # URL simulada privada — nunca pública permanente
        return self.signed_url

    async def create_upload_job(
        self,
        lesson_id: str,
        course_id: str,
        initiated_by: str,
        idempotency_key: str,
        raw_video_path: str,
    ) -> str:
        job = {
            "id": "job-uuid-9999",
            "lesson_id": lesson_id,
            "course_id": course_id,
            "initiated_by": initiated_by,
            "idempotency_key": idempotency_key,
            "raw_video_path": raw_video_path,
            "status": "upload_pending",
        }
        self.created_jobs.append(job)
        return "job-uuid-9999"

    async def get_upload_job_by_idempotency_key(
        self, idempotency_key: str
    ) -> Optional[dict]:
        return self.existing_job


def make_use_case(
    instructor_id: Optional[str] = "teacher-owner-id",
    lesson_exists: bool = True,
    existing_job: Optional[dict] = None,
    fail_generate_url: bool = False,
):
    course_repo = MockCourseRepository()
    course_repo.instructor_id = instructor_id
    if not lesson_exists:
        course_repo.lesson = None

    storage_repo = MockStorageRepository()
    storage_repo.existing_job = existing_job
    storage_repo.fail_generate_url = fail_generate_url

    uc = GenerateLessonUploadUrlUseCase(
        course_repository=course_repo,
        storage_repository=storage_repo,
    )
    return uc, course_repo, storage_repo


DEFAULT_PARAMS = dict(
    user_id="teacher-owner-id",
    role="teacher",
    course_id="course-uuid-5678",
    lesson_id="lesson-uuid-1234",
    filename="minha-aula.mp4",
    content_type="video/mp4",
    size_bytes=1_000_000,
    idempotency_key=None,
)


# ============================================================
# Testes de Roles e Ownership (BOLA)
# ============================================================


def test_teacher_owner_success():
    """Teacher que é dono do curso pode gerar URL."""
    uc, course_repo, storage_repo = make_use_case()
    result = asyncio.run(uc.execute(**DEFAULT_PARAMS))

    assert "signed_url" in result
    assert "job_id" in result
    assert "path" in result
    assert result["expires_in"] == UPLOAD_URL_EXPIRES_IN  # 7200 segundos
    # Verifica path no formato correto
    assert result["path"].startswith(f"uploads/{DEFAULT_PARAMS['course_id']}/")
    assert result["path"].endswith(f"/{DEFAULT_PARAMS['lesson_id']}.mp4")
    # Verifica que um UUID foi inserido no meio do path
    parts = result["path"].split("/")
    assert len(parts) == 4  # uploads/{course_id}/{uuid}/{lesson_id}.mp4
    # O UUID do meio deve ser um UUID válido
    uuid_part = parts[2]
    assert re.match(
        r"^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$",
        uuid_part,
    ), f"UUID parte do path inválido: {uuid_part!r}"


def test_teacher_not_owner_denied():
    """Teacher que NÃO é dono do curso deve ser bloqueado (BOLA)."""
    uc, _, _ = make_use_case(instructor_id="outro-teacher-id")
    with pytest.raises(AuthorizationError):
        asyncio.run(uc.execute(**{**DEFAULT_PARAMS, "user_id": "teacher-intruso"}))


def test_student_denied():
    """Student nunca pode gerar URL de upload."""
    uc, _, _ = make_use_case()
    with pytest.raises(AuthorizationError):
        asyncio.run(uc.execute(**{**DEFAULT_PARAMS, "role": "student"}))


def test_unauthenticated_role_denied():
    """Role desconhecida deve ser bloqueada."""
    uc, _, _ = make_use_case()
    with pytest.raises(AuthorizationError):
        asyncio.run(uc.execute(**{**DEFAULT_PARAMS, "role": "anonymous"}))


def test_admin_success_without_ownership_check():
    """Admin pode gerar URL mesmo não sendo instructor do curso."""
    uc, _, storage_repo = make_use_case(instructor_id="outro-professor")
    result = asyncio.run(
        uc.execute(**{**DEFAULT_PARAMS, "user_id": "admin-uuid", "role": "admin"})
    )
    assert result["job_id"] == "job-uuid-9999"
    assert result["expires_in"] == UPLOAD_URL_EXPIRES_IN


def test_super_admin_success():
    """Super admin pode gerar URL mesmo não sendo instructor do curso."""
    uc, _, _ = make_use_case(instructor_id="outro-professor")
    result = asyncio.run(
        uc.execute(
            **{**DEFAULT_PARAMS, "user_id": "super-admin-uuid", "role": "super_admin"}
        )
    )
    assert result["job_id"]
    assert result["expires_in"] == UPLOAD_URL_EXPIRES_IN


# ============================================================
# Testes de Recurso Não Encontrado
# ============================================================


def test_course_not_found():
    """Curso inexistente retorna NotFoundError para teacher."""
    uc, _, _ = make_use_case(instructor_id=None)
    with pytest.raises(NotFoundError):
        asyncio.run(uc.execute(**DEFAULT_PARAMS))


def test_lesson_not_found():
    """Aula inexistente no curso retorna NotFoundError."""
    uc, _, _ = make_use_case(lesson_exists=False)
    with pytest.raises(NotFoundError):
        asyncio.run(uc.execute(**DEFAULT_PARAMS))


# ============================================================
# Testes de Validação de Arquivo
# ============================================================


def test_invalid_content_type_rejected():
    """MIME type inválido deve ser rejeitado."""
    uc, _, _ = make_use_case()
    with pytest.raises(ValidationError):
        asyncio.run(uc.execute(**{**DEFAULT_PARAMS, "content_type": "image/png"}))


def test_invalid_content_type_pdf():
    """PDF deve ser rejeitado."""
    uc, _, _ = make_use_case()
    with pytest.raises(ValidationError):
        asyncio.run(uc.execute(**{**DEFAULT_PARAMS, "content_type": "application/pdf"}))


def test_valid_mov_content_type():
    """video/quicktime (MOV) deve ser aceito."""
    uc, _, _ = make_use_case()
    result = asyncio.run(
        uc.execute(**{**DEFAULT_PARAMS, "content_type": "video/quicktime"})
    )
    assert result["job_id"]


def test_valid_m4v_content_type():
    """video/x-m4v deve ser aceito."""
    uc, _, _ = make_use_case()
    result = asyncio.run(
        uc.execute(**{**DEFAULT_PARAMS, "content_type": "video/x-m4v"})
    )
    assert result["job_id"]


def test_file_exactly_2gb_accepted():
    """Arquivo com tamanho exatamente igual ao limite (2GB) deve ser aceito."""
    uc, _, _ = make_use_case()
    result = asyncio.run(
        uc.execute(**{**DEFAULT_PARAMS, "size_bytes": MAX_FILE_SIZE_BYTES})
    )
    assert result["job_id"]


def test_file_over_2gb_rejected():
    """Arquivo maior que 2GB deve ser rejeitado."""
    uc, _, _ = make_use_case()
    with pytest.raises(ValidationError):
        asyncio.run(
            uc.execute(**{**DEFAULT_PARAMS, "size_bytes": MAX_FILE_SIZE_BYTES + 1})
        )


def test_file_3gb_rejected():
    """Arquivo de 3GB deve ser claramente rejeitado."""
    uc, _, _ = make_use_case()
    with pytest.raises(ValidationError):
        asyncio.run(
            uc.execute(**{**DEFAULT_PARAMS, "size_bytes": 3 * 1024 * 1024 * 1024})
        )


# ============================================================
# Testes de Path Traversal (Segurança)
# ============================================================


def test_path_traversal_double_dot_rejected():
    """Filename com '..' deve ser rejeitado."""
    uc, _, _ = make_use_case()
    with pytest.raises(ValidationError):
        asyncio.run(uc.execute(**{**DEFAULT_PARAMS, "filename": "../etc/passwd"}))


def test_path_traversal_slash_rejected():
    """Filename com '/' deve ser rejeitado."""
    uc, _, _ = make_use_case()
    with pytest.raises(ValidationError):
        asyncio.run(uc.execute(**{**DEFAULT_PARAMS, "filename": "path/video.mp4"}))


def test_path_traversal_backslash_rejected():
    """Filename com '\\' deve ser rejeitado."""
    uc, _, _ = make_use_case()
    with pytest.raises(ValidationError):
        asyncio.run(uc.execute(**{**DEFAULT_PARAMS, "filename": "path\\video.mp4"}))


# ============================================================
# Teste de Path Gerado pelo Backend
# ============================================================


def test_path_generated_by_backend_format():
    """O path final NÃO usa o filename do cliente — é gerado exclusivamente pelo backend."""
    uc, _, storage_repo = make_use_case()
    result = asyncio.run(
        uc.execute(**{**DEFAULT_PARAMS, "filename": "qualquer_nome_do_cliente.mp4"})
    )
    # O path gerado usa lesson_id.mp4, não o filename do cliente
    assert "qualquer_nome_do_cliente" not in result["path"]
    assert result["path"].endswith(f"/{DEFAULT_PARAMS['lesson_id']}.mp4")
    # Verifica que o path foi passado corretamente ao generate_signed_upload_url
    assert result["path"] in storage_repo.generated_urls


def test_path_unique_per_upload():
    """Cada chamada gera um path único (UUID diferente), evitando sobrescrita."""
    uc1, _, storage1 = make_use_case()
    uc2, _, storage2 = make_use_case()

    result1 = asyncio.run(uc1.execute(**DEFAULT_PARAMS))
    result2 = asyncio.run(uc2.execute(**DEFAULT_PARAMS))

    assert result1["path"] != result2["path"], "Paths devem ser únicos por upload"


# ============================================================
# Testes de Idempotência
# ============================================================


def test_idempotency_key_existing_job_reuses():
    """Se idempotency_key já existe, retorna nova URL para o job existente sem criar novo job."""
    existing_path = "uploads/course-uuid/existing-uuid/lesson-uuid-1234.mp4"
    existing_job = {
        "id": "existing-job-id",
        "raw_video_path": existing_path,
        "status": "upload_pending",
        "lesson_id": "lesson-uuid-1234",
    }
    uc, _, storage_repo = make_use_case(existing_job=existing_job)
    result = asyncio.run(
        uc.execute(**{**DEFAULT_PARAMS, "idempotency_key": "chave-existente-unica"})
    )
    # Deve reusar o job existente
    assert result["job_id"] == "existing-job-id"
    assert result["path"] == existing_path
    # Não deve criar novo job
    assert len(storage_repo.created_jobs) == 0
    # Deve gerar nova URL para o mesmo path
    assert existing_path in storage_repo.generated_urls


def test_no_idempotency_key_creates_new_job():
    """Se idempotency_key não fornecida, gera UUID automaticamente e cria novo job."""
    uc, _, storage_repo = make_use_case()
    result = asyncio.run(uc.execute(**{**DEFAULT_PARAMS, "idempotency_key": None}))
    # Deve criar novo job
    assert len(storage_repo.created_jobs) == 1
    assert result["job_id"] == "job-uuid-9999"


# ============================================================
# Teste de Imutabilidade da Lição Publicada
# ============================================================


def test_lesson_published_not_altered():
    """A lição publicada NÃO deve ser alterada ao gerar URL de upload."""
    uc, course_repo, _ = make_use_case()
    # lesson está com status 'published'
    assert course_repo.lesson and course_repo.lesson["status"] == "published"

    asyncio.run(uc.execute(**DEFAULT_PARAMS))

    # reset_called não deve ter sido acionado
    assert not course_repo.reset_called, (
        "reset_lesson_for_upload foi chamado, mas não deveria: "
        "a lição publicada não deve ser alterada ao gerar URL."
    )
    # O status da lição mockada permanece 'published'
    assert course_repo.lesson["status"] == "published"


# ============================================================
# Teste de Registro do Job
# ============================================================


def test_upload_job_registered_before_url():
    """Job deve ser registrado em video_processing_jobs com status upload_pending."""
    uc, _, storage_repo = make_use_case()
    result = asyncio.run(uc.execute(**DEFAULT_PARAMS))

    assert len(storage_repo.created_jobs) == 1
    job = storage_repo.created_jobs[0]
    assert job["status"] == "upload_pending"
    assert job["lesson_id"] == DEFAULT_PARAMS["lesson_id"]
    assert job["course_id"] == DEFAULT_PARAMS["course_id"]
    assert job["initiated_by"] == DEFAULT_PARAMS["user_id"]
    assert job["raw_video_path"] == result["path"]


# ============================================================
# Teste de Expiração Correta (2 horas)
# ============================================================


def test_expires_in_is_7200():
    """expires_in deve ser 7200 segundos (2 horas — padrão real do Supabase Storage)."""
    uc, _, _ = make_use_case()
    result = asyncio.run(uc.execute(**DEFAULT_PARAMS))
    assert result["expires_in"] == 7200, (
        f"expires_in deve ser 7200 (2 horas), mas foi {result['expires_in']}. "
        "O Supabase Storage define 2h por padrão para create_signed_upload_url."
    )


# ============================================================
# Teste de Bucket Privado (URL assinada, não pública)
# ============================================================


def test_signed_url_is_not_permanent_public():
    """A URL gerada deve ser pré-assinada (temporária), não uma URL pública permanente."""
    uc, _, storage_repo = make_use_case()
    result = asyncio.run(uc.execute(**DEFAULT_PARAMS))

    # URL deve conter parâmetro de token (assinada)
    assert "token=" in result["signed_url"] or "sign" in result["signed_url"], (
        "A URL deve ser pré-assinada (temporária), não uma URL pública permanente."
    )
    # URL nunca deve ter 'public' diretamente no path de acesso permanente
    assert "/storage/v1/object/public/" not in result["signed_url"]


# ============================================================
# Teste de Falha no Storage
# ============================================================


def test_storage_failure_raises_external_error():
    """Falha ao gerar URL no Storage deve propagar ExternalServiceError."""
    uc, _, _ = make_use_case(fail_generate_url=True)
    with pytest.raises(ExternalServiceError):
        asyncio.run(uc.execute(**DEFAULT_PARAMS))
