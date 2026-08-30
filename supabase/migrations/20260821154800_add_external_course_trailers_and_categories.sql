-- Keep the authoring category contract aligned with the database enum.
ALTER TYPE public.course_category ADD VALUE IF NOT EXISTS 'bordado';
ALTER TYPE public.course_category ADD VALUE IF NOT EXISTS 'negocios';
ALTER TYPE public.course_category ADD VALUE IF NOT EXISTS 'outros';

-- Public course trailers may be produced internally or embedded from a
-- trusted external provider. Raw URLs are never persisted.
ALTER TABLE public.courses
  ADD COLUMN IF NOT EXISTS trailer_source_type TEXT NOT NULL DEFAULT 'upload',
  ADD COLUMN IF NOT EXISTS trailer_external_video_id TEXT;

ALTER TABLE public.courses
  DROP CONSTRAINT IF EXISTS courses_trailer_source_check;
ALTER TABLE public.courses
  ADD CONSTRAINT courses_trailer_source_check CHECK (
    (
      trailer_source_type = 'upload'
      AND trailer_external_video_id IS NULL
    )
    OR
    (
      trailer_source_type = 'youtube'
      AND trailer_external_video_id ~ '^[A-Za-z0-9_-]{11}$'
      AND trailer_hls_path IS NULL
    )
    OR
    (
      trailer_source_type = 'vimeo'
      AND trailer_external_video_id ~ '^[0-9]{1,20}$'
      AND trailer_hls_path IS NULL
    )
  );

COMMENT ON COLUMN public.courses.trailer_source_type IS
  'Trailer source: private upload converted to HLS, YouTube, or Vimeo.';
COMMENT ON COLUMN public.courses.trailer_external_video_id IS
  'Normalized provider identifier; the submitted external URL is not stored.';
