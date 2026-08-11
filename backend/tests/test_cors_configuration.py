from unittest.mock import MagicMock, patch

from fastapi.testclient import TestClient

from src.main import DEVELOPMENT_ORIGINS, app, resolve_cors_origins


def test_development_cors_supports_docker_frontend_port() -> None:
    origins = resolve_cors_origins(["*"], "development")
    assert "http://localhost:8080" in origins
    assert "http://localhost:18080" in origins


def test_explicit_cors_origins_are_preserved() -> None:
    configured = ["https://app.lawrence.example"]
    assert resolve_cors_origins(configured, "production") == configured


def test_production_never_falls_back_to_wildcard() -> None:
    assert resolve_cors_origins(["*"], "production") == []
    assert "http://localhost:8080" in DEVELOPMENT_ORIGINS


def test_readiness_fails_when_supabase_is_unreachable() -> None:
    with patch("src.main.urlopen", side_effect=OSError("dns unavailable")):
        response = TestClient(app).get("/ready")

    assert response.status_code == 503


def test_readiness_passes_when_supabase_auth_is_available() -> None:
    upstream = MagicMock()
    upstream.__enter__.return_value.status = 200
    with patch("src.main.urlopen", return_value=upstream):
        response = TestClient(app).get("/ready")

    assert response.status_code == 200
    assert response.json() == {"status": "ready"}
