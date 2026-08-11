"""Docker liveness probe for the long-running video worker."""

from __future__ import annotations

import os
import socket
import sys
import time
from pathlib import Path
from urllib.parse import urlparse

HEARTBEAT_FILE = Path(
    os.getenv(
        "VIDEO_WORKER_HEARTBEAT_FILE",
        "/tmp/lawrence-video-worker/heartbeat",
    )
)
MAX_HEARTBEAT_AGE_SECONDS = int(
    os.getenv("VIDEO_WORKER_HEARTBEAT_MAX_AGE_SECONDS", "45")
)
CLOCK_SKEW_TOLERANCE_SECONDS = 5


def is_worker_alive(now: float | None = None) -> bool:
    try:
        heartbeat_age = (now or time.time()) - HEARTBEAT_FILE.stat().st_mtime
    except OSError:
        return False
    # Filesystems and container hosts can differ by a few milliseconds. A
    # bounded future timestamp must not make a healthy worker flap, while a
    # materially future or stale heartbeat still fails closed.
    return (
        -CLOCK_SKEW_TOLERANCE_SECONDS
        <= heartbeat_age
        <= MAX_HEARTBEAT_AGE_SECONDS
    )


def can_resolve_supabase() -> bool:
    hostname = urlparse(os.getenv("SUPABASE_URL", "")).hostname
    if not hostname:
        return False
    try:
        socket.getaddrinfo(hostname, 443)
        return True
    except socket.gaierror:
        return False


def main() -> int:
    return 0 if is_worker_alive() and can_resolve_supabase() else 1


if __name__ == "__main__":
    sys.exit(main())
