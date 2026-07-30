BEGIN;

SELECT plan(18);

SELECT has_column(
  'public', 'video_processing_jobs', 'claimed_by',
  'video jobs record their current worker'
);
SELECT has_column(
  'public', 'video_processing_jobs', 'lease_expires_at',
  'video jobs have an expiring processing lease'
);
SELECT has_column(
  'public', 'video_processing_jobs', 'claim_attempts',
  'video jobs count atomic claims'
);
SELECT has_index(
  'public', 'video_processing_jobs', 'idx_vpj_claim_eligible',
  'claim eligibility has a partial supporting index'
);
SELECT has_function(
  'public',
  'claim_next_video_processing_job',
  ARRAY['text', 'integer']::name[],
  'workers can claim with identity and lease duration'
);
SELECT function_privs_are(
  'public',
  'claim_next_video_processing_job',
  ARRAY['text', 'integer']::name[],
  'authenticated',
  ARRAY[]::text[],
  'authenticated users cannot claim leased video jobs'
);
SELECT function_privs_are(
  'public',
  'claim_next_video_processing_job',
  ARRAY['text', 'integer']::name[],
  'service_role',
  ARRAY['EXECUTE']::text[],
  'service role can claim leased video jobs'
);
SELECT has_function(
  'public',
  'renew_video_processing_job_lease',
  ARRAY['uuid', 'text', 'integer']::name[],
  'workers can renew a long-running video job lease'
);
SELECT function_privs_are(
  'public',
  'renew_video_processing_job_lease',
  ARRAY['uuid', 'text', 'integer']::name[],
  'authenticated',
  ARRAY[]::text[],
  'authenticated users cannot renew video job leases'
);
SELECT function_privs_are(
  'public',
  'renew_video_processing_job_lease',
  ARRAY['uuid', 'text', 'integer']::name[],
  'service_role',
  ARRAY['EXECUTE']::text[],
  'service role can renew video job leases'
);

INSERT INTO auth.users (id, email, raw_user_meta_data)
VALUES (
  '91000000-0000-0000-0000-000000000001',
  'video-lease-worker@example.test',
  '{"full_name":"Video Lease Worker Test"}'::JSONB
)
ON CONFLICT (id) DO NOTHING;

INSERT INTO public.profiles (id, email, role, full_name)
VALUES (
  '91000000-0000-0000-0000-000000000001',
  'video-lease-worker@example.test',
  'teacher',
  'Video Lease Worker Test'
)
ON CONFLICT (id) DO UPDATE SET role = EXCLUDED.role;

INSERT INTO public.courses (
  id, instructor_id, title, slug, category, level, summary, status
)
VALUES (
  '92000000-0000-0000-0000-000000000001',
  '91000000-0000-0000-0000-000000000001',
  'Video Lease Test Course',
  'video-lease-test-course',
  'costura',
  'iniciante',
  'Course fixture for video queue lease tests.',
  'draft'
);

INSERT INTO public.modules (id, course_id, title, order_index)
VALUES (
  '93000000-0000-0000-0000-000000000001',
  '92000000-0000-0000-0000-000000000001',
  'Video Lease Test Module',
  0
);

INSERT INTO public.lessons (id, module_id, course_id, title, order_index)
VALUES (
  '94000000-0000-0000-0000-000000000001',
  '93000000-0000-0000-0000-000000000001',
  '92000000-0000-0000-0000-000000000001',
  'Video Lease Test Lesson',
  0
);

UPDATE public.video_processing_jobs
SET status = 'completed',
    claimed_by = NULL,
    lease_expires_at = NULL
WHERE status IN (
  'uploaded',
  'processing_pending',
  'processing',
  'validating',
  'transcoding',
  'generating_hls',
  'generating_thumbnail'
);

INSERT INTO public.video_processing_jobs (
  lesson_id,
  course_id,
  initiated_by,
  idempotency_key,
  raw_video_path,
  status,
  processing_started_at,
  claimed_by,
  lease_expires_at,
  retry_count,
  max_retries,
  created_at
)
VALUES (
  '94000000-0000-0000-0000-000000000001',
  '92000000-0000-0000-0000-000000000001',
  NULL,
  'pgtap-lease-expired',
  'pgtap/lease-expired.mp4',
  'transcoding',
  NOW() - INTERVAL '2 hours',
  'dead-worker',
  NOW() - INTERVAL '1 minute',
  0,
  3,
  NOW() - INTERVAL '3 hours'
);

INSERT INTO public.video_processing_jobs (
  lesson_id,
  course_id,
  idempotency_key,
  raw_video_path,
  status,
  processing_started_at,
  claimed_by,
  lease_expires_at,
  retry_count,
  max_retries,
  created_at
)
VALUES (
  '94000000-0000-0000-0000-000000000001',
  '92000000-0000-0000-0000-000000000001',
  'pgtap-lease-exhausted',
  'pgtap/lease-exhausted.mp4',
  'validating',
  NOW() - INTERVAL '2 hours',
  'dead-worker',
  NOW() - INTERVAL '1 minute',
  3,
  3,
  NOW() - INTERVAL '2 hours'
);

CREATE TEMP TABLE claimed_job AS
SELECT *
FROM public.claim_next_video_processing_job('pgtap-worker-a', 600);

SELECT is(
  (SELECT claimed_by FROM claimed_job),
  'pgtap-worker-a',
  'an expired in-flight job is reclaimed by the requesting worker'
);
SELECT is(
  (SELECT status::TEXT FROM claimed_job),
  'processing',
  'a reclaimed job returns to processing'
);
SELECT is(
  (SELECT retry_count FROM claimed_job),
  1,
  'reclaiming an abandoned job consumes one retry'
);
SELECT is(
  (SELECT claim_attempts FROM claimed_job),
  1,
  'every successful claim increments claim_attempts'
);
SELECT ok(
  (SELECT lease_expires_at > NOW() FROM claimed_job),
  'the reclaimed job receives a future lease'
);
SELECT is(
  (
    SELECT status::TEXT
    FROM public.video_processing_jobs
    WHERE idempotency_key = 'pgtap-lease-exhausted'
  ),
  'dead_letter',
  'an expired job with exhausted retries is terminalized'
);
SELECT ok(
  public.renew_video_processing_job_lease(
    (SELECT id FROM claimed_job),
    'pgtap-worker-a',
    900
  ),
  'the owning worker can renew a long-running job lease'
);

CREATE TEMP TABLE second_claim AS
SELECT *
FROM public.claim_next_video_processing_job('pgtap-worker-b', 600);

SELECT is(
  (SELECT COUNT(*)::INTEGER FROM second_claim),
  0,
  'a live lease prevents a second worker from claiming the same job'
);

SELECT * FROM finish();
ROLLBACK;
