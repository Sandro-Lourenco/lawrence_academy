# Plano de Banco de Dados e Segurança (Fase 3) — Lawrence Academy

**Versão:** 1.0.0  
**Data:** 10 de Julho de 2026  
**Responsável:** Antigravity AI Engineering Team  
**Status:** Proposta de Plano de Migração — Aguardando Aprovação  

---

## 1. Estado Atual das Tabelas e Dados Existentes

Realizada a auditoria programática na base de dados ativa do Supabase (`https://xblesfvcrnbsfhlmoffz.supabase.co`), com os seguintes resultados:

- **`profiles`:** 1 registro (estudante `sandrocalebe8@gmail.com`, ID `bb0306b3-8da2-448a-99c2-27d802fa058f`).
- **`courses`:** 0 registros.
- **`lessons`:** 0 registros.
- **`subscriptions`:** 0 registros.
- **`lesson_progress`:** 0 registros.

> [!NOTE]
> Como não existem registros de assinaturas, cursos ou progresso, o risco de perda de dados é **NULO**. A migração estrutural pode ocorrer diretamente sem necessidade de scripts complexos de backfill de dados históricos.

---

## 2. Tabelas Afetadas

### 2.1. `public.subscriptions`
- Renomeação de `user_id` para `student_id`.
- Inclusão do campo `course_id` (UUID, NOT NULL) com chave estrangeira apontando para `public.courses(id)`.
- Inclusão do campo `provider` (TEXT, NOT NULL, ex: `'stripe'`).
- Renomeação de `stripe_customer_id` para `provider_customer_id` (TEXT, Nullable).
- Renomeação de `stripe_subscription_id` para `provider_subscription_id` (TEXT, Nullable).
- Inclusão do campo `monthly_price` (NUMERIC(10,2), NOT NULL, default `0.00`).
- Inclusão do campo `currency` (TEXT, NOT NULL, default `'BRL'`).
- Inclusão dos campos `cancel_at_period_end` (BOOLEAN, default `FALSE`), `canceled_at` (TIMESTAMPTZ, Nullable) e `deleted_at` (TIMESTAMPTZ, Nullable).
- Remoção das restrições antigas de unicidade e criação de índice único condicional para impedir assinaturas ativas concorrentes para o mesmo curso e aluno.

### 2.2. `public.lesson_progress`
- Validação das colunas `user_id` (renomeado/documentado como `student_id` ou mantendo `user_id` com política de propriedade clara) e `lesson_id`.
- Garantia de que `course_id` seja preenchido de forma consistente. Adição de uma constraint para validar que o `course_id` no progresso seja idêntico ao `course_id` da lição.

### 2.3. `public.payment_events` (Nova Tabela)
Tabela criada para controle de idempotência e auditoria de webhooks financeiros.
- `id` UUID PRIMARY KEY (padrão `gen_random_uuid()`)
- `provider` TEXT NOT NULL
- `provider_event_id` VARCHAR(255) NOT NULL
- `event_type` TEXT NOT NULL
- `status` TEXT NOT NULL DEFAULT 'received' (received, processed, failed)
- `payload_hash` VARCHAR(64) NOT NULL
- `received_at` TIMESTAMPTZ NOT NULL DEFAULT NOW()
- `processed_at` TIMESTAMPTZ
- `processing_error` TEXT
- `retry_count` INTEGER DEFAULT 0
- `created_at` TIMESTAMPTZ NOT NULL DEFAULT NOW()

---

## 3. Políticas de RLS Afetadas

### 3.1. `public.profiles`
A política atual de leitura pública (`USING (true)`) expõe e-mails, referral codes e papéis internos de todos os usuários. Será substituída por:
- **`student_select_own_profile`**: Permite ao aluno ler apenas o próprio perfil.
- **`public_select_teacher_profile`**: Permite visualização pública restrita apenas a perfis do tipo `teacher` e `admin`, expondo apenas dados não confidenciais (nome, avatar, bio).
- **`admin_select_all_profiles`**: Permite aos administradores ler todos os perfis.

### 3.2. `public.lessons`
A política atual de lições permite acesso se o usuário possuir *qualquer* assinatura ativa na plataforma. Será atualizada para validar o vínculo do curso específico:
- Acesso concedido se o usuário for o instrutor (`instructor_id`), admin ou se possuir assinatura ativa com `status` em `('active', 'trialing', 'past_due')` **e** cujo `course_id` na tabela `subscriptions` seja igual ao `course_id` da lição.

---

## 4. Triggers e Funções Afetados

- **`public.handle_new_user()`**: Revisada para garantir integridade e atribuir campos iniciais corretamente.
- **Triggers de Mudança de Status de Assinatura**: Ajustes automáticos baseados nos eventos do webhook do Stripe.

---

## 5. Contratos de Dados Afetados

### 5.1. Contratos Flutter (Frontend)
- **Progresso de Aula:** O payload do sync offline deve passar `course_id` obrigatório e usar `watched_seconds` no lugar de `last_position_seconds`.
- **Assinatura:** Mapeamento de `stripe_subscription_id` para `provider_subscription_id` e introdução de múltiplos cursos.

### 5.2. Contratos FastAPI (Backend)
- Rotas de vídeo e streaming `/courses/{course_id}/lessons/{lesson_id}/stream` corrigidas para aceitar apenas requisições autenticadas de estudantes com assinatura válida para aquele curso específico.
- Remoção do fallback mock financeiro automático.

---

## 6. Migration UP (Proposta)

Criaremos uma nova migration sequencial na pasta `supabase/migrations/20260710131000_database_and_security_refactor.sql` contendo:
1. Criação da tabela `payment_events` com restrição UNIQUE composta de `(provider, provider_event_id)`.
2. Alterações na tabela `subscriptions` (renomeação de colunas, adição de `course_id` FK, criação de índices e restrição única de assinatura ativa).
3. Criação de trigger para validação cruzada de integridade de `course_id` em `lesson_progress`.
4. Correção e restrição das políticas de RLS das lições e perfis.

---

## 7. Migration de Rollback (Proposta)

Criaremos o script correspondente de reversão para reverter a tabela `subscriptions` ao estado original e restaurar as políticas RLS flexíveis anteriores caso necessário.

---

## 8. Estratégia de Backup e Backfill

- **Backup:** Como existem dados mínimos, executaremos um backup do registro do perfil existente antes de rodar a migration:
  ```sql
  -- Backup preventivo do perfil de Sandro
  SELECT * FROM public.profiles WHERE email = 'sandrocalebe8@gmail.com';
  ```
- **Backfill:** Por haver zero assinaturas cadastradas, a estratégia de backfill é classificada como **Vazia**. Nenhuma ação de reconciliação de dados antigos é necessária.

---

## 9. Ordem de Aplicação Recomendada

1. Executar backup lógico do perfil existente.
2. Aplicar a migration UP estrutural `20260710131000_database_and_security_refactor.sql`.
3. Executar o script de testes de RLS transacional (`test_schema.sql` adaptado).
4. Validar alterações locais no backend e contratos do Flutter.

---

## 10. Critérios de Aprovação

- Nenhuma perda do perfil de usuário `sandrocalebe8@gmail.com`.
- Todos os testes SQL RLS executando com sucesso (asserts válidos).
- Tentativas de acessar aulas de cursos sem assinatura ativa retornando erro de permissão (RLS Blocked).
- Tentativas de ler perfis alheios sem privilégio administrativo retornando erro.
