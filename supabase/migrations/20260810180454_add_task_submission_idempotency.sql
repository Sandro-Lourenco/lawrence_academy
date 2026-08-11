-- PostgreSQL requires a commit before a newly added enum value can be used.
ALTER TYPE public.submission_status ADD VALUE IF NOT EXISTS 'draft';
