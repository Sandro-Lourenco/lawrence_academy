import stripe
from datetime import datetime, timezone
from src.shared import database

class StripeWebhookProcessor:
    """Serviço de aplicação para processar eventos do Stripe Webhook de forma idempotente."""

    @staticmethod
    def register_idempotency(provider: str, event_id: str, event_type: str, payload_hash: str) -> bool:
        """Registra o evento no banco para garantir processamento único (idempotente).
        Retorna True se for um evento novo, False se for duplicado.
        """
        try:
            lock_res = database.db.table("payment_events") \
                .insert({
                    "provider": provider,
                    "provider_event_id": event_id,
                    "event_type": event_type,
                    "payload_hash": payload_hash,
                    "status": "processing"
                }) \
                .execute()
            
            if not lock_res.data:
                return False
            return True
        except Exception as db_err:
            # Capturar erro de Unique Constraint (duplicado)
            if "duplicate key" in str(db_err).lower() or "unique constraint" in str(db_err).lower():
                return False
            raise db_err

    @staticmethod
    def remove_idempotency(provider: str, event_id: str) -> None:
        """Remove a trava de idempotência se houver falha no processamento, permitindo reenvio."""
        database.db.table("payment_events").delete()\
            .eq("provider", provider)\
            .eq("provider_event_id", event_id)\
            .execute()

    @staticmethod
    def mark_event_processed(provider: str, event_id: str) -> None:
        """Marca o evento como processado com sucesso."""
        database.db.table("payment_events").update({
            "status": "processed",
            "processed_at": datetime.now(timezone.utc).isoformat()
        }).eq("provider", provider).eq("provider_event_id", event_id).execute()

    @classmethod
    async def process_event(cls, event: dict) -> None:
        """Roteia o evento do Stripe para o processador específico."""
        event_type = event["type"]
        
        if event_type == "invoice.payment_succeeded":
            await cls._process_payment_succeeded(event)
        elif event_type == "invoice.payment_failed":
            await cls._process_payment_failed(event)
        elif event_type == "customer.subscription.deleted":
            await cls._process_subscription_deleted(event)
        else:
            print(f"[Stripe Webhook] Evento ignorado: {event_type}")

    @staticmethod
    async def _process_payment_succeeded(event: dict) -> None:
        """Trata o pagamento realizado com sucesso (renovação de assinatura e referral)."""
        invoice = event["data"]["object"]
        stripe_sub_id = invoice.get("subscription")
        stripe_cust_id = invoice.get("customer")
        customer_email = invoice.get("customer_email")
        
        if not stripe_sub_id:
            return
            
        # Obter detalhes da assinatura diretamente da API do Stripe
        stripe_sub = stripe.Subscription.retrieve(stripe_sub_id)
        user_id = stripe_sub.metadata.get("user_id")
        course_id = stripe_sub.metadata.get("course_id")
        
        # Fallback: buscar perfil pelo e-mail caso não tenha user_id no metadata
        if not user_id and customer_email:
            prof_res = database.db.table("profiles").select("id").eq("email", customer_email).limit(1).execute()
            if prof_res.data:
                user_id = prof_res.data[0]["id"]
                
        if not user_id:
            raise ValueError(f"Não foi possível mapear o user_id para o cliente Stripe {stripe_cust_id}")
            
        # Fallback para course_id: buscar o primeiro curso disponível para evitar falha
        if not course_id:
            course_res = database.db.table("courses").select("id").limit(1).execute()
            if course_res.data:
                course_id = course_res.data[0]["id"]
            else:
                raise ValueError("Não foi possível mapear o course_id para a assinatura")
            
        current_period_start = stripe_sub.current_period_start
        current_period_end = stripe_sub.current_period_end
        
        dt_start = datetime.fromtimestamp(current_period_start, tz=timezone.utc).isoformat()
        dt_end = datetime.fromtimestamp(current_period_end, tz=timezone.utc).isoformat()
        
        # Salvar ou atualizar na tabela public.subscriptions
        sub_data = {
            "student_id": user_id,
            "course_id": course_id,
            "provider": "stripe",
            "provider_customer_id": stripe_cust_id,
            "provider_subscription_id": stripe_sub_id,
            "status": "active",
            "monthly_price": float(stripe_sub.plan.amount) / 100.0 if stripe_sub.plan else 89.90,
            "currency": stripe_sub.plan.currency.upper() if (stripe_sub.plan and stripe_sub.plan.currency) else "BRL",
            "current_period_start": dt_start,
            "current_period_end": dt_end,
            "updated_at": datetime.now(timezone.utc).isoformat()
        }
        
        database.db.table("subscriptions") \
            .upsert(sub_data, on_conflict="provider_subscription_id") \
            .execute()
            
        # Emitir notificação de sucesso
        database.db.table("notifications").insert({
            "user_id": user_id,
            "title": "Assinatura Renovada",
            "message": "Seu pagamento foi confirmado! Aproveite o conteúdo completo do curso.",
            "notification_type": "success"
        }).execute()
        
        # Lógica de Indicação (Referral)
        billing_reason = invoice.get("billing_reason")
        if billing_reason == "subscription_create":
            # Verificar se o novo aluno possui um indicador (referred_by)
            user_prof = database.db.table("profiles").select("referred_by").eq("id", user_id).limit(1).execute()
            if user_prof.data and user_prof.data[0]["referred_by"]:
                referred_by = user_prof.data[0]["referred_by"]
                
                # Buscar a assinatura ativa do indicador para obter seu customer_id no Stripe
                ind_sub = database.db.table("subscriptions") \
                    .select("*") \
                    .eq("student_id", referred_by) \
                    .eq("status", "active") \
                    .order("created_at", desc=True) \
                    .limit(1) \
                    .execute()
                    
                if ind_sub.data:
                    ind_cust_id = ind_sub.data[0].get("provider_customer_id") or ind_sub.data[0].get("stripe_customer_id")
                    
                    # Injetar crédito fixo de R$ 20.00 (2000 centavos) na conta do indicador no Stripe
                    print(f"[Referral] Aplicando R$20.00 de crédito ao indicador {referred_by} (Customer: {ind_cust_id})")
                    stripe.Customer.create_balance_transaction(
                        ind_cust_id,
                        amount=-2000, # Negativo representa crédito
                        currency="brl",
                        description=f"Crédito de indicação do aluno indicado: {customer_email}"
                    )
                    
                    # Notificar o indicador
                    database.db.table("notifications").insert({
                        "user_id": referred_by,
                        "title": "Indicação bem-sucedida! ✨",
                        "message": f"Seu amigo indicado assinou a Lawrence Academy. Você recebeu R$ 20,00 de crédito em sua próxima mensalidade!",
                        "notification_type": "success"
                    }).execute()

    @staticmethod
    async def _process_payment_failed(event: dict) -> None:
        """Trata a falha de pagamento (muda status para past_due e notifica o aluno)."""
        invoice = event["data"]["object"]
        stripe_sub_id = invoice.get("subscription")
        
        if not stripe_sub_id:
            return
            
        sub_res = database.db.table("subscriptions") \
            .update({"status": "past_due", "updated_at": datetime.now(timezone.utc).isoformat()}) \
            .eq("provider_subscription_id", stripe_sub_id) \
            .execute()
            
        if sub_res.data:
            user_id = sub_res.data[0].get("student_id") or sub_res.data[0].get("user_id")
            
            database.db.table("notifications").insert({
                "user_id": user_id,
                "title": "Problema no Pagamento",
                "message": "Não conseguimos cobrar seu cartão. Suas aulas continuam liberadas por 5 dias. Por favor, atualize seus dados de pagamento.",
                "notification_type": "warning"
            }).execute()

    @staticmethod
    async def _process_subscription_deleted(event: dict) -> None:
        """Trata o cancelamento definitivo de uma assinatura."""
        subscription = event["data"]["object"]
        stripe_sub_id = subscription.get("id")
        
        sub_res = database.db.table("subscriptions") \
            .update({"status": "canceled", "updated_at": datetime.now(timezone.utc).isoformat()}) \
            .eq("provider_subscription_id", stripe_sub_id) \
            .execute()
            
        if sub_res.data:
            user_id = sub_res.data[0].get("student_id") or sub_res.data[0].get("user_id")
            
            database.db.table("notifications").insert({
                "user_id": user_id,
                "title": "Assinatura Cancelada",
                "message": "Sua assinatura foi encerrada. Esperamos ter você de volta em breve!",
                "notification_type": "info"
            }).execute()
