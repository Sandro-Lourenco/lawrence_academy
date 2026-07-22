-- ======================================================
-- Lawrence Academy RBAC and RLS Tests
-- Date: 2026-07-11
-- Purpose: Verify RBAC constraints and Lesson RLS logic
-- ======================================================

SELECT plan(1);

BEGIN;

DEALLOCATE ALL;

-- 1. Setup Mock Data
-- auth.users will trigger handle_new_user which creates profiles.
-- We will also explicitly set their roles in `roles` and `user_roles`.
INSERT INTO auth.users (id, email, raw_user_meta_data)
VALUES 
    ('11111111-1111-1111-1111-111111111111', 'instructor_owner@lawrence.academy', '{"full_name": "Instructor Owner"}'),
    ('11111111-2222-2222-2222-222222222222', 'instructor_other@lawrence.academy', '{"full_name": "Instructor Other"}'),
    ('22222222-2222-2222-2222-222222222222', 'student_active@lawrence.academy', '{"full_name": "Student Active"}'),
    ('33333333-3333-3333-3333-333333333333', 'student_nosub@lawrence.academy', '{"full_name": "Student No Sub"}'),
    ('44444444-4444-4444-4444-444444444444', 'student_grace@lawrence.academy', '{"full_name": "Student Grace"}'),
    ('66666666-6666-6666-6666-666666666666', 'student_other@lawrence.academy', '{"full_name": "Student Other Course"}'),
    ('77777777-7777-7777-7777-777777777777', 'admin@lawrence.academy', '{"full_name": "Admin"}'),
    ('88888888-8888-8888-8888-888888888888', 'superadmin@lawrence.academy', '{"full_name": "Super Admin"}');

-- Set up roles correctly
-- We assume roles 'student', 'teacher', 'admin', 'super_admin' exist from migration.
-- By default handle_new_user might insert 'student' into profile.role or user_roles.
-- Let's manually set user_roles.
DELETE FROM public.user_roles WHERE user_id IN (
    '11111111-1111-1111-1111-111111111111',
    '11111111-2222-2222-2222-222222222222',
    '77777777-7777-7777-7777-777777777777',
    '88888888-8888-8888-8888-888888888888'
);

INSERT INTO public.user_roles (user_id, role_id)
SELECT '11111111-1111-1111-1111-111111111111', id FROM public.roles WHERE name = 'teacher';
INSERT INTO public.user_roles (user_id, role_id)
SELECT '11111111-2222-2222-2222-222222222222', id FROM public.roles WHERE name = 'teacher';
INSERT INTO public.user_roles (user_id, role_id)
SELECT '77777777-7777-7777-7777-777777777777', id FROM public.roles WHERE name = 'admin';
INSERT INTO public.user_roles (user_id, role_id)
SELECT '88888888-8888-8888-8888-888888888888', id FROM public.roles WHERE name = 'super_admin';

-- Create Course
INSERT INTO public.courses (
    id,
    instructor_id,
    title,
    slug,
    category,
    level,
    summary,
    status,
    monthly_price
)
VALUES 
    ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', '11111111-1111-1111-1111-111111111111', 'Curso A', 'curso-a', 'modelagem', 'iniciante', 'Resumo A', 'published', 89.90),
    ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', '11111111-1111-1111-1111-111111111111', 'Curso B', 'curso-b', 'costura', 'iniciante', 'Resumo B', 'published', 89.90);

INSERT INTO public.modules (id, course_id, title, order_index)
VALUES 
    ('c1111111-1111-1111-1111-111111111111', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Módulo 1 Curso A', 1);

INSERT INTO public.lessons (id, module_id, course_id, title, status, hls_storage_path, is_preview)
VALUES 
    ('d1111111-1111-1111-1111-111111111111', 'c1111111-1111-1111-1111-111111111111', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Lição Premium', 'published', 'lessons/l1/master.m3u8', false),
    ('d2222222-2222-2222-2222-222222222222', 'c1111111-1111-1111-1111-111111111111', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Lição Preview', 'published', 'lessons/l2/master.m3u8', true);

-- Subscriptions
-- Active in Course A
INSERT INTO public.subscriptions (student_id, course_id, provider_customer_id, provider_subscription_id, status, monthly_price, currency, current_period_start, current_period_end)
VALUES ('22222222-2222-2222-2222-222222222222', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'cust_1', 'sub_1', 'active', 89.90, 'BRL', NOW() - INTERVAL '10 days', NOW() + INTERVAL '20 days');

-- Grace in Course A (past_due, ended 2 days ago)
INSERT INTO public.subscriptions (student_id, course_id, provider_customer_id, provider_subscription_id, status, monthly_price, currency, current_period_start, current_period_end)
VALUES ('44444444-4444-4444-4444-444444444444', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'cust_3', 'sub_3', 'past_due', 89.90, 'BRL', NOW() - INTERVAL '32 days', NOW() - INTERVAL '2 days');

-- Active in Course B
INSERT INTO public.subscriptions (student_id, course_id, provider_customer_id, provider_subscription_id, status, monthly_price, currency, current_period_start, current_period_end)
VALUES ('66666666-6666-6666-6666-666666666666', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'cust_4', 'sub_4', 'active', 89.90, 'BRL', NOW() - INTERVAL '10 days', NOW() + INTERVAL '20 days');


-- 2. Tests
DO $$
DECLARE
    v_count integer;
BEGIN
    -- TEST: Anonymous access
    SET LOCAL role = 'anon';
    SELECT COUNT(*) INTO v_count FROM public.modules WHERE id = 'c1111111-1111-1111-1111-111111111111';
    IF v_count = 0 THEN RAISE EXCEPTION 'FAIL: Anon could not read module'; END IF;

    SELECT COUNT(*) INTO v_count FROM public.lessons WHERE id = 'd1111111-1111-1111-1111-111111111111';
    IF v_count <> 0 THEN RAISE EXCEPTION 'FAIL: Anon could read premium lesson'; END IF;

    SELECT COUNT(*) INTO v_count FROM public.lessons WHERE id = 'd2222222-2222-2222-2222-222222222222';
    IF v_count = 0 THEN RAISE EXCEPTION 'FAIL: Anon could not read preview lesson'; END IF;

    -- TEST: Student No Sub
    SET LOCAL role = 'authenticated';
    SET LOCAL request.jwt.claim.sub = '33333333-3333-3333-3333-333333333333';
    SELECT COUNT(*) INTO v_count FROM public.lessons WHERE id = 'd1111111-1111-1111-1111-111111111111';
    IF v_count <> 0 THEN RAISE EXCEPTION 'FAIL: No-sub student could read premium lesson'; END IF;

    -- TEST: Student Active
    SET LOCAL request.jwt.claim.sub = '22222222-2222-2222-2222-222222222222';
    SELECT COUNT(*) INTO v_count FROM public.lessons WHERE id = 'd1111111-1111-1111-1111-111111111111';
    IF v_count = 0 THEN RAISE EXCEPTION 'FAIL: Active student could not read premium lesson'; END IF;

    -- TEST: Student Grace
    SET LOCAL request.jwt.claim.sub = '44444444-4444-4444-4444-444444444444';
    SELECT COUNT(*) INTO v_count FROM public.lessons WHERE id = 'd1111111-1111-1111-1111-111111111111';
    IF v_count = 0 THEN RAISE EXCEPTION 'FAIL: Grace student could not read premium lesson'; END IF;

    -- TEST: Student Other Course
    SET LOCAL request.jwt.claim.sub = '66666666-6666-6666-6666-666666666666';
    SELECT COUNT(*) INTO v_count FROM public.lessons WHERE id = 'd1111111-1111-1111-1111-111111111111';
    IF v_count <> 0 THEN RAISE EXCEPTION 'FAIL: Other course student could read premium lesson'; END IF;

    -- TEST: Teacher Owner
    SET LOCAL request.jwt.claim.sub = '11111111-1111-1111-1111-111111111111';
    SELECT COUNT(*) INTO v_count FROM public.lessons WHERE id = 'd1111111-1111-1111-1111-111111111111';
    IF v_count = 0 THEN RAISE EXCEPTION 'FAIL: Teacher owner could not read premium lesson'; END IF;

    -- TEST: Teacher Non-Owner
    SET LOCAL request.jwt.claim.sub = '11111111-2222-2222-2222-222222222222';
    SELECT COUNT(*) INTO v_count FROM public.lessons WHERE id = 'd1111111-1111-1111-1111-111111111111';
    IF v_count <> 0 THEN RAISE EXCEPTION 'FAIL: Teacher non-owner could read premium lesson'; END IF;

    -- TEST: Admin
    SET LOCAL request.jwt.claim.sub = '77777777-7777-7777-7777-777777777777';
    SELECT COUNT(*) INTO v_count FROM public.lessons WHERE id = 'd1111111-1111-1111-1111-111111111111';
    IF v_count = 0 THEN RAISE EXCEPTION 'FAIL: Admin could not read premium lesson'; END IF;

    -- TEST: Super Admin
    SET LOCAL request.jwt.claim.sub = '88888888-8888-8888-8888-888888888888';
    SELECT COUNT(*) INTO v_count FROM public.lessons WHERE id = 'd1111111-1111-1111-1111-111111111111';
    IF v_count = 0 THEN RAISE EXCEPTION 'FAIL: Super admin could not read premium lesson'; END IF;

    RAISE NOTICE 'ALL TESTS PASSED.';
END $$;

ROLLBACK;

SELECT pass('All assertions completed');
SELECT * FROM finish();
