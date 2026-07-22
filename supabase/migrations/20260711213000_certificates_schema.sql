-- Migration: 20260711213000_certificates_schema.sql
-- Purpose: Create Certificates table, constraints and RLS policies

CREATE TABLE IF NOT EXISTS certificates (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    student_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    course_id UUID NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
    validation_code VARCHAR(50) UNIQUE NOT NULL,
    signature VARCHAR(255) NOT NULL,
    signature_algorithm VARCHAR(50) NOT NULL,
    signature_version INTEGER NOT NULL DEFAULT 1,
    revoked_at TIMESTAMPTZ,
    revocation_reason TEXT,
    metadata JSONB NOT NULL DEFAULT '{}'::jsonb,
    issued_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(student_id, course_id)
);

-- A migration inicial já criou certificates com o contrato legado
-- (user_id/certificate_hash). Evolua a tabela sem descartar certificados.
ALTER TABLE public.certificates
    ADD COLUMN IF NOT EXISTS student_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    ADD COLUMN IF NOT EXISTS validation_code VARCHAR(50),
    ADD COLUMN IF NOT EXISTS signature VARCHAR(255),
    ADD COLUMN IF NOT EXISTS signature_algorithm VARCHAR(50),
    ADD COLUMN IF NOT EXISTS signature_version INTEGER NOT NULL DEFAULT 1,
    ADD COLUMN IF NOT EXISTS revoked_at TIMESTAMPTZ,
    ADD COLUMN IF NOT EXISTS revocation_reason TEXT,
    ADD COLUMN IF NOT EXISTS metadata JSONB NOT NULL DEFAULT '{}'::jsonb;

UPDATE public.certificates
SET student_id = user_id
WHERE student_id IS NULL;

UPDATE public.certificates
SET validation_code = 'LEGACY-' || replace(id::text, '-', '')
WHERE validation_code IS NULL;

UPDATE public.certificates
SET signature = certificate_hash,
    signature_algorithm = 'LEGACY-SHA256'
WHERE signature IS NULL;

ALTER TABLE public.certificates
    ALTER COLUMN student_id SET NOT NULL,
    ALTER COLUMN validation_code SET NOT NULL,
    ALTER COLUMN signature SET NOT NULL,
    ALTER COLUMN signature_algorithm SET NOT NULL,
    ALTER COLUMN user_id DROP NOT NULL,
    ALTER COLUMN certificate_hash DROP NOT NULL;

CREATE UNIQUE INDEX IF NOT EXISTS idx_certificates_validation_code
    ON public.certificates(validation_code);

CREATE UNIQUE INDEX IF NOT EXISTS idx_certificates_student_course
    ON public.certificates(student_id, course_id);

-- RLS
ALTER TABLE public.certificates ENABLE ROW LEVEL SECURITY;

-- Note: No public policy is added here. 
-- Public verification is handled exclusively by the backend service.

-- Policy: Students can view their own certificates
CREATE POLICY "Students can view own certificates"
    ON public.certificates FOR SELECT
    USING (auth.uid() = student_id);

-- Add certificates to DATABASE_SCHEMA.md
-- This migration assumes the DB schema has been properly planned as per PHASE_6C_IMPLEMENTATION_PLAN.md
