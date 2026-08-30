from decimal import Decimal
from types import SimpleNamespace
from unittest.mock import AsyncMock
from urllib.parse import urlsplit

from fastapi import FastAPI
from fastapi.testclient import TestClient

from src.core.errors.handlers import install_error_handlers
from src.core.security.security import CurrentUser, get_current_user
from src.modules.courses.interface.api.dependencies import get_course_repository
from src.modules.courses.interface.api.routes import router
from src.modules.courses.domain.entities import Lesson


def _client(repository: AsyncMock) -> TestClient:
    app = FastAPI()
    app.include_router(router)
    install_error_handlers(app)
    app.dependency_overrides[get_current_user] = lambda: CurrentUser(
        id="student-1",
        email="student@example.com",
        role="student",
    )
    app.dependency_overrides[get_course_repository] = lambda: repository
    return TestClient(app)


def test_student_hls_proxy_rewrites_every_private_asset_url(monkeypatch):
    monkeypatch.setenv("APP_ENV", "test")
    repository = AsyncMock()
    repository.get_published_by_id.return_value = SimpleNamespace(
        monthly_price=Decimal("0"),
    )
    repository.get_published_lesson_stream_path.return_value = (
        "lessons/lesson-1/job-1/hls/master.m3u8"
    )
    repository.download_hls_asset.return_value = (
        b'#EXTM3U\n#EXT-X-KEY:METHOD=AES-128,URI="key.bin"\n480p/index.m3u8\n'
    )
    client = _client(repository)

    stream = client.get("/api/v1/courses/course-1/lessons/lesson-1/stream")

    assert stream.status_code == 200
    playback_url = stream.json()["signedUrl"]
    assert playback_url.startswith("/api/v1/")
    assert not playback_url.startswith("http://")
    parsed = urlsplit(playback_url)
    manifest = client.get(f"{parsed.path}?{parsed.query}")
    assert manifest.status_code == 200
    assert "480p/index.m3u8?token=" in manifest.text
    assert 'URI="key.bin?token=' in manifest.text
    repository.generate_signed_url.assert_not_awaited()
    repository.download_hls_asset.assert_awaited_once_with("lessons/lesson-1/job-1/hls/master.m3u8")


def test_playback_url_does_not_trust_internal_proxy_origin(monkeypatch):
    monkeypatch.setenv("APP_ENV", "test")
    repository = AsyncMock()
    repository.get_published_by_id.return_value = SimpleNamespace(
        monthly_price=Decimal("0"),
    )
    repository.get_published_lesson_stream_path.return_value = (
        "lessons/lesson-1/job-1/hls/master.m3u8"
    )
    client = _client(repository)

    response = client.get(
        "/api/v1/courses/course-1/lessons/lesson-1/stream",
        headers={"host": "backend.internal:8000", "x-forwarded-proto": "http"},
    )

    assert response.status_code == 200
    assert response.json()["signedUrl"].startswith(
        "/api/v1/courses/course-1/lessons/lesson-1/hls/master.m3u8?token="
    )


def test_external_video_url_is_returned_after_authenticated_access_check(monkeypatch):
    monkeypatch.setenv("APP_ENV", "test")
    repository = AsyncMock()
    repository.get_published_by_id.return_value = SimpleNamespace(
        monthly_price=Decimal("0"),
    )
    repository.get_published_lesson.return_value = Lesson(
        id="lesson-1",
        module_id="module-1",
        course_id="course-1",
        title="Aula externa",
        hls_storage_path=None,
        video_source_type="vimeo",
        external_video_id="123456789",
    )
    client = _client(repository)

    response = client.get("/api/v1/courses/course-1/lessons/lesson-1/stream")

    assert response.status_code == 200
    assert response.json() == {
        "sourceType": "external",
        "provider": "vimeo",
        "url": "https://vimeo.com/123456789",
    }
    repository.generate_signed_url.assert_not_awaited()


def test_student_hls_proxy_rejects_token_for_another_lesson(monkeypatch):
    monkeypatch.setenv("APP_ENV", "test")
    repository = AsyncMock()
    repository.get_published_by_id.return_value = SimpleNamespace(
        monthly_price=Decimal("0"),
    )
    repository.get_published_lesson_stream_path.return_value = (
        "lessons/lesson-1/job-1/hls/master.m3u8"
    )
    client = _client(repository)
    playback_url = client.get("/api/v1/courses/course-1/lessons/lesson-1/stream").json()[
        "signedUrl"
    ]
    token = urlsplit(playback_url).query

    response = client.get(f"/api/v1/courses/course-1/lessons/lesson-2/hls/master.m3u8?{token}")

    assert response.status_code == 401
    repository.download_hls_asset.assert_not_awaited()


def test_student_hls_proxy_rejects_unknown_asset_type(monkeypatch):
    monkeypatch.setenv("APP_ENV", "test")
    repository = AsyncMock()
    repository.get_published_by_id.return_value = SimpleNamespace(
        monthly_price=Decimal("0"),
    )
    repository.get_published_lesson_stream_path.return_value = (
        "lessons/lesson-1/job-1/hls/master.m3u8"
    )
    client = _client(repository)
    playback_url = client.get("/api/v1/courses/course-1/lessons/lesson-1/stream").json()[
        "signedUrl"
    ]
    token = urlsplit(playback_url).query

    response = client.get(f"/api/v1/courses/course-1/lessons/lesson-1/hls/raw.mp4?{token}")

    assert response.status_code == 404
    repository.download_hls_asset.assert_not_awaited()


def test_hls_segments_redirect_to_storage_instead_of_crossing_api(monkeypatch):
    monkeypatch.setenv("APP_ENV", "test")
    repository = AsyncMock()
    repository.get_published_by_id.return_value = SimpleNamespace(
        monthly_price=Decimal("0"),
    )
    repository.get_published_lesson_stream_path.return_value = (
        "lessons/lesson-1/job-1/hls/master.m3u8"
    )
    repository.generate_signed_url.return_value = "https://storage.example/segment.ts?signed=1"
    client = _client(repository)
    playback_url = client.get("/api/v1/courses/course-1/lessons/lesson-1/stream").json()[
        "signedUrl"
    ]
    token = urlsplit(playback_url).query

    response = client.get(
        f"/api/v1/courses/course-1/lessons/lesson-1/hls/480p/segment.ts?{token}",
        follow_redirects=False,
    )

    assert response.status_code == 307
    assert response.headers["location"].startswith("https://storage.example/")
    repository.generate_signed_url.assert_awaited_once_with(
        "lessons/lesson-1/job-1/hls/480p/segment.ts"
    )
    repository.download_hls_asset.assert_not_awaited()
