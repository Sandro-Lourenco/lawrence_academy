SELECT plan(1);

BEGIN;

DO $$
DECLARE
    v_reloptions text[];
    v_proconfig text[];
    v_signature regprocedure;
BEGIN
    SELECT c.reloptions
      INTO v_reloptions
      FROM pg_class AS c
      JOIN pg_namespace AS n ON n.oid = c.relnamespace
     WHERE n.nspname = 'public'
       AND c.relname = 'profile_public_view';

    IF v_reloptions IS NULL
       OR NOT ('security_invoker=true' = ANY (v_reloptions)) THEN
        RAISE EXCEPTION 'profile_public_view must use security_invoker=true';
    END IF;

    FOREACH v_signature IN ARRAY ARRAY[
        'public.auto_grade_submission()'::regprocedure,
        'public.check_progress_course_integrity()'::regprocedure,
        'public.handle_new_user()'::regprocedure,
        'public.handle_storage_video_upload()'::regprocedure,
        'public.is_admin(uuid)'::regprocedure,
        'public.is_teacher(uuid)'::regprocedure
    ]
    LOOP
        SELECT p.proconfig
          INTO v_proconfig
          FROM pg_proc AS p
         WHERE p.oid = v_signature;

        IF v_proconfig IS NULL
           OR NOT ('search_path=pg_catalog, public' = ANY (v_proconfig)) THEN
            RAISE EXCEPTION '% must have a fixed search_path', v_signature;
        END IF;
    END LOOP;

    FOREACH v_signature IN ARRAY ARRAY[
        'public.auto_grade_submission()'::regprocedure,
        'public.check_progress_course_integrity()'::regprocedure,
        'public.handle_new_user()'::regprocedure,
        'public.handle_storage_video_upload()'::regprocedure
    ]
    LOOP
        IF has_function_privilege('anon', v_signature, 'EXECUTE')
           OR has_function_privilege('authenticated', v_signature, 'EXECUTE') THEN
            RAISE EXCEPTION '% must not be directly executable by API roles', v_signature;
        END IF;
    END LOOP;

    IF NOT has_function_privilege(
        'anon', 'public.is_admin(uuid)', 'EXECUTE'
    ) OR NOT has_function_privilege(
        'anon', 'public.is_teacher(uuid)', 'EXECUTE'
    ) OR NOT has_function_privilege(
        'authenticated', 'public.is_admin(uuid)', 'EXECUTE'
    ) OR NOT has_function_privilege(
        'authenticated', 'public.is_teacher(uuid)', 'EXECUTE'
    ) THEN
        RAISE EXCEPTION 'RLS authorization helpers must remain available to authenticated users';
    END IF;

    PERFORM set_config('request.jwt.claim.sub', '', true);
    IF public.is_admin(NULL) OR public.is_teacher(NULL) THEN
        RAISE EXCEPTION 'Authorization helpers must deny requests without a JWT subject';
    END IF;
END
$$;

ROLLBACK;

SELECT pass('All assertions completed');
SELECT * FROM finish();
