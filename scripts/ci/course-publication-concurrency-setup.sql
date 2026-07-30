\set ON_ERROR_STOP on

DELETE FROM public.courses
WHERE id = '90100000-0000-0000-0000-000000000001';
DELETE FROM auth.users
WHERE id = '90100000-0000-0000-0000-000000000002';

INSERT INTO auth.users(id, email, raw_user_meta_data)
VALUES (
  '90100000-0000-0000-0000-000000000002',
  'publication-concurrency@lawrence.test',
  '{}'::jsonb
);

UPDATE public.profiles
SET
  full_name = 'Publication Concurrency Teacher',
  role = 'teacher'
WHERE id = '90100000-0000-0000-0000-000000000002';

INSERT INTO public.courses(
  id,
  instructor_id,
  title,
  slug,
  category,
  level,
  summary,
  cover_status,
  learning_objectives,
  target_audience
)
VALUES (
  '90100000-0000-0000-0000-000000000001',
  '90100000-0000-0000-0000-000000000002',
  'Course publication concurrency',
  'course-publication-concurrency',
  'costura',
  'iniciante',
  'Synthetic local-only concurrency fixture',
  'ready',
  ARRAY['Validate idempotent publication'],
  ARRAY['Local CI']
);
