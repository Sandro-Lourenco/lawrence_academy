# Contrato de Schema: Subscription

**Versão:** 1.0.0  
**Data:** 10 de Julho de 2026  
**Status:** Oficial  

---

## 1. Descrição
Este contrato define a estrutura do objeto que representa o direito de acesso recorrente (assinatura ativa) de um estudante a um curso específico.

---

## 2. Estrutura do Objeto (JSON)

```json
{
  "id": "e4f8d2b9-1234-4bc1-9a8b-123456789abc",
  "student_id": "bb0306b3-8da2-448a-99c2-27d802fa058f",
  "course_id": "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa",
  "provider": "stripe",
  "provider_customer_id": "cus_Q12345678",
  "provider_subscription_id": "sub_123456789",
  "status": "active",
  "monthly_price": "89.90",
  "currency": "BRL",
  "current_period_start": "2026-07-01T00:00:00Z",
  "current_period_end": "2026-08-01T00:00:00Z",
  "cancel_at_period_end": false,
  "canceled_at": null,
  "created_at": "2026-07-01T00:00:00Z",
  "updated_at": "2026-07-01T00:00:00Z",
  "deleted_at": null
}
```

---

## 3. Definição de Campos

| Campo | Tipo | Obrigatório | Nullable | Descrição |
|---|---|---|---|---|
| `id` | UUID (String) | Sim | Não | ID único da assinatura na plataforma. |
| `student_id` | UUID (String) | Sim | Não | ID único do estudante associado (FK profiles). |
| `course_id` | UUID (String) | Sim | Não | ID único do curso assinado (FK courses). |
| `provider` | String | Sim | Não | Nome do gateway de pagamento (`stripe` ou `fake`). |
| `provider_customer_id` | String | Não | Sim | ID do cliente no provedor financeiro. |
| `provider_subscription_id` | String | Não | Sim | ID da assinatura no provedor financeiro. |
| `status` | String (Enum) | Sim | Não | Status atual: `active`, `past_due`, `canceled`, `trialing`. |
| `monthly_price` | Decimal (String) | Sim | Não | Preço mensal cobrado (ex: `"89.90"`). |
| `currency` | String | Sim | Não | Código de moeda ISO 4217 (padrão `"BRL"`). |
| `current_period_start` | DateTime (ISO 8601) | Sim | Não | Data de início do ciclo atual (UTC). |
| `current_period_end` | DateTime (ISO 8601) | Sim | Não | Data de término do ciclo atual (UTC). |
| `cancel_at_period_end` | Boolean | Sim | Não | Flag para cancelamento automático no fim do período. |
| `canceled_at` | DateTime (ISO 8601) | Não | Sim | Data e hora de solicitação do cancelamento (UTC). |
| `created_at` | DateTime (ISO 8601) | Sim | Não | Registro de criação (UTC). |
| `updated_at` | DateTime (ISO 8601) | Sim | Não | Registro de atualização (UTC). |
| `deleted_at` | DateTime (ISO 8601) | Não | Sim | Timestamp para deleção lógica/soft delete (UTC). |

---

## 4. Regras de Unicidade
- Apenas uma assinatura ativa por estudante e curso é permitida de forma concorrente.
- A restrição é aplicada no banco através de um índice único parcial:
  `CREATE UNIQUE INDEX idx_active_subscriptions_uniq ON subscriptions(student_id, course_id) WHERE status IN ('active', 'trialing', 'past_due');`
