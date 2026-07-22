# B2 Final Architecture Gate

**Date:** 2026-07-13  
**Official status:** `B2_NEEDS_CHANGES`  
**B3:** `BLOCKED`  
**Production:** `BLOCKED`

## Approved evidence

| Gate | Result |
|---|---|
| Progress HTTP semantics | PATCH only |
| Server percentage calculation | Passed backend and SQL tests |
| Watched seconds validation | Reject strategy, HTTP 422 |
| Event store | TEXT justified; server-owned append-only audit |
| Database reset | Passed from all migrations |
| Database lint | No schema errors |
| SQL/RLS suites | 5 passed |
| Ruff | Passed |
| Mypy | 107 source files passed |
| Python compileall | Passed |
| Pytest | 108 passed |
| Dart format check | 185 files, 0 changes |
| Flutter analyze | No issues found |
| Flutter tests | 39 passed |
| APK release | Passed; 57,891,679 bytes |
| Web build | Passed; 39 output files |
| OpenAPI | 54 operations; no duplicate IDs or method/path pairs |
| Flutter legacy snapshot | Preserved with SHA-256 hashes |
| Removal lots A-D | Passed all required gates |
| Migrated legacy HTTP calls | No active match for students/progress/teacher/checkout creation |

## Changes still required

1. Define and authorize a v1 backend contract for subscription cancellation.
   Flutter actively calls `/subscriptions/{id}/cancel`, but the backend registers
   no corresponding route.
2. Define and authorize a v1 backend contract for checkout status. Flutter
   actively calls `/payments/checkout/status/{id}`, but the backend registers no
   corresponding route.
3. Complete Stripe Dashboard validation and one signed sandbox delivery to
   `/api/v1/payments/webhook`; keep `/webhooks/stripe` until then.
4. Migrate legacy backend contract tests and complete the documented access-log
   observation windows before removing non-v1 routers from `main.py`.

No B3 work was started. The missing contracts require a separately authorized B2
lot because B2.24 explicitly prohibited new functionality and new public REST
contracts.
