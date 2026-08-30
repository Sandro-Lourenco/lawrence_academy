BEGIN;

SELECT plan(6);

SELECT has_column('lessons', 'video_source_type');
SELECT has_column('lessons', 'external_video_id');
SELECT col_default_is(
  'lessons',
  'video_source_type',
  'upload',
  'lesson video source defaults to private upload'
);
SELECT col_not_null(
  'lessons',
  'video_source_type',
  'lesson video source is required'
);
SELECT isnt_empty(
  $$SELECT 1 FROM pg_constraint WHERE conname='lessons_video_source_check'$$,
  'lesson external video provider and id stay coherent'
);
SELECT is(
  (SELECT count(*) FROM pg_policies WHERE schemaname='public' AND tablename='lessons'),
  3::bigint,
  'existing lesson RLS remains enabled'
);

SELECT * FROM finish();
ROLLBACK;
