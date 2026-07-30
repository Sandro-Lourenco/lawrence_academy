BEGIN;
SELECT plan(3);
SELECT has_column('courses','publication_requested_at');
SELECT has_column('courses','published_at');
SELECT isnt_empty($$SELECT 1 FROM pg_indexes WHERE indexname='idx_courses_publication_status'$$);

SELECT * FROM finish();
ROLLBACK;
