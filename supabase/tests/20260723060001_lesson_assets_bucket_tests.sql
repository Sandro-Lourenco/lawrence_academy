BEGIN;
SELECT plan(3);
SELECT isnt_empty($$SELECT 1 FROM storage.buckets WHERE id='lesson-assets' AND public=false$$);
SELECT isnt_empty($$SELECT 1 FROM storage.buckets WHERE id='lesson-assets' AND file_size_limit=104857600$$);
SELECT is_empty($$SELECT 1 FROM pg_policies WHERE schemaname='storage' AND tablename='objects' AND policyname='lesson_assets_direct_access'$$);
SELECT * FROM finish();
ROLLBACK;
