REVOKE ALL ON TABLE
  public.courses,
  public.modules,
  public.lessons,
  public.lesson_blocks
FROM service_role;

GRANT SELECT, INSERT, UPDATE ON TABLE
  public.courses,
  public.modules,
  public.lessons,
  public.lesson_blocks
TO service_role;

REVOKE ALL ON TABLE public.video_processing_jobs FROM service_role;
GRANT SELECT ON TABLE public.video_processing_jobs TO service_role;
