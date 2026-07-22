# API Endpoint Matrix

This matrix represents the registered routes in FastAPI and their parameters.

| Method | Endpoint | Module | Auth Required | Role Authorized | Status |
| --- | --- | --- | --- | --- | --- |
| GET | `/` | root | No | Public | Active |
| GET | `/health` | root | No | Public | Active |
| GET | `/api/v1/profiles/me` | profiles | Yes | Authenticated | Active |
| PATCH | `/api/v1/profiles/me` | profiles | Yes | Authenticated | Active |
| GET | `/api/v1/courses` | courses | No | Public | Active |
| GET | `/api/v1/courses/{id}` | courses | No | Public | Active |
| POST | `/api/v1/teacher/courses` | courses | Yes | Teacher, Admin | Active |
| PATCH | `/api/v1/teacher/courses/{id}` | courses | Yes | Teacher, Admin | Active |
| DELETE | `/api/v1/teacher/courses/{id}` | courses | Yes | Teacher, Admin | Active |
| POST | `/api/v1/payments/checkout` | payments | Yes | Student | Active |
| GET | `/api/v1/payments/checkout/status/{checkout_id}`| payments | Yes | Student | Active |
| POST | `/api/v1/payments/webhook` | payments | No | Stripe (HMAC) | Active |
| GET | `/api/v1/subscriptions/me` | subscriptions | Yes | Student | Active |
| GET | `/api/v1/subscriptions/eligibility/{course_id}` | subscriptions | Yes | Student | Active |
| PATCH | `/api/v1/subscriptions/{subscription_id}/cancel`| subscriptions | Yes | Student | Active |
| POST | `/api/v1/sync` | sync | Yes | Student | Active |
| GET | `/api/v1/sync/progress` | sync | Yes | Student | Active |
| POST | `/api/v1/certificates/generate` | certificates | Yes | Student | Active |
| GET | `/api/v1/certificates/{code}/verify` | certificates | No | Public | Active |
| GET | `/api/v1/invoices` | invoices | Yes | Student | Active |
