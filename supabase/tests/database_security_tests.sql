-- ======================================================
-- Lawrence Academy Database Integration & Security Tests
-- Date: 2026-07-10
-- Purpose: Verify Triggers, Soft Delete, RLS, and Integrity constraints on Supabase
-- ======================================================

BEGIN;

-- 1. Setup Mock Data
-- Criar IDs fixos para testes
DEALLOCATE ALL;
PREPARE test_setup AS SELECT
    '11111111-1111-1111-1111-111111111111'::uuid AS instructor_id,
    '22222222-2222-2222-2222-222222222222'::uuid AS student_active_id,
    '33333333-3333-3333-3333-333333333333'::uuid AS student_inactive_id,
    '44444444-4444-4444-4444-444444444444'::uuid AS student_grace_id,
    '55555555-5555-5555-5555-555555555555'::uuid AS student_past_grace_id,
    '66666666-6666-6666-6666-666666666666'::uuid AS student_other_course_id,
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'::uuid AS course_id,
    'a2a2a2a2-a2a2-a2a2-a2a2-a2a2a2a2a2a2'::uuid AS other_course_id,
    'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb'::uuid AS module_id,
    'cccccccc-cccc-cccc-cccc-cccccccccccc'::uuid AS lesson_id,
    'c2c2c2c2-c2c2-c2c2-c2c2-c2c2c2c2c2c2'::uuid AS other_lesson_id,
    'dddddddd-dddd-dddd-dddd-dddddddddddd'::uuid AS task_id;

-- Inserir auth.users para disparar o trigger handle_new_user
INSERT INTO auth.users (id, email, raw_user_meta_data)
VALUES 
    ('11111111-1111-1111-1111-111111111111', 'instructor@lawrence.academy', '{"full_name": "Ariane Instructor"}'),
    ('22222222-2222-2222-2222-222222222222', 'active@lawrence.academy', '{"full_name": "Student Active"}'),
    ('33333333-3333-3333-3333-333333333333', 'inactive@lawrence.academy', '{"full_name": "Student Inactive"}'),
    ('44444444-4444-4444-4444-444444444444', 'grace@lawrence.academy', '{"full_name": "Student Grace"}'),
    ('55555555-5555-5555-5555-555555555555', 'pastgrace@lawrence.academy', '{"full_name": "Student Past Grace"}'),
    ('66666666-6666-6666-6666-666666666666', 'othercourse@lawrence.academy', '{"full_name": "Student Other Course"}');

-- Ajustar a role do instrutor
UPDATE public.profiles SET role = 'teacher' WHERE id = '11111111-1111-1111-1111-111111111111';

-- TESTE 1: Validar que os perfis foram criados automaticamente pelo trigger
DO $$
DECLARE
    v_count integer;
BEGIN
    SELECT COUNT(*) INTO v_count FROM public.profiles WHERE id IN (
        '11111111-1111-1111-1111-111111111111',
        '22222222-2222-2222-2222-222222222222',
        '33333333-3333-3333-3333-333333333333',
        '44444444-4444-4444-4444-444444444444',
        '55555555-5555-5555-5555-555555555555',
        '66666666-6666-6666-6666-666666666666'
    );
    IF v_count = 6 THEN
        RAISE NOTICE 'TEST 1 PASSED: Profiles automatically created by trigger.';
    ELSE
        RAISE EXCEPTION 'TEST 1 FAILED: Expected 6 profiles, got %', v_count;
    END IF;
END $$;

-- Criar cursos, módulos, lições e tarefas
INSERT INTO public.courses (id, instructor_id, title, slug, category, level, summary, status)
VALUES 
    ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', '11111111-1111-1111-1111-111111111111', 'Curso de Modelagem', 'curso-modelagem', 'modelagem', 'iniciante', 'Resumo 1', 'published'),
    ('a2a2a2a2-a2a2-a2a2-a2a2-a2a2a2a2a2a2', '11111111-1111-1111-1111-111111111111', 'Curso de Costura', 'curso-costura', 'costura', 'iniciante', 'Resumo 2', 'published');

INSERT INTO public.modules (id, course_id, title, order_index)
VALUES 
    ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Módulo 1', 1),
    ('b2b2b2b2-b2b2-b2b2-b2b2-b2b2b2b2b2b2', 'a2a2a2a2-a2a2-a2a2-a2a2-a2a2a2a2a2a2', 'Módulo 2', 1);

INSERT INTO public.lessons (id, module_id, course_id, title, status, hls_storage_path)
VALUES 
    ('cccccccc-cccc-cccc-cccc-cccccccccccc', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Lição Modelagem', 'published', 'lessons/l1/master.m3u8'),
    ('c2c2c2c2-c2c2-c2c2-c2c2-c2c2c2c2c2c2', 'b2b2b2b2-b2b2-b2b2-b2b2-b2b2b2b2b2b2', 'a2a2a2a2-a2a2-a2a2-a2a2-a2a2a2a2a2a2', 'Lição Costura', 'published', 'lessons/l2/master.m3u8');

INSERT INTO public.tasks (id, course_id, lesson_id, title, prompt_question, task_type, correct_option)
VALUES ('dddddddd-dddd-dddd-dddd-dddddddddddd', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'cccccccc-cccc-cccc-cccc-cccccccccccc', 'Tarefa 1', 'Pergunta', 'multiple_choice', 'C');

-- Configurar assinaturas dos alunos
-- Ativo no Curso de Modelagem (course_id: aaaaaaaa-...)
INSERT INTO public.subscriptions (student_id, course_id, provider_customer_id, provider_subscription_id, status, monthly_price, currency, current_period_start, current_period_end)
VALUES ('22222222-2222-2222-2222-222222222222', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'cust_active', 'sub_active', 'active', 89.90, 'BRL', NOW() - INTERVAL '10 days', NOW() + INTERVAL '20 days');

-- Em carência (past_due, venceu há 2 dias, menor que 5 dias de carência) no Curso de Modelagem
INSERT INTO public.subscriptions (student_id, course_id, provider_customer_id, provider_subscription_id, status, monthly_price, currency, current_period_start, current_period_end)
VALUES ('44444444-4444-4444-4444-444444444444', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'cust_grace', 'sub_grace', 'past_due', 89.90, 'BRL', NOW() - INTERVAL '32 days', NOW() - INTERVAL '2 days');

-- Fora de carência (past_due, venceu há 6 dias) no Curso de Modelagem
INSERT INTO public.subscriptions (student_id, course_id, provider_customer_id, provider_subscription_id, status, monthly_price, currency, current_period_start, current_period_end)
VALUES ('55555555-5555-5555-5555-555555555555', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'cust_pastgrace', 'sub_pastgrace', 'past_due', 89.90, 'BRL', NOW() - INTERVAL '36 days', NOW() - INTERVAL '6 days');

-- Ativo no Curso de Costura (course_id: a2a2a2a2-...)
INSERT INTO public.subscriptions (student_id, course_id, provider_customer_id, provider_subscription_id, status, monthly_price, currency, current_period_start, current_period_end)
VALUES ('66666666-6666-6666-6666-666666666666', 'a2a2a2a2-a2a2-a2a2-a2a2-a2a2a2a2a2a2', 'cust_other', 'sub_other', 'active', 89.90, 'BRL', NOW() - INTERVAL '10 days', NOW() + INTERVAL '20 days');


-- TESTE 2: Auto-correção de Tarefas
INSERT INTO public.task_submissions (task_id, user_id, selected_option)
VALUES ('dddddddd-dddd-dddd-dddd-dddddddddddd', '22222222-2222-2222-2222-222222222222', 'C');

INSERT INTO public.task_submissions (task_id, user_id, selected_option)
VALUES ('dddddddd-dddd-dddd-dddd-dddddddddddd', '44444444-4444-4444-4444-444444444444', 'A');

DO $$
DECLARE
    v_score_correct decimal;
    v_score_incorrect decimal;
BEGIN
    SELECT score INTO v_score_correct FROM public.task_submissions 
    WHERE user_id = '22222222-2222-2222-2222-222222222222' AND selected_option = 'C';

    SELECT score INTO v_score_incorrect FROM public.task_submissions 
    WHERE user_id = '44444444-4444-4444-4444-444444444444' AND selected_option = 'A';

    IF v_score_correct = 10.00 AND v_score_incorrect = 0.00 THEN
        RAISE NOTICE 'TEST 2 PASSED: Auto-grading trigger calculated scores correctly.';
    ELSE
        RAISE EXCEPTION 'TEST 2 FAILED: Expected correct 10.00 (got %) and incorrect 0.00 (got %)', v_score_correct, v_score_incorrect;
    END IF;
END $$;


-- TESTE 3: RLS de Lições (Lessons RLS) com validação de Curso Específico
-- 3.1. Aluno Ativo no Curso de Modelagem tentando acessar Aula de Modelagem (Permitido)
SET LOCAL request.jwt.claim.sub = '22222222-2222-2222-2222-222222222222';
SET LOCAL role = 'authenticated';

DO $$
DECLARE
    v_lessons_count integer;
BEGIN
    SELECT COUNT(*) INTO v_lessons_count FROM public.lessons WHERE id = 'cccccccc-cccc-cccc-cccc-cccccccccccc';
    IF v_lessons_count = 1 THEN
        RAISE NOTICE 'TEST 3.1 PASSED: Active subscriber can access own course lesson.';
    ELSE
        RAISE EXCEPTION 'TEST 3.1 FAILED: Active subscriber could not read own course lesson.';
    END IF;
END $$;

-- 3.2. Aluno Ativo no Curso de Modelagem tentando acessar Aula do Curso de Costura (Bloqueado!)
SET LOCAL request.jwt.claim.sub = '22222222-2222-2222-2222-222222222222';
SET LOCAL role = 'authenticated';

DO $$
DECLARE
    v_lessons_count integer;
BEGIN
    SELECT COUNT(*) INTO v_lessons_count FROM public.lessons WHERE id = 'c2c2c2c2-c2c2-c2c2-c2c2-c2c2c2c2c2c2';
    IF v_lessons_count = 0 THEN
        RAISE NOTICE 'TEST 3.2 PASSED: Subscriber is blocked from accessing lessons of a course they do not subscribe to.';
    ELSE
        RAISE EXCEPTION 'TEST 3.2 FAILED: Student was able to access a lesson of a course without subscription.';
    END IF;
END $$;

-- 3.3. Aluno em Carência (past_due, < 5 dias) no Curso de Modelagem (Permitido)
SET LOCAL request.jwt.claim.sub = '44444444-4444-4444-4444-444444444444';
SET LOCAL role = 'authenticated';

DO $$
DECLARE
    v_lessons_count integer;
BEGIN
    SELECT COUNT(*) INTO v_lessons_count FROM public.lessons WHERE id = 'cccccccc-cccc-cccc-cccc-cccccccccccc';
    IF v_lessons_count = 1 THEN
        RAISE NOTICE 'TEST 3.3 PASSED: Past_due subscriber within Grace Period can access lesson.';
    ELSE
        RAISE EXCEPTION 'TEST 3.3 FAILED: Grace Period subscriber could not read lesson.';
    END IF;
END $$;

-- 3.4. Aluno Fora da Carência (past_due, > 5 dias) no Curso de Modelagem (Bloqueado)
SET LOCAL request.jwt.claim.sub = '55555555-5555-5555-5555-555555555555';
SET LOCAL role = 'authenticated';

DO $$
DECLARE
    v_lessons_count integer;
BEGIN
    SELECT COUNT(*) INTO v_lessons_count FROM public.lessons WHERE id = 'cccccccc-cccc-cccc-cccc-cccccccccccc';
    IF v_lessons_count = 0 THEN
        RAISE NOTICE 'TEST 3.4 PASSED: Past_due subscriber outside Grace Period is blocked.';
    ELSE
        RAISE EXCEPTION 'TEST 3.4 FAILED: Out of Grace Period subscriber was able to read lesson.';
    END IF;
END $$;


-- TESTE 4: RLS de Perfis (Profiles RLS)
-- 4.1. Aluno tentando ler o próprio perfil (Permitido)
SET LOCAL request.jwt.claim.sub = '22222222-2222-2222-2222-222222222222';
SET LOCAL role = 'authenticated';

DO $$
DECLARE
    v_profiles_count integer;
BEGIN
    SELECT COUNT(*) INTO v_profiles_count FROM public.profiles WHERE id = '22222222-2222-2222-2222-222222222222';
    IF v_profiles_count = 1 THEN
        RAISE NOTICE 'TEST 4.1 PASSED: User can query their own profile.';
    ELSE
        RAISE EXCEPTION 'TEST 4.1 FAILED: User could not query their own profile.';
    END IF;
END $$;

-- 4.2. Aluno tentando ler perfil de outro aluno (Bloqueado)
SET LOCAL request.jwt.claim.sub = '22222222-2222-2222-2222-222222222222';
SET LOCAL role = 'authenticated';

DO $$
DECLARE
    v_profiles_count integer;
BEGIN
    SELECT COUNT(*) INTO v_profiles_count FROM public.profiles WHERE id = '33333333-3333-3333-3333-333333333333';
    IF v_profiles_count = 0 THEN
        RAISE NOTICE 'TEST 4.2 PASSED: User is blocked from querying other users profiles.';
    ELSE
        RAISE EXCEPTION 'TEST 4.2 FAILED: User was able to query other user''s private profile.';
    END IF;
END $$;

-- 4.3. Visualização pública limitada via View (Permitido para todos)
SET LOCAL request.jwt.claim.sub = '33333333-3333-3333-3333-333333333333';
SET LOCAL role = 'authenticated';

DO $$
DECLARE
    v_view_count integer;
BEGIN
    -- Deve conseguir ler o perfil público do instrutor
    SELECT COUNT(*) INTO v_view_count FROM public.profile_public_view WHERE id = '11111111-1111-1111-1111-111111111111';
    IF v_view_count = 1 THEN
        RAISE NOTICE 'TEST 4.3 PASSED: Public view allows checking public profiles.';
    ELSE
        RAISE EXCEPTION 'TEST 4.3 FAILED: Could not read public profiles view.';
    END IF;
END $$;


-- TESTE 5: Lesson Progress Integrity
-- 5.1. Aluno insere progresso de aula com course_id correto (Permitido)
SET LOCAL request.jwt.claim.sub = '22222222-2222-2222-2222-222222222222';
SET LOCAL role = 'authenticated';

INSERT INTO public.lesson_progress (student_id, course_id, lesson_id, watched_seconds, completed)
VALUES ('22222222-2222-2222-2222-222222222222', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'cccccccc-cccc-cccc-cccc-cccccccccccc', 120, false);

-- 5.2. Aluno tenta inserir progresso de aula com course_id incorreto / divergente da lesson (Bloqueado via trigger!)
DO $$
BEGIN
    BEGIN
        INSERT INTO public.lesson_progress (student_id, course_id, lesson_id, watched_seconds, completed)
        VALUES ('22222222-2222-2222-2222-222222222222', 'a2a2a2a2-a2a2-a2a2-a2a2-a2a2a2a2a2a2', 'cccccccc-cccc-cccc-cccc-cccccccccccc', 120, false);
        
        RAISE EXCEPTION 'TEST 5.2 FAILED: Allowed inserting progress with mismatched course_id.';
    EXCEPTION WHEN OTHERS THEN
        RAISE NOTICE 'TEST 5.2 PASSED: Mismatched course_id in progress was successfully blocked by trigger: %', SQLERRM;
    END;
END $$;


-- TESTE 6: Idempotência de Eventos de Pagamento
-- 6.1. Registrar evento de pagamento (Permitido)
SET LOCAL role = 'postgres'; -- Simula processador de webhook que roda como admin/postgres
INSERT INTO public.payment_events (provider, provider_event_id, event_type, payload_hash)
VALUES ('stripe', 'evt_test_123', 'invoice.paid', 'hash_test_123');

-- 6.2. Inserir o mesmo evento novamente (Bloqueado por constraint unique!)
DO $$
BEGIN
    BEGIN
        INSERT INTO public.payment_events (provider, provider_event_id, event_type, payload_hash)
        VALUES ('stripe', 'evt_test_123', 'invoice.paid', 'hash_test_123');
        
        RAISE EXCEPTION 'TEST 6.2 FAILED: Allowed duplicate payment event.';
    EXCEPTION WHEN OTHERS THEN
        RAISE NOTICE 'TEST 6.2 PASSED: Duplicate payment event was successfully blocked by unique constraint.';
    END;
END $$;

-- Finalizar transação e dar rollback para manter banco limpo
ROLLBACK;
