import re

file_transcriber = r'backend/src/workers/video_worker/transcriber.py'
with open(file_transcriber, 'r', encoding='utf-8') as f:
    content = f.read()

content = content.replace(
    'if hasattr(response, "segments") and getattr(response, "segments", None) is not None:\n        for seg in response.segments:',
    'segments_data = getattr(response, "segments", []) or []\n    if segments_data:\n        for seg in segments_data:'
)

with open(file_transcriber, 'w', encoding='utf-8') as f:
    f.write(content)

file_summarizer = r'backend/src/workers/video_worker/summarizer.py'
with open(file_summarizer, 'r', encoding='utf-8') as f:
    content3 = f.read()
content3 = content3.replace('summary_text = response.text.strip() if response.text else ""', 'text_val = getattr(response, "text", "") or ""\n    summary_text = text_val.strip()')
with open(file_summarizer, 'w', encoding='utf-8') as f:
    f.write(content3)
