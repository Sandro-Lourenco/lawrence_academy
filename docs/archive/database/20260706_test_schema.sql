-- ==========================================
-- Lawrence Academy Database Integration Tests
-- Date: 2026-07-06
-- Purpose: Verify Triggers, Soft Delete, and RLS policies on Supabase
-- ==========================================

BEGIN;

-- 1. Setup Mock Data
-- Criar IDs fixos para testes (apenas hexadecimais válidos para UUID)
DEALLOCATE ALL;
PREPARE test_setup AS SELECT
    '11111111-1111-1111-1111-111111111111'::uuid AS instructor_id,
    '22222222-2222-2222-2222-222222222222'::uuid AS student_active_id,
    '33333333-3333-3333-3333-333333333333'::uuid AS student_inactive_id,
    '44444444-4444-4444-4444-444444444444'::uuid AS student_grace_id,
    '55555555-5555-5555-5555-555555555555'::uuid AS student_past_grace_id,
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'::uuid AS course_id,
    'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb'::uuid AS module_id,
    'cccccccc-cccc-cccc-cccc-cccccccccccc'::uuid AS lesson_id,
    'dddddddd-dddd-dddd-dddd-dddddddddddd'::uuid AS task_id;

-- Para fins de teste na transação, vamos inserir na auth.users para disparar o trigger
INSERT INTO auth.users (id, email, raw_user_meta_data)
VALUES 
    ('11111111-1111-1111-1111-111111111111', 'instructor@lawrence.academy', '{"full_name": "Ariane Instructor"}'),
    ('22222222-2222-2222-2222-222222222222', 'active@lawrence.academy', '{"full_name": "Student Active"}'),
    ('33333333-3333-3333-3333-333333333333', 'inactive@lawrence.academy', '{"full_name": "Student Inactive"}'),
    ('44444444-4444-4444-4444-444444444444', 'grace@lawrence.academy', '{"full_name": "Student Grace"}'),
    ('55555555-5555-5555-5555-555555555555', 'pastgrace@lawrence.academy', '{"full_name": "Student Past Grace"}');

-- Ajustar a role do instrutor para 'teacher'
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
        '55555555-5555-5555-5555-555555555555'
    );
    IF v_count = 5 THEN
        RAISE NOTICE 'TEST 1 PASSED: Profiles automatically created by trigger.';
    ELSE
        RAISE EXCEPTION 'TEST 1 FAILED: Expected 5 profiles, got %', v_count;
    END IF;
END $$;

-- Criar curso, módulo, aula e tarefa
INSERT INTO public.courses (id, instructor_id, title, slug, category, level, summary, status)
VALUES ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', '11111111-1111-1111-1111-111111111111', 'Curso de Teste', 'curso-de-teste', 'modelagem', 'iniciante', 'Resumo', 'published');

INSERT INTO public.modules (id, course_id, title, order_index)
VALUES ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Módulo 1', 1);

INSERT INTO public.lessons (id, module_id, course_id, title, status, hls_storage_path)
VALUES ('cccccccc-cccc-cccc-cccc-cccccccccccc', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Lição 1', 'published', 'lessons/l1/master.m3u8');

INSERT INTO public.tasks (id, course_id, lesson_id, title, prompt_question, task_type, correct_option)
VALUES ('dddddddd-dddd-dddd-dddd-dddddddddddd', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'cccccccc-cccc-cccc-cccc-cccccccccccc', 'Tarefa 1', 'Pergunta', 'multiple_choice', 'C');

-- Configurar assinaturas dos alunos
-- Ativo
INSERT INTO public.subscriptions (user_id, stripe_customer_id, stripe_subscription_id, status, current_period_start, current_period_end)
VALUES ('22222222-2222-2222-2222-222222222222', 'cust_active', 'sub_active', 'active', NOW() - INTERVAL '10 days', NOW() + INTERVAL '20 days');

-- Em carência (past_due, venceu há 2 dias, menor que 5 dias de carência)
INSERT INTO public.subscriptions (user_id, stripe_customer_id, stripe_subscription_id, status, current_period_start, current_period_end)
VALUES ('44444444-4444-4444-4444-444444444444', 'cust_grace', 'sub_grace', 'past_due', NOW() - INTERVAL '32 days', NOW() - INTERVAL '2 days');

-- Fora de carência (past_due, venceu há 6 dias)
INSERT INTO public.subscriptions (user_id, stripe_customer_id, stripe_subscription_id, status, current_period_start, current_period_end)
VALUES ('55555555-5555-5555-5555-555555555555', 'cust_pastgrace', 'sub_pastgrace', 'past_due', NOW() - INTERVAL '36 days', NOW() - INTERVAL '6 days');

-- Inativo (sem assinatura) - nada inserido.

-- TESTE 2: Auto-correção de Tarefas
-- Inserir resposta correta
INSERT INTO public.task_submissions (task_id, user_id, selected_option)
VALUES ('dddddddd-dddd-dddd-dddd-dddddddddddd', '22222222-2222-2222-2222-222222222222', 'C');

-- Inserir resposta incorreta
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


-- TESTE 3: RLS com Grace Period e Inativos
-- Simular diferentes usuários definindo auth.uid() localmente na transação
-- Nota: Para simular o RLS no PostgreSQL nativo via sessões do Supabase, definimos as variáveis de configuração de segurança do Supabase:
-- set local request.jwt.claim.sub = 'user_id'

-- 3.1. Aluno Ativo (Acesso permitido)
SET LOCAL request.jwt.claim.sub = '22222222-2222-2222-2222-222222222222';
SET LOCAL role = 'authenticated';

DO $$
DECLARE
    v_lessons_count integer;
BEGIN
    SELECT COUNT(*) INTO v_lessons_count FROM public.lessons WHERE id = 'cccccccc-cccc-cccc-cccc-cccccccccccc';
    IF v_lessons_count = 1 THEN
        RAISE NOTICE 'TEST 3.1 PASSED: Active subscriber can access lesson.';
    ELSE
        RAISE EXCEPTION 'TEST 3.1 FAILED: Active subscriber could not read lesson.';
    END IF;
END $$;

-- 3.2. Aluno em Carência (past_due, < 5 dias) - (Acesso permitido)
SET LOCAL request.jwt.claim.sub = '44444444-4444-4444-4444-444444444444';
SET LOCAL role = 'authenticated';

DO $$
DECLARE
    v_lessons_count integer;
BEGIN
    SELECT COUNT(*) INTO v_lessons_count FROM public.lessons WHERE id = 'cccccccc-cccc-cccc-cccc-cccccccccccc';
    IF v_lessons_count = 1 THEN
        RAISE NOTICE 'TEST 3.2 PASSED: Past_due subscriber within Grace Period can access lesson.';
    ELSE
        RAISE EXCEPTION 'TEST 3.2 FAILED: Grace Period subscriber could not read lesson.';
    END IF;
END $$;

-- 3.3. Aluno Inativo (Acesso negado)
SET LOCAL request.jwt.claim.sub = '33333333-3333-3333-3333-333333333333';
SET LOCAL role = 'authenticated';

DO $$
DECLARE
    v_lessons_count integer;
BEGIN
    SELECT COUNT(*) INTO v_lessons_count FROM public.lessons WHERE id = 'cccccccc-cccc-cccc-cccc-cccccccccccc';
    IF v_lessons_count = 0 THEN
        RAISE NOTICE 'TEST 3.3 PASSED: Inactive user cannot read lesson.';
    ELSE
        RAISE EXCEPTION 'TEST 3.3 FAILED: Inactive user was able to read lesson.';
    END IF;
END $$;

-- 3.4. Aluno Fora da Carência (past_due, > 5 dias) - (Acesso negado)
SET LOCAL request.jwt.claim.sub = '55555555-5555-5555-5555-555555555555';
SET LOCAL role = 'authenticated';

DO $$
DECLARE
    v_lessons_count integer;
BEGIN
    SELECT COUNT(*) INTO v_lessons_count FROM public.lessons WHERE id = 'cccccccc-cccc-cccc-cccc-cccccccccccc';
    IF v_lessons_count = 0 THEN
        RAISE NOTICE 'TEST 3.4 PASSED: Past_due subscriber outside Grace Period cannot read lesson.';
    ELSE
        RAISE EXCEPTION 'TEST 3.4 FAILED: Out of Grace Period subscriber was able to read lesson.';
    END IF;
END $$;


-- TESTE 4: Soft Delete
-- Restaurar privilégios de Admin
SET LOCAL request.jwt.claim.sub = '11111111-1111-1111-1111-111111111111';
SET LOCAL role = 'authenticated';

-- Soft delete a lição
UPDATE public.lessons SET deleted_at = NOW() WHERE id = 'cccccccc-cccc-cccc-cccc-cccccccccccc';

-- Simular Aluno Ativo lendo a lição deletada (Acesso negado)
SET LOCAL request.jwt.claim.sub = '22222222-2222-2222-2222-222222222222';
SET LOCAL role = 'authenticated';

DO $$
DECLARE
    v_lessons_count integer;
BEGIN
    SELECT COUNT(*) INTO v_lessons_count FROM public.lessons WHERE id = 'cccccccc-cccc-cccc-cccc-cccccccccccc';
    IF v_lessons_count = 0 THEN
        RAISE NOTICE 'TEST 4 PASSED: Soft-deleted lesson is automatically hidden from select query.';
    ELSE
        RAISE EXCEPTION 'TEST 4 FAILED: Soft-deleted lesson is still visible to student.';
    END IF;
END $$;

-- Voltar a ser admin para reverter modificações
SET LOCAL request.jwt.claim.sub = '11111111-1111-1111-1111-111111111111';
SET LOCAL role = 'postgres';

-- Cancelar alterações para não poluir o banco de dados
ROLLBACK;
