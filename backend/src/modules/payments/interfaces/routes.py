from fastapi import APIRouter, Request, Header, HTTPException, status, Depends
import stripe
from pydantic import BaseModel, Field
from src.shared.config import settings
from src.modules.payments.application.process_webhook import StripeWebhookProcessor
from src.modules.auth.dependencies import get_current_user

router = APIRouter(tags=["payments"])

class CheckoutSessionRequest(BaseModel):
    price_id: str = Field(..., description="ID do Preço no Stripe para a assinatura")
    course_id: str = Field(..., description="ID do Curso associado à assinatura")
    success_url: str = Field(..., description="URL de retorno para sucesso no pagamento")
    cancel_url: str = Field(..., description="URL de retorno caso o pagamento seja cancelado")

@router.post("/api/checkout/session")
async def create_checkout_session(
    payload: CheckoutSessionRequest,
    current_user: dict = Depends(get_current_user)
):
    """Cria uma sessão de checkout do Stripe segura para pagamento recorrente (assinatura)."""
    from src.shared import database
    from datetime import datetime, timezone
    
    # 1. Validar se já existe assinatura ativa para este curso
    sub_res = database.db.table("subscriptions")\
        .select("*")\
        .eq("student_id", current_user["id"])\
        .eq("course_id", payload.course_id)\
        .execute()
        
    if sub_res.data:
        for sub in sub_res.data:
            status_sub = sub.get("status")
            if status_sub in ["active", "trialing"]:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="Você já possui uma assinatura ativa para este curso."
                )
            elif status_sub == "past_due":
                period_end_str = sub.get("current_period_end")
                if period_end_str:
                    try:
                        period_end = datetime.fromisoformat(period_end_str.replace("Z", "+00:00"))
                        now = datetime.now(timezone.utc)
                        diff = now - period_end
                        if diff.days <= 5:
                            raise HTTPException(
                                status_code=status.HTTP_400_BAD_REQUEST,
                                detail="Você já possui uma assinatura ativa (em período de carência) para este curso."
                            )
                    except Exception:
                        pass

    try:
        session = stripe.checkout.Session.create(
            payment_method_types=["card"],
            line_items=[
                {
                    "price": payload.price_id,
                    "quantity": 1,
                }
            ],
            mode="subscription",
            subscription_data={
                "metadata": {
                    "course_id": payload.course_id,
                    "user_id": current_user["id"]
                }
            },
            success_url=payload.success_url + "?session_id={CHECKOUT_SESSION_ID}",
            cancel_url=payload.cancel_url,
            client_reference_id=current_user["id"],
            customer_email=current_user["email"],
            metadata={
                "course_id": payload.course_id,
                "user_id": current_user["id"]
            }
        )
        return {
            "status": "success",
            "data": {
                "checkout_url": session.url,
                "session_id": session.id
            }
        }
    except Exception as e:
        is_mock_allowed = settings.app_env == "test" or settings.payment_provider == "fake"
        if is_mock_allowed:
            err_msg = str(e).lower()
            if "api_key" in err_msg or "invalid" in err_msg or "auth" in err_msg or "cannot" in err_msg:
                print(f"[Stripe Checkout Sandbox] Simulando checkout para o usuário {current_user['email']}")
                return {
                    "status": "success",
                    "data": {
                        "checkout_url": f"https://checkout.stripe.com/pay/mock_session_for_{current_user['id']}_course_{payload.course_id}",
                        "session_id": f"mock_session_{current_user['id']}_{payload.course_id}"
                    }
                }
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Erro ao criar sessão de checkout: {str(e)}"
        )

@router.post("/webhooks/stripe")
async def handle_stripe_webhook(request: Request, stripe_signature: str = Header(None)):
    """Recebe, verifica e processa eventos de faturamento do Stripe de forma assíncrona com proteção de idempotência."""
    if not stripe_signature or not settings.stripe_webhook_secret:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST, 
            detail="Missing signature or secret configurations."
        )
        
    payload = await request.body()
    
    # 1. Verificar a assinatura do webhook do Stripe
    try:
        event = stripe.Webhook.construct_event(
            payload, 
            stripe_signature, 
            settings.stripe_webhook_secret
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST, 
            detail=f"Webhook signature verification failed: {str(e)}"
        )
        
    event_id = event["id"]
    event_type = event.get("type", "unknown")
    import hashlib
    payload_hash = hashlib.sha256(payload).hexdigest()
    
    # 2. Registrar a trava de idempotência
    is_new_event = StripeWebhookProcessor.register_idempotency(
        provider="stripe",
        event_id=event_id,
        event_type=event_type,
        payload_hash=payload_hash
    )
    if not is_new_event:
        print(f"[Stripe Webhook] Evento duplicado ignorado (idempotente): {event_id}")
        return {"status": "success", "message": "Duplicate event ignored."}
        
    # 3. Processar o evento
    try:
        await StripeWebhookProcessor.process_event(event)
        StripeWebhookProcessor.mark_event_processed(provider="stripe", event_id=event_id)
        return {"status": "success", "event_processed": event_id}
    except Exception as proc_err:
        print(f"[Stripe Webhook] Erro ao processar evento {event_id}: {proc_err}")
        # Desfazer a trava de idempotência para permitir reenvio
        try:
            StripeWebhookProcessor.remove_idempotency(provider="stripe", event_id=event_id)
        except Exception as db_del_err:
            print(f"[Stripe Webhook] Erro ao desfazer idempotência para {event_id}: {db_del_err}")
            
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, 
            detail=f"Error processing webhook: {str(proc_err)}"
        )
