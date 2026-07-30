FROM python:3.11-slim

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

RUN apt-get update && apt-get install -y --no-install-recommends \
    ffmpeg \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY src/workers/video_worker/requirements.txt /app/requirements.txt
RUN pip install --no-cache-dir --requirement /app/requirements.txt

COPY src /app/src

RUN addgroup --system worker \
    && adduser --system --ingroup worker worker \
    && mkdir -p /tmp/lawrence-video-worker \
    && chown -R worker:worker /tmp/lawrence-video-worker

USER worker

ENV VIDEO_WORKER_TEMP_DIR=/tmp/lawrence-video-worker/jobs
ENV VIDEO_WORKER_HEARTBEAT_FILE=/tmp/lawrence-video-worker/heartbeat
ENV VIDEO_JOB_POLL_INTERVAL_SECONDS=1
ENV VIDEO_UPLOAD_CONCURRENCY=4
ENV VIDEO_FFMPEG_PRESET=veryfast
ENV VIDEO_AI_ENRICHMENT_ENABLED=false

HEALTHCHECK --interval=30s --timeout=5s --start-period=20s --retries=3 \
    CMD ["python", "-m", "src.workers.video_worker.healthcheck"]

CMD ["python", "-m", "src.workers.video_worker.worker"]
