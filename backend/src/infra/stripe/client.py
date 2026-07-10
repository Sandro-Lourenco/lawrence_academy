import stripe
from src.shared.config import settings

# Configuração global da chave de API secreta do Stripe
stripe.api_key = settings.stripe_api_key

def get_stripe_client():
    """Retorna a biblioteca stripe pré-configurada."""
    return stripe
