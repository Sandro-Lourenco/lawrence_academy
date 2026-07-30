-- Test-only bootstrap executed first by database-ci.yml.
-- This file is not a migration and never changes the production schema.

CREATE EXTENSION IF NOT EXISTS pgtap;

BEGIN;
SELECT plan(1);
SELECT has_extension('pgtap', 'pgTAP test extension is installed');
SELECT * FROM finish();
ROLLBACK;

