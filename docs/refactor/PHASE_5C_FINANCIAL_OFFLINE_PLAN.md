# Phase 5C Lote 1 - Subscriptions, Payments & Invoices

## Visão Geral
Esta fase implementa as funcionalidades financeiras no Flutter (Subscriptions, Payments, Invoices) conectando com os contratos da API v1 definidos no backend, mantendo o backend como a fonte da verdade para segurança e autorização, de acordo com o `PED-overview.md` e `SERVICE_API.md`.

## Escopo
1. **Subscriptions (Assinaturas)**
   - Listagem de assinaturas ativas e inativas do usuário (`/api/v1/subscriptions`).
   - UI de Gerenciamento da Assinatura e Histórico.
2. **Payments (Pagamentos)**
   - Fluxo de Checkout para cursos (redirecionamento Stripe).
   - `POST /api/v1/subscriptions/checkout`.
   - Histórico de pagamentos.
3. **Invoices (Faturas)**
   - Listagem e visualização (ou download) das faturas.

## Arquitetura (Flutter)
- `features/subscriptions`
  - `domain`: `Subscription` entity, `SubscriptionRepository` interface, UseCases (`GetSubscriptionsUseCase`, `CheckoutCourseUseCase`).
  - `data`: `SubscriptionRepositoryImpl`, `SubscriptionRemoteDataSource` (consumindo `/api/v1/subscriptions`).
  - `presentation`: `SubscriptionsController`, UI Pages (`SubscriptionsPage`, `CheckoutRedirectPage`).
- `features/payments`
  - `domain`: `Payment` entity, `PaymentRepository`.
  - `data`: `PaymentRepositoryImpl`, `PaymentRemoteDataSource`.
  - `presentation`: `PaymentHistoryController`, `PaymentHistoryPage`.
- `features/invoices`
  - `domain`: `Invoice` entity, `InvoiceRepository`.
  - `data`: `InvoiceRepositoryImpl`, `InvoiceRemoteDataSource`.
  - `presentation`: `InvoicesController`, `InvoicesPage`.

## Segurança
- Nenhum estado local determina acesso premium. O Flutter apenas exibe as assinaturas.
- Secrets e manipulação do Stripe restritas ao Backend. O app apenas recebe a URL e abre a página (`url_launcher`).
- RLS do Supabase protegido via token JWT.

## Passos da Execução
1. Mapear DTOs e Entities.
2. Implementar repositórios (NetworkClient).
3. Criar Controllers (Riverpod `AutoDisposeAsyncNotifier`).
4. Desenvolver UI usando Lawrence Design System.
5. Ajustar Rotas no `GoRouter` (`/subscriptions`, `/payments`, `/invoices`).
6. Testes unitários para UseCases e Repositórios.
