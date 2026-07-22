-- Local-only E2E fixtures.
-- Required psql variables: student_id and teacher_id.
-- Load only through scripts/load-local-fixtures.ps1, which refuses non-local URLs.

BEGIN;

UPDATE public.profiles
SET full_name = 'Aluno Local', role = 'student', updated_at = NOW()
WHERE id = :'student_id'::uuid;

UPDATE public.profiles
SET full_name = 'Professora Local', role = 'teacher', updated_at = NOW()
WHERE id = :'teacher_id'::uuid;

INSERT INTO public.user_roles (user_id, role_id)
SELECT :'teacher_id'::uuid, id
FROM public.roles
WHERE name = 'teacher'
ON CONFLICT DO NOTHING;

INSERT INTO public.courses (
    id, instructor_id, title, slug, category, level, summary, description,
    monthly_price, status
)
VALUES
    (
        '91000000-0000-0000-0000-000000000001', :'teacher_id'::uuid,
        'Costura Essencial — Fixture Local', 'costura-essencial-fixture-local',
        'costura', 'iniciante', 'Curso sintético para homologação local.',
        'Conteúdo não destinado a staging ou produção.', 89.90, 'published'
    ),
    (
        '91000000-0000-0000-0000-000000000002', :'teacher_id'::uuid,
        'Modelagem Concluída — Fixture Local', 'modelagem-concluida-fixture-local',
        'modelagem', 'iniciante', 'Curso gratuito sintético já concluído.',
        'Conteúdo não destinado a staging ou produção.', 0.00, 'published'
    )
ON CONFLICT (id) DO UPDATE SET
    instructor_id = EXCLUDED.instructor_id,
    title = EXCLUDED.title,
    slug = EXCLUDED.slug,
    category = EXCLUDED.category,
    level = EXCLUDED.level,
    summary = EXCLUDED.summary,
    description = EXCLUDED.description,
    monthly_price = EXCLUDED.monthly_price,
    status = EXCLUDED.status,
    deleted_at = NULL,
    updated_at = NOW();

INSERT INTO public.modules (id, course_id, title, order_index)
VALUES
    ('92000000-0000-0000-0000-000000000001', '91000000-0000-0000-0000-000000000001', 'Primeiros pontos', 1),
    ('92000000-0000-0000-0000-000000000002', '91000000-0000-0000-0000-000000000002', 'Projeto final', 1)
ON CONFLICT (id) DO UPDATE SET
    course_id = EXCLUDED.course_id,
    title = EXCLUDED.title,
    order_index = EXCLUDED.order_index,
    deleted_at = NULL;

INSERT INTO public.lessons (
    id, module_id, course_id, title, description, order_index,
    duration_seconds, hls_storage_path, status, is_preview
)
VALUES
    (
        '93000000-0000-0000-0000-000000000001',
        '92000000-0000-0000-0000-000000000001',
        '91000000-0000-0000-0000-000000000001',
        'Conhecendo a máquina', 'Aula concluída da fixture.', 1, 900,
        'local-fixtures/costura/01/master.m3u8', 'published', true
    ),
    (
        '93000000-0000-0000-0000-000000000002',
        '92000000-0000-0000-0000-000000000001',
        '91000000-0000-0000-0000-000000000001',
        'Ponto reto na prática', 'Aula em andamento da fixture.', 2, 1200,
        'local-fixtures/costura/02/master.m3u8', 'published', false
    ),
    (
        '93000000-0000-0000-0000-000000000003',
        '92000000-0000-0000-0000-000000000002',
        '91000000-0000-0000-0000-000000000002',
        'Molde base concluído', 'Aula concluída para validar certificado.', 1,
        600, 'local-fixtures/modelagem/01/master.m3u8', 'published', false
    )
ON CONFLICT (id) DO UPDATE SET
    module_id = EXCLUDED.module_id,
    course_id = EXCLUDED.course_id,
    title = EXCLUDED.title,
    description = EXCLUDED.description,
    order_index = EXCLUDED.order_index,
    duration_seconds = EXCLUDED.duration_seconds,
    hls_storage_path = EXCLUDED.hls_storage_path,
    status = EXCLUDED.status,
    is_preview = EXCLUDED.is_preview,
    deleted_at = NULL,
    updated_at = NOW();

INSERT INTO public.subscriptions (
    id, student_id, course_id, provider, provider_customer_id,
    provider_subscription_id, status, monthly_price, currency,
    current_period_start, current_period_end
)
VALUES (
    '94000000-0000-0000-0000-000000000001', :'student_id'::uuid,
    '91000000-0000-0000-0000-000000000001', 'stripe',
    'local_fixture_customer', 'local_fixture_subscription', 'active', 89.90,
    'BRL', NOW() - INTERVAL '5 days', NOW() + INTERVAL '25 days'
)
ON CONFLICT (id) DO UPDATE SET
    student_id = EXCLUDED.student_id,
    course_id = EXCLUDED.course_id,
    status = EXCLUDED.status,
    monthly_price = EXCLUDED.monthly_price,
    current_period_start = EXCLUDED.current_period_start,
    current_period_end = EXCLUDED.current_period_end,
    deleted_at = NULL,
    updated_at = NOW();

INSERT INTO public.lesson_progress (
    id, student_id, course_id, lesson_id, watched_seconds,
    progress_percentage, completed, completed_at
)
VALUES
    (
        '95000000-0000-0000-0000-000000000001', :'student_id'::uuid,
        '91000000-0000-0000-0000-000000000001',
        '93000000-0000-0000-0000-000000000001', 900, 100, true,
        NOW() - INTERVAL '1 day'
    ),
    (
        '95000000-0000-0000-0000-000000000002', :'student_id'::uuid,
        '91000000-0000-0000-0000-000000000001',
        '93000000-0000-0000-0000-000000000002', 480, 40, false, NULL
    ),
    (
        '95000000-0000-0000-0000-000000000003', :'student_id'::uuid,
        '91000000-0000-0000-0000-000000000002',
        '93000000-0000-0000-0000-000000000003', 600, 100, true,
        NOW() - INTERVAL '2 days'
    )
ON CONFLICT (id) DO UPDATE SET
    student_id = EXCLUDED.student_id,
    course_id = EXCLUDED.course_id,
    lesson_id = EXCLUDED.lesson_id,
    watched_seconds = EXCLUDED.watched_seconds,
    progress_percentage = EXCLUDED.progress_percentage,
    completed = EXCLUDED.completed,
    completed_at = EXCLUDED.completed_at,
    last_synced_at = NOW(),
    updated_at = NOW();

INSERT INTO public.certificates (
    id, user_id, student_id, course_id, certificate_hash,
    validation_code, signature, signature_algorithm, metadata
)
VALUES (
    '96000000-0000-0000-0000-000000000001', :'student_id'::uuid,
    :'student_id'::uuid, '91000000-0000-0000-0000-000000000002',
    'local_fixture_certificate_hash_000000000000000000000000000000',
    'LOCAL-FIXTURE-2026', 'local-fixture-signature', 'fixture-only',
    '{"environment":"local","synthetic":true}'::jsonb
)
ON CONFLICT (id) DO UPDATE SET
    user_id = EXCLUDED.user_id,
    student_id = EXCLUDED.student_id,
    course_id = EXCLUDED.course_id,
    certificate_hash = EXCLUDED.certificate_hash,
    validation_code = EXCLUDED.validation_code,
    signature = EXCLUDED.signature,
    signature_algorithm = EXCLUDED.signature_algorithm,
    metadata = EXCLUDED.metadata,
    revoked_at = NULL,
    revocation_reason = NULL;

COMMIT;

