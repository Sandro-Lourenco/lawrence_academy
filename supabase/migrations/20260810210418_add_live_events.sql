-- Agenda de lives da Lawrence Academy.
-- Participantes autenticados enxergam somente eventos publicados; professores
-- administram apenas os eventos que criaram e super admins administram todos.
CREATE TABLE public.live_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    instructor_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE RESTRICT,
    title TEXT NOT NULL CHECK (char_length(btrim(title)) BETWEEN 3 AND 160),
    description TEXT NOT NULL DEFAULT '' CHECK (char_length(description) <= 2000),
    tag TEXT NOT NULL DEFAULT 'Alta-costura' CHECK (char_length(btrim(tag)) BETWEEN 2 AND 60),
    scheduled_for TIMESTAMPTZ NOT NULL,
    timezone TEXT NOT NULL DEFAULT 'America/Sao_Paulo'
        CHECK (timezone ~ '^[A-Za-z_]+(?:/[A-Za-z0-9_+\-]+)+$'),
    duration_minutes INTEGER NOT NULL DEFAULT 60 CHECK (duration_minutes BETWEEN 10 AND 480),
    status TEXT NOT NULL DEFAULT 'draft'
        CHECK (status IN ('draft', 'scheduled', 'live', 'ended', 'cancelled')),
    youtube_url TEXT NOT NULL CHECK (
        youtube_url ~* '^https://(www\.|m\.)?youtube\.com/(watch\?v=|live/)[A-Za-z0-9_-]+'
        OR youtube_url ~* '^https://youtu\.be/[A-Za-z0-9_-]+'
    ),
    banner_url TEXT CHECK (banner_url IS NULL OR banner_url ~* '^https://'),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_live_events_public_schedule
    ON public.live_events (scheduled_for DESC)
    WHERE status IN ('scheduled', 'live', 'ended');
CREATE INDEX idx_live_events_instructor_schedule
    ON public.live_events (instructor_id, scheduled_for DESC);

CREATE TRIGGER set_live_events_updated_at
BEFORE UPDATE ON public.live_events
FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

ALTER TABLE public.live_events ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON public.live_events FROM anon, authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.live_events TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.live_events TO service_role;

CREATE POLICY live_events_participant_select
ON public.live_events FOR SELECT TO authenticated
USING (status IN ('scheduled', 'live', 'ended'));

CREATE POLICY live_events_teacher_select_own
ON public.live_events FOR SELECT TO authenticated
USING (
    (SELECT auth.uid()) = instructor_id
    AND (SELECT auth.jwt() -> 'app_metadata' ->> 'role') = 'teacher'
);

CREATE POLICY live_events_super_admin_select
ON public.live_events FOR SELECT TO authenticated
USING ((SELECT auth.jwt() -> 'app_metadata' ->> 'role') = 'super_admin');

CREATE POLICY live_events_teacher_insert_own
ON public.live_events FOR INSERT TO authenticated
WITH CHECK (
    (SELECT auth.uid()) = instructor_id
    AND (SELECT auth.jwt() -> 'app_metadata' ->> 'role') IN ('teacher', 'super_admin')
);

CREATE POLICY live_events_teacher_update_own
ON public.live_events FOR UPDATE TO authenticated
USING (
    (SELECT auth.uid()) = instructor_id
    AND (SELECT auth.jwt() -> 'app_metadata' ->> 'role') IN ('teacher', 'super_admin')
)
WITH CHECK (
    (SELECT auth.uid()) = instructor_id
    AND (SELECT auth.jwt() -> 'app_metadata' ->> 'role') IN ('teacher', 'super_admin')
);

CREATE POLICY live_events_super_admin_update
ON public.live_events FOR UPDATE TO authenticated
USING ((SELECT auth.jwt() -> 'app_metadata' ->> 'role') = 'super_admin')
WITH CHECK ((SELECT auth.jwt() -> 'app_metadata' ->> 'role') = 'super_admin');

CREATE POLICY live_events_teacher_delete_own
ON public.live_events FOR DELETE TO authenticated
USING (
    (SELECT auth.uid()) = instructor_id
    AND (SELECT auth.jwt() -> 'app_metadata' ->> 'role') IN ('teacher', 'super_admin')
);

CREATE POLICY live_events_super_admin_delete
ON public.live_events FOR DELETE TO authenticated
USING ((SELECT auth.jwt() -> 'app_metadata' ->> 'role') = 'super_admin');
