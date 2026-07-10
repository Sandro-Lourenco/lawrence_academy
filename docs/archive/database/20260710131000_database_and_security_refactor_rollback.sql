-- ======================================================
-- Lawrence Academy Rollback Script for Refactor Migration
-- Date: 2026-07-10
-- Purpose: Revert subscriptions, lesson_progress, profiles/lessons RLS to initial state.
-- ======================================================

-- 1. REVERTER POLÍTICAS RLS DE PERFIS (PROFILES)
DROP POLICY IF EXISTS "student_select_own_profile" ON public.profiles;
DROP POLICY IF EXISTS "student_update_own_profile" ON public.profiles;
DROP POLICY IF EXISTS "admin_all_profile" ON public.profiles;
DROP VIEW IF EXISTS public.profile_public_view CASCADE;

CREATE POLICY "Leitura pública de perfis" ON public.profiles FOR SELECT USING (true);
CREATE POLICY "Usuário atualiza próprio perfil" ON public.profiles FOR UPDATE USING (auth.uid() = id);


-- 2. REVERTER POLÍTICAS RLS DE LIÇÕES (LESSONS)
DROP POLICY IF EXISTS "student_select_lesson" ON public.lessons;
DROP POLICY IF EXISTS "teacher_all_own_lesson" ON public.lessons;
DROP POLICY IF EXISTS "admin_all_lesson" ON public.lessons;

CREATE POLICY "Acesso seguro a lições para assinantes com tolerância" ON public.lessons
    FOR SELECT USING (
        deleted_at IS NULL AND (
            EXISTS (SELECT 1 FROM public.courses c WHERE c.id = course_id AND c.instructor_id = auth.uid())
            OR EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin')
            OR (
                status = 'published' 
                AND EXISTS (
                    SELECT 1 FROM public.subscriptions s
                    WHERE s.user_id = auth.uid()
                      AND s.status IN ('active', 'trialing', 'past_due')
                      AND s.current_period_end + INTERVAL '5 days' > NOW()
                )
            )
        )
    );

CREATE POLICY "Gerenciamento de lições por instrutor ou admin" ON public.lessons
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM public.courses c
            WHERE c.id = course_id
              AND (
                  c.instructor_id = auth.uid() 
                  OR EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin')
              )
        )
    );


-- 3. REVERTER PROGRESSO DE AULA (LESSON_PROGRESS)
DROP TRIGGER IF EXISTS trg_check_progress_course_integrity ON public.lesson_progress;
DROP FUNCTION IF EXISTS public.check_progress_course_integrity();
DROP TABLE IF EXISTS public.lesson_progress CASCADE;

CREATE TABLE public.lesson_progress (
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    lesson_id UUID NOT NULL REFERENCES public.lessons(id) ON DELETE CASCADE,
    course_id UUID NOT NULL REFERENCES public.courses(id) ON DELETE CASCADE,
    completed BOOLEAN NOT NULL DEFAULT FALSE,
    watched_seconds INTEGER DEFAULT 0,
    completed_at TIMESTAMPTZ,
    PRIMARY KEY (user_id, lesson_id)
);

CREATE INDEX idx_progress_user_course ON public.lesson_progress(user_id, course_id);
ALTER TABLE public.lesson_progress ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Gerenciamento do próprio progresso" ON public.lesson_progress FOR ALL USING (auth.uid() = user_id);


-- 4. REVERTER TABELA DE ASSINATURAS (SUBSCRIPTIONS)
DROP POLICY IF EXISTS "student_select_own_subscription" ON public.subscriptions;
DROP POLICY IF EXISTS "admin_all_subscription" ON public.subscriptions;
DROP INDEX IF EXISTS idx_active_subscriptions_uniq;
DROP INDEX IF EXISTS idx_subscriptions_student_id;
DROP INDEX IF EXISTS idx_subscriptions_course_id;
DROP INDEX IF EXISTS idx_subscriptions_status;
DROP INDEX IF EXISTS idx_subscriptions_current_period_end;
DROP INDEX IF EXISTS idx_subscriptions_provider_subscription_id;

-- Renomear student_id para user_id
ALTER TABLE public.subscriptions RENAME COLUMN student_id TO user_id;

-- Remover colunas adicionadas
ALTER TABLE public.subscriptions DROP COLUMN IF EXISTS course_id;
ALTER TABLE public.subscriptions DROP COLUMN IF EXISTS provider;
ALTER TABLE public.subscriptions DROP COLUMN IF EXISTS monthly_price;
ALTER TABLE public.subscriptions DROP COLUMN IF EXISTS currency;
ALTER TABLE public.subscriptions DROP COLUMN IF EXISTS cancel_at_period_end;
ALTER TABLE public.subscriptions DROP COLUMN IF EXISTS canceled_at;
ALTER TABLE public.subscriptions DROP COLUMN IF EXISTS deleted_at;

-- Renomear de volta provider_customer_id e provider_subscription_id
ALTER TABLE public.subscriptions RENAME COLUMN provider_customer_id TO stripe_customer_id;
ALTER TABLE public.subscriptions RENAME COLUMN provider_subscription_id TO stripe_subscription_id;

-- Restaurar NOT NULL e UNIQUE originais
ALTER TABLE public.subscriptions ALTER COLUMN stripe_customer_id SET NOT NULL;
ALTER TABLE public.subscriptions ALTER COLUMN stripe_subscription_id SET NOT NULL;
ALTER TABLE public.subscriptions ADD CONSTRAINT subscriptions_stripe_customer_id_key UNIQUE (stripe_customer_id);
ALTER TABLE public.subscriptions ADD CONSTRAINT subscriptions_stripe_subscription_id_key UNIQUE (stripe_subscription_id);

CREATE INDEX idx_subscriptions_user_status ON public.subscriptions(user_id, status);
ALTER TABLE public.subscriptions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Leitura de própria assinatura" ON public.subscriptions FOR SELECT USING (auth.uid() = user_id OR EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin'));
CREATE POLICY "Mutação de assinatura por admin" ON public.subscriptions FOR ALL USING (EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin'));


-- 5. EXCLUIR TABELA DE EVENTOS DE PAGAMENTO
DROP TABLE IF EXISTS public.payment_events CASCADE;
