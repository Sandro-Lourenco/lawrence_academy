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

## Evidence

| Gate | Result |
|---|---|
| Ruff | Passed |
| Mypy | 104 source files passed |
| Pytest | 100 passed |
| OpenAPI operation IDs | No duplicates |
| Registered method/path pairs | No duplicates |
| Migrated v1 route infrastructure imports | None |
| Flutter analyze | No issues found |
| Flutter tests | 33 passed |
| Canonical Flutter imports from legacy roots | None |
| Migrated Flutter presentation/domain imports from data | None |

## Remaining B2 Work

1. Inventory consumers of legacy backend routers and define expiry dates for
   the compatibility aliases.
2. Remove non-v1 router registration from `main.py` only after consumer and
   contract tests prove it is safe.
3. Remove the now-unreferenced Flutter legacy trees only after reviewing the
   pre-existing local changes in those files and capturing an approved snapshot.
4. Inventory remaining feature presentation/application imports of concrete
   Flutter data implementations and migrate them in bounded lots.
5. Run backend and Flutter regression gates after each removal lot.
6. Migrate `subscriptions/subscriptions_providers.dart`, the only remaining
   direct `features` import of concrete `data` found after the sync lot.
7. Define and migrate the canonical lesson-progress endpoint before removing
   `/students/me/progress` compatibility.
8. Capture the full binary Flutter legacy patch immediately before any approved
   deletion; the current map records 29 changed tracked files and is not a
   deletion authorization.

## Decision

Backend v1 dependency boundaries for this lot are accepted. B2 remains in
progress; B3 must not be marked started until the remaining router and Flutter
canonicalization gates pass.
