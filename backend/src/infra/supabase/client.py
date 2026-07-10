from supabase import create_client
from src.shared.config import settings

# Inicialização direta das instâncias de infraestrutura básica
supabase_admin = create_client(settings.supabase_url, settings.supabase_service_key)
supabase_anon = create_client(settings.supabase_url, settings.supabase_anon_key)
