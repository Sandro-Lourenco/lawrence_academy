# Lesson Progress Schema Decision

**Decision:** `ACCEPTED_FOR_B2_IMPLEMENTATION`  
**Date:** 2026-07-12

## Canonical state table

- Name: `public.lesson_progress`.
- Primary key: `id UUID DEFAULT gen_random_uuid()`.
- Unique key: `(student_id, lesson_id)`.
- Foreign keys: `student_id -> profiles(id)`, `course_id -> courses(id)`,
  `lesson_id -> lessons(id)`, all `ON DELETE CASCADE`.
- Required state: `watched_seconds INTEGER NOT NULL DEFAULT 0`,
  `progress_percentage NUMERIC(5,2) NOT NULL DEFAULT 0`,
  `completed BOOLEAN NOT NULL DEFAULT FALSE`.
- Optional state: `completed_at TIMESTAMPTZ`.
- Timestamps: `last_synced_at`, `created_at`, and `updated_at`, all non-null
  UTC timestamps with `NOW()` defaults.
- Soft delete: none. Progress is dependent state and is deleted with its
  student or lesson.

## Invariants

1. `0 <= watched_seconds <= lessons.duration_seconds`.
2. `0 <= progress_percentage <= 100`.
3. `course_id` must equal the course owning `lesson_id`.
4. Progress never decreases: merge uses `GREATEST` for watched seconds and
   percentage.
5. Completion is irreversible: existing or incoming completion wins.
6. Completion sets percentage to `100` and preserves the first
   `completed_at`; non-completed events cannot clear it.
7. `updated_at` and `last_synced_at` use server time after an accepted event.
8. Percentage is calculated by the server from lesson duration and watched time.

## Idempotency and multi-device conflict

`lesson_progress` stores only consolidated state. Durable request/event
idempotency belongs to `public.event_store`:

- `event_id TEXT` is globally unique, preserving existing client identifiers.
- `(user_id, idempotency_key)` is unique.
- `device_id` and `occurred_at` retain the source and client time.
- Replays return the previously accepted result without changing state.
- Out-of-order valid events are safe because state merging is monotonic.
- Server receive order never allows a lower value to overwrite a higher one.

`event_id` remains `TEXT` because existing offline queues use deterministic,
semantic retry IDs such as `sync_<course>_<lesson>_<timestamp>`. Converting to
UUID would invalidate already persisted retry identities and break replay
deduplication. New IDs may be UUID strings, but the storage contract must accept
the deployed deterministic format through its compatibility lifetime.

## Audit and RLS

- `event_store` is append-only; authenticated users may insert/read only their
  own rows. Update and delete are not granted.
- `lesson_progress` allows students to select/insert/update only rows where
  `auth.uid() = student_id`, with both `USING` and `WITH CHECK` for update.
- Admin access uses the existing `public.is_admin(auth.uid())` predicate.
- Backend service-role access remains server-only and does not weaken RLS.

## Indexes

- Unique `(student_id, lesson_id)` for point lookup/upsert.
- `(student_id, course_id)` for dashboards/course progress.
- `(lesson_id)` for certificate/completion aggregation.
- Event indexes on `(user_id, device_id)`, `correlation_id`, and
  `(user_id, occurred_at DESC)`.

## Certificate eligibility

Certificates consume the consolidated row only. Eligibility requires every
required lesson row to have `completed = TRUE`; event telemetry alone never
grants a certificate.
