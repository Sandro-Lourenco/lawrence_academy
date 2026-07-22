import re
from pathlib import Path


REPOSITORY_ROOT = Path(__file__).resolve().parents[2]

CREDENTIAL_PATTERNS = [
    re.compile(r"eyJ[A-Za-z0-9_-]{20,}\.[A-Za-z0-9_-]{20,}\.[A-Za-z0-9_-]{20,}"),
    re.compile(r"sk_(?:live|test|proj)_[A-Za-z0-9_-]{16,}"),
    re.compile(r"whsec_[A-Za-z0-9_-]{16,}"),
]


def test_runtime_configuration_files_do_not_contain_credentials() -> None:
    paths = [
        REPOSITORY_ROOT / "backend" / "docker-compose.yml",
        REPOSITORY_ROOT / "lawrence" / "lib" / "main.dart",
        REPOSITORY_ROOT
        / "lawrence"
        / "lib"
        / "app"
        / "config"
        / "env_config.dart",
    ]
    for path in paths:
        content = path.read_text(encoding="utf-8")
        for pattern in CREDENTIAL_PATTERNS:
            assert pattern.search(content) is None, f"Credential pattern found in {path}"


def test_network_client_does_not_log_headers_or_bodies() -> None:
    path = (
        REPOSITORY_ROOT
        / "lawrence"
        / "lib"
        / "core"
        / "network"
        / "network_client.dart"
    )
    content = path.read_text(encoding="utf-8")
    forbidden = [
        "Request Headers",
        "Response Headers",
        "Request Body",
        "Response Body",
        "options.headers}",
        "response.data}",
    ]
    assert all(fragment not in content for fragment in forbidden)
