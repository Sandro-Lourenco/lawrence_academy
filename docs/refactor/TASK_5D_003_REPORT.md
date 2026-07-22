# TASK-5D-003 — Relatório de Implementação

**Data:** 2026-07-11  
**Status:** ✅ DONE  
**Autor:** Agente de Implementação (Lawrence Academy)

---

## Objetivo

Implementar o fluxo seguro de upload direto de vídeos para o Storage por meio de URL pré-assinada, sem enviar arquivos grandes pelo FastAPI, com todos os requisitos de segurança, idempotência e pipeline de processamento.

---

## Arquivos Criados

| Arquivo | Descrição |
|---------|-----------|
| `supabase/migrations/20260711200000_video_upload_pipeline.sql` | ENUM `video_job_status`, tabela `video_processing_jobs`, RLS, trigger atualizada, coluna `pending_raw_video_path` nas `lessons` |
| `backend/src/core/storage/__init__.py` | `StorageRepository` Protocol — abstração separada do domínio de cursos |
| `backend/src/core/storage/supabase_storage_repository.py` | `SupabaseStorageRepository` — implementação com signed URL, create_upload_job e idempotência |
| `backend/tests/test_upload_video.py` | Suite completa com 27 testes |

---

## Arquivos Modificados

| Arquivo | Alteração |
|---------|-----------|
| `backend/src/modules/courses/application/use_cases/generate_lesson_upload_url_use_case.py` | Refatorado: injeção de StorageRepository, idempotência, sem mutação da lição, expires_in=7200 |
| `backend/src/modules/courses/domain/repositories.py` | Removidos `generate_signed_upload_url` e `reset_lesson_for_upload` (movidos para StorageRepository) |
| `backend/src/modules/courses/infrastructure/repositories/supabase_course_repository.py` | Removidos métodos de storage |
| `backend/src/modules/courses/interface/api/teacher_routes.py` | Endpoint atualizado: injeção dupla de repositórios, payload com `idempotency_key`, response com `job_id` e `expires_in: 7200` |

---

## Ajustes Obrigatórios Implementados

| # | Requisito | Implementado |
|---|-----------|:---:|
| 1 | Registrar `video_processing_jobs` com `upload_pending` | OK |
| 2 | Trigger atualiza para `uploaded` após o arquivo existir | OK |
| 3 | Não iniciar processamento antes da confirmação | OK |
| 4 | Estados: `upload_pending, uploaded, processing_pending, processing, completed, failed` | OK |
| 5 | Path `uploads/{course_id}/{upload_id}/{lesson_id}.mp4` corretamente interpretado | OK |
| 6 | Lição publicada NÃO é alterada ao gerar a URL | OK |
| 7 | Versão candidata via `pending_raw_video_path` | OK |
| 8 | Limite de 2GB no backend | OK |
| 9 | Validação de MIME types declarados | OK |
| 10 | Não confiar em MIME do cliente (Worker usa ffprobe) | OK |
| 11 | `idempotency_key` por tentativa | OK |
| 12 | `upsert=false`, path gerado pelo backend | OK |
| 13 | Bucket `raw-videos` privado | OK |
| 14 | Nunca logar `signed_url`, token ou secrets | OK |
| 15 | `expires_in: 7200` (2 horas, real) | OK |
| 16 | Upload resumível: decisão documentada (TUS experimental) | OK |
| 17 | StorageRepository separado do domínio de Courses | OK |
| 18 | Testes completos (27 cenários) | OK |

---

## Decisão: Upload Resumível

**Decisão:** Não implementado nesta task.

**Razão:** O Supabase TUS v1 está em fase experimental. A URL pré-assinada padrão suporta arquivos até 2GB. TUS deve ser habilitado em sprint futura para arquivos maiores.

---

## Fluxo Implementado

```
Teacher: POST /api/v1/teacher/courses/{course_id}/lessons/{lesson_id}/upload
  -> RBAC + BOLA + Validation
  -> video_processing_jobs INSERT (upload_pending)
  -> Supabase Storage signed URL (2h, upsert=false)
  <- { job_id, path, expires_in: 7200, signed_url }

Teacher: PUT <signed_url> (upload direto)
  -> Storage trigger: video_processing_jobs UPDATE (uploaded)
  -> Worker FFmpeg (próxima task)
```

---

## Resultado dos Testes

```
27/27 PASSED (test_upload_video.py)
69/69 PASSED (suite completa)
Ruff check: all checks passed
```
