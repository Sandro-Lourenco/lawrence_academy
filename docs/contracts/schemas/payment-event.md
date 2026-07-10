# Contrato de Schema: PaymentEvent

**Versão:** 1.0.0  
**Data:** 10 de Julho de 2026  
**Status:** Oficial  

---

## 1. Descrição
Este contrato define a estrutura do objeto que representa eventos de pagamento recebidos via webhook para garantir processamento idempotente.

---

## 2. Estrutura do Objeto (JSON)

```json
{
  "id": "f5e9d2c8-1234-4bc1-9a8b-123456789abc",
  "provider": "stripe",
  "provider_event_id": "evt_123456789abc",
  "event_type": "invoice.payment_succeeded",
  "status": "processed",
  "payload_hash": "a1b2c3d4e5f6...64charhash",
  "processing_error": null,
  "retry_count": 0,
  "received_at": "2026-07-10T13:00:00Z",
  "processed_at": "2026-07-10T13:00:02Z",
  "created_at": "2026-07-10T13:00:00Z"
}
```

---

## 3. Definição de Campos

| Campo | Tipo | Obrigatório | Nullable | Descrição |
|---|---|---|---|---|
| `id` | UUID (String) | Sim | Não | ID único do evento gerado localmente. |
| `provider` | String | Sim | Não | Nome do provedor financeiro (`stripe`). |
| `provider_event_id` | String | Sim | Não | ID único enviado pelo provedor financeiro. |
| `event_type` | String | Sim | Não | Tipo de evento (ex: `customer.subscription.deleted`). |
| `status` | String | Sim | Não | Status de processamento: `received`, `processed`, `failed`. |
| `payload_hash` | String | Sim | Não | Hash SHA256 do payload cru para checagem rápida de integridade. |
| `processing_error` | String | Não | Sim | Descrição do erro em caso de falha de processamento. |
| `retry_count` | Integer | Sim | Não | Número de tentativas de reprocessamento (padrão `0`). |
| `received_at` | DateTime (ISO 8601) | Sim | Não | Data/hora em que a requisição de webhook foi recebida (UTC). |
| `processed_at` | DateTime (ISO 8601) | Não | Sim | Data/hora em que o processamento foi concluído (UTC). |
| `created_at` | DateTime (ISO 8601) | Sim | Não | Registro interno de criação do evento no banco (UTC). |

---

## 4. Garantia de Idempotência
A unicidade da tupla `(provider, provider_event_id)` impede duplicidade de processamento no webhook do gateway de pagamento, protegendo a integridade financeira e de assinaturas do usuário.
- **Erro de Duplicação:** `ERROR: duplicate key value violates unique constraint "uniq_provider_event"` (Retorna 200/204 para o Stripe sem processar novamente).
