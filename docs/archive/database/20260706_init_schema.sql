-- ==========================================
-- Lawrence Academy Database Initialization
-- Date: 2026-07-06
-- Purpose: Schema, Soft Delete, Video Queue, Stripe Idempotency, Triggers, and RLS with Grace Period.
-- ==========================================

-- Limpar elementos existentes para reinicialização limpa (se necessário)
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users CASCADE;
DROP FUNCTION IF EXISTS public.handle_new_user() CASCADE;
DROP TRIGGER IF EXISTS trg_auto_grade ON public.task_submissions CASCADE;
DROP FUNCTION IF EXISTS public.auto_grade_submission() CASCADE;

DROP TABLE IF EXISTS public.stripe_processed_events CASCADE;
DROP TABLE IF EXISTS public.video_processing_jobs CASCADE;
DROP TABLE IF EXISTS public.task_submissions CASCADE;
DROP TABLE IF EXISTS public.tasks CASCADE;
DROP TABLE IF EXISTS public.certificates CASCADE;
DROP TABLE IF EXISTS public.lesson_progress CASCADE;
DROP TABLE IF EXISTS public.subscriptions CASCADE;
DROP TABLE IF EXISTS public.lessons CASCADE;
DROP TABLE IF EXISTS public.modules CASCADE;
DROP TABLE IF EXISTS public.courses CASCADE;
DROP TABLE IF EXISTS public.profiles CASCADE;

DROP TYPE IF EXISTS user_role CASCADE;
DROP TYPE IF EXISTS course_category CASCADE;
DROP TYPE IF EXISTS course_level CASCADE;
DROP TYPE IF EXISTS content_status CASCADE;
DROP TYPE IF EXISTS assessment_type CASCADE;
DROP TYPE IF EXISTS submission_status CASCADE;
DROP TYPE IF EXISTS subscription_status CASCADE;
DROP TYPE IF EXISTS video_job_status CASCADE;

-- Habilitar extensões necessárias
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ==========================================
-- 1. TIPOS CUSTOMIZADOS (ENUMS)
-- ==========================================

CREATE TYPE user_role AS ENUM ('student', 'teacher', 'admin');
CREATE TYPE course_category AS ENUM ('corte', 'costura', 'modelagem', 'fashion_design', 'style_design', 'mini_curso');
CREATE TYPE course_level AS ENUM ('iniciante', 'intermediario', 'avancado');
CREATE TYPE content_status AS ENUM ('draft', 'reviewing', 'published', 'archived');
CREATE TYPE assessment_type AS ENUM ('multiple_choice', 'true_false', 'essay');
CREATE TYPE submission_status AS ENUM ('pending_auto', 'pending_review', 'graded');
CREATE TYPE subscription_status AS ENUM ('active', 'past_due', 'canceled', 'trialing');
CREATE TYPE video_job_status AS ENUM ('pending', 'processing', 'completed', 'failed');

-- ==========================================
-- 2. TABELAS E ESTRUTURA DDL
-- ==========================================

-- 2.1. Perfis de Usuário (Integrado ao auth.users do Supabase)
CREATE TABLE public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    full_name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    role user_role NOT NULL DEFAULT 'student',
    avatar_url TEXT,
    bio TEXT,
    referral_code VARCHAR(20) UNIQUE,
    referred_by UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_profiles_role ON public.profiles(role);
CREATE INDEX idx_profiles_referral ON public.profiles(referral_code);

-- 2.2. Cursos (Raiz do Agregado de Conteúdo)
CREATE TABLE public.courses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    instructor_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE RESTRICT,
    title VARCHAR(255) NOT NULL,
    slug VARCHAR(255) UNIQUE NOT NULL,
    category course_category NOT NULL,
    level course_level NOT NULL,
    summary TEXT NOT NULL,
    description TEXT,
    requirements TEXT[],
    thumbnail_url TEXT,
    trailer_hls_path TEXT,
    monthly_price DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    status content_status NOT NULL DEFAULT 'draft',
    deleted_at TIMESTAMPTZ, -- Soft Delete
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_courses_category_status ON public.courses(category, status);
CREATE INDEX idx_courses_slug ON public.courses(slug);
CREATE INDEX idx_courses_deleted ON public.courses(deleted_at) WHERE deleted_at IS NULL;

-- 2.3. Módulos
CREATE TABLE public.modules (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    course_id UUID NOT NULL REFERENCES public.courses(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    order_index INTEGER NOT NULL DEFAULT 0,
    deleted_at TIMESTAMPTZ, -- Soft Delete
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_modules_course ON public.modules(course_id);
CREATE INDEX idx_modules_deleted ON public.modules(deleted_at) WHERE deleted_at IS NULL;

-- 2.4. Aulas (Lessons)
CREATE TABLE public.lessons (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    module_id UUID NOT NULL REFERENCES public.modules(id) ON DELETE CASCADE,
    course_id UUID NOT NULL REFERENCES public.courses(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    order_index INTEGER NOT NULL DEFAULT 0,
    duration_seconds INTEGER DEFAULT 0,
    hls_storage_path TEXT, -- Nullable enquanto em processamento
    material_pdf_url TEXT,
    status content_status NOT NULL DEFAULT 'draft',
    ai_summary JSONB, -- Objeto de Valor Imutável
    deleted_at TIMESTAMPTZ, -- Soft Delete
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_lessons_course_module ON public.lessons(course_id, module_id);
CREATE INDEX idx_lessons_deleted ON public.lessons(deleted_at) WHERE deleted_at IS NULL;

-- 2.5. Assinaturas (Conexão com Stripe)
CREATE TABLE public.subscriptions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    stripe_customer_id VARCHAR(255) UNIQUE NOT NULL,
    stripe_subscription_id VARCHAR(255) UNIQUE NOT NULL,
    status subscription_status NOT NULL DEFAULT 'trialing',
    current_period_start TIMESTAMPTZ NOT NULL,
    current_period_end TIMESTAMPTZ NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_subscriptions_user_status ON public.subscriptions(user_id, status);

-- 2.6. Progresso das Aulas (Zeigarnik Effect)
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

-- 2.7. Certificados
CREATE TABLE public.certificates (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    course_id UUID NOT NULL REFERENCES public.courses(id) ON DELETE CASCADE,
    certificate_hash VARCHAR(64) UNIQUE NOT NULL,
    issued_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(user_id, course_id)
);

-- 2.8. Tarefas de Avaliação (Tasks)
CREATE TABLE public.tasks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    course_id UUID NOT NULL REFERENCES public.courses(id) ON DELETE CASCADE,
    lesson_id UUID REFERENCES public.lessons(id) ON DELETE SET NULL,
    title VARCHAR(255) NOT NULL,
    prompt_question TEXT NOT NULL,
    task_type assessment_type NOT NULL,
    options JSONB, -- Ex: {"A": "Fio Reto", "B": "Viés"}
    correct_option VARCHAR(10),
    deleted_at TIMESTAMPTZ, -- Soft Delete
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_tasks_deleted ON public.tasks(deleted_at) WHERE deleted_at IS NULL;

-- 2.9. Submissão de Tarefas
CREATE TABLE public.task_submissions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    task_id UUID NOT NULL REFERENCES public.tasks(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    selected_option VARCHAR(10),
    text_answer TEXT,
    score DECIMAL(4, 2),
    status submission_status NOT NULL DEFAULT 'pending_auto',
    teacher_feedback TEXT,
    graded_by UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    submitted_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    graded_at TIMESTAMPTZ
);

CREATE INDEX idx_submissions_task_user ON public.task_submissions(task_id, user_id);

-- 2.10. Fila de Processamento de Vídeos (Fila Assíncrona contra Timeouts)
CREATE TABLE public.video_processing_jobs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    lesson_id UUID NOT NULL REFERENCES public.lessons(id) ON DELETE CASCADE,
    raw_video_path TEXT NOT NULL,
    status video_job_status NOT NULL DEFAULT 'pending',
    error_message TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_video_jobs_status ON public.video_processing_jobs(status);

-- 2.11. Controle de Idempotência do Stripe
CREATE TABLE public.stripe_processed_events (
    event_id VARCHAR(255) PRIMARY KEY,
    processed_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ==========================================
-- 3. POLÍTICAS DE ROW LEVEL SECURITY (RLS)
-- ==========================================

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.courses ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.modules ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.lessons ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.subscriptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.lesson_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.certificates ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tasks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.task_submissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.video_processing_jobs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.stripe_processed_events ENABLE ROW LEVEL SECURITY;

-- 3.1. RLS - Profiles
CREATE POLICY "Leitura pública de perfis" ON public.profiles
    FOR SELECT USING (true);

CREATE POLICY "Usuário atualiza próprio perfil" ON public.profiles
    FOR UPDATE USING (auth.uid() = id);

-- 3.2. RLS - Courses
CREATE POLICY "Visualização de cursos publicados ativos" ON public.courses
    FOR SELECT USING (
        deleted_at IS NULL AND (
            status = 'published' 
            OR instructor_id = auth.uid() 
            OR EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin')
        )
    );

CREATE POLICY "Gerenciamento de cursos por instrutor ou admin" ON public.courses
    FOR ALL USING (
        instructor_id = auth.uid() 
        OR EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin')
    );

-- 3.3. RLS - Modules
CREATE POLICY "Visualização de módulos de cursos ativos" ON public.modules
    FOR SELECT USING (
        deleted_at IS NULL AND EXISTS (
            SELECT 1 FROM public.courses c
            WHERE c.id = course_id 
              AND c.deleted_at IS NULL
              AND (
                  c.status = 'published' 
                  OR c.instructor_id = auth.uid() 
                  OR EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin')
              )
        )
    );

CREATE POLICY "Gerenciamento de módulos por instrutor ou admin" ON public.modules
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

-- 3.4. RLS - Lessons (Acesso Seguro com Grace Period de 5 dias)
CREATE POLICY "Acesso seguro a lições para assinantes com tolerância" ON public.lessons
    FOR SELECT USING (
        deleted_at IS NULL AND (
            -- 1. É o instrutor do curso ou admin
            EXISTS (SELECT 1 FROM public.courses c WHERE c.id = course_id AND c.instructor_id = auth.uid())
            OR EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin')
            -- 2. É aluno e possui assinatura ativa, trialing ou past_due (dentro da carência de 5 dias)
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

-- 3.5. RLS - Subscriptions
CREATE POLICY "Leitura de própria assinatura" ON public.subscriptions
    FOR SELECT USING (
        auth.uid() = user_id 
        OR EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin')
    );

CREATE POLICY "Mutação de assinatura por admin" ON public.subscriptions
    FOR ALL USING (
        EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin')
    );

-- 3.6. RLS - Lesson Progress
CREATE POLICY "Gerenciamento do próprio progresso" ON public.lesson_progress
    FOR ALL USING (auth.uid() = user_id);

-- 3.7. RLS - Certificates
CREATE POLICY "Visualização de próprios certificados" ON public.certificates
    FOR SELECT USING (
        auth.uid() = user_id 
        OR EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin')
    );

-- 3.8. RLS - Tasks
CREATE POLICY "Visualização de tarefas de lições ativas" ON public.tasks
    FOR SELECT USING (
        deleted_at IS NULL AND EXISTS (
            SELECT 1 FROM public.courses c
            WHERE c.id = course_id 
              AND c.deleted_at IS NULL
              AND (
                  c.status = 'published' 
                  OR c.instructor_id = auth.uid() 
                  OR EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin')
              )
        )
    );

CREATE POLICY "Gerenciamento de tarefas por instrutor ou admin" ON public.tasks
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

-- 3.9. RLS - Task Submissions
CREATE POLICY "Aluno insere própria submissão" ON public.task_submissions
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Visualização de submissão por aluno, professor ou admin" ON public.task_submissions
    FOR SELECT USING (
        auth.uid() = user_id 
        OR EXISTS (
            SELECT 1 FROM public.tasks t
            JOIN public.courses c ON c.id = t.course_id
            WHERE t.id = task_id 
              AND (
                  c.instructor_id = auth.uid() 
                  OR EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin')
              )
        )
    );

CREATE POLICY "Professor ou admin avalia submissão" ON public.task_submissions
    FOR UPDATE USING (
        EXISTS (
            SELECT 1 FROM public.tasks t
            JOIN public.courses c ON c.id = t.course_id
            WHERE t.id = task_id 
              AND (
                  c.instructor_id = auth.uid() 
                  OR EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin')
              )
        )
    );

-- 3.10. RLS - Video Processing Jobs
CREATE POLICY "Acesso a logs de vídeo para professores e admins" ON public.video_processing_jobs
    FOR SELECT USING (
        EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role IN ('teacher', 'admin'))
    );

CREATE POLICY "Gerenciamento de logs por admin" ON public.video_processing_jobs
    FOR ALL USING (
        EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin')
    );

-- 3.11. RLS - Stripe Processed Events
CREATE POLICY "Acesso exclusivo de idempotência para admin" ON public.stripe_processed_events
    FOR ALL USING (
        EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin')
    );

-- ==========================================
-- 4. TRIGGERS E AUTOMATIZAÇÕES (PL/pgSQL)
-- ==========================================

-- 4.1. Cadastro Progressivo de Atrito Zero
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.profiles (id, full_name, email, role)
    VALUES (
        NEW.id,
        COALESCE(NEW.raw_user_meta_data->>'full_name', 'Estudante Lawrence'),
        NEW.email,
        'student'
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- 4.2. Auto-correção de Tarefas de Múltipla Escolha e V/F
CREATE OR REPLACE FUNCTION public.auto_grade_submission()
RETURNS TRIGGER AS $$
DECLARE
    v_task_type assessment_type;
    v_correct_opt VARCHAR(10);
BEGIN
    SELECT task_type, correct_option INTO v_task_type, v_correct_opt
    FROM public.tasks WHERE id = NEW.task_id;

    IF v_task_type IN ('multiple_choice', 'true_false') THEN
        IF NEW.selected_option = v_correct_opt THEN
            NEW.score := 10.00;
            NEW.teacher_feedback := 'Correção automática: Resposta correta.';
        ELSE
            NEW.score := 0.00;
            NEW.teacher_feedback := 'Correção automática: Resposta incorreta.';
        END IF;
        NEW.status := 'graded';
        NEW.graded_at := NOW();
    ELSE
        NEW.status := 'pending_review';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER trg_auto_grade
    BEFORE INSERT ON public.task_submissions
    FOR EACH ROW EXECUTE FUNCTION public.auto_grade_submission();
