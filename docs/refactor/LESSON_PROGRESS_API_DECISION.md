# Lesson Progress API Decision

**Status:** `IMPLEMENTED_IN_B2`  
**Base:** `/api/v1/offline`

## Operations

| Method | Path | Purpose |
|---|---|---|
| `GET` | `/progress` | Read all consolidated progress owned by the JWT student |
| `PATCH` | `/progress/{lesson_id}` | Idempotent monotonic merge of one lesson |
| `POST` | `/sync` | Batch offline events, maximum 100 events |

All operations require a valid JWT. `student_id` is never accepted from the
client; it is derived from `CurrentUser`. The path and body lesson IDs must
match for unit writes.

## Canonical payload

```json
{
  "course_id": "uuid",
  "lesson_id": "uuid",
  "watched_seconds": 120,
  "progress_percentage": 42.5,
  "completed": false,
  "completed_at": null,
  "device_id": "installation-id",
  "correlation_id": "uuid",
  "event_id": "uuid-or-stable-client-id",
  "idempotency_key": "stable-retry-key",
  "occurred_at": "2026-07-12T12:00:00Z"
}
```

Batch events use the same progress fields inside `payload`, with `id`,
`action`, `created_at`, and `idempotency_key` in the event envelope. Accepted
progress actions are `UPDATE_LESSON_PROGRESS` and `LESSON_COMPLETED`.

## Conflict and idempotency

- `(user_id, idempotency_key)` and `event_id` prevent replay.
- Duplicate requests return consolidated state without reapplying the event.
- Watched seconds and percentage merge with `MAX`.
- Completion is an irreversible OR operation and forces 100 percent.
- Out-of-order and multi-device delivery cannot decrease state.
- Invalid, unknown, or extra fields are rejected rather than translated by a
  silent compatibility fallback.

## Server-side calculation

- `progress_percentage = ROUND(watched_seconds * 100 / duration_seconds, 2)`.
- The client percentage is optional validation input and is never persisted as
  the source of truth.
- A difference greater than `0.01` returns HTTP 422.
- Strategy B was selected for excessive watch time: values above the lesson
  duration are rejected with HTTP 422; they are never silently clamped.
- Lessons without a positive server-side duration reject progress writes.
- Completion requires `watched_seconds == duration_seconds`.

## Certificates

Certificate eligibility reads only consolidated `lesson_progress.completed`.
Telemetry and client-provided percentage alone do not issue certificates.
