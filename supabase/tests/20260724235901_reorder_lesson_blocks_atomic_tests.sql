BEGIN;
SELECT plan(8);

SELECT has_function(
  'public', 'reorder_lesson_blocks_atomic',
  ARRAY['uuid','uuid','uuid','uuid[]','bigint']
);
SELECT function_privs_are(
  'public', 'reorder_lesson_blocks_atomic',
  ARRAY['uuid','uuid','uuid','uuid[]','bigint'],
  'anon', ARRAY[]::TEXT[]
);
SELECT function_privs_are(
  'public', 'reorder_lesson_blocks_atomic',
  ARRAY['uuid','uuid','uuid','uuid[]','bigint'],
  'authenticated', ARRAY[]::TEXT[]
);
SELECT function_privs_are(
  'public', 'reorder_lesson_blocks_atomic',
  ARRAY['uuid','uuid','uuid','uuid[]','bigint'],
  'service_role', ARRAY['EXECUTE']
);

INSERT INTO auth.users(id, email)
VALUES
  ('10000000-0000-0000-0000-000000000001', 'reorder-owner@test.local'),
  ('10000000-0000-0000-0000-000000000002', 'reorder-other@test.local')
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.profiles(id, email, role, full_name)
VALUES
  ('10000000-0000-0000-0000-000000000001', 'reorder-owner@test.local', 'teacher', 'Owner'),
  ('10000000-0000-0000-0000-000000000002', 'reorder-other@test.local', 'teacher', 'Other')
ON CONFLICT (id) DO UPDATE SET role = EXCLUDED.role;
INSERT INTO public.courses(
  id, instructor_id, title, slug, category, level, summary, status
)
VALUES (
  '20000000-0000-0000-0000-000000000001',
  '10000000-0000-0000-0000-000000000001',
  'Reorder', 'reorder-atomic-test', 'costura', 'iniciante',
  'Resumo suficientemente longo', 'draft'
);
INSERT INTO public.modules(id, course_id, title, order_index)
VALUES (
  '30000000-0000-0000-0000-000000000001',
  '20000000-0000-0000-0000-000000000001', 'Module', 0
);
INSERT INTO public.lessons(id, module_id, course_id, title, order_index)
VALUES (
  '40000000-0000-0000-0000-000000000001',
  '30000000-0000-0000-0000-000000000001',
  '20000000-0000-0000-0000-000000000001', 'Lesson', 0
);
INSERT INTO public.lesson_blocks(id, lesson_id, course_id, block_type, content, order_index)
VALUES
  ('50000000-0000-0000-0000-000000000001','40000000-0000-0000-0000-000000000001','20000000-0000-0000-0000-000000000001','text','{}',0),
  ('50000000-0000-0000-0000-000000000002','40000000-0000-0000-0000-000000000001','20000000-0000-0000-0000-000000000001','text','{}',1);

SELECT lives_ok(format(
  $$SELECT public.reorder_lesson_blocks_atomic(
    '20000000-0000-0000-0000-000000000001',
    '40000000-0000-0000-0000-000000000001',
    '10000000-0000-0000-0000-000000000001',
    ARRAY['50000000-0000-0000-0000-000000000002','50000000-0000-0000-0000-000000000001']::UUID[],
    %s)$$,
  (SELECT authoring_revision FROM public.courses WHERE id='20000000-0000-0000-0000-000000000001')
));
SELECT results_eq(
  $$SELECT id FROM public.lesson_blocks
    WHERE lesson_id='40000000-0000-0000-0000-000000000001'
    ORDER BY order_index$$,
  $$VALUES
    ('50000000-0000-0000-0000-000000000002'::UUID),
    ('50000000-0000-0000-0000-000000000001'::UUID)$$
);
SELECT throws_ok(
  $$SELECT public.reorder_lesson_blocks_atomic(
    '20000000-0000-0000-0000-000000000001',
    '40000000-0000-0000-0000-000000000001',
    '10000000-0000-0000-0000-000000000002',
    ARRAY['50000000-0000-0000-0000-000000000001','50000000-0000-0000-0000-000000000002']::UUID[],
    0)$$, '42501'
);
SELECT throws_ok(
  $$SELECT public.reorder_lesson_blocks_atomic(
    '20000000-0000-0000-0000-000000000001',
    '40000000-0000-0000-0000-000000000001',
    '10000000-0000-0000-0000-000000000001',
    ARRAY['50000000-0000-0000-0000-000000000001']::UUID[],
    0)$$, '40001'
);

SELECT * FROM finish();
ROLLBACK;
