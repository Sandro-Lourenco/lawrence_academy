# syntax=docker/dockerfile:1.7

FROM debian:bookworm-slim AS build

ARG FLUTTER_VERSION=3.44.9
ARG FLUTTER_SHA256=a9120fa4a01048bdef438ddc3a2d4b7389662ea98a95db86eeaf10382bc4efcb
ARG BUILD_ENV=development
ARG API_BASE_URL=http://localhost:8000
ARG PUBLIC_WEB_URL=http://localhost:18080
ARG SUPABASE_URL=
ARG SUPABASE_ANON_KEY=

ENV PATH="/opt/flutter/bin:/opt/flutter/bin/cache/dart-sdk/bin:${PATH}" \
    PUB_CACHE=/opt/pub-cache \
    CI=true

RUN apt-get update \
    && apt-get install --yes --no-install-recommends bash ca-certificates curl git libglu1-mesa xz-utils \
    && rm -rf /var/lib/apt/lists/* \
    && curl --fail --location --retry 5 --output /tmp/flutter.tar.xz \
       "https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz" \
    && echo "${FLUTTER_SHA256}  /tmp/flutter.tar.xz" | sha256sum --check --strict \
    && tar --extract --xz --file /tmp/flutter.tar.xz --directory /opt \
    && rm /tmp/flutter.tar.xz \
    && git config --global --add safe.directory /opt/flutter \
    && flutter config --enable-web --no-analytics \
    && flutter precache --web

WORKDIR /app

COPY pubspec.yaml pubspec.lock ./
RUN --mount=type=cache,target=/opt/pub-cache flutter pub get --enforce-lockfile

COPY . .

RUN --mount=type=cache,target=/opt/pub-cache \
    --mount=type=secret,id=frontend_build_env,required=false \
    flutter pub get --enforce-lockfile \
    && CONFIG_SUPABASE_URL="${SUPABASE_URL}" \
    && CONFIG_SUPABASE_ANON_KEY="${SUPABASE_ANON_KEY}" \
    && if [ -z "${CONFIG_SUPABASE_URL}" ] && [ -f /run/secrets/frontend_build_env ]; then \
         CONFIG_SUPABASE_URL="$(grep -m1 '^SUPABASE_URL=' /run/secrets/frontend_build_env | cut -d= -f2- | tr -d '\r')"; \
       fi \
    && if [ -z "${CONFIG_SUPABASE_ANON_KEY}" ] && [ -f /run/secrets/frontend_build_env ]; then \
         CONFIG_SUPABASE_ANON_KEY="$(grep -m1 '^SUPABASE_ANON_KEY=' /run/secrets/frontend_build_env | cut -d= -f2- | tr -d '\r')"; \
       fi \
    && test -n "${CONFIG_SUPABASE_URL}" \
    && test -n "${CONFIG_SUPABASE_ANON_KEY}" \
    && case "${CONFIG_SUPABASE_URL}" in *trycloudflare.com*) exit 1;; *) true;; esac \
    && case "${BUILD_ENV}:${API_BASE_URL}" in \
         prod:http://localhost*|production:http://localhost*|prod:http://127.0.0.1*|production:http://127.0.0.1*) exit 1;; \
         *) true;; \
       esac \
    && flutter build web --release --no-wasm-dry-run \
       "--dart-define=ENV=${BUILD_ENV}" \
       "--dart-define=API_BASE_URL=${API_BASE_URL}" \
       "--dart-define=PUBLIC_WEB_URL=${PUBLIC_WEB_URL}" \
       "--dart-define=SUPABASE_URL=${CONFIG_SUPABASE_URL}" \
       "--dart-define=SUPABASE_ANON_KEY=${CONFIG_SUPABASE_ANON_KEY}" \
    && cp web/stale_service_worker_cleanup.js build/web/flutter_service_worker.js

FROM nginx:1.30.4-alpine3.24 AS runtime

COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build --chown=nginx:nginx /app/build/web /usr/share/nginx/html

RUN chown -R nginx:nginx /etc/nginx/conf.d /usr/share/nginx/html /var/cache/nginx /var/run

USER nginx

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
    CMD ["wget", "--quiet", "--tries=1", "--spider", "http://127.0.0.1:8080/health"]

ENTRYPOINT ["nginx"]
CMD ["-g", "daemon off;"]
