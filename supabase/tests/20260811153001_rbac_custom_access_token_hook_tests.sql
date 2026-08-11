SELECT plan(7);

BEGIN;

INSERT INTO auth.users (
    id, instance_id, aud, role, email, encrypted_password,
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    'a1000000-0000-0000-0000-000000000001',
    '00000000-0000-0000-0000-000000000000',
    'authenticated', 'authenticated', 'rbac-hook@example.test', '',
    '{"provider":"email","providers":["email"]}', '{}', NOW(), NOW()
);

DELETE FROM public.user_roles
 WHERE user_id = 'a1000000-0000-0000-0000-000000000001';
INSERT INTO public.user_roles (user_id, role_id)
SELECT 'a1000000-0000-0000-0000-000000000001', id
  FROM public.roles
 WHERE name IN ('student', 'teacher');

SELECT is(
    public.custom_access_token_hook(
        jsonb_build_object(
            'user_id', 'a1000000-0000-0000-0000-000000000001',
            'claims', '{"sub":"a1000000-0000-0000-0000-000000000001","app_metadata":{"provider":"email"}}'::JSONB
        )
    ) #>> '{claims,app_metadata,role}',
    'teacher',
    'the highest-priority canonical role is emitted in app_metadata'
);

SELECT is(
    public.custom_access_token_hook(
        jsonb_build_object(
            'user_id', 'a1000000-0000-0000-0000-000000000001',
            'claims', '{"app_metadata":{"provider":"email"}}'::JSONB
        )
    ) #>> '{claims,app_metadata,provider}',
    'email',
    'existing app metadata is preserved'
);

SELECT ok(
    has_function_privilege(
        'supabase_auth_admin',
        'public.custom_access_token_hook(jsonb)',
        'EXECUTE'
    ),
    'Supabase Auth can execute the token hook'
);

SELECT ok(
    NOT has_function_privilege(
        'anon', 'public.custom_access_token_hook(jsonb)', 'EXECUTE'
    ) AND NOT has_function_privilege(
        'authenticated', 'public.custom_access_token_hook(jsonb)', 'EXECUTE'
    ),
    'Data API roles cannot invoke the privileged hook'
);

SELECT ok(
    EXISTS (
        SELECT 1
          FROM pg_proc AS p
         WHERE p.oid = 'public.custom_access_token_hook(jsonb)'::regprocedure
           AND NOT p.prosecdef
           AND 'search_path=pg_catalog, public' = ANY (p.proconfig)
    ),
    'the invoker-rights hook has a fixed search path'
);

SELECT ok(
    has_table_privilege('supabase_auth_admin', 'public.user_roles', 'SELECT')
    AND has_table_privilege('supabase_auth_admin', 'public.roles', 'SELECT'),
    'Supabase Auth receives only the table reads required by the hook'
);

SELECT ok(
    EXISTS (
        SELECT 1
          FROM pg_policies
         WHERE schemaname = 'public'
           AND tablename = 'user_roles'
           AND policyname = 'Auth hook reads canonical user roles'
           AND 'supabase_auth_admin' = ANY (roles)
    ),
    'RLS explicitly allows the Auth hook to read canonical roles'
);

SELECT * FROM finish();

ROLLBACK;
