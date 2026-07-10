from src.infra.supabase.client import supabase_admin, supabase_anon

# Exportação amigável para a camada de aplicação/módulos
# db: Usado por repositórios para operações que requerem service_role (criação, edição, etc.)
db = supabase_admin

# auth_db: Usado principalmente para validações que envolvem tokens e sessão direta do usuário
auth_db = supabase_anon
