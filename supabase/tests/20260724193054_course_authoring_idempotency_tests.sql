BEGIN;
SELECT plan(26);

SELECT has_table('course_publication_requests');
SELECT has_table('course_authoring_idempotency_requests');
SELECT has_column('courses', 'authoring_revision');
SELECT has_function(
  'public', 'register_course_authoring_request',
  ARRAY['uuid','text','text','text','uuid']
);
SELECT has_function(
  'public', 'publish_course_idempotent',
  ARRAY['uuid','uuid','text','text','text','timestamp with time zone']
);
SELECT function_privs_are(
  'public', 'register_course_authoring_request',
  ARRAY['uuid','text','text','text','uuid'],
  'authenticated', ARRAY[]::text[]
);
SELECT is_empty($$
  SELECT 1
  FROM information_schema.role_table_grants
  WHERE table_schema = 'public'
    AND table_name IN (
      'course_authoring_idempotency_requests',
      'course_publication_requests'
    )
    AND grantee IN ('anon', 'authenticated')
$$, 'idempotency ledgers are not exposed to Data API roles');
SELECT isnt_empty($$
  SELECT 1
  FROM information_schema.role_table_grants
  WHERE table_schema = 'public'
    AND table_name IN (
      'course_authoring_idempotency_requests',
      'course_publication_requests'
    )
    AND grantee = 'service_role'
    AND privilege_type IN ('SELECT', 'INSERT')
$$, 'service role can use the private idempotency ledgers');
SELECT function_privs_are(
  'public', 'publish_course_idempotent',
  ARRAY['uuid','uuid','text','text','text','timestamp with time zone'],
  'authenticated', ARRAY[]::text[]
);
SELECT isnt_empty($$SELECT 1 FROM pg_trigger
  WHERE tgname='bump_course_revision_from_modules' AND NOT tgisinternal$$);
SELECT isnt_empty($$SELECT 1 FROM pg_trigger
  WHERE tgname='bump_course_revision_from_lessons' AND NOT tgisinternal$$);
SELECT isnt_empty($$SELECT 1 FROM pg_trigger
  WHERE tgname='bump_course_revision_from_lesson_blocks' AND NOT tgisinternal$$);

INSERT INTO auth.users(id, email, raw_user_meta_data)
VALUES (
  'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
  'idempotency-teacher@example.test',
  '{}'::jsonb
);
INSERT INTO auth.users(id, email, raw_user_meta_data)
VALUES
  (
    'cccccccc-cccc-cccc-cccc-cccccccccccc',
    'other-teacher@example.test',
    '{}'::jsonb
  ),
  (
    'dddddddd-dddd-dddd-dddd-dddddddddddd',
    'idempotency-admin@example.test',
    '{}'::jsonb
  );
UPDATE public.profiles
SET full_name = 'Idempotency Teacher', role = 'teacher'
WHERE id = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa';
UPDATE public.profiles
SET full_name = 'Other Teacher', role = 'teacher'
WHERE id = 'cccccccc-cccc-cccc-cccc-cccccccccccc';
UPDATE public.profiles
SET full_name = 'Idempotency Admin', role = 'admin'
WHERE id = 'dddddddd-dddd-dddd-dddd-dddddddddddd';
INSERT INTO public.user_roles(user_id, role_id)
SELECT
  'dddddddd-dddd-dddd-dddd-dddddddddddd'::uuid,
  id
FROM public.roles
WHERE name = 'admin'
ON CONFLICT DO NOTHING;
INSERT INTO public.courses(
  id, instructor_id, title, slug, category, level, summary,
  cover_status, learning_objectives, target_audience
)
VALUES (
  'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
  'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
  'Curso idempotente', 'curso-idempotente', 'costura', 'iniciante',
  'Resumo suficientemente longo',
  'ready', ARRAY['Aprender'], ARRAY['Alunos']
);

SELECT is(
  public.register_course_authoring_request(
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
    'module:create:bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
    'opaque-create-key-0001',
    'create-request-hash-0001',
    'eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee'
  ),
  public.register_course_authoring_request(
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
    'module:create:bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
    'opaque-create-key-0001',
    'create-request-hash-0001',
    'eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee'
  ),
  'authoring request replay returns the same deterministic resource id'
);
SELECT throws_ok(
  $$SELECT public.register_course_authoring_request(
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
    'module:create:bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
    'opaque-create-key-0001',
    'different-create-request-hash',
    'eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee'
  )$$,
  'P0001',
  'Idempotency-Key was reused with a different request',
  'authoring key reuse with another payload is rejected'
);
SELECT is(
  public.register_course_authoring_request(
    'cccccccc-cccc-cccc-cccc-cccccccccccc',
    'module:create:bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
    'opaque-create-key-0001',
    'other-actor-request-hash',
    'ffffffff-ffff-ffff-ffff-ffffffffffff'
  ),
  'ffffffff-ffff-ffff-ffff-ffffffffffff'::uuid,
  'the same authoring key is independently scoped by actor'
);

INSERT INTO public.modules(id, course_id, title, order_index)
VALUES (
  'eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee',
  'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
  'Módulo idempotente',
  0
);
SELECT ok(
  (SELECT authoring_revision > 0
   FROM public.courses
   WHERE id = 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb'),
  'child inserts increment the authoritative course revision'
);
INSERT INTO public.lessons(
  id, module_id, course_id, title, order_index
)
VALUES (
  '12121212-1212-1212-1212-121212121212',
  'eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee',
  'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
  'Aula idempotente',
  0
);
SELECT is(
  (SELECT authoring_revision::integer
   FROM public.courses
   WHERE id = 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb'),
  2,
  'lesson inserts increment the authoritative course revision'
);
INSERT INTO public.lesson_blocks(
  id, lesson_id, course_id, block_type, content, order_index
)
VALUES (
  '13131313-1313-1313-1313-131313131313',
  '12121212-1212-1212-1212-121212121212',
  'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
  'text',
  '{"text":"Conteúdo idempotente"}'::jsonb,
  0
);
SELECT is(
  (SELECT authoring_revision::integer
   FROM public.courses
   WHERE id = 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb'),
  3,
  'lesson block inserts increment the authoritative course revision'
);

SELECT is(
  public.publish_course_idempotent(
    'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
    'primeira publicação', 'publish-attempt-0001', 'request-hash-0001', NULL
  ),
  public.publish_course_idempotent(
    'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
    'primeira publicação', 'publish-attempt-0001', 'request-hash-0001', NULL
  ),
  'replay returns the same version'
);
SELECT is(
  (SELECT count(*)::integer FROM public.course_versions
   WHERE course_id = 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb'),
  1,
  'replay creates exactly one immutable version'
);
SELECT is(
  (SELECT count(*)::integer FROM public.course_status_history
   WHERE course_id = 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb'
     AND to_status = 'published'),
  1,
  'replay creates exactly one publication history entry'
);
SELECT throws_ok(
  $$SELECT public.publish_course_idempotent(
    'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
    'payload alterado', 'publish-attempt-0001',
    'different-request-hash', NULL
  )$$,
  'P0001',
  'Idempotency-Key was reused with a different request',
  'publication key reuse with another payload is rejected'
);
SELECT throws_ok(
  $$SELECT public.publish_course_idempotent(
    'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
    'cccccccc-cccc-cccc-cccc-cccccccccccc',
    'tentativa BOLA', 'publish-bola-0001', 'bola-hash', NULL
  )$$,
  '42501',
  'actor cannot publish this course',
  'a non-owner teacher cannot publish the course'
);
SELECT throws_ok(
  $$SELECT public.publish_course_idempotent(
    'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
    'revisão obsoleta', 'publish-stale-0001', 'stale-hash',
    '2000-01-01T00:00:00Z'
  )$$,
  '40001',
  'authoring content changed; reload before publishing',
  'a stale expected revision is rejected'
);
SELECT is(
  public.publish_course_idempotent(
    'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
    'dddddddd-dddd-dddd-dddd-dddddddddddd',
    'publicação administrativa', 'publish-attempt-0001',
    'admin-request-hash', NULL
  ),
  2,
  'the same publication key is independently scoped by actor'
);
SELECT is(
  (SELECT count(*)::integer FROM public.course_versions
   WHERE course_id = 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb'),
  2,
  'actor-scoped publication creates exactly one additional version'
);

SELECT * FROM finish();
ROLLBACK;
