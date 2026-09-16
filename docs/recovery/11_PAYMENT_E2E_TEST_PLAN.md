# 11 — Plano obrigatório de testes E2E de pagamento

## Registro parcial executado — 2026-09-16

Foi executado um happy path técnico em Stripe TEST, sem dinheiro real:

- conta técnica e curso pago publicados apenas no Supabase staging;
- Checkout TEST de R$ 19,90/mês criado pelo FastAPI staging;
- assinatura Stripe TEST criada como ativa;
- primeira entrega `invoice.payment_succeeded` retornou 502 e ficou duravelmente `failed`;
- causa confirmada: `StripeObject.metadata` era tratado como `dict`, produzindo erro `get` no SDK Stripe 15;
- correção `c5edcb7` adicionou leitura compatível com dict/StripeObject e teste de regressão;
- 47 testes de pagamentos/assinaturas passaram;
- deploy Render concluiu `Live`;
- replay do mesmo event ID retornou `200 OK`, sem nova cobrança;
- `payment_events.status=processed` e uma assinatura local `active` foram confirmados para aluno+curso, BRL 19,90, com período final em 2026-10-16;
- teste automatizado `test_same_student_can_purchase_two_different_courses` passou, confirmando que o bloqueio é por aluno+curso.

Este registro satisfaz somente a parte backend do cenário 1. Ainda faltam: Flutter real/artefato distribuído, abertura de conteúdo protegido, ledger `payment_checkouts`, concorrência, stale-active, refund/dispute, dead-letter e os demais cenários deste documento. O run completo permanece **PARTIAL / NOT RELEASE APPROVED**.

## 1. Objetivo

Provar em ambiente isolado que dinheiro confirmado no Stripe TEST converge para uma única assinatura local e que somente a autorização local confirmada libera o curso no Flutter.

Nenhum cenário deve usar Stripe LIVE, dados de produção, cartão real ou banco de produção.

## 2. Pré-requisitos bloqueantes

- Supabase staging ativo ou banco efêmero criado exclusivamente para o run;
- Gates 0A–0C aprovados e baseline repetido no banco de staging;
- migrations M1–M5 aplicadas e verificadas nesse ambiente;
- Stripe em TEST com account ID, endpoint ID e API version registrados no artefato do run;
- endpoint webhook apontando para o backend de staging;
- secrets injetados pelo CI, nunca impressos;
- usuário, professor, curso publicado e preço criados com `test_run_id` único;
- logs correlacionáveis por checkout/event/subscription IDs técnicos;
- mecanismo de pausar o consumer ou injetar failpoint somente em staging;
- Flutter integration test apontando exclusivamente para staging;
- limpeza limitada aos objetos do `test_run_id`, preservando logs mínimos de auditoria.

Se staging permanecer inativo ou Stripe TEST continuar inacessível, os E2E ficam **BLOCKED**; mocks não satisfazem este gate.

## 3. Camadas do harness

```text
Flutter integration_test
        │
        ▼
FastAPI staging ───────── Stripe TEST
        │                     │
        ▼                     ▼
Supabase staging ◀──── webhook endpoint
        │
        ▼
assertions read-only de estado e acesso
```

As assertions de banco usam uma identidade de teste com privilégio mínimo. A coleta final guarda somente IDs técnicos, timestamps, statuses, HTTP codes e hashes; não guarda payload integral nem dados de cartão.

## 4. Cenário 1 — Happy path completo

**Fluxo:** aluno compra → Stripe confirma → webhook chega → assinatura fica ativa → curso aparece → conteúdo abre.

**Preparação:** aluno sem assinatura; curso pago publicado; webhook saudável.

**Passos:**

1. Flutter abre `CourseCheckoutPage` e cria checkout.
2. Confirmar que `payment_checkouts` contém vínculo correto e status inicial.
3. Concluir Checkout com método de teste bem-sucedido.
4. Aguardar delivery 2xx do evento.
5. Consultar status autenticado até estado terminal.
6. Abrir dashboard/“Meus cursos”.
7. Abrir uma aula protegida e o endpoint de conteúdo/stream.

**Assertions:**

- uma única linha de checkout para a tentativa;
- um evento `completed/APPLIED`;
- uma única assinatura `active` com aluno/curso/provider corretos;
- `access_granted_at` preenchido;
- API retorna `ACCESS_GRANTED`, `payment_confirmed=true`, `has_access=true`;
- curso aparece em “Meus cursos”;
- conteúdo protegido responde com sucesso;
- nenhuma notificação/efeito duplicado.

**Evidência:** timeline com timestamps e IDs técnicos, screenshot da UI, respostas sanitizadas e queries agregadas.

## 5. Cenário 2 — Webhook atrasado

**Fluxo:** pagamento confirma antes da projeção.

**Preparação:** consumer pausado ou delivery retido no proxy de staging; nunca desabilitar endpoint LIVE.

**Passos:** concluir Checkout, consultar status enquanto o evento está retido, observar UI, liberar delivery e continuar polling.

**Assertions antes do delivery:**

- UI passa por `PAYMENT_CONFIRMED`/`ACCESS_PROVISIONING`;
- não contém “Curso liberado”;
- não navega ao conteúdo;
- acesso protegido continua negado;
- após limiar, pode mostrar `ACCESS_DELAYED`, sem chamar o pagamento de falho.

**Assertions depois do delivery:**

- a mesma tela converge para `ACCESS_GRANTED`;
- curso aparece e abre sem novo pagamento;
- apenas uma assinatura/check-out/event effect.

## 6. Cenário 3 — Webhook duplicado

**Fluxo:** o mesmo event ID é entregue duas vezes, inclusive concorrentemente.

**Passos:** capturar evento TEST, enviar duas entregas simultâneas e depois um replay adicional.

**Assertions:**

- uma linha em `payment_events` para `(provider,event_id)`;
- uma aplicação efetiva e demais outcomes duplicate/already_processed;
- uma assinatura vigente;
- uma notificação e um efeito financeiro no máximo;
- respostas não produzem retry infinito;
- payload hash idêntico aceito como duplicate; hash diferente falha fechado.

## 7. Cenário 4 — Queda após `processing`

**Fluxo:** API/worker cai depois do claim e antes da projeção.

**Preparação:** failpoint staging logo após commit do claim; lease curto específico de teste.

**Passos:** entregar evento, acionar failpoint, reiniciar processo, confirmar que lease ainda vigente impede concorrente, avançar relógio/aguardar lease, executar reclaim.

**Assertions:**

- evento permanece auditável em `processing` durante lease;
- `retry_count` incrementa no reclaim;
- somente o dono do novo lease conclui;
- evento termina `completed/APPLIED`;
- assinatura/acesso convergem uma vez;
- nenhum efeito duplicado.

## 8. Cenário 5 — Recompra depois do grace

**Fluxo:** `past_due` com cinco dias completos recompra e recebe nova concessão.

**Preparação:** assinatura Stripe TEST/local `past_due`; relógio de teste ou período controlado. Executar três subcasos: 1 ms antes, exatamente no limite, 1 ms depois.

**Assertions:**

- antes do limite: acesso sim, compra não;
- no limite: acesso não, compra sim;
- depois: acesso não, compra sim;
- ao comprar, concessão antiga vira `expired` atomicamente;
- nova assinatura se torna `active` sem violar índice;
- existe apenas uma concessão vigente aluno/curso;
- histórico antigo permanece consultável.

## 9. Cenário 6 — Evento antigo depois de evento novo

**Fluxo:** lifecycle novo é aplicado e depois um evento anterior é entregue.

**Variantes mínimas:**

- `active` antigo depois de `canceled` novo;
- evento de subscription `active` antigo depois de uma dispute financeira mais nova;
- `past_due` antigo depois de pagamento/`active` novo.

**Assertions:**

- estado mais novo/verdade atual do Stripe não regride;
- evento antigo termina `completed/SUPERSEDED` com auditoria;
- `last_provider_event_*` permanece coerente;
- acesso acompanha o estado final, não a ordem de recebimento.

## 10. Cenário 7 — Update encontra zero linhas

**Fluxo:** evento de update referencia provider subscription ainda inexistente localmente.

**Passos:** entregar update antes da criação/projeção correspondente; observar falha; criar/resolver vínculo; reenviar/reconciliar.

**Assertions:**

- primeira tentativa não termina `completed/APPLIED`;
- erro é classificado retryable e gera métrica/alerta;
- nenhuma linha incorreta é criada a partir de identidade insuficiente;
- após resolução, retry aplica uma vez e concede/revoga conforme verdade atual.

## 11. Cenário 8 — Payload obrigatório incompleto

**Variantes:**

- invoice sem `subscription` legado e sem `parent.subscription_details.subscription`;
- parent de tipo não relacionado a assinatura;
- subscription sem `user_id`;
- subscription sem `course_id`;
- preço recorrente ausente;
- metadata divergente do ledger.

**Assertions:**

- evento termina `RETRYABLE` ou `TERMINAL_FAILED`/dead-letter explícito, nunca `APPLIED`;
- falha transitória retorna non-2xx; falha permanente retorna 2xx somente após dead-letter e alerta duráveis;
- nenhum acesso, assinatura ou benefício é criado;
- erro logado usa código seguro, sem payload/secret/PII;
- evento pode ser reprocessado após correção da causa, com ator, motivo e lineage auditados.

## 12. Cenário 9 — Clique/retry duplicado antes do provider ID

**Fluxo:** duas requisições concorrentes usam o mesmo `Idempotency-Key` antes de `provider_checkout_session_id` ser persistido; uma variante perde a resposta Stripe.

**Assertions:**

- uma linha local para `(provider, student_id, client_idempotency_key)`;
- mesmo fingerprint retoma a tentativa; fingerprint diferente retorna 409 sem chamar Stripe;
- uma única Checkout Session no Stripe;
- retry depois da resposta perdida recupera a mesma sessão;
- `payment_status` e `provisioning_status` evoluem independentemente.

## 13. Cenário 10 — Subscription `active` stale

Executar antes do `entitlement_valid_until`, no limite, dentro do buffer e depois do hard stale deadline, com Stripe temporariamente indisponível.

**Assertions:**

- válido/fresco: `ACCESS_GRANTED`;
- stale dentro do buffer: `RECONCILIATION_REQUIRED`, acesso temporário explícito e reconciliação enfileirada uma vez;
- retorno do Stripe antes do hard deadline restaura `ACCESS_GRANTED` sem interrupção;
- depois do hard deadline sem confirmação: `ACCESS_DENIED`, alerta/suporte e provider status preservado como última observação;
- nenhuma linha `active` concede acesso indefinidamente.

## 14. Cenário 11 — Refund e dispute multidimensionais

Variantes: refund parcial, refund integral, dispute aberta com subscription ainda `active`, dispute ganha e dispute perdida.

**Assertions:**

- refund parcial não revoga automaticamente o entitlement;
- refund integral revoga somente a concessão vinculada;
- dispute não altera `provider_subscription_status=active`, mas suspende o entitlement conforme política aprovada;
- resolução recupera a verdade atual antes de restaurar/revogar;
- eventos fora de ordem não apagam o overlay financeiro.

## 15. Cenário 12 — Terminal failure e replay

Entregar payload autenticado permanentemente incompatível e, separadamente, induzir falha transitória do Supabase/Stripe.

**Assertions:**

- permanente: `TERMINAL_FAILED`, dead-letter/alerta duráveis e resposta 2xx apenas após commit;
- transitória: `RETRYABLE`, non-2xx e retry com backoff;
- replay manual exige identidade autorizada, motivo e mantém o event ID/lineage;
- assinatura inválida recebe 400 e não é persistida como evento confiável;
- nenhum caso produz loop infinito silencioso.

Incluir fixtures para formato legado e para Basil+, cuja referência de assinatura está em `invoice.parent.subscription_details.subscription`.

## 16. Testes complementares obrigatórios

### Banco/RLS

- `anon` e `authenticated` não escrevem `payment_checkouts`, `payment_events` ou `subscriptions`;
- estudante não consulta checkout alheio;
- a função tri-state/wrapper recusa `student_id` diferente de `auth.uid()`;
- service-role só é usado pelo backend;
- constraints e índices existem como especificados;
- RPCs concorrentes não produzem duas concessões.

### API

- JWT ausente/inválido: 401;
- checkout de outro usuário: 403/404 sem enumeração;
- amount, currency, course e user divergentes: falha fechada;
- status composto preserva campos de compatibilidade;
- polling aplica rate limit e `retry_after_seconds`.

### Flutter

- widget/golden sem redesign para os estados compostos;
- sem string “Curso liberado” antes de `ACCESS_GRANTED`;
- retomada Android depois do browser preserva checkout local;
- fechar/reabrir app retoma provisionamento;
- retry de rede não inicia um segundo pagamento;
- acessibilidade anuncia pagamento e acesso como etapas distintas.

## 17. Critérios de aprovação do run

Um run é aprovado somente se:

1. todos os doze cenários passam;
2. nenhuma assertion depende de sleep arbitrário sem polling limitado;
3. nenhuma chamada aponta para LIVE/produção;
4. não há registros duplicados nem eventos presos após o teste;
5. logs não contêm secrets/PII/payload financeiro bruto;
6. relatório inclui API version e endpoint TEST usados;
7. métricas de zero-row, retry e delayed foram observadas nos cenários correspondentes;
8. cleanup remove apenas fixtures identificadas pelo `test_run_id`;
9. suites unitárias, integração, Flutter e pgTAP permanecem verdes.

## 18. Gate de release

- PR: unitários + PostgreSQL efêmero + Flutter widget/integration fake.
- Staging: doze E2E Stripe TEST obrigatórios.
- Produção: smoke read-only pós-deploy e monitoramento; nenhuma cobrança de teste em LIVE.
- Qualquer falha em acesso, idempotência, ownership, zero-row ou replay bloqueia release.

## 19. Evidência que ainda falta hoje

Este plano não foi executado. O Supabase staging está inativo, o Stripe TEST não foi identificado, o runtime real não foi vinculado e o baseline remoto contém drift P1. Até essas condições serem resolvidas, a suíte existente com mocks continua útil, porém insuficiente para aceitar o fluxo financeiro.
