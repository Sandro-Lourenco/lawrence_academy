# Phase 5C - Lote 1 Financial Report

## Visão Geral

Este documento detalha as implementações, refatorações e integrações realizadas durante a **Fase 5C - Lote 1 (Financeiro)** do aplicativo Flutter da Lawrence Academy. O escopo abrangeu Assinaturas (Subscriptions), Pagamentos (Payments/Checkout) e Faturas (Invoices).

Todas as modificações seguiram estritamente a documentação arquitetural, utilizando Clean Architecture, Riverpod, e integrações via API backend (removendo qualquer acesso direto ao Supabase SDK na UI).

---

## 1. Invoices (Faturas)
### Implementação Clean Architecture

As faturas foram implementadas como uma funcionalidade completa dentro da arquitetura do aplicativo.

- **Domain Layer:** Criada a entidade `Invoice` contendo os dados essenciais (amountPaid, currency, status, pdf url, etc.). Adicionados os use cases `GetInvoicesUseCase` e o contrato de repositório.
- **Data Layer:** Implementado o `InvoiceModel` para desserialização do JSON, e a integração na API com `InvoiceRemoteDataSource` e `InvoiceRepositoryImpl` chamando `GET /api/v1/invoices`.
- **Presentation Layer:** Criado o `InvoicesController` (AutoDisposeAsyncNotifier) para gerenciar o estado e tratar requisições. A `InvoicesPage` foi redesenhada de acordo com o Lawrence Design System, apresentando os estados: loading, success, empty, error, e offline. Implementada a visualização/download de faturas através do package `url_launcher`.

---

## 2. Checkout & Pagamentos (Payments)
### Fluxo Confiável e Prevenção de Falhas

O botão de Checkout e a integração de Pagamento foram ajustados para maior segurança e estabilidade, com polling de confirmação pelo Backend.

- **Double Tap Prevention:** O botão de Checkout agora possui um estado `_isLoading` local para prevenir a criação de múltiplas sessões do Stripe por toques duplos.
- **Idempotency Key:** Na camada do Flutter, implementamos a geração do Idempotency Key via `uuid`. A chave é enviada para `POST /api/v1/payments/checkout` através do header `Idempotency-Key` (e também no payload via Data Source), garantindo que apenas uma sessão seja gerada.
- **Deep Link Handling & Polling:** O Success URL agora envia o usuário de volta para o App via `lawrence://payment/pending/{CHECKOUT_SESSION_ID}`.
- **PaymentPendingPage:** Criada página dedicada (`PaymentPendingPage`) mapeada no GoRouter (`/payment/pending/:sessionId`). A página entra em uma rotina de Polling chamando `GET /api/v1/payments/checkout/status/{session_id}` a cada 2 segundos para validar o status real do pagamento diretamente no servidor (webhook do Stripe processado no backend), prevenindo a liberação de conteúdo de forma prematura ou insegura por spoofing de URL.

---

## 3. Subscriptions (Assinaturas)
### Mapeamento de Estados e UI

O modelo de Assinaturas foi incrementado para comportar de forma segura o controle de acesso e visualizações de expiração.

- **Status Handle:** O `Subscription` entity agora processa e provê computados para os status do Stripe: `isActive`, `isTrialing`, `isCanceled`, `isPastDue`, e `isExpired`. Também foi mapeado o `hasAccess` combinando se a assinatura está ativa, ou se foi cancelada, mas o período vigente de acesso ainda está ativo (`current_period_end`).
- **Access until current_period_end:** A interface (`SubscriptionsPage`) foi atualizada para indicar precisamente se a data informada é a de "Próxima cobrança" ou "Acesso até" (caso o `cancel_at_period_end` seja verdadeiro).
- **Cancelamento:** Confirmado o funcionamento do UseCase de Cancelamento, que reflete imediatamente as mudanças nos estados e renova o cache via `ref.invalidate`.

---

## 4. Integração Backend (API v1)

- Adicionado o EndPoint de consulta de Invoices: `GET /api/v1/invoices` utilizando o Stripe SDK.
- Adicionado o EndPoint de status de Checkout: `GET /api/v1/payments/checkout/status/{session_id}` permitindo o app Flutter fazer polling sem exigir chaves sensíveis.
- As rotas da v1 para invoices foram registradas no módulo e atreladas em `main.py`.

---

> [!NOTE]
> Todos os acessos de banco de dados e controle financeiro foram delegados integralmente para a Service Role via Python API (FastAPI), validando a postura de não expor regras de negócios críticas no Client Side (Flutter).

## Próximos Passos (Próxima Fase)
- Iniciar a Fase 5C - Lote 2 (Downloads e Offline Storage via SQLite), conforme documentado.
