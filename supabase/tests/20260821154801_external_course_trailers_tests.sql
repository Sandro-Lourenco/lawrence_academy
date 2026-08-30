BEGIN;
SELECT plan(10);

SELECT enum_has_labels(
  'public', 'course_category',
  ARRAY['corte','costura','modelagem','fashion_design','style_design','mini_curso','bordado','negocios','outros'],
  'course categories match the authoring form'
);
SELECT has_column('public', 'courses', 'trailer_source_type', 'course stores trailer source');
SELECT has_column('public', 'courses', 'trailer_external_video_id', 'course stores normalized trailer id');
SELECT col_default_is(
  'public', 'courses', 'trailer_source_type', 'upload',
  'uploaded trailer remains the backwards-compatible default'
);

INSERT INTO auth.users(id, email, raw_user_meta_data)
VALUES ('7b000000-0000-4000-8000-000000000001', 'external-trailer-teacher@example.test', '{}'::JSONB);
UPDATE public.profiles SET role = 'teacher'
WHERE id = '7b000000-0000-4000-8000-000000000001';

SELECT lives_ok(
  $$INSERT INTO public.courses(
      id,instructor_id,title,slug,category,level,summary,status,monthly_price,
      trailer_source_type,trailer_external_video_id,trailer_status
    ) VALUES (
      '7b000000-0000-4000-8000-000000000011',
      '7b000000-0000-4000-8000-000000000001',
      'Bordado contemporâneo','bordado-contemporaneo-external-trailer-test',
      'bordado','iniciante','Curso com trailer do YouTube','draft',10,
      'youtube','dQw4w9WgXcQ','ready'
    )$$,
  'YouTube trailer and the new category are accepted'
);

SELECT lives_ok(
  $$UPDATE public.courses
    SET trailer_source_type='vimeo', trailer_external_video_id='123456789'
    WHERE id='7b000000-0000-4000-8000-000000000011'$$,
  'Vimeo trailer is accepted'
);

SELECT throws_ok(
  $$UPDATE public.courses
    SET trailer_source_type='youtube', trailer_external_video_id='invalid'
    WHERE id='7b000000-0000-4000-8000-000000000011'$$,
  '23514', NULL,
  'invalid YouTube id is rejected'
);
SELECT throws_ok(
  $$UPDATE public.courses
    SET trailer_source_type='untrusted', trailer_external_video_id='123456789'
    WHERE id='7b000000-0000-4000-8000-000000000011'$$,
  '23514', NULL,
  'untrusted provider is rejected'
);
SELECT throws_ok(
  $$UPDATE public.courses
    SET trailer_source_type='vimeo', trailer_external_video_id='123456789',
        trailer_hls_path='course-trailers/id/master.m3u8'
    WHERE id='7b000000-0000-4000-8000-000000000011'$$,
  '23514', NULL,
  'external trailer cannot also expose an HLS path'
);
SELECT lives_ok(
  $$UPDATE public.courses
    SET category='outros', trailer_source_type='upload',
        trailer_external_video_id=NULL, trailer_hls_path=NULL
    WHERE id='7b000000-0000-4000-8000-000000000011'$$,
  'other category and upload mode remain valid'
);

SELECT * FROM finish();
ROLLBACK;
