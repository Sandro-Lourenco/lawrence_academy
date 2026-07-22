-- ============================================================
-- Lawrence Academy - Video Worker Refinement Migration
-- Date: 2026-07-11
-- Version: 20260711210000
-- Purpose: Atualizar a tabela video_processing_jobs e enums de estados.
-- ============================================================

BEGIN;

-- 1. Adicionar novos estados ao enum de video_job_status se necessário.
-- Como PostgreSQL não permite ALTER TYPE ADD VALUE dentro de transações de forma simples se o tipo for usado por tabelas,
-- vamos migrar e recriar o tipo ou renomear.
-- Para manter 100% de compatibilidade sem recriar todas dependências na mão, podemos converter a coluna para TEXT temporariamente,
-- atualizar o tipo e converter de volta.

ALTER TABLE public.video_processing_jobs ALTER COLUMN status TYPE TEXT;
DROP TYPE IF EXISTS video_job_status CASCADE;

CREATE TYPE video_job_status AS ENUM (
    'upload_pending',
    'uploaded',
    'processing_pending',
    'processing',
    'validating',
    'transcoding',
    'generating_hls',
    'generating_thumbnail',
    'completed',
    'failed',
    'dead_letter'
);

ALTER TABLE public.video_processing_jobs ALTER COLUMN status TYPE video_job_status USING status::video_job_status;

-- 2. Adicionar colunas de retentativa, observabilidade e metadados na tabela
ALTER TABLE public.video_processing_jobs 
    ADD COLUMN IF NOT EXISTS retry_count INTEGER NOT NULL DEFAULT 0,
    ADD COLUMN IF NOT EXISTS max_retries INTEGER NOT NULL DEFAULT 3,
    ADD COLUMN IF NOT EXISTS last_error TEXT,
    ADD COLUMN IF NOT EXISTS next_retry_at TIMESTAMPTZ,
    ADD COLUMN IF NOT EXISTS expected_size_bytes BIGINT,
    ADD COLUMN IF NOT EXISTS real_size_bytes BIGINT,
    ADD COLUMN IF NOT EXISTS video_metadata JSONB DEFAULT '{}'::jsonb;

-- 3. Adicionar coluna na tabela lessons se não existir
ALTER TABLE public.lessons 
    ADD COLUMN IF NOT EXISTS pending_raw_video_path TEXT,
    ADD COLUMN IF NOT EXISTS pending_upload_job_id UUID REFERENCES public.video_processing_jobs(id);

COMMIT;
