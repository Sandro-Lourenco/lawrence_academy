# Legacy API Consumer Inventory

**Date:** 2026-07-12  
**Phase:** B2 only  
**Status:** `IN_PROGRESS`

## Scope and method

The repository was searched across Flutter, backend, workers, tests, webhooks,
scripts, CI, Supabase files, and documentation. UI navigation paths such as
`/courses` and `/admin/*` were excluded unless they are sent through an HTTP
client. Router declarations are listed as compatibility providers, not as
consumers.

No repository evidence of a deployed external consumer was found. The Stripe
Dashboard remains an external dependency whose current configuration must be
verified outside this repository.

## Inventory

| Rota legada | Consumidor | Rota canonica | Compatibilidade necessaria | Data de expiracao | Status |
|---|---|---|---|---|---|
| `GET/PUT /api/profiles/me` | `backend/tests/test_main_api.py`; legacy router provider | `GET/PATCH /api/v1/profiles/me` | Yes, until legacy contract tests are moved and response compatibility is recorded | 2026-08-15 | `MIGRATE_TESTS` |
| `GET/PUT /students/me` | `backend/tests/test_courses_students_crud.py`; legacy router provider. The canonical Flutter dashboard was migrated on 2026-07-12 | `GET/PUT /api/v1/profiles/me` | Yes only until legacy contract tests migrate and the staging observation gate passes | 2026-08-15 | `MIGRATE_TESTS` |
| `GET/POST /api/courses`; `/api/courses/slug/{slug}`; `/api/courses/{id}` | Legacy router provider and historical documentation; no active canonical Flutter HTTP consumer found | Equivalent `/api/v1/courses*` routes | Yes only for contract-test migration and a staging access-log observation window | 2026-08-15 | `READY_FOR_CONSUMER_PROOF` |
| `GET /courses`; `/courses/{id}/lessons/{lesson_id}`; `/courses/{id}/lessons/{lesson_id}/stream` | `backend/tests/test_courses_students_crud.py`; legacy router provider. Flutter legacy consumer removed in B2.24 | Equivalent `/api/v1/courses*` routes | Yes until tests migrate and staging access logs prove zero traffic | 2026-08-15 | `MIGRATE_TESTS` |
| `POST /api/task_submissions` | `backend/tests/test_main_api.py`; legacy router provider | `POST /api/v1/tasks/{task_id}/submissions` | Yes until payload and route tests are migrated to the task-scoped contract | 2026-08-15 | `MIGRATE_TESTS` |
| `PUT /api/teacher/submissions/{id}/review` | `backend/tests/test_phase4_validation.py`; legacy router provider | `PUT /api/v1/tasks/submissions/{id}/review` | Yes until authorization tests use the canonical route | 2026-08-15 | `MIGRATE_TESTS` |
| `POST /webhooks/stripe` | `backend/tests/test_stripe_webhook.py`, `backend/tests/test_phase4_validation.py`; possible Stripe Dashboard configuration | `POST /api/v1/payments/webhook` | Yes, financial integration must not be removed before Dashboard verification and one signed staging delivery | 2026-09-30 | `EXTERNAL_CONFIRMATION_REQUIRED` |
| `GET/POST /certificates*` | Deprecated router and historical API documentation; no active Flutter HTTP consumer found | Equivalent `/api/v1/certificates*` routes | Yes through one staging access-log observation window; Flutter is already canonical | 2026-08-31 | `READY_FOR_ACCESS_LOG_PROOF` |
| `GET/POST /students/me/progress` | No active Flutter consumer remains | `GET /api/v1/offline/progress`, `PATCH /api/v1/offline/progress/{lesson_id}`, `POST /api/v1/offline/sync` | No runtime compatibility required after staging access-log confirmation | 2026-08-15 | `READY_FOR_ACCESS_LOG_PROOF` |
| `/teacher/courses*` | No active HTTP consumer after B2.24; UI navigation paths are not API calls | `/api/v1/teacher/courses*` | No, subject to access-log proof | 2026-08-15 | `MIGRATED_FLUTTER` |
| `POST /payments/checkout` | No active consumer after B2.24 | `POST /api/v1/payments/checkout` | No, subject to access-log proof | 2026-08-15 | `MIGRATED_FLUTTER` |
| `PATCH /subscriptions/{id}/cancel` | Active Flutter subscriptions workflow, but no backend route exists | None approved | Cannot be canonicalized without a new contract, prohibited in B2.24 | None | `CONTRACT_MISSING` |
| `GET /payments/checkout/status/{id}` | Active Flutter payment-pending workflow, but no backend route exists | None approved | Cannot be canonicalized without a new contract, prohibited in B2.24 | None | `CONTRACT_MISSING` |

## Findings by area

- **Flutter:** dashboard, progress, teacher studio, checkout creation, courses,
  profiles, certificates, tasks, invoices, and subscriptions listing use v1.
  Two active subscription operations have no backend contract and remain a B2
  blocker rather than being silently redirected.
- **Backend:** all legacy routers are explicitly registered as deprecated in
  `src/main.py`. Their own definitions are compatibility providers.
- **Workers:** no legacy HTTP consumer found. Worker code uses storage/database
  integration rather than these API aliases.
- **Tests:** several tests intentionally exercise legacy endpoints and must be
  migrated or converted into time-bounded compatibility tests.
- **Webhooks:** the Stripe alias remains operationally sensitive. Repository
  inspection cannot prove the Dashboard destination.
- **Scripts and CI:** no legacy API consumer found. Flutter CI injects a base
  URL ending in `/api/v1`.
- **Documentation:** `SERVICE_API.md` and older refactor reports contain legacy
  examples. These are references, not runtime consumers, but must be annotated
  or removed with the aliases.
- **External integrations:** Stripe is the only identified possible external
  consumer. No evidence was found for other integrations.

## Removal gates

1. Migrate active Flutter calls and legacy endpoint tests.
2. Add canonical contract coverage for lesson progress.
3. Observe staging access logs for at least 14 consecutive days with zero
   legacy traffic, excluding explicit compatibility probes.
4. Verify the Stripe Dashboard URL and deliver a signed sandbox event to the
   canonical webhook.
5. Remove aliases only in a separate approved B2 lot, then run the complete
   backend and Flutter regression gates.
