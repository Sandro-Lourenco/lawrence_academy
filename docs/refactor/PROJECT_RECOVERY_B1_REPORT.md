# Project Recovery - B1 Automated Quality Gates

**Date:** 2026-07-12  
**Status:** `LOCAL_GATES_PASS_AWAITING_REMOTE_RUN`

## Delivered automation

### Backend CI

- Python 3.13 with dependency caching.
- Ruff baseline for syntax, undefined names, unused imports, and core style errors.
- Mypy validation.
- Python bytecode compilation.
- Pytest with JUnit artifact retention.
- Non-publishing API container build with BuildKit cache.

### Flutter CI

- Flutter 3.44.0 / Dart 3.12.0, matching the validated local toolchain.
- Locked dependency resolution.
- Static analysis and widget/unit/provider tests.
- Web release smoke build with non-production configuration.
- Android App Bundle release smoke build with non-production configuration.
- No production credential is used or published by these jobs.

### Database CI

- Supabase CLI 2.84.2 on an isolated Docker stack.
- Database rebuild exclusively from migrations.
- Database lint.
- Direct execution of integration and RBAC/RLS SQL tests with `ON_ERROR_STOP`.
- Guaranteed stack shutdown through an `always()` cleanup step.

### Security CI

- Full-history Gitleaks scan.
- Python dependency audit.
- CodeQL analysis for Python.
- Weekly scheduled security execution.
- Minimal workflow token permissions.

### Dependency maintenance

Dependabot is configured for Python, Dart/Flutter, GitHub Actions, and Docker.

## Supporting changes

- Added pinned backend quality dependencies.
- Added a conservative Ruff baseline; broad modernization rules remain B2 scope.
- Added `.dockerignore`, reducing the observed build context from about 188 MB to
  10.75 KB.
- Added an explicit empty Supabase seed file; environment-scoped demo data must be
  loaded deliberately.
- Replaced obsolete Supabase `[local_smtp]` configuration with `[inbucket]`.
- Corrected invalid UUID fixtures in the RBAC/RLS SQL test.
- Corrected the initial migration so it no longer drops a trigger on a table that does
  not exist during a clean bootstrap.
- Upgraded pytest from 8.4.2 to 9.0.3 after the dependency audit reported
  `PYSEC-2026-1845`.

## Local evidence

| Gate | Result |
|---|---|
| Workflow/dependabot YAML parse | 5 files valid |
| Ruff | Passed |
| Mypy 2.1.0 | 93 source files passed |
| Pytest 9.0.3 | 93 passed, 3 warnings |
| Pip audit | No known vulnerabilities |
| Flutter analyze | No issues found |
| Flutter tests | 30 passed |
| Flutter web release smoke build | Passed |
| API Docker image build | Passed |
| Docker build context | 10.75 KB |
| Flutter App Bundle release build | Local toolchain failure while stripping native debug symbols |
| Supabase clean reset | Passed from the complete migration history |
| Supabase database lint | Passed: no schema errors in `public` or `private` |
| SQL/RLS suites | Passed: 3 files, including security-definer regression coverage |

## Open gates

1. Run all workflows from a clean GitHub checkout and record immutable run URLs.
2. Confirm the Android App Bundle job passes on the GitHub Linux runner. The local
   Windows toolchain reached Gradle but failed during native symbol stripping.
3. Configure branch protection to require backend, Flutter, database, and security
   checks before merge.
4. Address the existing global Dart formatting backlog during B2 without mixing it
   into functional changes.

## Database rerun evidence

The local Supabase stack was rebuilt on 2026-07-12 with CLI 2.84.2. The clean
bootstrap exposed and corrected two compatibility defects before passing:

- the video pipeline now evolves the pre-existing `video_processing_jobs` table
  and enum before creating indexes or using new states;
- the certificate migration now evolves and backfills the legacy certificate
  contract before enforcing the canonical fields and indexes.

The security hardening migration was included in the clean reset. It moves public
profile projection behind a fixed-search-path function in the non-exposed `private`
schema, uses a `security_invoker` view, scopes role helpers to the current JWT subject,
and removes direct API execution from trigger-only functions.

## Decision

**Automation implementation:** `PASS`  
**Local backend/security gates:** `PASS`  
**Local Flutter analysis/tests/web:** `PASS`  
**Database gate:** `PASS_LOCAL`  
**Remote clean-checkout evidence:** `PENDING_REMOTE`  
**B1 overall:** `LOCAL_PASS_AWAITING_REMOTE_EVIDENCE`

Production remains blocked.
