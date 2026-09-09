import typing
import stripe
from datetime import datetime, timezone
from src.shared import database


def _resource_value(resource: typing.Any, name: str) -> typing.Any:
    if isinstance(resource, dict):
        return resource.get(name)
    return getattr(resource, name, None)


def _stripe_invoice_subscription_id(invoice: typing.Any) -> str | None:
    """Read the subscription relation from legacy and Basil+ invoice payloads."""
    legacy = _resource_value(invoice, "subscription")
    if isinstance(legacy, str):
        return legacy
    if legacy is not None:
        expanded_id = _resource_value(legacy, "id")
        if isinstance(expanded_id, str):
            return expanded_id

    parent = _resource_value(invoice, "parent")
    if _resource_value(parent, "type") != "subscription_details":
        return None
    details = _resource_value(parent, "subscription_details")
    subscription = _resource_value(details, "subscription")
    if isinstance(subscription, str):
        return subscription
    expanded_id = _resource_value(subscription, "id")
    return expanded_id if isinstance(expanded_id, str) else None


def _stripe_subscription_period(subscription: typing.Any) -> tuple[int, int]:
    """Read billing period from legacy subscriptions or their first Basil+ item."""
    start = _resource_value(subscription, "current_period_start")
    end = _resource_value(subscription, "current_period_end")
    if isinstance(start, (int, float)) and isinstance(end, (int, float)):
        return int(start), int(end)

    items = _resource_value(subscription, "items")
    items_data = _resource_value(items, "data")
    if not items_data:
        raise ValueError("Stripe subscription is missing billing period data")
    first_item = items_data[0]
    start = _resource_value(first_item, "current_period_start")
    end = _resource_value(first_item, "current_period_end")
    if not isinstance(start, (int, float)) or not isinstance(end, (int, float)):
        raise ValueError("Stripe subscription item is missing billing period data")
    return int(start), int(end)


def _stripe_subscription_price(subscription: typing.Any) -> tuple[float, str]:
    """Extract the recurring price from current and legacy Stripe payloads."""
    items = getattr(subscription, "items", None)
    items_data = getattr(items, "data", None)
    if items_data is None and isinstance(items, dict):
        items_data = items.get("data")

    price = None
    if items_data:
        first_item = items_data[0]
        price = getattr(first_item, "price", None)
        if price is None and isinstance(first_item, dict):
            price = first_item.get("price")

    if price is None:
        price = getattr(subscription, "plan", None)

    amount = getattr(price, "unit_amount", None)
    if amount is None:
        amount = getattr(price, "amount", None)
    if amount is None and isinstance(price, dict):
        amount = price.get("unit_amount", price.get("amount"))

    currency = getattr(price, "currency", None)
    if currency is None and isinstance(price, dict):
        currency = price.get("currency")

    if amount is None or not currency:
        raise ValueError("Stripe subscription is missing recurring price data")

    return float(amount) / 100.0, str(currency).upper()


class StripeWebhookProcessor:
    """Serviço de aplicação para processar eventos do Stripe Webhook de forma idempotente."""

    @staticmethod
    def register_idempotency(
        provider: str, event_id: str, event_type: str, payload_hash: str
    ) -> bool:
        """Registra o evento no banco para garantir processamento único (idempotente).
        Retorna True se puder ser processado, False se for duplicado (já processado/em processamento).
        Permite retry se o status anterior era 'failed'.
        """
        try:
            lock_res = (
                database.db.table("payment_events")
                .insert(
                    {
                        "provider": provider,
                        "provider_event_id": event_id,
                        "event_type": event_type,
                        "payload_hash": payload_hash,
                        "status": "processing",
                    }
                )
                .execute()
            )
            return True if lock_res.data else False
        except Exception as db_err:
            if "duplicate key" in str(db_err).lower() or "unique constraint" in str(db_err).lower():
                existing = (
                    database.db.table("payment_events")
                    .select("status, payload_hash")
                    .eq("provider", provider)
                    .eq("provider_event_id", event_id)
                    .execute()
                )
                if existing.data:
                    existing_event = typing.cast(dict[str, typing.Any], existing.data[0])
                    current_status = existing_event.get("status")
                    if existing_event.get("payload_hash") not in {None, payload_hash}:
                        raise ValueError("Stripe event id was received with a different payload")
                    if current_status == "failed" or current_status == "received":
                        update_res = (
                            database.db.table("payment_events")
                            .update({"status": "processing", "payload_hash": payload_hash})
                            .eq("provider", provider)
                            .eq("provider_event_id", event_id)
                            .eq("status", current_status)
                            .execute()
                        )
                        return True if update_res.data else False
                return False
            raise db_err

    @staticmethod
    def mark_event_failed(provider: str, event_id: str, error_message: str) -> None:
        """Marca o evento como falho em vez de deletá-lo, mantendo histórico e permitindo reenvio."""
        database.db.table("payment_events").update(
            {"status": "failed", "processing_error": error_message[:1000]}
        ).eq("provider", provider).eq("provider_event_id", event_id).eq(
            "status", "processing"
        ).execute()

    @staticmethod
    def mark_event_processed(provider: str, event_id: str) -> None:
        """Marca o evento como processado com sucesso."""
        database.db.table("payment_events").update(
            {
                "status": "processed",
                "processed_at": datetime.now(timezone.utc).isoformat(),
            }
        ).eq("provider", provider).eq("provider_event_id", event_id).execute()

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
        elif event_type == "customer.subscription.updated":
            await cls._process_subscription_updated(event)
        elif event_type == "charge.refunded":
            await cls._process_charge_state(event, status="canceled")
        elif event_type == "charge.dispute.created":
            await cls._process_charge_state(event, status="past_due")
        else:
            print(f"[Stripe Webhook] Evento ignorado: {event_type}")

    @staticmethod
    async def _process_payment_succeeded(event: dict) -> None:
        """Trata o pagamento realizado com sucesso (renovação de assinatura e referral)."""
        invoice = typing.cast(dict[str, typing.Any], event.get("data", {}).get("object", {}))
        stripe_sub_id = _stripe_invoice_subscription_id(invoice)
        stripe_cust_id = invoice.get("customer")
        customer_email = invoice.get("customer_email")

        if not stripe_sub_id:
            return

        # Obter detalhes da assinatura diretamente da API do Stripe
        stripe_sub = typing.cast(typing.Any, stripe.Subscription.retrieve(stripe_sub_id))
        user_id = stripe_sub.metadata.get("user_id")
        course_id = stripe_sub.metadata.get("course_id")

        # Fallback: buscar perfil pelo e-mail caso não tenha user_id no metadata
        if not user_id and customer_email:
            prof_res = (
                database.db.table("profiles")
                .select("id")
                .eq("email", customer_email)
                .limit(1)
                .execute()
            )
            if prof_res.data:
                user_id = typing.cast(dict[str, typing.Any], prof_res.data[0])["id"]

        if not user_id:
            raise ValueError(
                f"Não foi possível mapear o user_id para o cliente Stripe {stripe_cust_id}"
            )

        # A assinatura é vinculada ao curso exclusivamente pelos metadados confiáveis
        # criados pelo backend no checkout. Nunca inferir outro curso.
        if not course_id:
            raise ValueError("Stripe subscription is missing required course_id metadata")

        current_period_start, current_period_end = _stripe_subscription_period(stripe_sub)

        dt_start = datetime.fromtimestamp(current_period_start, tz=timezone.utc).isoformat()
        dt_end = datetime.fromtimestamp(current_period_end, tz=timezone.utc).isoformat()
        monthly_price, currency = _stripe_subscription_price(stripe_sub)

        # Salvar ou atualizar na tabela public.subscriptions
        sub_data = {
            "student_id": user_id,
            "course_id": course_id,
            "provider": "stripe",
            "provider_customer_id": stripe_cust_id,
            "provider_subscription_id": stripe_sub_id,
            "status": "active",
            "monthly_price": monthly_price,
            "currency": currency,
            "current_period_start": dt_start,
            "current_period_end": dt_end,
            "updated_at": datetime.now(timezone.utc).isoformat(),
        }

        database.db.table("subscriptions").upsert(
            typing.cast(typing.Any, sub_data), on_conflict="provider_subscription_id"
        ).execute()

        # Emitir notificação de sucesso
        database.db.table("notifications").insert(
            {
                "user_id": user_id,
                "title": "Assinatura Renovada",
                "message": "Seu pagamento foi confirmado! Aproveite o conteúdo completo do curso.",
                "notification_type": "success",
            }
        ).execute()

        # Lógica de Indicação (Referral)
        billing_reason = invoice.get("billing_reason")
        if billing_reason == "subscription_create":
            # Verificar se o novo aluno possui um indicador (referred_by)
            user_prof = (
                database.db.table("profiles")
                .select("referred_by")
                .eq("id", user_id)
                .limit(1)
                .execute()
            )
            if (
                user_prof.data
                and typing.cast(dict[str, typing.Any], user_prof.data[0])["referred_by"]
            ):
                referred_by = typing.cast(dict[str, typing.Any], user_prof.data[0])["referred_by"]

                # Buscar a assinatura ativa do indicador para obter seu customer_id no Stripe
                ind_sub = (
                    database.db.table("subscriptions")
                    .select("*")
                    .eq("student_id", referred_by)
                    .eq("status", "active")
                    .order("created_at", desc=True)
                    .limit(1)
                    .execute()
                )

                if ind_sub.data:
                    ind_cust_id = typing.cast(dict[str, typing.Any], ind_sub.data[0]).get(
                        "provider_customer_id"
                    ) or typing.cast(dict[str, typing.Any], ind_sub.data[0]).get(
                        "stripe_customer_id"
                    )

                    # Injetar crédito fixo de R$ 20.00 (2000 centavos) na conta do indicador no Stripe
                    print(
                        f"[Referral] Aplicando R$20.00 de crédito ao indicador {referred_by} (Customer: {ind_cust_id})"
                    )
                    stripe.Customer.create_balance_transaction(
                        typing.cast(str, ind_cust_id),
                        amount=-2000,  # Negativo representa crédito
                        currency="brl",
                        description=f"Crédito de indicação do aluno indicado: {customer_email}",
                        idempotency_key=f"referral_{event['id']}",
                    )

                    # Notificar o indicador
                    database.db.table("notifications").insert(
                        {
                            "user_id": referred_by,
                            "title": "Indicação bem-sucedida! ✨",
                            "message": "Seu amigo indicado assinou a Lawrence Academy. Você recebeu R$ 20,00 de crédito em sua próxima mensalidade!",
                            "notification_type": "success",
                        }
                    ).execute()

    @staticmethod
    async def _process_payment_failed(event: dict) -> None:
        """Trata a falha de pagamento (muda status para past_due e notifica o aluno)."""
        invoice = typing.cast(dict[str, typing.Any], event.get("data", {}).get("object", {}))
        stripe_sub_id = _stripe_invoice_subscription_id(invoice)

        if not stripe_sub_id:
            return

        sub_res = (
            database.db.table("subscriptions")
            .update(
                {
                    "status": "past_due",
                    "updated_at": datetime.now(timezone.utc).isoformat(),
                }
            )
            .eq("provider_subscription_id", stripe_sub_id)
            .execute()
        )

        if sub_res.data:
            user_id = typing.cast(dict[str, typing.Any], sub_res.data[0]).get(
                "student_id"
            ) or typing.cast(dict[str, typing.Any], sub_res.data[0]).get("user_id")

            database.db.table("notifications").insert(
                {
                    "user_id": user_id,
                    "title": "Problema no Pagamento",
                    "message": "Não conseguimos cobrar seu cartão. Suas aulas continuam liberadas por 5 dias. Por favor, atualize seus dados de pagamento.",
                    "notification_type": "warning",
                }
            ).execute()

    @staticmethod
    async def _process_subscription_deleted(event: dict) -> None:
        """Trata o cancelamento definitivo de uma assinatura."""
        subscription = typing.cast(dict[str, typing.Any], event.get("data", {}).get("object", {}))
        stripe_sub_id = subscription.get("id")

        sub_res = (
            database.db.table("subscriptions")
            .update(
                {
                    "status": "canceled",
                    "updated_at": datetime.now(timezone.utc).isoformat(),
                }
            )
            .eq("provider_subscription_id", stripe_sub_id)
            .execute()
        )

        if sub_res.data:
            user_id = typing.cast(dict[str, typing.Any], sub_res.data[0]).get(
                "student_id"
            ) or typing.cast(dict[str, typing.Any], sub_res.data[0]).get("user_id")

            database.db.table("notifications").insert(
                {
                    "user_id": user_id,
                    "title": "Assinatura Cancelada",
                    "message": "Sua assinatura foi encerrada. Esperamos ter você de volta em breve!",
                    "notification_type": "info",
                }
            ).execute()

    @staticmethod
    async def _process_subscription_updated(event: dict) -> None:
        """Synchronize Stripe subscription lifecycle changes into access state."""
        subscription = typing.cast(dict[str, typing.Any], event.get("data", {}).get("object", {}))
        stripe_sub_id = subscription.get("id")
        if not stripe_sub_id:
            raise ValueError("Stripe subscription update is missing its id")

        stripe_status = str(subscription.get("status") or "")
        status_map = {
            "active": "active",
            "trialing": "trialing",
            "past_due": "past_due",
            "unpaid": "past_due",
            "incomplete": "past_due",
            "incomplete_expired": "canceled",
            "paused": "past_due",
            "canceled": "canceled",
        }
        local_status = status_map.get(stripe_status)
        if local_status is None:
            raise ValueError("Unsupported Stripe subscription status")

        update_data: dict[str, typing.Any] = {
            "status": local_status,
            "updated_at": datetime.now(timezone.utc).isoformat(),
        }
        try:
            period_start, period_end = _stripe_subscription_period(subscription)
        except ValueError:
            period_start = period_end = None
        if period_start is not None and period_end is not None:
            update_data["current_period_start"] = datetime.fromtimestamp(
                period_start, tz=timezone.utc
            ).isoformat()
            update_data["current_period_end"] = datetime.fromtimestamp(
                period_end, tz=timezone.utc
            ).isoformat()

        database.db.table("subscriptions").update(typing.cast(typing.Any, update_data)).eq(
            "provider_subscription_id", stripe_sub_id
        ).execute()

    @staticmethod
    async def _process_charge_state(event: dict, *, status: str) -> None:
        """Suspend access after a refund or dispute using the invoice relationship."""
        charge = typing.cast(dict[str, typing.Any], event.get("data", {}).get("object", {}))
        invoice_value = charge.get("invoice")
        subscription_id: str | None = None
        if isinstance(invoice_value, dict):
            raw_subscription = invoice_value.get("subscription")
            subscription_id = raw_subscription if isinstance(raw_subscription, str) else None
        elif isinstance(invoice_value, str):
            invoice = typing.cast(typing.Any, stripe.Invoice.retrieve(invoice_value))
            raw_subscription = getattr(invoice, "subscription", None)
            subscription_id = raw_subscription if isinstance(raw_subscription, str) else None

        if not subscription_id:
            raise ValueError("Stripe charge is not linked to a subscription")

        database.db.table("subscriptions").update(
            {
                "status": status,
                "updated_at": datetime.now(timezone.utc).isoformat(),
            }
        ).eq("provider_subscription_id", subscription_id).execute()
