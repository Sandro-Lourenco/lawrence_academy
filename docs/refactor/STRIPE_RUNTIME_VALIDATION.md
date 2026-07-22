# Stripe Runtime Validation

**Date:** 2026-07-13  
**Status:** `EXTERNAL_VALIDATION_BLOCKED`

| Check | Evidence | Result |
|---|---|---|
| Canonical webhook | `POST /api/v1/payments/webhook` registered and tested | Passed locally |
| Raw signed body | Test verifies raw bytes reach Stripe signature validation | Passed locally |
| Invalid signature | Rejected by API test | Passed locally |
| Duplicate replay | Duplicate event returns success without reprocessing | Passed locally |
| Failed-event retry | Retry path covered by backend test | Passed locally |
| Processing failure | Event marked failed and external-service error returned | Passed locally |
| Sandbox secret | No `STRIPE_SECRET_KEY` or `STRIPE_WEBHOOK_SECRET` available in process, user, or machine environment | Blocked |
| Stripe CLI | Executable not installed | Blocked |
| Dashboard endpoint | Browser connection failed before the Dashboard could be inspected | Blocked |
| Signed sandbox delivery | Requires Dashboard/CLI and staging callback URL | Blocked |

The deprecated alias `POST /webhooks/stripe` must remain registered until the
Stripe Dashboard target is confirmed and a signed sandbox event succeeds on the
canonical URL. Expiration remains 2026-09-30 and is conditional on that proof.
No secret value was read or logged during this review.
