# Stripe Production Report

**Date:** 2026-07-13  
**Status:** EXTERNAL_VALIDATION_BLOCKED

## Local Validation

- Webhook raw-body signature tests pass.
- Invalid signatures are rejected.
- Idempotency, duplicate delivery, retry and replay tests pass.
- Subscription cancellation gateway and checkout status mapping are isolated
  behind domain contracts and covered without external calls.

## External Blocker

The current environment has no `STRIPE_SECRET_KEY`, `STRIPE_API_KEY` or
`STRIPE_WEBHOOK_SECRET`, and Stripe CLI is not installed. Consequently the
Stripe Dashboard target, signed sandbox delivery, CLI forwarding, real retry,
real replay and live subscription cancellation cannot be validated here.

`POST /webhooks/stripe` remains registered as a deprecated compatibility alias.
It must not be removed until the Dashboard points to
`POST /api/v1/payments/webhook`, a signed sandbox delivery succeeds, and the
documented access-log window closes.

