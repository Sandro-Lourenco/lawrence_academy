import re

file_path = r'backend/tests/test_video_worker.py'
with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

content = re.sub(r'@patch\(\"supabase_client\.', '@patch(\"src.workers.video_worker.worker.supabase_client.', content)
content = re.sub(r'@patch\(\"transcoder\.', '@patch(\"src.workers.video_worker.worker.transcoder.', content)
content = re.sub(r'@patch\(\"transcriber\.', '@patch(\"src.workers.video_worker.worker.transcriber.', content)
content = re.sub(r'@patch\(\"summarizer\.', '@patch(\"src.workers.video_worker.worker.summarizer.', content)

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)
