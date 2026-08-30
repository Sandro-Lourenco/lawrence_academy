ALTER TABLE public.lessons
  ADD COLUMN IF NOT EXISTS video_source_type TEXT NOT NULL DEFAULT 'upload',
  ADD COLUMN IF NOT EXISTS external_video_id TEXT;

ALTER TABLE public.lessons
  DROP CONSTRAINT IF EXISTS lessons_video_source_check;

ALTER TABLE public.lessons
  ADD CONSTRAINT lessons_video_source_check CHECK (
    (video_source_type = 'upload' AND external_video_id IS NULL)
    OR (
      video_source_type = 'youtube'
      AND external_video_id ~ '^[A-Za-z0-9_-]{11}$'
    )
    OR (
      video_source_type = 'vimeo'
      AND external_video_id ~ '^[0-9]{1,20}$'
    )
  );

COMMENT ON COLUMN public.lessons.video_source_type IS
  'Fonte de reprodução: upload privado processado em HLS, YouTube ou Vimeo.';
COMMENT ON COLUMN public.lessons.external_video_id IS
  'Identificador normalizado do provedor. A URL original nunca é persistida.';
