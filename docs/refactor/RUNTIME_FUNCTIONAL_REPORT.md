# Runtime Functional Report

**Date:** 2026-07-13  
**Status:** PARTIAL_BLOCKED

## Executed Evidence

- Backend contract/runtime tests: 130 passed.
- Flutter provider/widget/unit tests: 41 passed.
- OpenAPI generation and duplicate checks passed.
- Supabase reset, migrations, seed, lint, SQL and RLS suites passed.
- APK, App Bundle and Web release builds passed.
- Subscription cancellation and checkout status are wired end to end at the
  HTTP datasource and provider refresh boundaries.

## Real-flow Matrix

| Flow | Result | Evidence / blocker |
|---|---|---|
| Login, logout, registration | Not executed live | Local seed intentionally contains no test account |
| Dashboard, courses, player | Not executed live | No environment-scoped catalog/student fixtures |
| Profile and password | Needs changes | Password-reset use case remains a stub |
| Lives | Needs changes | Provider contains static demo events and room navigation is TODO |
| Downloads/offline | Needs changes | Download cancellation and real sync status are TODO |
| Certificates | Needs changes | PDF download and share buttons have no action |
| Subscriptions cancellation | Automated pass | Canonical API, ownership and refresh tests passed |
| Payment checkout | Needs changes | Course UI still supplies `price_placeholder`; no canonical per-course Stripe price source exists |
| Checkout polling | Automated pass | Canonical status path and six-state API coverage passed |
| Invoices | Automated backend coverage | Live Stripe credentials unavailable |
| DRM/download license | Automated backend coverage only | Physical-device flow unavailable |

## Placeholder Audit

The production tree still contains functional TODOs in lives, offline sync and
downloads, certificates, password reset, calendar rendering, and the course
checkout price. Resolving the Stripe price requires an approved source of truth
such as a course price mapping; inventing that schema or changing the existing
checkout contract is outside the B2.25 code freeze.

No claim of full runtime validation is made. This report blocks B2 approval.

