BEGIN;

CREATE TABLE public.download_tokens (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  jti TEXT NOT NULL UNIQUE,
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  lesson_id UUID NOT NULL REFERENCES public.lessons(id) ON DELETE CASCADE,
  issued_at BIGINT NOT NULL,
  expires_at BIGINT NOT NULL,
  status TEXT NOT NULL DEFAULT 'ACTIVE'
    CHECK (status IN ('ACTIVE', 'USED', 'REVOKED', 'EXPIRED')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CHECK (expires_at > issued_at)
);

CREATE INDEX idx_download_tokens_user_id
  ON public.download_tokens(user_id);
CREATE INDEX idx_download_tokens_expiry_active
  ON public.download_tokens(expires_at)
  WHERE status = 'ACTIVE';

ALTER TABLE public.download_tokens ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON public.download_tokens FROM anon, authenticated;
GRANT SELECT, INSERT, UPDATE ON public.download_tokens TO service_role;

COMMIT;
