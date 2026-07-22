# Remaining Technical Debt

## 1. Authentication Integration
- **Direct Supabase Auth usage:** The frontend connects directly to Supabase Auth. While standard, this diverges from having a fully custom endpoint router in FastAPI for `/auth/...` as detailed in `SERVICE_API.md`. If required by enterprise compliance, the backend should serve as a reverse proxy/session manager, but direct Supabase Auth integration is preferred for zero-latency operations.

## 2. Telemetry and Sentry Integration
- The sync engine logs telemetries locally in SQLite and pushes them to FastAPI. Production environments require Sentry reporting integration to watch for synchronization failures.

## 3. Advanced DRM/DRM-Ready HLS
- Memory decryption of HLS files is simulated on Android. True DRM implementation (Widevine/FairPlay) should be configured when publishing to Apple/Google stores.
