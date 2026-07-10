-- ======================================================
-- Lawrence Academy Database & Security Refactor
-- Date: 2026-07-10
-- Purpose: Refactor subscriptions, lesson_progress, profiles RLS, lessons RLS, payment_events.
-- ======================================================

-- 0. AUXILIARY SECURITY DEFINER FUNCTIONS (TO AVOID RLS INFINITE RECURSION)
CREATE OR REPLACE FUNCTION public.is_admin(p_user_id UUID)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM public.profiles
        WHERE id = p_user_id AND role = 'admin'
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION public.is_teacher(p_user_id UUID)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM public.profiles
        WHERE id = p_user_id AND role = 'teacher'
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;


-- 1. CRIAR TABELA DE EVENTOS DE PAGAMENTO (IDEMPOTÊNCIA E AUDITORIA)
CREATE TABLE IF NOT EXISTS public.payment_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    provider TEXT NOT NULL,
    provider_event_id VARCHAR(255) NOT NULL,
    event_type TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'received',
    payload_hash VARCHAR(64) NOT NULL,
    processing_error TEXT,
    retry_count INTEGER DEFAULT 0,
    received_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    processed_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT uniq_provider_event UNIQUE(provider, provider_event_id)
);

ALTER TABLE public.payment_events ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Admin gerencia payment_events" ON public.payment_events
    FOR ALL USING (
        public.is_admin(auth.uid())
    );


-- 2. REESTRUTURAR TABELA DE ASSINATURAS (SUBSCRIPTIONS)
-- Dropar políticas antigas para evitar erros de dependência
DROP POLICY IF EXISTS "Leitura de própria assinatura" ON public.subscriptions;
DROP POLICY IF EXISTS "Mutação de assinatura por admin" ON public.subscriptions;
DROP POLICY IF EXISTS "student_select_own_subscription" ON public.subscriptions;
DROP POLICY IF EXISTS "admin_all_subscription" ON public.subscriptions;

-- Modificações na tabela subscriptions
ALTER TABLE public.subscriptions DROP CONSTRAINT IF EXISTS subscriptions_stripe_customer_id_key;
ALTER TABLE public.subscriptions DROP CONSTRAINT IF EXISTS subscriptions_stripe_subscription_id_key;

-- Renomear user_id para student_id
ALTER TABLE public.subscriptions RENAME COLUMN user_id TO student_id;

-- Adicionar course_id como NOT NULL (já que a base está vazia)
ALTER TABLE public.subscriptions ADD COLUMN course_id UUID NOT NULL REFERENCES public.courses(id) ON DELETE CASCADE;

-- Adicionar provider
ALTER TABLE public.subscriptions ADD COLUMN provider TEXT NOT NULL DEFAULT 'stripe';

-- Renomear stripe_customer_id e stripe_subscription_id
ALTER TABLE public.subscriptions RENAME COLUMN stripe_customer_id TO provider_customer_id;
ALTER TABLE public.subscriptions RENAME COLUMN stripe_subscription_id TO provider_subscription_id;

-- Ajustar nulabilidade dos IDs do provedor (podem ser nulos em caso de teste ou gateway alternativo)
ALTER TABLE public.subscriptions ALTER COLUMN provider_customer_id DROP NOT NULL;
ALTER TABLE public.subscriptions ALTER COLUMN provider_subscription_id DROP NOT NULL;

-- Adicionar campos de valores e datas de controle financeiro
ALTER TABLE public.subscriptions ADD COLUMN monthly_price NUMERIC(10,2) NOT NULL DEFAULT 0.00;
ALTER TABLE public.subscriptions ADD COLUMN currency TEXT NOT NULL DEFAULT 'BRL';
ALTER TABLE public.subscriptions ADD COLUMN cancel_at_period_end BOOLEAN NOT NULL DEFAULT FALSE;
ALTER TABLE public.subscriptions ADD COLUMN canceled_at TIMESTAMPTZ;
ALTER TABLE public.subscriptions ADD COLUMN deleted_at TIMESTAMPTZ;

-- Índices recomendados
CREATE INDEX IF NOT EXISTS idx_subscriptions_student_id ON public.subscriptions(student_id);
CREATE INDEX IF NOT EXISTS idx_subscriptions_course_id ON public.subscriptions(course_id);
CREATE INDEX IF NOT EXISTS idx_subscriptions_status ON public.subscriptions(status);
CREATE INDEX IF NOT EXISTS idx_subscriptions_current_period_end ON public.subscriptions(current_period_end);
CREATE INDEX IF NOT EXISTS idx_subscriptions_provider_subscription_id ON public.subscriptions(provider_subscription_id);

-- Restrição estrita de 1 assinatura ativa por aluno e curso
CREATE UNIQUE INDEX idx_active_subscriptions_uniq 
    ON public.subscriptions(student_id, course_id) 
    WHERE status IN ('active', 'trialing', 'past_due');

-- Habilitar RLS e aplicar novas políticas de subscriptions
CREATE POLICY "student_select_own_subscription" ON public.subscriptions
    FOR SELECT USING (auth.uid() = student_id);

CREATE POLICY "admin_all_subscription" ON public.subscriptions
    FOR ALL USING (
        public.is_admin(auth.uid())
    );


-- 3. REESTRUTURAR TABELA DE PROGRESSO DE AULA (LESSON_PROGRESS)
DROP TABLE IF EXISTS public.lesson_progress CASCADE;

CREATE TABLE public.lesson_progress (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    student_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    course_id UUID NOT NULL REFERENCES public.courses(id) ON DELETE CASCADE,
    lesson_id UUID NOT NULL REFERENCES public.lessons(id) ON DELETE CASCADE,
    watched_seconds INTEGER DEFAULT 0,
    progress_percentage DECIMAL(5,2) DEFAULT 0.00,
    completed BOOLEAN NOT NULL DEFAULT FALSE,
    completed_at TIMESTAMPTZ,
    last_synced_at TIMESTAMPTZ DEFAULT NOW(),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT uniq_student_lesson UNIQUE(student_id, lesson_id)
);

CREATE INDEX idx_progress_student_course ON public.lesson_progress(student_id, course_id);

-- Trigger de validação para integridade de course_id em lesson_progress
CREATE OR REPLACE FUNCTION public.check_progress_course_integrity()
RETURNS TRIGGER AS $$
DECLARE
    v_lesson_course_id UUID;
BEGIN
    SELECT course_id INTO v_lesson_course_id FROM public.lessons WHERE id = NEW.lesson_id;
    IF NEW.course_id <> v_lesson_course_id THEN
        RAISE EXCEPTION 'course_id in lesson_progress (%) does not match course_id of the lesson (%)', NEW.course_id, v_lesson_course_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_check_progress_course_integrity
    BEFORE INSERT OR UPDATE ON public.lesson_progress
    FOR EACH ROW EXECUTE FUNCTION public.check_progress_course_integrity();

-- Habilitar RLS e aplicar políticas
ALTER TABLE public.lesson_progress ENABLE ROW LEVEL SECURITY;

CREATE POLICY "student_all_own_progress" ON public.lesson_progress
    FOR ALL USING (auth.uid() = student_id);

CREATE POLICY "admin_all_progress" ON public.lesson_progress
    FOR ALL USING (
        public.is_admin(auth.uid())
    );


-- 4. ATUALIZAR POLÍTICAS DE RLS DE LIÇÕES (LESSONS)
DROP POLICY IF EXISTS "Acesso seguro a lições para assinantes com tolerância" ON public.lessons;
DROP POLICY IF EXISTS "Acesso seguro a lições para assinantes ativos" ON public.lessons;
DROP POLICY IF EXISTS "Gerenciamento de lições por instrutor ou admin" ON public.lessons;
DROP POLICY IF EXISTS "student_select_lesson" ON public.lessons;
DROP POLICY IF EXISTS "teacher_all_own_lesson" ON public.lessons;
DROP POLICY IF EXISTS "admin_all_lesson" ON public.lessons;

-- 4.1. Aluno com assinatura ativa para o respectivo curso
CREATE POLICY "student_select_lesson" ON public.lessons
    FOR SELECT USING (
        status = 'published'
        AND deleted_at IS NULL
        AND EXISTS (
            SELECT 1 FROM public.subscriptions s
            WHERE s.student_id = auth.uid()
              AND s.course_id = lessons.course_id
              AND s.status IN ('active', 'trialing', 'past_due')
              AND s.current_period_end + INTERVAL '5 days' > NOW()
        )
    );

-- 4.2. Professor dono do curso
CREATE POLICY "teacher_all_own_lesson" ON public.lessons
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM public.courses c
            WHERE c.id = lessons.course_id
              AND c.instructor_id = auth.uid()
        )
    );

-- 4.3. Administrador
CREATE POLICY "admin_all_lesson" ON public.lessons
    FOR ALL USING (
        public.is_admin(auth.uid())
    );


-- 5. ATUALIZAR POLÍTICAS DE RLS DE PERFIS (PROFILES) E SEGURANÇA
DROP POLICY IF EXISTS "Leitura pública de perfis" ON public.profiles;
DROP POLICY IF EXISTS "Usuário atualiza o próprio perfil" ON public.profiles;
DROP POLICY IF EXISTS "Usuário atualiza próprio perfil" ON public.profiles;
DROP POLICY IF EXISTS "student_select_own_profile" ON public.profiles;
DROP POLICY IF EXISTS "student_update_own_profile" ON public.profiles;
DROP POLICY IF EXISTS "admin_all_profile" ON public.profiles;

-- 5.1. Aluno seleciona apenas o próprio perfil
CREATE POLICY "student_select_own_profile" ON public.profiles
    FOR SELECT USING (auth.uid() = id);

-- 5.2. Aluno atualiza apenas o próprio perfil
CREATE POLICY "student_update_own_profile" ON public.profiles
    FOR UPDATE USING (auth.uid() = id) WITH CHECK (auth.uid() = id);

-- 5.3. Admin gerencia todos os perfis
CREATE POLICY "admin_all_profile" ON public.profiles
    FOR ALL USING (
        public.is_admin(auth.uid())
    );

-- 5.4. Criar View Segura para exibição pública de perfis autorizados (Professor e Admin)
DROP VIEW IF EXISTS public.profile_public_view CASCADE;
CREATE OR REPLACE VIEW public.profile_public_view AS
SELECT id, full_name, avatar_url, bio, role
FROM public.profiles;
