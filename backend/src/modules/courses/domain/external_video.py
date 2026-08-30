import re
from dataclasses import dataclass
from urllib.parse import parse_qs, urlparse

from src.core.errors.errors import ValidationError


_YOUTUBE_ID = re.compile(r"^[A-Za-z0-9_-]{11}$")
_VIMEO_ID = re.compile(r"^[0-9]{1,20}$")


@dataclass(frozen=True)
class ExternalVideo:
    provider: str
    video_id: str

    @property
    def canonical_url(self) -> str:
        if self.provider == "youtube":
            return f"https://www.youtube.com/watch?v={self.video_id}"
        return f"https://vimeo.com/{self.video_id}"


def parse_external_video_url(value: str) -> ExternalVideo:
    raw = value.strip()
    if len(raw) > 2048:
        raise ValidationError("O link do vídeo é muito longo.")
    parsed = urlparse(raw)
    if parsed.scheme != "https" or parsed.username or parsed.password or parsed.port:
        raise ValidationError("Informe um link HTTPS oficial do YouTube ou Vimeo.")

    host = (parsed.hostname or "").lower().rstrip(".")
    path_parts = [part for part in parsed.path.split("/") if part]
    video_id: str | None = None
    provider: str | None = None

    if host in {"youtube.com", "www.youtube.com", "m.youtube.com"}:
        provider = "youtube"
        if parsed.path == "/watch":
            video_id = parse_qs(parsed.query).get("v", [None])[0]
        elif len(path_parts) == 2 and path_parts[0] in {"embed", "shorts", "live"}:
            video_id = path_parts[1]
    elif host == "youtu.be" and len(path_parts) == 1:
        provider = "youtube"
        video_id = path_parts[0]
    elif host in {"vimeo.com", "www.vimeo.com"} and len(path_parts) == 1:
        provider = "vimeo"
        video_id = path_parts[0]
    elif host == "player.vimeo.com" and len(path_parts) == 2 and path_parts[0] == "video":
        provider = "vimeo"
        video_id = path_parts[1]

    valid = (
        provider == "youtube" and video_id is not None and _YOUTUBE_ID.fullmatch(video_id)
    ) or (provider == "vimeo" and video_id is not None and _VIMEO_ID.fullmatch(video_id))
    if not valid:
        raise ValidationError("Use um link válido de vídeo do YouTube ou Vimeo.")
    # ``valid`` proves both values are populated, but mypy cannot narrow the
    # two optionals through the compound provider-specific expression above.
    assert provider is not None and video_id is not None
    return ExternalVideo(provider=provider, video_id=video_id)


def external_video_url(provider: str, video_id: str) -> str:
    video = ExternalVideo(provider=provider, video_id=video_id)
    if provider == "youtube" and _YOUTUBE_ID.fullmatch(video_id):
        return video.canonical_url
    if provider == "vimeo" and _VIMEO_ID.fullmatch(video_id):
        return video.canonical_url
    raise ValidationError("A fonte externa persistida é inválida.")
