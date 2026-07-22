import jwt
import time
import uuid
import os
from typing import Dict, Any, Optional


class JwtDownloadService:
    def __init__(self, secret_key: Optional[str] = None):
        env_secret = os.environ.get("JWT_SECRET_KEY")
        self.secret_key = secret_key or env_secret
        if not self.secret_key:
            if os.environ.get("ENV", "development") != "test":
                raise ValueError(
                    "JWT_SECRET_KEY is not configured and is required for non-test environments."
                )
            self.secret_key = "test_only_secret_key"

        assert isinstance(self.secret_key, str)
        self.algorithm = "HS256"
        self.issuer = "lawrence-academy"
        self.audience = "download-manager"
        self.token_version = "1.0"

    def generate_download_token(
        self,
        user_id: str,
        course_id: str,
        lesson_id: str,
        installation_id: str,
        duration_seconds: int = 900,
    ) -> Dict[str, Any]:
        """
        Gera um JWT de curta duração para autorizar a obtenção de uma Signed URL.
        """
        iat = int(time.time())
        exp = iat + duration_seconds
        nbf = iat
        jti = str(uuid.uuid4())

        payload = {
            "iss": self.issuer,
            "aud": self.audience,
            "sub": user_id,
            "jti": jti,
            "iat": iat,
            "nbf": nbf,
            "exp": exp,
            "scope": "offline_download",
            "device_id": installation_id,
            "course_id": course_id,
            "lesson_id": lesson_id,
            "token_version": self.token_version,
        }

        assert self.secret_key is not None
        token = jwt.encode(payload, self.secret_key, algorithm=self.algorithm)

        return {"token": token, "payload": payload}

    def validate_download_token(self, token: str) -> Dict[str, Any]:
        """
        Valida o token de autorização. Lança exceções jwt.ExpiredSignatureError ou jwt.InvalidTokenError em caso de falha.
        """
        assert self.secret_key is not None
        payload = jwt.decode(
            token,
            self.secret_key,
            algorithms=[self.algorithm],
            issuer=self.issuer,
            audience=self.audience,
        )

        # Verify required claims
        required_claims = [
            "sub",
            "jti",
            "device_id",
            "course_id",
            "lesson_id",
            "scope",
            "token_version",
        ]
        for claim in required_claims:
            if claim not in payload:
                raise jwt.InvalidTokenError(f"Missing claim: {claim}")

        if payload["scope"] != "offline_download":
            raise jwt.InvalidTokenError("Invalid scope")

        return payload
