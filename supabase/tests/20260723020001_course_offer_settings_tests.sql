SELECT plan(1);

DO $$
DECLARE
    missing_columns TEXT[];
BEGIN
    SELECT ARRAY_AGG(required.column_name)
    INTO missing_columns
    FROM (
        VALUES
            ('promotional_monthly_price'),
            ('promotion_starts_at'),
            ('promotion_ends_at'),
            ('certificate_enabled'),
            ('reviews_enabled'),
            ('comments_enabled'),
            ('visibility'),
            ('availability'),
            ('scheduled_publish_at'),
            ('is_featured')
    ) AS required(column_name)
    WHERE NOT EXISTS (
        SELECT 1
        FROM information_schema.columns existing
        WHERE existing.table_schema = 'public'
          AND existing.table_name = 'courses'
          AND existing.column_name = required.column_name
    );

    IF missing_columns IS NOT NULL THEN
        RAISE EXCEPTION 'Missing course offer columns: %', missing_columns;
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conrelid = 'public.courses'::regclass
          AND conname = 'courses_promotional_price_check'
    ) THEN
        RAISE EXCEPTION 'Promotional price constraint is missing';
    END IF;
END;
$$;

SELECT pass('Course offer settings and financial constraints are present');
SELECT * FROM finish();
