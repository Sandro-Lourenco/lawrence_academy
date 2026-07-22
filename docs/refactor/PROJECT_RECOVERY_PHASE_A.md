# Project Recovery - Phase A Audit and Execution Plan

**Date:** 2026-07-12  
**Status:** `PHASE_B_B0_COMPLETE_B1_AWAITING_EVIDENCE`  
**Scope:** Architecture, functional wiring, security, CI/CD, and production readiness

## 1. Executive Decision

The current repository must not be classified as production ready.

The backend unit/API suite is green, but executable evidence contradicts the existing
Go-Live and Production Ready reports. Critical production journeys remain mocked or
disconnected, secrets are present in a tracked configuration file, CI/CD is absent,
and the active Flutter application does not expose the documented teacher/admin
navigation.

Existing approval reports are historical inputs, not release evidence. They remain
invalid for a new release until the gates in section 10 are reproduced by CI and a
staging environment.

## 2. Evidence Collected

### Commands executed

| Validation | Result |
|---|---|
| `python -m mypy src` | Passed: 93 source files |
| `python -m compileall -q src` | Passed |
| `python -m pytest -q` | Passed: 82 tests, 4 warnings |
| `python -m ruff check .` | Not executed: Ruff is not installed |
| `flutter analyze` | Inconclusive: Flutter process did not complete in the current environment |
| `flutter test` | Inconclusive: Flutter process did not complete in the current environment |
| Git worktree inspection | Large pre-existing dirty worktree; recovery must preserve those changes |

### Evidence limitations

- No test was executed against a real staging Supabase project.
- SQL RLS tests were inspected but not executed against PostgreSQL/Supabase.
- No Stripe sandbox webhook was delivered end to end.
- No Android device test proved background sync, encrypted download, or license expiry.
- No web or APK artifact was produced during this audit.
- No latency, FPS, accessibility, load, backup, or disaster-recovery target was measured.

## 3. Architecture Decision

### Flutter canonical architecture

The canonical implementation is:

```text
lawrence/lib/app
lawrence/lib/core
lawrence/lib/design_system
lawrence/lib/shared
lawrence/lib/features/<feature>/{presentation,application,domain,data}
```

The active application imports `app/app.dart`, which uses
`app/router/app_router.dart`. The following trees are legacy and must be migrated and
then removed only after reference and behavioral checks:

```text
lawrence/lib/presentation
lawrence/lib/ui
lawrence/lib/data
lawrence/lib/core/router.dart
```

Confirmed duplicate implementations include catalog, course detail, login, player,
dashboard controller, auth controller, course repository, task execution, theme, and
Liquid Glass widgets.

The active `features` tree is not yet Clean Architecture compliant. Presentation and
application code import concrete data implementations in auth, courses, lessons,
player, dashboard, invoices, certificates, sync, lesson progress, and teacher studio.
These dependencies must be inverted through domain interfaces and providers.

### Backend canonical architecture

The canonical public API is `/api/v1`, implemented by:

```text
domain -> application -> infrastructure -> interface/api
```

Current startup registers three generations simultaneously:

- legacy `/api/*` routers;
- intermediate `/courses` and `/students` routers;
- `/api/v1/*` routers.

Routes also instantiate admin Supabase clients and concrete repositories directly.
The target flow is:

```text
Router -> security dependency -> DTO -> use case -> repository interface
       -> repository implementation -> Supabase/RLS
```

Legacy routes may be removed only after Flutter, worker, webhook, tests, and external
consumer references are migrated. The Stripe legacy webhook requires an explicit
provider-dashboard migration and deprecation window.

## 4. Critical Findings

### P0 - Security incident

`backend/docker-compose.yml` contains hardcoded service and provider credentials.
The Supabase service-role credential bypasses RLS. All credentials in that file must
be treated as compromised.

Required external action before code rollout:

1. Revoke and rotate Supabase service role, Stripe, AI, and webhook credentials.
2. Review provider audit logs from the first known exposure date.
3. Remove secrets from the current files and Git history using an approved history
   rewrite procedure.
4. Invalidate old build/deploy environments that may still use revoked credentials.

Additional security blockers:

- `NetworkClient` logs request headers and bodies, including the Authorization header.
- Auth diagnostics log user email and session metadata.
- Backend and worker settings silently accept placeholder credentials.
- Flutter contains a hardcoded Supabase project URL and anon key instead of build-time
  environment configuration.
- Docker runs the API as root.
- There is no automated secret or dependency scanning.

### P0 - False production evidence

Current reports claim zero secrets, zero live mocks, working offline sync, and Go-Live
approval. Those claims conflict with the repository and must be retracted or marked
superseded. Release status returns to `RECOVERY_IN_PROGRESS` until Phase B gates pass.

### P0 - Offline data loss

`SyncScheduler` marks all pending events complete without calling the backend.
`SQLiteQueueRepository` is an in-memory list, so queued events do not survive process
termination. The background callback initializes storage and returns success without
syncing. The backend also emits a mock signed HLS URL.

### P0 - Checkout is not wired

Course checkout sends `price_placeholder`. A successful UI interaction cannot prove a
real per-course subscription. Checkout must resolve the server-owned price for the
course and validate eligibility before creating a provider session.

## 5. Functional Findings

| Journey | Current state | Required outcome | Priority |
|---|---|---|---|
| Login/session | Implemented, excessive diagnostics | Sanitized logs, restore/refresh tests | P1 |
| Registration | Shares login page/route | Dedicated validated flow and states | P1 |
| Password reset | Empty use-case stub | Supabase reset request and deep-link completion | P0 |
| Profile | Read UI exists | Real edit use case and persistence | P1 |
| Change password | Visible no-op | Re-authentication and update flow | P1 |
| Dark mode | Hardcoded toggle | Persisted provider connected to `MaterialApp.router` | P1 |
| Notifications/privacy | Visible no-op | Real pages or explicitly disabled controls | P1 |
| Catalog | API path exists | Diagnosable empty/error/auth/RLS states and pagination | P0 |
| Checkout | Placeholder price | Real server-controlled price and Stripe session | P0 |
| Subscriptions | Partial | Contract-consistent list/cancel/end-of-period behavior | P0 |
| Invoices | Partial | Downloadable provider receipt or explicit unavailable state | P1 |
| Player/HLS | Partial | Subscription guard and real signed HLS URL | P0 |
| Activities | Mock data | Repository/API-backed tasks and submissions | P1 |
| Offline sync | False success | Durable queue, batch API, retry, idempotency | P0 |
| Certificates | Partial/mocked metadata | Real eligibility, generation, download, share, verification | P1 |
| Lives | Mock data | Backend-backed feature or feature-flagged unavailable state | P2 |
| Teacher portal | Code exists, not routed | Role guard and complete active routes | P1 |
| Admin portal | Legacy single page only | Permission guard and documented MVP admin scope | P2 |

## 6. API Contract Mismatches

- Flutter certificate clients call `/api/v1/certificates`, while the backend router is
  mounted at `/certificates`.
- Flutter teacher datasource uses `/teacher/courses`, while the backend canonical
  prefix is `/api/v1/teacher/courses` unless the configured base URL compensates for
  it. This must be made unambiguous.
- Flutter course repositories use `/courses`; compatibility currently depends on the
  base URL and the simultaneous registration of intermediate and v1 routers.
- Subscription cancellation calls `/subscriptions/{id}/cancel`, but the registered
  backend contract must be verified and normalized under `/api/v1`.
- The active Flutter router does not include teacher, admin, certificate-detail, or
  task-execution routes that exist in legacy routing/code.

All clients must consume one generated or centrally defined API contract. Compatibility
aliases require explicit expiry dates and contract tests.

## 7. Phase B Execution Backlog

### B0 - Incident containment and truthful status

Deliverables:

- Rotate exposed credentials and document rotation evidence without storing values.
- Replace committed values with environment references and validated examples.
- Add startup validation that rejects missing/placeholder production configuration.
- Sanitize client/server logs and add regression tests for token redaction.
- Mark contradictory Go-Live/Production reports as superseded.

Gate:

- Secret scan returns zero verified secrets.
- Production boot fails with incomplete configuration.
- No request log contains Authorization, cookies, signed URLs, or sensitive payloads.

### B1 - Establish automated quality gates

Create GitHub Actions jobs for:

```text
backend: ruff, mypy, compileall, pytest, dependency audit, Docker build
flutter: format check, analyze, test, web build, Android app bundle build
database: migration lint, local reset, SQL/RLS tests
security: secret scan, SAST, dependency scan, container scan
```

Pin Python dependencies and add Ruff to development dependencies. CI must not use
production credentials.

Gate:

- All jobs pass from a clean checkout.
- Branch protection requires the jobs.

### B2 - Canonicalize architecture without behavior changes

Deliverables:

- Inventory references to every legacy Flutter file.
- Move remaining consumers to `features` and remove the duplicate router.
- Invert presentation/application dependencies on concrete data classes.
- Register only `/api/v1` routers, retaining narrowly scoped deprecated aliases.
- Move backend repository construction into dependency providers.
- Add architecture/import tests and OpenAPI collision tests.

Gate:

- No active import from Flutter legacy trees.
- No backend route constructs an admin client or concrete repository.
- OpenAPI contains no unintended duplicate operations.
- Existing behavior tests remain green.

### B3 - Repair identity, settings, and profile

Deliverables:

- Implement password-reset request and reset completion.
- Add profile edit, password change, notification preferences, and privacy routes/pages.
- Implement persisted ThemeMode and bind it to `MaterialApp.router`.
- Replace every visible no-op with a real flow or disabled/feature-flagged state.
- Add auth, navigation, provider, widget, and accessibility tests.

Gate:

- All visible controls have tested behavior.
- Session refresh/logout and reset deep links pass integration tests.

### B4 - Repair catalog, checkout, and financial access

Deliverables:

- Normalize course endpoints and DTOs under `/api/v1`.
- Add cursor pagination and explicit published/empty diagnostics.
- Resolve Stripe price server-side from the selected course.
- Verify idempotent checkout/webhook/subscription cancellation.
- Add course access tests for student, other student, teacher, anonymous, and admin.
- Add a staging seed mechanism that never runs in production automatically.

Gate:

- Catalog -> course -> checkout -> webhook -> active access succeeds in Stripe sandbox.
- Duplicate webhook and double-click checkout do not duplicate subscriptions.
- Cancellation preserves access through the paid period.

### B5 - Repair learning, offline, and certificates

Deliverables:

- Replace mock HLS URLs with access-checked signed URLs.
- Implement durable SQLite queue and real `/api/v1/offline/sync` batches.
- Add exponential backoff, retry scheduling, idempotency, conflict resolution, and
  background execution.
- Remove production mock fallback from video/AI workers or guard it behind an explicit
  non-production adapter.
- Implement certificate eligibility metadata, PDF download, sharing, and public verify.
- Feature-flag lives/achievements/favorites until backed by real data.

Gate:

- Device offline/online/kill/restart scenarios preserve and eventually sync progress.
- Unauthorized or expired users cannot stream or download course media.
- Certificate generation is idempotent and its public verification excludes PII.

### B6 - Production validation

Deliverables:

- Staging deployment from CI using production-equivalent topology.
- Supabase migration reset and RLS/BOLA test evidence.
- Web/Android E2E for auth, catalog, checkout, player, offline, and certificates.
- Accessibility checks, Flutter frame profiling, API load tests, and database plans.
- Health/readiness checks for database, storage, Stripe configuration, and workers.
- Backup restore drill with documented RPO/RTO and rollback rehearsal.
- New security, architecture, QA, performance, and production-readiness reports linked
  to immutable CI runs and artifact hashes.

Gate:

- Zero open P0/P1 issues.
- API P95 and Flutter performance budgets meet documented targets.
- Security and dependency scans have no unaccepted critical/high findings.
- Rollback and restore are demonstrated, not only documented.

## 8. Dependency Order

```text
B0 Security containment
  -> B1 CI and reproducibility
    -> B2 architecture and contract canonicalization
      -> B3 identity/profile/settings
      -> B4 catalog/financial access
        -> B5 learning/offline/certificates
          -> B6 production validation
```

B3 may run in parallel with the later part of B4 only after B2 freezes shared auth and
network contracts. B5 depends on confirmed subscription access from B4.

## 9. Change Safety

The worktree contains extensive pre-existing modified, deleted, and untracked files.
Before Phase B:

1. Capture the current diff and ownership of changes.
2. Create a recovery branch or snapshot without discarding local work.
3. Split work into reviewable commits by B0-B6.
4. Never delete a legacy file until reference search, build, and regression tests prove
   it is unused.
5. Never rewrite Git history for secret removal without explicit approval and a backup.

## 10. Release Gates

A production-ready declaration requires all of the following evidence:

- Clean-checkout CI run with backend, Flutter, database, and security jobs green.
- Staging URLs/artifacts tied to the tested commit SHA.
- Stripe sandbox transaction and signed webhook evidence.
- Supabase RLS/BOLA suite executed on the deployed migration set.
- Android device evidence for offline persistence and background retry.
- Web and Android E2E evidence for all MVP journeys.
- Secret rotation confirmation and zero-secret scan.
- Measured performance and accessibility results.
- Successful backup restore and rollback rehearsal.
- No mocks, placeholders, stubs, or false-success branches reachable in production.

## 11. Phase A Result

**Result:** `REQUEST_CHANGES`  
**Production status:** `BLOCKED`  
**Phase B approval:** Granted by the project owner on 2026-07-12.  
**Current action:** B0 is complete; B1 automation is implemented and awaiting
remote/database evidence. See
`docs/refactor/PROJECT_RECOVERY_B0_REPORT.md` and
`docs/refactor/PROJECT_RECOVERY_B1_REPORT.md`.  
**Production status:** Remains blocked until B1-B6 pass.
