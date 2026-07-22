-- ==========================================
-- Lawrence Academy - Video Upload Pipeline
-- Date: 2026-07-11
-- Version: 20260711200000
-- Purpose: Registrar jobs de upload e processamento de vídeo com estados granulares.
--   Ajusta trigger do Storage para parsear novo path e atualizar job existente.
--   Adiciona pending_raw_video_path na tabela lessons para versão candidata.
-- Rollback: ver seção ROLLBACK ao final deste arquivo
-- ==========================================

BEGIN;

-- ============================================================
-- 1. ENUM: video_job_status com 6 estados
-- ============================================================
DO $$ BEGIN
    CREATE TYPE video_job_status AS ENUM (
        'upload_pending',
        'uploaded',
        'processing_pending',
        'processing',
        'completed',
        'failed'
    );
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;

-- Instalações anteriores já possuem uma versão menor do enum. Novos valores
-- precisam ser confirmados antes de serem usados como defaults pelo PostgreSQL.
ALTER TYPE public.video_job_status ADD VALUE IF NOT EXISTS 'upload_pending';
ALTER TYPE public.video_job_status ADD VALUE IF NOT EXISTS 'uploaded';
ALTER TYPE public.video_job_status ADD VALUE IF NOT EXISTS 'processing_pending';
ALTER TYPE public.video_job_status ADD VALUE IF NOT EXISTS 'processing';
ALTER TYPE public.video_job_status ADD VALUE IF NOT EXISTS 'completed';
ALTER TYPE public.video_job_status ADD VALUE IF NOT EXISTS 'failed';

COMMIT;
BEGIN;

-- ============================================================
-- 2. Tabela video_processing_jobs
--    Registra cada tentativa de upload e o ciclo de vida do processamento.
-- ============================================================
CREATE TABLE IF NOT EXISTS public.video_processing_jobs (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    lesson_id           UUID NOT NULL REFERENCES public.lessons(id) ON DELETE CASCADE,
    course_id           UUID NOT NULL,
    initiated_by        UUID,   -- user_id do professor que iniciou
    idempotency_key     TEXT NOT NULL,  -- chave única por tentativa
    raw_video_path      TEXT NOT NULL,  -- path completo no bucket raw-videos
    status              video_job_status NOT NULL DEFAULT 'upload_pending',
    error_message       TEXT,
    upload_pending_at   TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    uploaded_at         TIMESTAMPTZ,
    processing_started_at TIMESTAMPTZ,
    completed_at        TIMESTAMPTZ,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT video_processing_jobs_idempotency_key_unique UNIQUE (idempotency_key)
);

-- A tabela já existe em instalações criadas pela migration inicial. Evoluí-la
-- antes de criar índices mantém a migration compatível com bancos novos e com
-- bancos que possuem jobs legados.
ALTER TABLE public.video_processing_jobs
    ADD COLUMN IF NOT EXISTS course_id UUID,
    ADD COLUMN IF NOT EXISTS initiated_by UUID,
    ADD COLUMN IF NOT EXISTS idempotency_key TEXT,
    ADD COLUMN IF NOT EXISTS upload_pending_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    ADD COLUMN IF NOT EXISTS uploaded_at TIMESTAMPTZ,
    ADD COLUMN IF NOT EXISTS processing_started_at TIMESTAMPTZ,
    ADD COLUMN IF NOT EXISTS completed_at TIMESTAMPTZ;

UPDATE public.video_processing_jobs AS job
SET course_id = lesson.course_id
FROM public.lessons AS lesson
WHERE lesson.id = job.lesson_id
  AND job.course_id IS NULL;

UPDATE public.video_processing_jobs
SET idempotency_key = 'legacy:' || id::text
WHERE idempotency_key IS NULL;

ALTER TABLE public.video_processing_jobs
    ALTER COLUMN course_id SET NOT NULL,
    ALTER COLUMN idempotency_key SET NOT NULL,
    ALTER COLUMN status SET DEFAULT 'upload_pending';

CREATE UNIQUE INDEX IF NOT EXISTS idx_vpj_idempotency_key
    ON public.video_processing_jobs(idempotency_key);

-- Índices para queries frequentes
CREATE INDEX IF NOT EXISTS idx_vpj_lesson_id ON public.video_processing_jobs(lesson_id);
CREATE INDEX IF NOT EXISTS idx_vpj_status ON public.video_processing_jobs(status);
CREATE INDEX IF NOT EXISTS idx_vpj_raw_video_path ON public.video_processing_jobs(raw_video_path);
CREATE INDEX IF NOT EXISTS idx_vpj_course_id ON public.video_processing_jobs(course_id);

-- ============================================================
-- 3. Coluna pending_raw_video_path na tabela lessons
--    Versão candidata: lesson publicada NÃO é alterada até o vídeo ser processado.
-- ============================================================
ALTER TABLE public.lessons
    ADD COLUMN IF NOT EXISTS pending_raw_video_path TEXT,
    ADD COLUMN IF NOT EXISTS pending_upload_job_id UUID REFERENCES public.video_processing_jobs(id);

-- ============================================================
-- 4. RLS em video_processing_jobs
-- ============================================================
ALTER TABLE public.video_processing_jobs ENABLE ROW LEVEL SECURITY;

-- Teacher vê apenas jobs de seus próprios cursos
CREATE POLICY "teacher_see_own_jobs"
    ON public.video_processing_jobs
    FOR SELECT
    USING (
        initiated_by = auth.uid()
        OR public.is_admin(auth.uid())
    );

-- Apenas admin ou service_role pode inserir/atualizar
CREATE POLICY "admin_manage_jobs"
    ON public.video_processing_jobs
    FOR ALL
    USING (public.is_admin(auth.uid()));

-- ============================================================
-- 5. Função de trigger ATUALIZADA para o novo path
--    Path esperado: uploads/{course_id}/{upload_id}/{lesson_id}.mp4
--    Ao invés de inserir novo job, ATUALIZA job existente para 'uploaded'
-- ============================================================
CREATE OR REPLACE FUNCTION public.handle_storage_video_upload()
RETURNS TRIGGER AS $$
DECLARE
    v_lesson_id     UUID;
    v_path_parts    TEXT[];
    v_filename      TEXT;
    v_job_id        UUID;
BEGIN
    -- Verificar se o upload ocorreu no bucket 'raw-videos'
    IF NEW.bucket_id <> 'raw-videos' THEN
        RETURN NEW;
    END IF;

    -- O path esperado é: uploads/{course_id}/{upload_id}/{lesson_id}.mp4
    -- Extrair o nome do arquivo (última parte do path)
    v_filename := regexp_replace(NEW.name, '^.*/', '');  -- ex: "abc-lesson-id.mp4"
    v_filename := regexp_replace(v_filename, '\.[^.]*$', '');  -- remove extensão: "abc-lesson-id"

    -- Validar se é um UUID válido (lesson_id)
    IF v_filename ~ '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$' THEN
        v_lesson_id := v_filename::uuid;

        -- Verificar se a lição existe
        IF NOT EXISTS (SELECT 1 FROM public.lessons WHERE id = v_lesson_id) THEN
            RETURN NEW;
        END IF;

        -- Buscar job existente pelo raw_video_path (path completo no Storage)
        SELECT id INTO v_job_id
        FROM public.video_processing_jobs
        WHERE raw_video_path = NEW.name
          AND status = 'upload_pending'
        LIMIT 1;

        IF v_job_id IS NOT NULL THEN
            -- Atualizar job existente para 'uploaded'
            UPDATE public.video_processing_jobs
            SET
                status       = 'uploaded',
                uploaded_at  = NOW(),
                updated_at   = NOW()
            WHERE id = v_job_id;
        ELSE
            -- Fallback: criar job se não existir (compatibilidade com uploads legados)
            INSERT INTO public.video_processing_jobs (lesson_id, course_id, idempotency_key, raw_video_path, status)
            VALUES (
                v_lesson_id,
                -- Tentar extrair course_id do path (parte 2: uploads/{course_id}/...)
                CASE
                    WHEN NEW.name ~ '^uploads/[0-9a-f-]+/'
                    THEN (regexp_match(NEW.name, '^uploads/([0-9a-f-]+)/'))[1]::uuid
                    ELSE NULL
                END,
                gen_random_uuid()::text,  -- idempotency_key gerada para fallback
                NEW.name,
                'uploaded'
            )
            ON CONFLICT (idempotency_key) DO NOTHING;
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public, pg_temp;

-- Recriar trigger
DROP TRIGGER IF EXISTS on_storage_video_uploaded ON storage.objects;
CREATE TRIGGER on_storage_video_uploaded
    AFTER INSERT ON storage.objects
    FOR EACH ROW EXECUTE FUNCTION public.handle_storage_video_upload();

-- ============================================================
-- 6. Função trigger para updated_at automático
-- ============================================================
CREATE OR REPLACE FUNCTION public.set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS set_vpj_updated_at ON public.video_processing_jobs;
CREATE TRIGGER set_vpj_updated_at
    BEFORE UPDATE ON public.video_processing_jobs
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

COMMIT;

-- ============================================================
-- ROLLBACK (executar manualmente se necessário):
-- ============================================================
-- BEGIN;
-- DROP TRIGGER IF EXISTS on_storage_video_uploaded ON storage.objects;
-- DROP TRIGGER IF EXISTS set_vpj_updated_at ON public.video_processing_jobs;
-- DROP FUNCTION IF EXISTS public.handle_storage_video_upload();
-- DROP FUNCTION IF EXISTS public.set_updated_at();
-- ALTER TABLE public.lessons DROP COLUMN IF EXISTS pending_raw_video_path;
-- ALTER TABLE public.lessons DROP COLUMN IF EXISTS pending_upload_job_id;
-- DROP TABLE IF EXISTS public.video_processing_jobs;
-- DROP TYPE IF EXISTS video_job_status;
-- COMMIT;
