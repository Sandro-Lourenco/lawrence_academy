import os


# Test configuration is explicit so application code never needs insecure fallbacks.
os.environ.setdefault("APP_ENV", "test")
os.environ.setdefault("SUPABASE_URL", "https://mock.supabase.co")
os.environ.setdefault("SUPABASE_SERVICE_ROLE_KEY", "mock-service-role-key")
os.environ.setdefault("SUPABASE_SERVICE_KEY", "mock-service-role-key")
os.environ.setdefault("SUPABASE_ANON_KEY", "mock-anon-key")
os.environ.setdefault("STRIPE_SECRET_KEY", "sk_test_mock")
os.environ.setdefault("STRIPE_API_KEY", "sk_test_mock")
os.environ.setdefault("STRIPE_WEBHOOK_SECRET", "whsec_test_mock")
os.environ.setdefault("ALLOWED_ORIGINS", "http://localhost")
