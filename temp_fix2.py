import re

file_transcriber = r'backend/src/workers/video_worker/transcriber.py'
with open(file_transcriber, 'r', encoding='utf-8') as f:
    content = f.read()

content = content.replace(
    'def clean_up_segments(segments: list) -> list:',
    'from typing import Any\ndef clean_up_segments(segments: list[dict[str, Any]]) -> list[dict[str, Any]]:'
)
content = content.replace(
    'if hasattr(response, "segments"):',
    'if hasattr(response, "segments") and getattr(response, "segments", None) is not None:'
)
content = content.replace(
    'cleaned = []',
    'cleaned: list[dict[str, Any]] = []'
)
with open(file_transcriber, 'w', encoding='utf-8') as f:
    f.write(content)

file_supabase = r'backend/src/workers/video_worker/supabase_client.py'
with open(file_supabase, 'r', encoding='utf-8') as f:
    content2 = f.read()

content2 = content2.replace(
    'def process(self, msg: str, kwargs: Dict[str, Any]) -> tuple[str, Dict[str, Any]]:',
    'from typing import MutableMapping\n    def process(self, msg: str, kwargs: MutableMapping[str, Any]) -> tuple[str, MutableMapping[str, Any]]:'
)
content2 = content2.replace(
    'kwargs["extra"] = {"job_id": self.extra.get("job_id", "system")}',
    'if self.extra:\n            kwargs["extra"] = {"job_id": self.extra.get("job_id", "system")}\n        else:\n            kwargs["extra"] = {"job_id": "system"}'
)
content2 = content2.replace(
    'if res.data and len(res.data) > 0:\n            return res.data[0]',
    'if res.data and len(res.data) > 0:\n            import typing\n            return typing.cast(Dict[str, Any], res.data[0])'
)

with open(file_supabase, 'w', encoding='utf-8') as f:
    f.write(content2)

file_summarizer = r'backend/src/workers/video_worker/summarizer.py'
with open(file_summarizer, 'r', encoding='utf-8') as f:
    content3 = f.read()
content3 = content3.replace('summary_text = response.text.strip()', 'summary_text = response.text.strip() if response.text else ""')
with open(file_summarizer, 'w', encoding='utf-8') as f:
    f.write(content3)
