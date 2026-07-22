# Project Recovery - B0 Incident Containment Report

**Date:** 2026-07-12  
**Status:** `COMPLETE`

## Scope completed

- Removed hardcoded provider credentials from `backend/docker-compose.yml`.
- Removed hardcoded Supabase configuration from Flutter runtime sources.
- Added build-time Flutter configuration through `--dart-define`.
- Added strict backend production validation for required settings, HTTPS, and CORS.
- Removed the insecure service-role-to-anon-key fallback.
- Added explicit isolated test environment configuration.
- Changed the API container to run as an unprivileged user.
- Removed request/response headers, bodies, tokens, emails, and detailed auth errors
  from Flutter diagnostics.
- Added regression tests for production configuration and repository secret hygiene.
- Marked prior production, security, and Go-Live approvals as superseded.
- Changed official project status to `RECOVERY_IN_PROGRESS / PRODUCTION_BLOCKED`.

## Executable evidence

| Check | Result |
|---|---|
| Backend tests | 93 passed, 4 non-blocking warnings |
| Backend typing | `mypy`: 93 source files passed |
| Backend compilation | `compileall`: passed |
| Flutter analysis | No issues found |
| Flutter tests | 30 passed |
| Current worktree credential-pattern scan | No matches |
| Sensitive logging-pattern scan | No matches |

Flutter tests used explicit non-production values:

```text
ENV=dev
SUPABASE_URL=https://mock.supabase.co
SUPABASE_ANON_KEY=mock-anon-key
API_BASE_URL=http://localhost:8000/api/v1
```

No production credential was used by the validation.

## External incident actions

The credentials previously committed must still be considered compromised even though
they no longer exist in the current worktree.

Completed or confirmed by the project owner:

1. Rotate the Supabase service-role credential.
2. Rotate Stripe secret and webhook signing credentials.
3. Rotate AI provider credentials that were present in the compose file.
4. Review provider audit logs for unauthorized use.
5. Confirm deployment environments use only the rotated values.
6. Approved and performed a controlled Git history rewrite.
7. Re-scanned the rewritten repository with zero credential-pattern matches.

Credential values and rotation evidence must never be committed to this repository.
Record only provider-side timestamps, credential identifiers, and responsible owner.

## Gate decision

**Local containment:** `PASS`  
**Credential rotation:** `CONFIRMED_BY_PROJECT_OWNER`  
**Git history cleanup:** `PASS`  
**B0 overall:** `PASS`

Production remains blocked by the later recovery batches even though B0 is complete.
