-- Phase 2 of the teacher authoring studio: offer and operational settings.

ALTER TABLE public.courses
    ADD COLUMN IF NOT EXISTS promotional_monthly_price DECIMAL(10, 2),
    ADD COLUMN IF NOT EXISTS promotion_starts_at TIMESTAMPTZ,
    ADD COLUMN IF NOT EXISTS promotion_ends_at TIMESTAMPTZ,
    ADD COLUMN IF NOT EXISTS certificate_enabled BOOLEAN NOT NULL DEFAULT TRUE,
    ADD COLUMN IF NOT EXISTS reviews_enabled BOOLEAN NOT NULL DEFAULT TRUE,
    ADD COLUMN IF NOT EXISTS comments_enabled BOOLEAN NOT NULL DEFAULT TRUE,
    ADD COLUMN IF NOT EXISTS visibility TEXT NOT NULL DEFAULT 'public',
    ADD COLUMN IF NOT EXISTS availability TEXT NOT NULL DEFAULT 'immediate',
    ADD COLUMN IF NOT EXISTS scheduled_publish_at TIMESTAMPTZ,
    ADD COLUMN IF NOT EXISTS is_featured BOOLEAN NOT NULL DEFAULT FALSE;

ALTER TABLE public.courses
    DROP CONSTRAINT IF EXISTS courses_promotional_price_check,
    DROP CONSTRAINT IF EXISTS courses_promotion_period_check,
    DROP CONSTRAINT IF EXISTS courses_visibility_check,
    DROP CONSTRAINT IF EXISTS courses_availability_check,
    DROP CONSTRAINT IF EXISTS courses_schedule_check,
    ADD CONSTRAINT courses_promotional_price_check CHECK (
        promotional_monthly_price IS NULL
        OR (
            promotional_monthly_price >= 0
            AND promotional_monthly_price < monthly_price
        )
    ),
    ADD CONSTRAINT courses_promotion_period_check CHECK (
        (promotion_starts_at IS NULL AND promotion_ends_at IS NULL)
        OR (
            promotion_starts_at IS NOT NULL
            AND promotion_ends_at IS NOT NULL
            AND promotion_ends_at > promotion_starts_at
        )
    ),
    ADD CONSTRAINT courses_visibility_check CHECK (
        visibility IN ('public', 'private', 'unlisted')
    ),
    ADD CONSTRAINT courses_availability_check CHECK (
        availability IN ('immediate', 'scheduled')
    ),
    ADD CONSTRAINT courses_schedule_check CHECK (
        availability <> 'scheduled' OR scheduled_publish_at IS NOT NULL
    );

COMMENT ON COLUMN public.courses.is_featured IS
    'Administrative merchandising flag. Teacher APIs must not accept this field.';
