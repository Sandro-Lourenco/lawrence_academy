# Project Recovery - B2 Architecture Canonicalization

**Date:** 2026-07-12  
**Status:** `IN_PROGRESS_BACKEND_V1_BOUNDARIES_ESTABLISHED`

## Completed

- Added explicit repository providers for profiles, courses, assessments,
  subscriptions, payments, certificates, and teacher course operations.
- Removed direct Supabase client/repository construction from the migrated v1
  route modules.
- Added domain protocols for certificates and video upload storage.
- Moved certificate listing behind `CertificateRepository`.
- Made `/api/v1/certificates` canonical while retaining `/certificates` as an
  explicitly deprecated compatibility alias.
- Added architecture tests for infrastructure imports, duplicate HTTP
  method/path registrations, and duplicate OpenAPI operation IDs.
- Migrated the active profile and teacher pages away from root-level Flutter
  `presentation` and `ui` imports.
- Moved `LiquidTheme` into the canonical design-system tokens and retained the
  legacy theme file as an export-only compatibility shim.
- Normalized the active course repository to explicit `/api/v1/courses`
  endpoints instead of relying on implicit base-URL composition.
- Added a Flutter architecture test that rejects imports from root-level
  `presentation`, `ui`, or `data` inside canonical `app` and `features` trees.
- Registered the previously disconnected `/api/v1/invoices` router.
- Marked every non-v1 business router as deprecated in the generated OpenAPI.
- Added an architecture test that rejects non-v1 business operations unless
  they are explicit deprecated aliases.
- Moved Stripe invoice calls out of the router into an `InvoiceGateway`, with
  production and fake adapters plus application use cases.
- Added invoice ownership tests so another customer's invoice is rejected.
- Moved learning repository providers out of concrete data repositories into
  `app/providers/learning_repositories.dart`, the Flutter composition root.
- Removed presentation-to-data imports from courses, lessons, lesson progress,
  dashboard, and player.
- Normalized active lesson and stream requests to explicit `/api/v1/courses`
  endpoints.
- Added an architecture test that prevents the migrated learning presentation
  layers from importing `data` directly.
- Centralized auth, certificate, invoice, and teacher-studio infrastructure
  providers in `app/providers/service_repositories.dart`.
- Removed Riverpod composition from auth and teacher-studio data/domain layers.
- Added the missing certificate repository contract and concrete adapter, so
  certificate presentation no longer calls the remote data source directly.
- Removed direct data imports from auth, certificates, invoices, and
  teacher-studio presentation, and from the teacher-studio domain layer.
- Expanded the Flutter architecture gate to cover all newly migrated feature
  layers while preserving repository overrides used by controller tests.
- Added `LEGACY_API_CONSUMER_INVENTORY.md` with runtime consumers, canonical
  destinations, compatibility reasons, explicit expiry dates, and removal
  gates for every registered legacy API family.
- Added `FLUTTER_LEGACY_MIGRATION_MAP.md` covering the root `presentation`,
  `ui`, `data`, and `core/router.dart` trees, including active imports and the
  local-change snapshot summary.
- Moved the sync queue repository contract from `data` to `domain`, kept the
  existing adapter behavior, and composed it from the app provider root.
- Added sync queue transition coverage and extended the architecture gate to
  reject sync application/domain imports from `data`.
- Moved subscriptions datasource, repository, and use-case providers to the
  app composition root. The former feature provider file is now an export-only
  compatibility facade with no concrete `data` dependency.
- Expanded the Flutter architecture gate to protect subscriptions layers and
  feature-level provider facades from composing infrastructure adapters.
- Added the canonical Flutter profile entity, repository contract, use case,
  and HTTP adapter for `GET /api/v1/profiles/me`.
- Migrated the active dashboard away from direct `NetworkClient` access and
  the legacy `/students/me` endpoint while preserving its offline fallback.
- Added an architecture gate preventing migrated dashboard/profile
  presentation layers from importing the network layer directly.
- Established `lesson_progress` as the canonical state table and `event_store`
  as its append-only idempotency and multi-device audit log.
- Added an additive Supabase migration with cleanup, constraints, explicit RLS
  policies/grants, indexes, and a transaction-safe monotonic merge RPC.
- Replaced obsolete backend progress mappings with canonical entities, DTOs,
  repository protocols, injected adapters, and v1 read/write/batch use cases.
- Migrated Flutter from `/students/me/progress` to the canonical v1 progress
  read, update, and batch-sync contracts while preserving SQLite retry state.
- Added SQL, backend, API authorization, and Flutter contract coverage for
  replay, out-of-order events, multi-device conflicts, monotonic progress, and
  irreversible completion.

## Evidence

| Gate | Result |
|---|---|
| Ruff | Passed |
| Mypy | 107 source files passed |
| Pytest | 108 passed |
| OpenAPI operation IDs | No duplicates |
| Registered method/path pairs | No duplicates |
| Migrated v1 route infrastructure imports | None |
| Flutter analyze | No issues found |
| Flutter tests | 39 passed |
| Flutter APK release | Passed, 57,891,679 bytes |
| Flutter web build | Passed, 39 output files |
| Canonical Flutter imports from legacy roots | None |
| Migrated Flutter presentation/domain imports from data | None |
| Direct concrete `data` imports inside canonical `features` | None |
| Supabase reset | Passed with all migrations |
| Supabase db lint | No schema errors |
| Lesson progress SQL suite | Passed |
| Security-definer SQL suite | Passed |
| All SQL/RLS suites | 5 suites passed |
| OpenAPI B2.24 contract | 54 operations; PATCH progress; no duplicates |

## Remaining B2 Work

1. Keep non-v1 router registration until compatibility tests migrate and the
   documented staging access-log windows close.
2. Validate the Stripe Dashboard target and deliver one signed sandbox event to
   `/api/v1/payments/webhook`; the legacy alias remains until this succeeds.
3. Define an approved backend contract for subscription cancellation and checkout
   status. Active Flutter workflows currently call paths for which no backend
   route exists, and B2.24 prohibits creating new functionality.
4. Migrate legacy backend tests and observe the documented access-log windows
   before removing non-v1 router registrations.

## Decision

Progress hardening, database permissions, snapshot preservation, and authorized
Flutter removal lots are accepted. Final B2.24 status is `B2_NEEDS_CHANGES`;
B3 must not start while external Stripe validation and missing subscription
contracts remain.
