BEGIN;
SELECT plan(6);

SELECT has_column('public', 'modules', 'is_system', 'modules distinguishes internal containers');
SELECT col_not_null('public', 'modules', 'is_system', 'is_system is not nullable');
SELECT col_has_default('public', 'modules', 'is_system', 'is_system defaults to false');
SELECT has_index(
    'public',
    'modules',
    'idx_modules_one_active_system_per_course',
    'quick courses have at most one active internal module'
);
SELECT has_index(
    'public',
    'subscriptions',
    'idx_subscriptions_course_active_students',
    'teacher course detail can list students efficiently'
);
SELECT has_trigger(
    'public',
    'courses',
    'trg_sync_quick_course_system_module',
    'course type synchronizes the internal module'
);

SELECT * FROM finish();
ROLLBACK;
