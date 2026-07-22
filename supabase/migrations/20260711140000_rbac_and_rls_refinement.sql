-- ======================================================
-- Lawrence Academy RBAC and RLS Refinement
-- Date: 2026-07-11
-- Purpose: Implement Role-Based Access Control and fine-grained RLS.
-- ======================================================

-- 1. Create RBAC Tables with UNIQUE Constraints
CREATE TABLE IF NOT EXISTS public.roles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) UNIQUE NOT NULL,
    description TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.permissions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    key VARCHAR(100) UNIQUE NOT NULL,
    description TEXT
);

CREATE TABLE IF NOT EXISTS public.role_permissions (
    role_id UUID REFERENCES public.roles(id) ON DELETE CASCADE,
    permission_id UUID REFERENCES public.permissions(id) ON DELETE CASCADE,
    PRIMARY KEY(role_id, permission_id)
);

CREATE TABLE IF NOT EXISTS public.user_roles (
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    role_id UUID REFERENCES public.roles(id) ON DELETE CASCADE,
    PRIMARY KEY(user_id, role_id)
);

-- Seed basic roles
INSERT INTO public.roles (name, description) VALUES
    ('student', 'Estudante da plataforma'),
    ('teacher', 'Instrutor da plataforma'),
    ('admin', 'Administrador com acesso gerenciado'),
    ('super_admin', 'Administrador global')
ON CONFLICT (name) DO NOTHING;

-- 2. Migrate existing roles from profiles (WITHOUT dropping profiles.role yet)
-- Note: users can have multiple roles in the new schema. 
-- The main role will be determined by get_primary_role().
INSERT INTO public.user_roles (user_id, role_id)
SELECT p.id, r.id
FROM public.profiles p
JOIN public.roles r ON r.name = p.role::text
ON CONFLICT DO NOTHING;

-- 3. Centralized Access Function (SECURITY DEFINER with search_path)
CREATE OR REPLACE FUNCTION public.has_active_course_access(p_user_id UUID, p_course_id UUID)
RETURNS BOOLEAN
SET search_path = public
SECURITY DEFINER
AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM public.subscriptions s
        WHERE s.student_id = p_user_id
          AND s.course_id = p_course_id
          AND s.status IN ('active', 'trialing', 'past_due')
          AND s.current_period_end + INTERVAL '5 days' > NOW()
    );
END;
$$ LANGUAGE plpgsql;

-- 4. Helper Functions (Admin / Teacher) (SECURITY DEFINER with search_path)
CREATE OR REPLACE FUNCTION public.is_admin(p_user_id UUID)
RETURNS BOOLEAN
SET search_path = public
SECURITY DEFINER
AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM public.user_roles ur
        JOIN public.roles r ON r.id = ur.role_id
        WHERE ur.user_id = p_user_id AND r.name IN ('admin', 'super_admin')
    );
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION public.is_teacher(p_user_id UUID)
RETURNS BOOLEAN
SET search_path = public
SECURITY DEFINER
AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM public.user_roles ur
        JOIN public.roles r ON r.id = ur.role_id
        WHERE ur.user_id = p_user_id AND r.name = 'teacher'
    );
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION public.get_primary_role(p_user_id UUID)
RETURNS VARCHAR
SET search_path = public
SECURITY DEFINER
AS $$
DECLARE
    v_role VARCHAR;
BEGIN
    SELECT r.name INTO v_role
    FROM public.user_roles ur
    JOIN public.roles r ON r.id = ur.role_id
    WHERE ur.user_id = p_user_id
    ORDER BY 
        CASE r.name
            WHEN 'super_admin' THEN 1
            WHEN 'admin' THEN 2
            WHEN 'teacher' THEN 3
            WHEN 'student' THEN 4
            ELSE 5
        END
    LIMIT 1;
    
    RETURN COALESCE(v_role, 'student');
END;
$$ LANGUAGE plpgsql;

-- 5. profile_public_view
-- Evita expor dados privados e usa o primary role derivado do RBAC.
DROP VIEW IF EXISTS public.profile_public_view CASCADE;
CREATE VIEW public.profile_public_view AS
SELECT 
    id, 
    full_name, 
    avatar_url, 
    bio, 
    public.get_primary_role(id) AS role
FROM public.profiles;

-- 6. RBAC Tables RLS
ALTER TABLE public.roles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.permissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.role_permissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_roles ENABLE ROW LEVEL SECURITY;

-- Block self-assignment, escalation or changes by non-authorized users
DROP POLICY IF EXISTS "Public read for roles" ON public.roles;
CREATE POLICY "Public read for roles" ON public.roles FOR SELECT USING (true);

DROP POLICY IF EXISTS "Public read for permissions" ON public.permissions;
CREATE POLICY "Public read for permissions" ON public.permissions FOR SELECT USING (true);

DROP POLICY IF EXISTS "Admin manage roles" ON public.roles;
CREATE POLICY "Admin manage roles" ON public.roles FOR ALL USING (public.is_admin(auth.uid()));

DROP POLICY IF EXISTS "Admin manage permissions" ON public.permissions;
CREATE POLICY "Admin manage permissions" ON public.permissions FOR ALL USING (public.is_admin(auth.uid()));

DROP POLICY IF EXISTS "Admin manage role_permissions" ON public.role_permissions;
CREATE POLICY "Admin manage role_permissions" ON public.role_permissions FOR ALL USING (public.is_admin(auth.uid()));

-- For user_roles: User can read their own roles. Only admins can insert/update/delete.
DROP POLICY IF EXISTS "User read own roles" ON public.user_roles;
CREATE POLICY "User read own roles" ON public.user_roles FOR SELECT USING (
    auth.uid() = user_id OR public.is_admin(auth.uid())
);

DROP POLICY IF EXISTS "Admin manage user_roles" ON public.user_roles;
CREATE POLICY "Admin manage user_roles" ON public.user_roles FOR ALL USING (
    public.is_admin(auth.uid())
);

-- 7. Update Existing Policies

-- 7.1 Courses
DROP POLICY IF EXISTS "Visualização de cursos publicados ativos" ON public.courses;
CREATE POLICY "Visualização de cursos publicados ativos" ON public.courses
    FOR SELECT USING (
        deleted_at IS NULL AND (
            status = 'published' 
            OR instructor_id = auth.uid() 
            OR public.is_admin(auth.uid())
        )
    );

DROP POLICY IF EXISTS "Gerenciamento de cursos por instrutor ou admin" ON public.courses;
CREATE POLICY "Gerenciamento de cursos por instrutor ou admin" ON public.courses
    FOR ALL USING (
        instructor_id = auth.uid() 
        OR public.is_admin(auth.uid())
    );

-- 7.2 Modules (Keep public for published courses)
DROP POLICY IF EXISTS "Visualização de módulos de cursos ativos" ON public.modules;
CREATE POLICY "Visualização de módulos de cursos ativos" ON public.modules
    FOR SELECT USING (
        deleted_at IS NULL AND EXISTS (
            SELECT 1 FROM public.courses c
            WHERE c.id = course_id 
              AND c.deleted_at IS NULL
              AND (
                  c.status = 'published' 
                  OR c.instructor_id = auth.uid() 
                  OR public.is_admin(auth.uid())
              )
        )
    );

DROP POLICY IF EXISTS "Gerenciamento de módulos por instrutor ou admin" ON public.modules;
CREATE POLICY "Gerenciamento de módulos por instrutor ou admin" ON public.modules
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM public.courses c
            WHERE c.id = course_id
              AND (
                  c.instructor_id = auth.uid() 
                  OR public.is_admin(auth.uid())
              )
        )
    );

-- 7.3 Lessons (Protect content but respect preview)
ALTER TABLE public.lessons ADD COLUMN IF NOT EXISTS is_preview BOOLEAN NOT NULL DEFAULT FALSE;

DROP POLICY IF EXISTS "Acesso seguro a lições para assinantes com tolerância" ON public.lessons;
DROP POLICY IF EXISTS "student_select_lesson" ON public.lessons;
CREATE POLICY "student_select_lesson" ON public.lessons
    FOR SELECT USING (
        deleted_at IS NULL AND status = 'published' AND (
            is_preview = true
            OR public.has_active_course_access(auth.uid(), course_id)
        )
    );

DROP POLICY IF EXISTS "teacher_all_own_lesson" ON public.lessons;
CREATE POLICY "teacher_all_own_lesson" ON public.lessons
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM public.courses c
            WHERE c.id = lessons.course_id
              AND c.instructor_id = auth.uid()
        )
    );

DROP POLICY IF EXISTS "admin_all_lesson" ON public.lessons;
CREATE POLICY "admin_all_lesson" ON public.lessons
    FOR ALL USING (public.is_admin(auth.uid()));

-- 7.4 Tasks
DROP POLICY IF EXISTS "Visualização de tarefas de lições ativas" ON public.tasks;
CREATE POLICY "Visualização de tarefas de lições ativas" ON public.tasks
    FOR SELECT USING (
        deleted_at IS NULL AND (
            public.has_active_course_access(auth.uid(), course_id)
            OR EXISTS (SELECT 1 FROM public.courses c WHERE c.id = course_id AND c.instructor_id = auth.uid())
            OR public.is_admin(auth.uid())
        )
    );

DROP POLICY IF EXISTS "Gerenciamento de tarefas por instrutor ou admin" ON public.tasks;
CREATE POLICY "Gerenciamento de tarefas por instrutor ou admin" ON public.tasks
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM public.courses c
            WHERE c.id = course_id
              AND c.instructor_id = auth.uid()
        )
        OR public.is_admin(auth.uid())
    );

-- 7.5 Task Submissions
DROP POLICY IF EXISTS "Visualização de submissão por aluno, professor ou admin" ON public.task_submissions;
CREATE POLICY "Visualização de submissão por aluno, professor ou admin" ON public.task_submissions
    FOR SELECT USING (
        auth.uid() = user_id 
        OR EXISTS (
            SELECT 1 FROM public.tasks t
            JOIN public.courses c ON c.id = t.course_id
            WHERE t.id = task_id 
              AND (
                  c.instructor_id = auth.uid() 
                  OR public.is_admin(auth.uid())
              )
        )
    );

DROP POLICY IF EXISTS "Professor ou admin avalia submissão" ON public.task_submissions;
CREATE POLICY "Professor ou admin avalia submissão" ON public.task_submissions
    FOR UPDATE USING (
        EXISTS (
            SELECT 1 FROM public.tasks t
            JOIN public.courses c ON c.id = t.course_id
            WHERE t.id = task_id 
              AND (
                  c.instructor_id = auth.uid() 
                  OR public.is_admin(auth.uid())
              )
        )
    );

-- 7.6 Certificates
DROP POLICY IF EXISTS "Visualização de próprios certificados" ON public.certificates;
CREATE POLICY "Visualização de próprios certificados" ON public.certificates
    FOR SELECT USING (
        auth.uid() = user_id 
        OR public.is_admin(auth.uid())
    );
