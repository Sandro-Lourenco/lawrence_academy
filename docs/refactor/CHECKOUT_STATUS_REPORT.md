# Checkout Status Report

**Date:** 2026-07-13  
**Status:** IMPLEMENTED_AND_TESTED

## Contract

`GET /api/v1/payments/checkout/status/{checkout_id}`

Response fields:

- `status`
- `payment_status`
- `subscription_status`
- `created_at`
- `updated_at`
- `checkout_url`

`updated_at` is the instant at which the external state was observed because a
Stripe Checkout Session does not expose a general update timestamp.

## State Mapping

| Canonical | Stripe evidence |
|---|---|
| `pending` | session is open |
| `processing` | session completed but payment/subscription is not terminal |
| `paid` | session complete and payment paid or no payment required |
| `expired` | session expired |
| `failed` | subscription incomplete and expired |
| `cancelled` | subscription canceled/cancelled |

The gateway retrieves the session with the subscription expanded. Ownership is
resolved from `client_reference_id`, with `metadata.user_id` as the compatible
fallback, and is checked by the use case against the authenticated user.

## Evidence

- API tests passed for all six canonical states.
- Missing checkout returns HTTP 404.
- Checkout belonging to another user returns HTTP 403.
- Stripe-to-canonical mapping tests passed for all states.
- Flutter uses only the v1 route and accepts `cancelled` and `failed` as
  terminal states.
- OpenAPI: 45 paths, 56 operations, no duplicate operation IDs.

