-- 1. Tipos Customizados (PostgreSQL Enums)
CREATE TYPE user_role AS ENUM ('student', 'teacher', 'admin');
CREATE TYPE course_category AS ENUM ('corte', 'costura', 'modelagem', 'fashion_design', 'style_design', 'mini_curso');
CREATE TYPE course_level AS ENUM ('iniciante', 'intermediario', 'avancado');
CREATE TYPE content_status AS ENUM ('draft', 'reviewing', 'published', 'archived');
CREATE TYPE assessment_type AS ENUM ('multiple_choice', 'true_false', 'essay');
CREATE TYPE submission_status AS ENUM ('pending_auto', 'pending_review', 'graded');
CREATE TYPE subscription_status AS ENUM ('active', 'past_due', 'canceled', 'trialing');

-- 2. Esquema DDL (Tabelas e Relacionamentos)

-- Contexto de Usuários
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

-- Contexto de Cursos
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
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_courses_category_status ON public.courses(category, status);
CREATE INDEX idx_courses_slug ON public.courses(slug);

-- Contexto de Módulos e Lições
CREATE TABLE public.modules (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    course_id UUID NOT NULL REFERENCES public.courses(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    order_index INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE public.lessons (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    module_id UUID NOT NULL REFERENCES public.modules(id) ON DELETE CASCADE,
    course_id UUID NOT NULL REFERENCES public.courses(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    order_index INTEGER NOT NULL DEFAULT 0,
    duration_seconds INTEGER DEFAULT 0,
    hls_storage_path TEXT NOT NULL,
    material_pdf_url TEXT,
    ai_summary JSONB,
    status content_status NOT NULL DEFAULT 'draft',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_lessons_course_module ON public.lessons(course_id, module_id);

-- Contexto de Pagamentos
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

-- Contexto de Progresso e Certificados
CREATE TABLE public.lesson_progress (
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    lesson_id UUID NOT NULL REFERENCES public.lessons(id) ON DELETE CASCADE,
    course_id UUID NOT NULL REFERENCES public.courses(id) ON DELETE CASCADE,
    completed BOOLEAN NOT NULL DEFAULT FALSE,
    watched_seconds INTEGER DEFAULT 0,
    completed_at TIMESTAMPTZ,
    PRIMARY KEY (user_id, lesson_id)
);

CREATE TABLE public.certificates (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    course_id UUID NOT NULL REFERENCES public.courses(id) ON DELETE CASCADE,
    certificate_hash VARCHAR(64) UNIQUE NOT NULL,
    issued_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(user_id, course_id)
);

-- Contexto de Avaliações
CREATE TABLE public.tasks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    course_id UUID NOT NULL REFERENCES public.courses(id) ON DELETE CASCADE,
    lesson_id UUID REFERENCES public.lessons(id) ON DELETE SET NULL,
    title VARCHAR(255) NOT NULL,
    prompt_question TEXT NOT NULL,
    task_type assessment_type NOT NULL,
    options JSONB,
    correct_option VARCHAR(10),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

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

-- 3. Políticas de Segurança (RLS)

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.courses ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.modules ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.lessons ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.subscriptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.lesson_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.certificates ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tasks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.task_submissions ENABLE ROW LEVEL SECURITY;

-- Políticas de Profiles
CREATE POLICY "Leitura pública de perfis" ON public.profiles FOR SELECT USING (true);
CREATE POLICY "Usuário atualiza o próprio perfil" ON public.profiles FOR UPDATE USING (auth.uid() = id);

-- Políticas de Cursos
CREATE POLICY "Visualizar cursos publicados" ON public.courses FOR SELECT USING (status = 'published');
CREATE POLICY "Instrutor gerencia seus cursos" ON public.courses FOR ALL USING (auth.uid() = instructor_id);

-- Políticas de Lições
CREATE POLICY "Acesso seguro a lições para assinantes ativos" ON public.lessons FOR SELECT USING (
    status = 'published' AND (
        EXISTS (SELECT 1 FROM public.courses c WHERE c.id = course_id AND c.instructor_id = auth.uid())
        OR EXISTS (SELECT 1 FROM public.profiles p WHERE p.id = auth.uid() AND p.role = 'admin')
        OR EXISTS (SELECT 1 FROM public.subscriptions s WHERE s.user_id = auth.uid() AND s.status IN ('active', 'trialing') AND s.current_period_end > NOW())
    )
);

-- Políticas de Progresso e Submissões
CREATE POLICY "Aluno gerencia próprio progresso" ON public.lesson_progress FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "Aluno insere submissão" ON public.task_submissions FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Aluno visualiza própria submissão" ON public.task_submissions FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Professor corrige submissões" ON public.task_submissions FOR UPDATE USING (
    EXISTS (SELECT 1 FROM public.tasks t JOIN public.courses c ON c.id = t.course_id WHERE t.id = task_id AND c.instructor_id = auth.uid())
);

-- 4. Triggers de Automatização

-- Criar perfil automaticamente após signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.profiles (id, full_name, email, role)
    VALUES (NEW.id, COALESCE(NEW.raw_user_meta_data->>'full_name', 'Estudante'), NEW.email, 'student');
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Auto-correção de questões fechadas
CREATE OR REPLACE FUNCTION public.auto_grade_submission()
RETURNS TRIGGER AS $$
DECLARE
    v_task_type assessment_type;
    v_correct_opt VARCHAR(10);
BEGIN
    SELECT task_type, correct_option INTO v_task_type, v_correct_opt FROM public.tasks WHERE id = NEW.task_id;
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

CREATE TRIGGER trg_auto_grade
    BEFORE INSERT ON public.task_submissions FOR EACH ROW EXECUTE FUNCTION public.auto_grade_submission();