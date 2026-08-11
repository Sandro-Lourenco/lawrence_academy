import os
import time
from typing import Any

import jwt


class JwtPlaybackService:
    """Short-lived capability token for browser-compatible private HLS playback."""

    def __init__(self, secret_key: str | None = None):
        resolved_secret = secret_key or os.getenv("JWT_SECRET_KEY")
        environment = os.getenv("APP_ENV") or os.getenv("ENV") or "development"
        if not resolved_secret:
            if environment != "test":
                raise ValueError("JWT_SECRET_KEY is required for protected playback.")
            resolved_secret = "test_only_playback_secret_key_32_bytes"
        self.secret_key: str = resolved_secret

    def generate(
        self,
        *,
        user_id: str,
        course_id: str,
        lesson_id: str,
        master_path: str,
        duration_seconds: int = 300,
    ) -> str:
        now = int(time.time())
        return jwt.encode(
            {
                "iss": "lawrence-academy",
                "aud": "video-playback",
                "sub": user_id,
                "course_id": course_id,
                "lesson_id": lesson_id,
                "master_path": master_path,
                "scope": "stream_hls",
                "iat": now,
                "nbf": now,
                "exp": now + duration_seconds,
            },
            self.secret_key,
            algorithm="HS256",
        )

    def validate(
        self,
        token: str,
        *,
        course_id: str,
        lesson_id: str,
    ) -> dict[str, Any]:
        payload = jwt.decode(
            token,
            self.secret_key,
            algorithms=["HS256"],
            issuer="lawrence-academy",
            audience="video-playback",
        )
        if (
            payload.get("scope") != "stream_hls"
            or payload.get("course_id") != course_id
            or payload.get("lesson_id") != lesson_id
            or not isinstance(payload.get("master_path"), str)
        ):
            raise jwt.InvalidTokenError("Playback token scope mismatch.")
        return payload
