# syntax=docker/dockerfile:1.7

ARG PYTHON_VERSION=3.13.14

FROM python:${PYTHON_VERSION}-slim-bookworm AS dependencies

ENV PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PIP_NO_CACHE_DIR=1

WORKDIR /build

COPY src/workers/video_worker/requirements.txt ./requirements.txt
RUN python -m venv /opt/venv \
    && /opt/venv/bin/pip install --upgrade pip setuptools wheel \
    && /opt/venv/bin/pip install --requirement requirements.txt

FROM python:${PYTHON_VERSION}-slim-bookworm AS runtime

ENV PATH="/opt/venv/bin:${PATH}" \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PYTHONFAULTHANDLER=1 \
    VIDEO_WORKER_TEMP_DIR=/tmp/lawrence-video-worker/jobs \
    VIDEO_WORKER_HEARTBEAT_FILE=/tmp/lawrence-video-worker/heartbeat \
    VIDEO_JOB_POLL_INTERVAL_SECONDS=1 \
    VIDEO_FFMPEG_PRESET=veryfast \
    VIDEO_AI_ENRICHMENT_ENABLED=false

RUN apt-get update \
    && apt-get install --yes --no-install-recommends ffmpeg \
    && rm -rf /var/lib/apt/lists/* \
    && groupadd --gid 10002 worker \
    && useradd --uid 10002 --gid worker --create-home --shell /usr/sbin/nologin worker

WORKDIR /app

COPY --from=dependencies /opt/venv /opt/venv
COPY --chown=worker:worker src /app/src

# A imagem de produção prioriza compressão eficiente. Mantemos a configuração
# depois das dependências do sistema para mudanças de qualidade não invalidarem
# a camada pesada do FFmpeg no cache do Docker.
ENV VIDEO_FFMPEG_PRESET=slow

USER worker

HEALTHCHECK --interval=30s --timeout=5s --start-period=20s --retries=3 \
    CMD ["python", "-m", "src.workers.video_worker.healthcheck"]

CMD ["python", "-m", "src.workers.video_worker.worker"]
