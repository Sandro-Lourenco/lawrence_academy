# Contrato de API: Invoices (Faturas)

**Versão:** 1.0.0
**Data:** 10 de Julho de 2026
**Status:** Oficial

---

## 1. Descrição
Este documento especifica os endpoints relacionados à listagem e obtenção de faturas (invoices) do aluno. As faturas são espelhadas ou consultadas a partir do provedor de pagamentos (Stripe).

---

## 2. Endpoints

### 2.1. Listar Faturas do Aluno
- **Método:** `GET`
- **Path:** `/api/v1/invoices`
- **Autenticação:** Requerida (Bearer JWT)
- **Resposta (200 OK):**
  ```json
  {
    "status": "success",
    "data": [
      {
        "id": "in_123456789",
        "amount_paid": 89.90,
        "currency": "BRL",
        "status": "paid",
        "invoice_pdf": "https://pay.stripe.com/receipts/...",
        "hosted_invoice_url": "https://pay.stripe.com/invoice/...",
        "created_at": "2026-07-10T12:00:00Z"
      }
    ]
  }
  ```

### 2.2. Obter Fatura Específica
- **Método:** `GET`
- **Path:** `/api/v1/invoices/{invoice_id}`
- **Autenticação:** Requerida (Bearer JWT)
- **Regra:** O usuário só pode acessar faturas vinculadas à sua própria conta (validação de `customer_id` ou via RLS).
- **Resposta (200 OK):**
  ```json
  {
    "status": "success",
    "data": {
      "id": "in_123456789",
      "amount_paid": 89.90,
      "currency": "BRL",
      "status": "paid",
      "invoice_pdf": "https://pay.stripe.com/receipts/...",
      "hosted_invoice_url": "https://pay.stripe.com/invoice/...",
      "created_at": "2026-07-10T12:00:00Z"
    }
  }
  ```
