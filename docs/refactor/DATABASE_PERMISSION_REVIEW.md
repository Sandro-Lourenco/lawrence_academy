# Database Permission Review

**Date:** 2026-07-13  
**Migration:** `20260713133904_canonicalize_progress_and_permissions.sql`  
**Status:** `APPROVED_LOCAL`

Supabase separates object grants from row policies. The review follows the
official guidance that grants expose an object while RLS controls visible rows:
<https://supabase.com/docs/guides/api/securing-your-api>.

| Object | anon | authenticated | service_role | RLS / control |
|---|---|---|---|---|
| `courses` | SELECT | SELECT | Server access | Published/owner/admin policies |
| `modules` | SELECT | SELECT | Server access | Published course/owner/admin policies |
| `lessons` | SELECT | SELECT | Server access | Preview, subscription, teacher owner, admin |
| `lesson_progress` | None | SELECT, INSERT | Canonical merge | Ownership `USING`/`WITH CHECK`; no client update grant |
| `event_store` | None | None | SELECT, INSERT through backend | RLS enabled; server-owned append-only audit |
| `profiles` | None | SELECT | Server access | Own profile/admin rows only |
| `profile_public_view` | SELECT | SELECT | Server access | `security_invoker=true` |

`courses`, `profiles`, and `profile_public_view` grants are required dependencies
of the reviewed RLS policies and existing security contract tests. No mutation
grant was added for these objects.

The progress trigger and merge RPC are `SECURITY INVOKER`. Trigger helpers are
not executable by API roles. The merge RPC is executable only by `service_role`.
No new `SECURITY DEFINER` object was introduced.

## Evidence

- Local database rebuilt from every migration: passed.
- Supabase database lint at warning level: no schema errors.
- Five SQL/RLS suites passed, including anonymous preview access, subscription
  isolation, admin/teacher policies, progress ownership, server calculation,
  idempotency, out-of-order events, and privilege assertions.
- Rollback artifact:
  `docs/archive/database/20260713133904_canonicalize_progress_and_permissions_rollback.sql`.
