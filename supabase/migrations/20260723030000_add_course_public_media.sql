ALTER TABLE public.courses
  ADD COLUMN IF NOT EXISTS cover_image_path TEXT,
  ADD COLUMN IF NOT EXISTS cover_alt_text TEXT,
  ADD COLUMN IF NOT EXISTS cover_focal_x NUMERIC(5,4) NOT NULL DEFAULT 0.5,
  ADD COLUMN IF NOT EXISTS cover_focal_y NUMERIC(5,4) NOT NULL DEFAULT 0.5,
  ADD COLUMN IF NOT EXISTS cover_status TEXT NOT NULL DEFAULT 'empty',
  ADD COLUMN IF NOT EXISTS trailer_status TEXT NOT NULL DEFAULT 'empty',
  ADD COLUMN IF NOT EXISTS trailer_upload_job_id UUID;

ALTER TABLE public.courses DROP CONSTRAINT IF EXISTS courses_cover_focal_x_check;
ALTER TABLE public.courses ADD CONSTRAINT courses_cover_focal_x_check CHECK (cover_focal_x BETWEEN 0 AND 1);
ALTER TABLE public.courses DROP CONSTRAINT IF EXISTS courses_cover_focal_y_check;
ALTER TABLE public.courses ADD CONSTRAINT courses_cover_focal_y_check CHECK (cover_focal_y BETWEEN 0 AND 1);
ALTER TABLE public.courses DROP CONSTRAINT IF EXISTS courses_cover_alt_text_check;
ALTER TABLE public.courses ADD CONSTRAINT courses_cover_alt_text_check CHECK (cover_alt_text IS NULL OR char_length(cover_alt_text) <= 240);
ALTER TABLE public.courses DROP CONSTRAINT IF EXISTS courses_cover_status_check;
ALTER TABLE public.courses ADD CONSTRAINT courses_cover_status_check CHECK (cover_status IN ('empty','upload_pending','ready','failed'));
ALTER TABLE public.courses DROP CONSTRAINT IF EXISTS courses_trailer_status_check;
ALTER TABLE public.courses ADD CONSTRAINT courses_trailer_status_check CHECK (trailer_status IN ('empty','upload_pending','uploaded','processing','ready','failed'));

ALTER TABLE public.video_processing_jobs ADD COLUMN IF NOT EXISTS asset_kind TEXT NOT NULL DEFAULT 'lesson_video';
ALTER TABLE public.video_processing_jobs ALTER COLUMN lesson_id DROP NOT NULL;
ALTER TABLE public.video_processing_jobs DROP CONSTRAINT IF EXISTS video_processing_jobs_asset_kind_check;
ALTER TABLE public.video_processing_jobs ADD CONSTRAINT video_processing_jobs_asset_kind_check CHECK (
  (asset_kind = 'lesson_video' AND lesson_id IS NOT NULL) OR
  (asset_kind = 'course_trailer' AND lesson_id IS NULL)
);
ALTER TABLE public.courses DROP CONSTRAINT IF EXISTS courses_trailer_upload_job_id_fkey;
ALTER TABLE public.courses ADD CONSTRAINT courses_trailer_upload_job_id_fkey FOREIGN KEY (trailer_upload_job_id) REFERENCES public.video_processing_jobs(id) ON DELETE SET NULL;

INSERT INTO storage.buckets (id,name,public,file_size_limit,allowed_mime_types)
VALUES ('course-images','course-images',false,10485760,ARRAY['image/jpeg','image/png','image/webp'])
ON CONFLICT (id) DO UPDATE SET public=false,file_size_limit=EXCLUDED.file_size_limit,allowed_mime_types=EXCLUDED.allowed_mime_types;

CREATE OR REPLACE FUNCTION public.handle_storage_video_upload()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog, public AS $$
DECLARE v_job public.video_processing_jobs%ROWTYPE;
BEGIN
  IF NEW.bucket_id = 'course-images' THEN
    UPDATE public.courses SET cover_status='ready',updated_at=now()
      WHERE cover_image_path=NEW.name AND cover_status='upload_pending';
    RETURN NEW;
  END IF;
  IF NEW.bucket_id <> 'raw-videos' THEN RETURN NEW; END IF;
  SELECT * INTO v_job FROM public.video_processing_jobs WHERE raw_video_path=NEW.name AND status='upload_pending' ORDER BY created_at DESC LIMIT 1;
  IF v_job.id IS NULL THEN RETURN NEW; END IF;
  UPDATE public.video_processing_jobs SET status='uploaded',uploaded_at=now(),updated_at=now() WHERE id=v_job.id;
  IF v_job.asset_kind='course_trailer' THEN
    UPDATE public.courses SET trailer_status='uploaded',updated_at=now() WHERE id=v_job.course_id AND trailer_upload_job_id=v_job.id;
  END IF;
  RETURN NEW;
END; $$;
DROP TRIGGER IF EXISTS on_storage_video_uploaded ON storage.objects;
CREATE TRIGGER on_storage_video_uploaded AFTER INSERT ON storage.objects FOR EACH ROW EXECUTE FUNCTION public.handle_storage_video_upload();
