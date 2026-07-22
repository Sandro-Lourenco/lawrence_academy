# Lesson Progress Persistence Inventory

**Date:** 2026-07-12  
**Phase:** B2  
**Status:** `AUDITED`

## Source of truth

The latest active definition is
`supabase/migrations/20260710131000_database_and_security_refactor.sql`.
The earlier `20260706222207` definition and archived rollback files are
historical, not editable schema sources.

| Conceito | Migration atual | Backend atual | Flutter atual | Canonico proposto | Acao |
|---|---|---|---|---|---|
| Progress table | `public.lesson_progress` | `lesson_progress` | SQLite `lesson_progress` | `public.lesson_progress` | Keep |
| Owner | `student_id UUID` | `user_id` | Identity comes from JWT; not persisted locally | `student_id`, always derived from JWT | Rename backend mapping only |
| Primary key | `id UUID DEFAULT gen_random_uuid()` | Not modeled | Composite local key | UUID server PK | Keep |
| Natural key | `UNIQUE(student_id, lesson_id)` | Assumes `(user_id, lesson_id)` | `(course_id, lesson_id)` locally | `UNIQUE(student_id, lesson_id)` | Keep and test |
| Course | `course_id UUID` | `course_id` | `course_id` | `course_id`, validated against lesson | Keep |
| Lesson | `lesson_id UUID` | `lesson_id` | `lesson_id` | `lesson_id` | Keep |
| Watched time | `watched_seconds INTEGER` | `last_position` | `watched_seconds` | `watched_seconds >= 0`, monotonic MAX | Replace backend mapping |
| Percentage | `progress_percentage NUMERIC(5,2)` | `progress` | `progress_percentage` | `progress_percentage` in `[0,100]`, monotonic MAX | Replace backend mapping |
| Completion | `completed BOOLEAN` | String `status` | `completed BOOLEAN` | `completed BOOLEAN`, irreversible | Replace backend status mapping |
| Completion time | `completed_at TIMESTAMPTZ` | Not persisted | `completed_at` | First trusted completion time | Persist and never clear |
| Last sync | `last_synced_at TIMESTAMPTZ` | Not persisted | `last_synced_at` local | Server receive time; local updated after ACK | Align |
| Created/updated | Both `TIMESTAMPTZ` | Only ad-hoc update timestamp | Local queue timestamps | Both non-null UTC timestamps | Keep; add update trigger |
| Duration | On `lessons.duration_seconds` | Not loaded by sync validator | Lesson entity | Not duplicated in progress | Validate percentage/time against lesson when available |
| Device | Not on consolidated row | `device_id` in event payload/store | Sync telemetry payload | `device_id` in `event_store`, not state row | Create audited event store |
| Idempotency | No progress column | DTO field but no durable enforcement | Queue `idempotency_key` | Unique non-null `event_store.idempotency_key` per student | Add event store constraint |
| Event ID | No progress column | `event.id` | Queue event identity | Unique `event_store.event_id` | Add event store constraint |
| Multi-device order | Not represented | MAX percentage only | Local MAX merge | MAX watched/percentage, completion OR, never regress | Implement atomically |
| `progress_percent` / `percentage` | Absent | Absent in active code | Absent | Forbidden aliases | Reject in DTO |
| `last_position_seconds` | Absent | Historical legacy only | Legacy root tree only | Forbidden in canonical contract | Do not add |

## Material findings

- The current backend writes columns that do not exist in the active schema.
- The backend reads `progress/status`, also absent from the active schema.
- Existing sync tests mostly use unknown lower-case actions and therefore do
  not exercise persistence.
- `event_store` is documented in `DATABASE_SCHEMA.md` but missing from active
  migrations.
- Current RLS has `USING` clauses but lacks explicit `WITH CHECK` on writes.
- Current numeric columns permit null and out-of-range values.

