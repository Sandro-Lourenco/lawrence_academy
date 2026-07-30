from src.core.storage.public_url import to_public_supabase_url


def test_rewrites_internal_supabase_origin_for_browser(monkeypatch):
    monkeypatch.setenv("SUPABASE_URL", "http://host.docker.internal:54321")
    monkeypatch.setenv("SUPABASE_PUBLIC_URL", "http://127.0.0.1:54321")

    result = to_public_supabase_url(
        "http://host.docker.internal:54321/storage/v1/object/sign/lessons/a.ts?token=secret"
    )

    assert result == (
        "http://127.0.0.1:54321/storage/v1/object/sign/lessons/a.ts?token=secret"
    )


def test_does_not_rewrite_an_unrelated_origin(monkeypatch):
    monkeypatch.setenv("SUPABASE_URL", "https://internal.example")
    monkeypatch.setenv("SUPABASE_PUBLIC_URL", "https://public.example")

    result = to_public_supabase_url("https://cdn.example/video.ts?token=secret")

    assert result == "https://cdn.example/video.ts?token=secret"


def test_keeps_original_url_when_public_origin_is_not_configured(monkeypatch):
    monkeypatch.delenv("SUPABASE_PUBLIC_URL", raising=False)

    assert to_public_supabase_url("https://project.supabase.co/object") == (
        "https://project.supabase.co/object"
    )
