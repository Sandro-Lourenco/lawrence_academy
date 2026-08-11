-- Update public.handle_new_user() to support OAuth full name parsing and RBAC user_roles mapping.

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
DECLARE
    v_role_id UUID;
BEGIN
    -- Insert user profile. Handle full_name and name from OAuth metadata.
    INSERT INTO public.profiles (id, full_name, email, role)
    VALUES (
        NEW.id,
        COALESCE(
            NEW.raw_user_meta_data->>'full_name',
            NEW.raw_user_meta_data->>'name',
            'Estudante Lawrence'
        ),
        NEW.email,
        'student'
    )
    ON CONFLICT (id) DO UPDATE
    SET
        full_name = EXCLUDED.full_name,
        updated_at = NOW();

    -- Automatically assign 'student' role in RBAC user_roles table
    SELECT id INTO v_role_id FROM public.roles WHERE name = 'student';
    IF v_role_id IS NOT NULL THEN
        INSERT INTO public.user_roles (user_id, role_id)
        VALUES (NEW.id, v_role_id)
        ON CONFLICT DO NOTHING;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Reapply search path hardening for security definer
ALTER FUNCTION public.handle_new_user()
    SET search_path = pg_catalog, public;
