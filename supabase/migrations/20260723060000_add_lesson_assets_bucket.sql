INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'lesson-assets', 'lesson-assets', false, 104857600,
  ARRAY[
    'image/jpeg','image/png','image/webp','application/pdf',
    'audio/mpeg','audio/mp4','audio/wav','audio/ogg',
    'application/zip','application/vnd.openxmlformats-officedocument.wordprocessingml.document'
  ]
)
ON CONFLICT (id) DO UPDATE SET
  public=false,
  file_size_limit=EXCLUDED.file_size_limit,
  allowed_mime_types=EXCLUDED.allowed_mime_types;

-- Uploads use one-time signed tokens minted by the service-role backend.
-- Direct listing, reading, overwriting and deletion remain denied to clients.
DROP POLICY IF EXISTS lesson_assets_direct_access ON storage.objects;

