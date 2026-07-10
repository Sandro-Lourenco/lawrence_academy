# Contrato de API: Gerenciamento de Assinaturas (Subscriptions)

**Versão:** 1.0.0  
**Data:** 10 de Julho de 2026  
**Status:** Oficial  

---

## 1. Descrição
Este endpoint lista e gerencia as assinaturas do estudante ativo e lida com o redirecionamento/criação da sessão de checkout do Stripe.

---

## 2. Endpoints de Assinatura

### 2.1. Listar Assinaturas do Aluno
- **Método:** `GET`
- **Path:** `/api/v1/subscriptions`
- **Autenticação:** Requerida (Bearer JWT)
- **Resposta (200 OK):**
  ```json
  [
    {
      "id": "e4f8d2b9-1234-4bc1-9a8b-123456789abc",
      "student_id": "bb0306b3-8da2-448a-99c2-27d802fa058f",
      "course_id": "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa",
      "course_title": "Curso de Modelagem",
      "status": "active",
      "monthly_price": 89.90,
      "current_period_end": "2026-08-01T00:00:00Z"
    }
  ]
  ```

### 2.2. Iniciar Checkout de Curso
- **Método:** `POST`
- **Path:** `/api/v1/subscriptions/checkout`
- **Autenticação:** Requerida (Bearer JWT)
- **Request Body:**
  ```json
  {
    "course_id": "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa"
  }
  ```
- **Resposta (200 OK):**
  ```json
  {
    "checkout_url": "https://checkout.stripe.com/pay/cs_live_..."
  }
  ```

---

## 3. Segurança e Regras de Negócio
1. **Regra de Curso Único:** O estudante só pode assinar um curso se não possuir uma assinatura ativa/grace-period para o mesmo. O endpoint de checkout retorna `400 Bad Request` se já existir assinatura ativa:
   ```json
   {
     "detail": "Você já possui uma assinatura ativa para este curso."
   }
   ```
2. **Ambiente Real vs Teste:** Conforme a conformidade do projeto, mocks de checkout financeiro no Stripe só são aceitos quando `APP_ENV=test` ou `PAYMENT_PROVIDER=fake`. Em produção, o checkout redireciona obrigatoriamente para a URL oficial do Stripe.
