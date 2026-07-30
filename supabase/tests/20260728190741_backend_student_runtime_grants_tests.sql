BEGIN;

SELECT plan(13);

SELECT ok(has_table_privilege('service_role', 'public.profiles', 'SELECT'), 'backend reads profiles');
SELECT ok(has_table_privilege('service_role', 'public.profiles', 'UPDATE'), 'backend updates profiles');
SELECT ok(has_table_privilege('service_role', 'public.lesson_progress', 'SELECT'), 'backend lists progress');
SELECT ok(has_table_privilege('service_role', 'public.event_store', 'INSERT'), 'backend appends sync events');
SELECT ok(has_table_privilege('service_role', 'public.tasks', 'SELECT'), 'backend reads tasks');
SELECT ok(has_table_privilege('service_role', 'public.task_submissions', 'SELECT'), 'backend reads submissions');
SELECT ok(has_table_privilege('service_role', 'public.task_submissions', 'INSERT'), 'backend creates submissions');
SELECT ok(has_table_privilege('service_role', 'public.certificates', 'SELECT'), 'backend reads certificates');
SELECT ok(has_table_privilege('service_role', 'public.notifications', 'INSERT'), 'backend creates notifications');
SELECT ok(has_table_privilege('service_role', 'public.payment_events', 'INSERT'), 'backend registers payment events');
SELECT ok(has_table_privilege('service_role', 'public.payment_events', 'UPDATE'), 'backend updates payment events');
SELECT ok(has_table_privilege('service_role', 'public.video_processing_jobs', 'INSERT'), 'backend creates video jobs');
SELECT ok(has_table_privilege('service_role', 'public.video_processing_jobs', 'UPDATE'), 'worker updates video jobs');

SELECT * FROM finish();
ROLLBACK;
