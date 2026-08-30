# syntax=docker/dockerfile:1.7

ARG PYTHON_VERSION=3.13.14

FROM python:${PYTHON_VERSION}-slim-bookworm AS dependencies

ENV PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PIP_NO_CACHE_DIR=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /build

COPY requirements.txt ./
RUN python -m venv /opt/venv \
    && /opt/venv/bin/pip install --upgrade pip setuptools wheel \
    && /opt/venv/bin/pip install --requirement requirements.txt

FROM python:${PYTHON_VERSION}-slim-bookworm AS runtime

ENV PATH="/opt/venv/bin:${PATH}" \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PYTHONFAULTHANDLER=1 \
    APP_ENV=development

WORKDIR /app

RUN groupadd --gid 10001 lawrence \
    && useradd --uid 10001 --gid lawrence --create-home --shell /usr/sbin/nologin lawrence

COPY --from=dependencies /opt/venv /opt/venv
COPY --chown=lawrence:lawrence . .

USER lawrence

EXPOSE 8000

HEALTHCHECK --interval=30s --timeout=5s --start-period=15s --retries=3 \
    CMD ["python", "-c", "import urllib.request; urllib.request.urlopen('http://127.0.0.1:8000/live', timeout=3)"]

CMD ["uvicorn", "src.main:app", "--host", "0.0.0.0", "--port", "8000", "--workers", "2", "--limit-concurrency", "200", "--timeout-keep-alive", "10", "--no-server-header"]
