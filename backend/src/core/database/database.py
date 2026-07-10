from supabase import create_client, Client
from src.shared.config import settings

# Instâncias singleton inicializadas preguiçosamente
_admin_client: Client = None
_anon_client: Client = None


def get_admin_supabase_client() -> Client:
    """Retorna o cliente Supabase administrativo.
    Busca de src.shared.database para garantir compatibilidade com patches de testes.
    """
    try:
        from src.shared import database

        if database.db is not None:
            return database.db
    except ImportError:
        pass

    global _admin_client
    if _admin_client is None:
        _admin_client = create_client(
            settings.supabase_url, settings.supabase_service_key
        )
    return _admin_client


def get_authenticated_supabase_client(token: str = None) -> Client:
    """Retorna o cliente Supabase anon ou autenticado com token JWT."""
    if token:
        client = create_client(settings.supabase_url, settings.supabase_anon_key)
        client.postgrest.auth(token)
        return client

    try:
        from src.shared import database

        if database.auth_db is not None:
            return database.auth_db
    except ImportError:
        pass

    global _anon_client
    if _anon_client is None:
        _anon_client = create_client(settings.supabase_url, settings.supabase_anon_key)
    return _anon_client


def get_worker_supabase_client() -> Client:
    """Retorna o cliente Supabase para execução em background."""
    return get_admin_supabase_client()
