# 12 — Mapa estático dos ambientes de runtime

## Atualização operacional — 2026-09-16

O vínculo de **staging** deixou de ser apenas estático e foi verificado de ponta a ponta:

| Component | Environment | Host/project observado | Source of configuration | Estado |
|---|---|---|---|---|
| FastAPI | staging | `lawrence-api-staging.onrender.com`; deploy `c5edcb7` | Render service `srv-d9tlhoajobas73da1nhg`, branch `codex/staging-rc1` | **VERIFIED** |
| Supabase | staging | project ref `ctjsmeyilapeliptelfk` | `render.yaml` + ambiente efetivo do serviço | **VERIFIED**; Auth, SQL e projeção de pagamento exercitados |
| Stripe | staging | account `acct_1TY5Qb0B75YqkOQv`, TEST | chave restrita no Render; account/mode confirmados no Dashboard | **VERIFIED** |
| Stripe webhook | staging | `/api/v1/payments/webhook`, endpoint `we_1UDq980B75YqkOQvpkzCSJdd`, API `2026-04-22.dahlia` | Stripe Workbench | **VERIFIED**; replay real respondeu 200 |
| Payment projection | staging | Stripe TEST → FastAPI → Supabase | evento `invoice.payment_succeeded` autenticado | **VERIFIED**; evento processado e assinatura local ativa |
| Flutter distribuído | staging/produção | artefato efetivamente instalado não inspecionado | `--dart-define`/workflow | **UNVERIFIED** |
| FastAPI/worker | produção | nenhum recurso no environment Production do Render | Dashboard Render | **MISSING** |
| Supabase | produção | projeto/runtime definitivo não vinculado | configuração futura | **BLOCKED** |
| Stripe/webhook | produção | conta LIVE e endpoint LIVE não configurados/validados | configuração futura | **BLOCKED** |

O ambiente **Production** do projeto Render foi inspecionado e está vazio (`All (0)`, `Services (0)`). Portanto, staging TEST está operacional, mas não existe hoje um backend Render de produção para receber chaves LIVE ou webhooks LIVE. Criar os serviços declarados como `starter` em `render.yaml` pode gerar custo e exige decisão operacional explícita.

O Gate 0A passa para **VERIFIED FOR STAGING / BLOCKED FOR PRODUCTION**. Isso autoriza testes e correções em TEST, mas não autoriza reutilizar o Supabase de staging, a conta Stripe TEST ou o endpoint TEST em produção.

Data da verificação: 2026-09-05  
Método: inspeção estática do workspace e consulta somente leitura do catálogo Supabase. Nenhum deploy, secret, cobrança, evento Stripe ou configuração externa foi alterado.

## 1. Resultado do Gate 0A

**Gate 0A: BLOCKED.** O repositório define como os valores devem entrar em cada build e serviço, mas não prova quais valores foram usados nos artefatos Flutter distribuídos nem quais valores estão efetivamente salvos no serviço Render de produção e no endpoint Stripe. O projeto Supabase `lawrence-academy` acessível nesta auditoria foi confirmado como `xblesfvcrnbsfhlmoffz`, porém não há evidência estática de que ele seja o projeto consumido pelo runtime que recebeu as compras relatadas.

O sinal mais forte da incerteza é a combinação:

- Supabase acessível chamado `lawrence-academy`: `https://xblesfvcrnbsfhlmoffz.supabase.co`, estado `ACTIVE_HEALTHY`;
- nesse projeto, `public.payment_events = 0` e `public.subscriptions = 0` no snapshot anterior desta auditoria;
- existem relatos de compras;
- `render.yaml` deixa `SUPABASE_URL`, chaves Stripe e segredo do webhook de produção como valores externos (`sync: false`);
- o workflow Android recebe `api_base_url`, `public_web_url` e `supabase_url` manualmente a cada build e não registra um manifesto sanitizado de vínculo entre eles.

Isso admite, no mínimo, quatro hipóteses ainda não distinguíveis: runtime apontando para outro projeto; compras ocorridas em outro ambiente/conta Stripe; banco recriado/limpo; ou webhook não chegando ao serviço observado.

## 2. Cadeia real de configuração

```text
Flutter Android/Web
  ├─ API_BASE_URL --dart-define ──> NetworkClient ──> FastAPI /api/v1/*
  └─ SUPABASE_URL + anon key ─────> Supabase.initialize (Auth/Storage/Data API)

FastAPI deploy
  ├─ SUPABASE_URL + service role ─> projeto PostgreSQL/Supabase
  ├─ STRIPE_SECRET_KEY ───────────> conta Stripe e modo inferidos pela chave
  └─ STRIPE_WEBHOOK_SECRET <────── Stripe endpoint configurado externamente
                                      ├─ /api/v1/payments/webhook (canônico)
                                      └─ /webhooks/stripe (legado)
```

O Flutter fala com dois hosts independentes: `API_BASE_URL` para FastAPI e `SUPABASE_URL` para Auth/Storage. A validação atual exige HTTPS em stage/prod, mas não verifica que o Supabase embutido no app corresponde ao Supabase configurado na API.

## 3. Matriz de wiring

| Component | Environment | Host/project esperado ou observado | Source of configuration | Estado |
|---|---|---|---|---|
| Flutter Android flavor `production` | produção | API desconhecida; Supabase desconhecido | inputs manuais `api_base_url`, `supabase_url` e secret `SUPABASE_ANON_KEY` em `.github/workflows/android-production-apk.yml`; compilados por `--dart-define` | **UNVERIFIED**: não foi inspecionado o AAB/APK efetivamente publicado nem o run que o gerou |
| Flutter Android flavor `staging` | staging | API fornecida pelo operador; default Supabase `ctjsmeyilapeliptelfk` | `scripts/build-staging-apk.ps1`; `ApiBaseUrl` obrigatório e `SupabaseUrl` com default explícito | **PARTIALLY VERIFIED**: regra estática confirmada; artefato distribuído não verificado |
| Flutter Web via Docker local | development | API `http://localhost:8000`; Supabase `http://localhost:54321` no override local | `docker-compose.yml`, `docker-compose.local.yml`, `lawrence/Dockerfile` | **VERIFIED AS CONFIG TEMPLATE**, não como processo em execução |
| Flutter Web staging/produção | stage/prod | host web não definido no blueprint Render | `lawrence/Dockerfile` aceita build args; não há serviço web Flutter em `render.yaml` | **UNVERIFIED**: host, artefato e argumentos reais não encontrados |
| FastAPI local | development | porta local 8000; Supabase pode ser remoto do `.env` ou local via overrides | `.env`, `docker-compose.yml`, `docker-compose.local.yml` | **CONFIGURABLE/UNVERIFIED**; valores secretos não foram lidos |
| FastAPI Render staging | staging | serviço `lawrence-api-staging`; Supabase `ctjsmeyilapeliptelfk` | `render.yaml`; URL do Supabase versionada, secrets externos | **PARTIALLY VERIFIED**: declaração estática; projeto Supabase está `INACTIVE`; valores Stripe não verificados |
| FastAPI Render produção | produção | serviço nomeado `lawrence-api-production`; hostname provável `lawrence-api-production.onrender.com`; Supabase desconhecido | `render.yaml`, todos os vínculos operacionais relevantes com `sync: false` | **UNVERIFIED**: nome do serviço é versionado; URL pública e env efetivo não foram confirmados |
| Video worker Render staging | staging | `lawrence-video-worker-staging` → Supabase `ctjsmeyilapeliptelfk` | `render.yaml` | **PARTIALLY VERIFIED**: configuração estática; projeto inativo |
| Video worker Render produção | produção | `lawrence-video-worker-production` → Supabase desconhecido | `render.yaml`, `SUPABASE_URL` e service role externos | **UNVERIFIED** |
| Supabase acessível chamado `lawrence-academy` | presumida produção | project ref `xblesfvcrnbsfhlmoffz`; URL confirmada pelo provedor | projeto Supabase conectado à auditoria | **VERIFIED AS AN ACCESSIBLE PROJECT**, não como destino do runtime real |
| Supabase staging | staging | project ref `ctjsmeyilapeliptelfk` | `render.yaml` e script de APK staging | **VERIFIED ID / INACTIVE**; schema/runtime não validado |
| Stripe no FastAPI staging | staging | conta e modo desconhecidos | `STRIPE_SECRET_KEY` e `STRIPE_WEBHOOK_SECRET` externos em `render.yaml` | **UNVERIFIED**; staging não valida prefixo `sk_test_` e poderia receber chave live por erro |
| Stripe no FastAPI produção | produção | conta desconhecida; modo deve ser LIVE para o processo iniciar | `backend/src/shared/config.py` exige prefixo `sk_live_`; valor externo em `render.yaml` | **PARTIALLY VERIFIED**: fail-fast de modo; account ID e secret efetivo não verificados |
| Webhook canônico | stage/prod | `<API_ORIGIN>/api/v1/payments/webhook` | rota em `backend/src/modules/payments/interface/api/routes.py` | **VERIFIED IN CODE / UNVERIFIED IN STRIPE** |
| Webhook legado | stage/prod | `<API_ORIGIN>/webhooks/stripe` | rota de compatibilidade no mesmo arquivo | **VERIFIED IN CODE / UNVERIFIED USAGE** |

## 4. Evidências no código

- `lawrence/lib/app/config/env_config.dart`: `ENV`, `API_BASE_URL`, `SUPABASE_URL`, `SUPABASE_ANON_KEY` e `PUBLIC_WEB_URL` são constantes de compilação. Stage/prod não têm fallback de API ou Supabase e exigem HTTPS.
- `lawrence/lib/main.dart`: inicializa o cliente Supabase com os valores compilados.
- `lawrence/lib/core/network/network_client.dart`: usa `env.apiBaseUrl` como origem das chamadas FastAPI.
- `.github/workflows/android-production-apk.yml`: os três hosts vêm de `workflow_dispatch`; o workflow só valida HTTPS, não a associação entre API, Supabase e ambiente.
- `lawrence/Dockerfile`: incorpora os mesmos valores no bundle Web; não existe descoberta dinâmica em runtime.
- `render.yaml`: staging fixa o Supabase `ctjsmeyilapeliptelfk`; produção delega `PUBLIC_WEB_URL`, `SUPABASE_URL`, chaves Stripe e webhook ao painel Render.
- `backend/src/shared/config.py`: produção exige Supabase/Web HTTPS, `PAYMENT_PROVIDER=stripe`, `sk_live_` e `whsec_`; staging não exige `sk_test_`.
- `backend/src/modules/payments/interface/api/routes.py`: recebe webhooks no caminho canônico e mantém o caminho legado.

## 5. Riscos encontrados

| ID | Severidade | Evidência | Impacto |
|---|---:|---|---|
| ENV-001 | P1 | Supabase presumido de produção vazio apesar de relatos de compras; vínculo do Render é externo | auditoria e recovery podem mirar o banco errado |
| ENV-002 | P1 | account ID, mode real, endpoint ID, URL e API version do Stripe não estão versionados nem confirmados | eventos podem ir a outro serviço/conta/modo |
| ENV-003 | P1 | AAB/APK aceita endpoints manuais sem manifesto de ambiente nem cross-check | cliente publicado pode autenticar em um projeto e chamar API ligada a outro |
| ENV-004 | P2 | staging não rejeita `sk_live_` | risco de teste acionar LIVE por misconfiguration, embora nenhuma ação financeira tenha sido executada aqui |
| ENV-005 | P2 | `ALLOWED_ORIGINS` de staging contém a própria API e não um host Flutter Web conhecido | browser staging pode falhar por CORS |
| ENV-006 | P2 | serviço Flutter Web de stage/prod não está descrito em `render.yaml` | origem pública e retorno de Checkout ficam indeterminados |

## 6. Evidência necessária para abrir o gate

Sem revelar valores secretos, um operador deve produzir um manifesto assinado/sanitizado contendo:

1. SHA-256 e versão do AAB/APK/Web atualmente distribuídos;
2. `ENV`, origem de `API_BASE_URL`, origem de `PUBLIC_WEB_URL` e apenas o project ref extraído de `SUPABASE_URL` do artefato;
3. service ID, URL pública e deploy commit do FastAPI efetivamente atendendo esse cliente;
4. project ref extraído do `SUPABASE_URL` efetivo do FastAPI e do worker;
5. Stripe account ID, livemode boolean e prefixo seguro da chave (`sk_live_`/`sk_test_`, nunca a chave);
6. webhook endpoint ID, URL, modo, API version, eventos inscritos e timestamp do último delivery;
7. prova de que client, API, worker, Stripe e webhook pertencem ao mesmo ambiente lógico.

Esses itens são verificações operacionais read-only. Até existirem, não se deve aplicar M1 em nenhum banco.
