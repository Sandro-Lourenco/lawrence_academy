from supabase import create_client, Client
from src.shared.config import settings

# Instância administrativa do Supabase (utiliza a Service Key para bypass de RLS quando necessário)
supabase_admin: Client = create_client(
    settings.supabase_url, 
    settings.supabase_service_key
)

# Instância padrão/pública do Supabase (utiliza a Anon Key para operações restritas do lado do cliente e auth)
supabase_anon: Client = create_client(
    settings.supabase_url, 
    settings.supabase_anon_key
)
