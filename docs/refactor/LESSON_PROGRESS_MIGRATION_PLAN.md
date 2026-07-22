# Lesson Progress Migration Plan

**Strategy:** `2 - additive migration`  
**Date:** 2026-07-12

## Why

The active `lesson_progress` column names already match Flutter and the schema
contract. Renaming them would add risk without benefit. The safe correction is
to adapt backend mappings and add missing constraints, policies, indexes,
timestamp behavior, and durable event storage.

## Forward plan

1. Create a new migration; do not edit any applied migration.
2. Backfill null state/timestamps before applying `NOT NULL` constraints.
3. Clamp invalid historical values into valid ranges, recording pre-migration
   counts in deployment evidence.
4. Add check constraints as `NOT VALID`, validate them, then enforce non-null.
5. Add the lesson index and update timestamp trigger.
6. Replace broad progress policies with explicit select/insert/update policies
   containing ownership checks and admin policies.
7. Create `event_store` if absent with UUID event IDs, per-user idempotency,
   append-only grants, RLS, and indexes.
8. Update backend repository mappings and DTOs only after local reset proves
   the migration.

## Data migration

- Null `watched_seconds` -> `0`.
- Null `progress_percentage` -> `0`.
- Values below zero -> `0`; percentage above 100 -> `100`.
- Null sync/update timestamps -> `NOW()`.
- Rows already completed retain `completed_at`; if absent, use existing
  `updated_at`, then `NOW()`.
- No row or identifier is deleted or renamed.

## Rollback

Rollback removes only objects introduced by this migration: new checks,
indexes, trigger, policies, and `event_store` when deployment evidence confirms
it was created by this lot. It does not restore invalid/null data and never
drops `lesson_progress`. Application rollback remains compatible with the
strengthened table because canonical columns are unchanged.

## Deployment gates

- Fresh `supabase db reset` succeeds.
- SQL tests prove constraints, RLS ownership, monotonic merge, and replay
  idempotency.
- Existing rows are counted before/after with equal totals.
- Backend and Flutter full suites pass.
- Advisors/lint show no new security or performance findings.

## Validation result

- Fresh local reset: passed.
- Schema lint: passed with zero findings.
- Progress persistence SQL suite: passed.
- Security-definer suite: passed.
- Backend: Ruff passed, Mypy passed for 107 source files, compileall passed,
  and 103 Pytest tests passed.
- Flutter: analyze passed and 38 tests passed.
- Global legacy SQL suites remain blocked before progress assertions because
  their `lessons/modules` access expectations lack matching table grants. This
  unrelated grant contract must be resolved in a separate approved B2 lot.
