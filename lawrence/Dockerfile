# Stage 1: Build the Flutter Web app
FROM ubuntu:22.04 AS build

# Install dependencies for Flutter
RUN apt-get update && apt-get install -y bash curl git unzip xz-utils zip libglu1-mesa

# Download Flutter (targeting stable to match environment)
RUN git clone -b stable https://github.com/flutter/flutter.git /usr/local/flutter

# Add flutter to PATH
ENV PATH="/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin:${PATH}"

# Optionally run doctor to initialize flutter
RUN flutter doctor -v

# Enable web support
RUN flutter config --enable-web

WORKDIR /app

# Cache dependency resolution independently from application source changes.
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

# Copy the rest of the application code
COPY . .

# Argument for dart defines (e.g. API keys, base URLs)
ARG DART_DEFINES=""

# Build the web application using standard shell to evaluate DART_DEFINES properly
RUN bash -c 'test -n "$DART_DEFINES" \
    && case "$DART_DEFINES" in *trycloudflare.com*) exit 1;; esac \
    && case "$DART_DEFINES" in *API_BASE_URL=http://localhost*|*API_BASE_URL=http://127.0.0.1*) \
         case "$DART_DEFINES" in *ENV=prod*|*ENV=production*) exit 1;; esac;; esac \
    && flutter build web --release --no-wasm-dry-run $DART_DEFINES \
    && cp web/stale_service_worker_cleanup.js build/web/flutter_service_worker.js'

# Stage 2: Serve the app with Nginx
FROM nginx:alpine

# Copy the built web files to Nginx's default directory
COPY --from=build /app/build/web /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf

HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
    CMD ["wget", "--quiet", "--tries=1", "--spider", "http://localhost/health"]

# Expose port 80
EXPOSE 80

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]
