# 14 — Revisão crítica final do desenho de pagamentos

## Atualização de decisão — 2026-09-16

- **Staging TEST:** `READY_FOR_CONTINUED_RECOVERY_IMPLEMENTATION`. A cadeia Stripe TEST → webhook FastAPI → Supabase foi provada com pagamento técnico e replay idempotente.
- **Produção LIVE:** `BLOCKED`. O environment Production do Render contém zero serviços; Supabase de produção, host público, artefato Flutter, conta/chave Stripe LIVE e webhook LIVE ainda não formam uma cadeia verificável.
- O incidente real de staging confirmou a premissa central do desenho: pagamento aprovado não implica acesso até a projeção local terminar. A assinatura existia no Stripe enquanto `subscriptions` permanecia vazia.
- A correção pontual de compatibilidade do SDK não substitui M1–M5. `payment_checkouts`, estados separados, tri-state/freshness, leases, outcomes/dead-letter e projeção atômica continuam pendentes.

Assim, o veredito global continua **BLOCKED para produção**, mas os bloqueios 1 e 4 da seção 8 foram resolvidos especificamente para staging. O próximo gate de implementação continua dependendo do baseline aprovado e das decisões de negócio de Gate 0C; nenhuma chave LIVE deve ser inserida antes disso.

## 1. Veredito

**BLOCKED.** O modelo conceitual revisado está coerente, mas o sistema não está pronto para M1 porque o runtime real ainda não foi vinculado ao Supabase/Stripe observados e o baseline do projeto consultado revelou drift P1 anterior ao payment recovery.

## 2. Decisão sobre os estados

`active`, `trialing`, `past_due`, `canceled`, `unpaid`, `incomplete`, `incomplete_expired` e `paused` pertencem ao domínio de lifecycle do provedor. `refunded` e `disputed` pertencem ao domínio financeiro. `expired`, `granted`, `grace`, `suspended`, `revoked` e `reconciliation_required` pertencem ao domínio de entitlement.

Portanto, a decisão anterior de ampliar um único `subscription_status` com `expired`, `refunded` e `disputed` foi rejeitada.

### Modelo revisado

| Dimensão | Fonte | Estados mínimos propostos | Observação |
|---|---|---|---|
| `provider_subscription_status` | Stripe Subscription | `incomplete`, `incomplete_expired`, `trialing`, `active`, `past_due`, `unpaid`, `canceled`, `paused`, `unknown` | espelha o provedor sem reinterpretar dinheiro/acesso |
| `financial_status` | Checkout/Invoice/PaymentIntent/Charge/Refund/Dispute | `pending`, `paid`, `payment_failed`, `partially_refunded`, `refunded`, `disputed`, `resolved_won`, `resolved_lost`, `unknown` | pode coexistir com subscription `active` |
| `entitlement_status` | política local auditável | `pending`, `granted`, `grace`, `suspended`, `revoked`, `expired`, `reconciliation_required` | projeção usada para autorização; nunca inferida pelo Flutter |

As dimensões não devem formar um único enum cartesiano. A projeção deve guardar os três e suas observações, mas uma função canônica retorna a decisão de acesso.

### Casos críticos

- **Refund parcial:** `financial_status=partially_refunded`; não revoga automaticamente todo o curso. Acesso só muda se existir uma política explícita que associe o valor reembolsado à concessão integral. Sem essa política, manter entitlement e abrir revisão.
- **Refund integral:** `financial_status=refunded`; revogar somente o entitlement sustentado pela cobrança identificada, preservando histórico e outras concessões.
- **Dispute:** `financial_status=disputed`; a subscription do Stripe pode continuar `active`. Não sobrescrever `provider_subscription_status`. Política recomendada: `entitlement_status=suspended` após vínculo inequívoco da charge; recompra bloqueada até resolução.
- **Dispute ganha pelo comerciante:** recuperar objeto atual e, se a cobrança continuar válida, restaurar entitlement; nunca usar apenas ordem do evento.
- **Dispute perdida:** `resolved_lost`/revoked; provider pode ainda exigir cancelamento separado.
- **`cancel_at_period_end=true`:** não é `canceled`; manter provider `active/trialing` e entitlement até `entitlement_valid_until`, mostrar cancelamento agendado.
- **`unpaid`:** provider `unpaid`, financial `payment_failed`, entitlement `revoked/expired`; recompra permitida conforme política antifraude.
- **Stale `active`:** provider permanece como última observação, mas não concede acesso para sempre sem freshness/validity.

## 3. Stale active e decisão tri-state

Campos mínimos:

- `provider_state_observed_at`: quando a verdade do Stripe foi observada;
- `last_reconciled_at`: quando uma tentativa de reconciliação terminou, com sucesso ou não;
- `entitlement_valid_until`: limite materializado da concessão/grace;
- `last_provider_event_id` e `last_provider_event_created_at`: proteção contra regressão;
- contador/código seguro de falha e `next_reconciliation_at` para operação.

Resultado normativo:

| Condição | Decisão | Efeito imediato |
|---|---|---|
| evidência positiva e `now < entitlement_valid_until` | `ACCESS_GRANTED` | liberar |
| observação stale ou validade recém-expirada, sem evidência negativa, dentro de buffer operacional limitado | `RECONCILIATION_REQUIRED` | manter acesso provisoriamente e enfileirar reconciliação prioritária |
| evidência negativa explícita (`unpaid`, cancelamento efetivo, refund integral, dispute aplicável) | `ACCESS_DENIED` | negar |
| buffer máximo excedido sem confirmar pagamento | `ACCESS_DENIED` | negar com suporte/recovery, nunca fingir cancelamento Stripe |

`RECONCILIATION_REQUIRED` é fail-soft e precisa carregar `access_temporarily_allowed=true`, deadline e reason code. Isso evita cortar um cliente pago por uma indisponibilidade curta sem permitir `active` eterno.

O valor exato do buffer não deve ser enterrado em código. Recomendação inicial para teste: 24 horas após `entitlement_valid_until`, configurável e monitorada. A duração final é uma decisão de risco financeiro/produto ainda bloqueada; deve ser aprovada antes de M1.

## 4. Idempotência de Checkout

A chave enviada hoje ao Stripe é útil, mas não resolve o intervalo anterior à persistência local porque não existe ledger local de checkout.

Decisão revisada:

- adicionar `client_idempotency_key` não nula a `payment_checkouts`;
- unique `(provider, student_id, client_idempotency_key)`;
- guardar `request_fingerprint` dos campos server-owned relevantes (`course_id`, amount, currency e return target normalizado);
- inserir/reservar a linha local antes da chamada Stripe;
- conflito com mesma chave e mesmo fingerprint retorna/retoma o checkout existente;
- mesma chave com fingerprint diferente retorna conflito e não chama Stripe;
- usar chave Stripe determinística derivada do checkout local, permitindo retry seguro se a resposta Stripe se perder antes de salvar `provider_checkout_session_id`;
- manter unique `(provider, provider_checkout_session_id)` quando o provider ID existir.

O escopo não inclui `course_id` na constraint única: reutilizar a mesma chave para outro curso é erro de payload, não uma nova tentativa legítima.

Também foi aceita a separação:

| Campo | Exemplos | Responsabilidade |
|---|---|---|
| `payment_status` | `pending`, `paid`, `failed`, `expired`, `partially_refunded`, `refunded`, `disputed` | verdade financeira observada |
| `provisioning_status` | `not_started`, `pending`, `applied`, `reconciliation_required`, `failed` | conversão da confirmação em entitlement |

Um checkout `paid` + `provisioning_status=pending` é normal durante convergência e jamais autoriza “Curso liberado”.

## 5. Classificação de falhas de webhook

Assinatura inválida ocorre antes do ledger: o payload não é confiável, recebe 400 e não vira evento replayable.

Para evento autenticado e duravelmente registrado:

| Resultado | Definição | HTTP após persistência | Replay |
|---|---|---|---|
| `APPLIED` | efeito local transacional confirmado | 2xx | idempotente/no-op |
| `IGNORED` | tipo reconhecido como não acionável, com reason code | 2xx | normalmente não |
| `SUPERSEDED` | evento válido, porém mais antigo que a verdade já aplicada/objeto atual | 2xx | não regressivo |
| `RETRYABLE` | dependência transitória, lock, timeout, zero-row ainda reconciliável ou Stripe/Supabase indisponível | non-2xx enquanto o delivery externo ainda é útil; retry interno durável com backoff | automático e manual controlado |
| `TERMINAL_FAILED` | payload autenticado estruturalmente inválido, relação impossível ou violação permanente que exige correção humana | 2xx **somente depois** de gravar dead-letter e disparar alerta | manual após correção, com ator/motivo/auditoria |

`processing_status` e `outcome` devem ser campos separados. `RETRYABLE` não pode parecer sucesso; `TERMINAL_FAILED` não pode causar retry Stripe infinito. Toda transição precisa de `error_code` seguro, attempt count, timestamps e hash; payload integral deve ter retenção/proteção explícitas.

Casos de invoice sem relação de subscription:

1. tentar normalização legacy/Basil;
2. se houver ID confiável, recuperar objeto atual;
3. indisponibilidade da recuperação: `RETRYABLE`;
4. payload autenticado permanentemente incompatível: `TERMINAL_FAILED`, dead-letter, alerta, 2xx depois do commit;
5. replay manual usa o event ID original, nunca cria um evento artificial sem lineage.

## 6. Impacto de migration

A mudança deve ser aditiva e bifásica:

1. baseline/ambiente antes de qualquer DDL;
2. criar novos enums/colunas/tabelas sem remover `subscriptions.status`;
3. backfill determinístico com `unknown/reconciliation_required` quando não houver prova;
4. dual-read/validação sombreada;
5. reconciliar no Stripe TEST/staging;
6. trocar a função canônica e consumers;
7. só em release posterior retirar o campo legado.

Riscos: enum PostgreSQL e transações; backfill falso a partir de dados stale; locks de índice; duplicidades de provider ID; policy/grant divergente; clientes antigos. Por isso M1 não pode simplesmente executar `ALTER TYPE subscription_status ADD VALUE`.

## 7. Decisões mantidas e alteradas

Mantidas:

- Stripe paid não equivale a acesso confirmado;
- ledger local de checkout é necessário;
- função canônica única para acesso/compra;
- webhook com claim/lease, idempotência, proteção contra ordem e zero-row observável;
- UI só afirma liberação após autorização local;
- cinco dias continuam como proposta para `past_due`, com fronteira temporal exclusiva;
- RLS, privilégio mínimo, E2E Stripe TEST e rollout por gates.

Alteradas:

- enum único foi substituído por três dimensões;
- `active/trialing` não concedem acesso indefinidamente: entram freshness, validity e tri-state;
- `payment_checkouts.status` foi dividido em payment/provisioning;
- idempotência passou a ser reservada localmente antes da chamada Stripe;
- payload permanente inválido termina em dead-letter/2xx após persistência, não non-2xx infinito;
- M1 agora começa por environment/baseline e migration aditiva, não extensão direta do enum existente.

## 8. Bloqueios remanescentes

1. vínculo do runtime real com API, Supabase, Stripe account/mode e webhook;
2. baseline repetido no banco identificado pelo Gate 0A;
3. plano separado para drift P1 pré-existente;
4. staging Supabase ativo e Stripe TEST identificado;
5. decisão de negócio sobre buffer stale e política de dispute/refund parcial;
6. inventário de dados/duplicidades antes de constraints;
7. definição de retenção, alerta, dead-letter e autoridade de replay.

Enquanto qualquer item 1–4 estiver aberto, o status permanece **BLOCKED**.
