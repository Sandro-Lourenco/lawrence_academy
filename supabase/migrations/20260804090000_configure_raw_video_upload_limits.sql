-- Keep bucket restrictions aligned with the current Supabase Free plan.
-- Raise both this value and MAX_VIDEO_UPLOAD_BYTES when the project moves
-- to a paid plan that supports larger source videos.
UPDATE storage.buckets
SET public = false,
    file_size_limit = 52428800,
    allowed_mime_types = ARRAY[
      'video/mp4',
      'video/quicktime',
      'video/x-m4v'
    ]::TEXT[]
WHERE id = 'raw-videos';
