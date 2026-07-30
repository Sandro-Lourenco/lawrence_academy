import os
from urllib.parse import urlsplit, urlunsplit


def to_public_supabase_url(url: str) -> str:
    """Replace only the Supabase origin used inside Docker with its client origin."""
    public_url = os.getenv("SUPABASE_PUBLIC_URL")
    if not public_url:
        return url

    source = urlsplit(url)
    public = urlsplit(public_url)
    internal = urlsplit(os.getenv("SUPABASE_URL", ""))

    if public.scheme not in {"http", "https"} or not public.netloc:
        raise ValueError("SUPABASE_PUBLIC_URL must be an absolute HTTP(S) URL.")
    if internal.netloc and source.netloc != internal.netloc:
        return url

    return urlunsplit(
        (
            public.scheme,
            public.netloc,
            source.path,
            source.query,
            source.fragment,
        )
    )
