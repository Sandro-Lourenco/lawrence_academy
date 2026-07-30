---
id: AUDIT-RC-QA-2026-07-24
title: Gate independente do candidato de autoria
status: production-blocked
owner: qa-security
date: 2026-07-24
scope: teacher-authoring-release-candidate
---

# Resultado executivo

O lote de idempotência de autoria e publicação está apto a seguir como candidato,
mas não autoriza produção. O backend e o banco possuem evidência local verde; o
gate Flutter completo e o E2E em staging continuam obrigatórios.

# Evidências verificadas

| Gate | Resultado | Evidência |
| --- | --- | --- |
| Backend completo | aprovado | `201 passed`, Mypy e Ruff verdes |
| Backend focado em idempotência | aprovado | header obrigatório, recurso determinístico e hash de publicação |
| Supabase reset | aprovado pelo executor Data/Backend | todas as migrations aplicadas localmente |
| Supabase lint | aprovado pelo executor Data/Backend | zero erros |
| Supabase completo | aprovado | 19 arquivos, 111 testes |
| pgTAP de idempotência | aprovado pelo executor Data/Backend | 26/26 no arquivo focado |
| Concorrência PostgreSQL multiconexão | aprovado | duas conexões produziram uma versão, um ledger e um histórico |
| E2E professora -> FastAPI -> Supabase | aprovado | autoria, replay, publicação, cardinalidade e cleanup |
| Flutter focado no Studio | aprovado | 18 testes de autosave, CAS, polling e idempotência |
| Flutter completo neste host | sem evidência | processo iniciou sem produzir saída e não encerrou |
| Remoto/produção | não executado | proibido neste lote |

# Controles implementados e revisados

- `Idempotency-Key` obrigatório nas seis mutações POST críticas de autoria;
- ledger privado, sem grants para `anon` ou `authenticated`;
- fingerprint rejeita reutilização da chave com payload diferente;
- escopo por ator e operação;
- publicação serializada por lock do curso;
- alterações em módulos, aulas e blocos incrementam a revisão autoral;
- replay não incrementa versão nem histórico;
- BOLA de publicação retorna negação;
- cliente Flutter bloqueia reentrada e mantém a chave em falha ambígua;
- reordenação de blocos é uma única RPC transacional com CAS;
- autosave é serializado, preserva rascunho offline e trata `409` sem sobrescrever;
- `service_role` possui somente os grants necessários à autoria e ao checklist;
- CI unificado executa banco local, backend e Flutter sobre o mesmo SHA.

# Riscos residuais bloqueantes

1. A interface Flutter continua fora do E2E local de professora, FastAPI e Supabase.
2. O gate Flutter completo precisa passar em runner Linux e dispositivo Android.
3. Staging, observabilidade, backup/restore e rollback não foram comprovados.

# Gate reproduzível

O workflow `.github/workflows/release-candidate-ci.yml` executa:

```text
Supabase local start
  -> db reset
  -> db lint
  -> test db
  -> publicação concorrente em duas conexões psql
  -> fixtures locais + login + RLS
  -> professora -> FastAPI -> curso/módulo/aula/bloco -> publicação/replay
  -> backend lint/types/tests/container
  -> Flutter analyze/tests/Web/App Bundle
  -> gate agregado
```

O workflow não contém deploy nem credenciais de projeto remoto. As fixtures
recusam execução quando a URL Supabase não aponta para localhost.

## Executar a concorrência localmente

Com a stack Supabase local ativa:

```powershell
pwsh ./scripts/ci/test-course-publication-concurrency.ps1
```

O harness usa `psql` do host quando disponível. Caso contrário, descobre
exatamente um container local cujo nome corresponda a `supabase_db_*` e envia os
arquivos SQL por `docker exec -i`/stdin, sem depender de caminhos montados.
Ambiguidade, container parado, nome inválido ou URL PostgreSQL não local
interrompem a execução. Para selecionar explicitamente entre várias stacks:

```powershell
pwsh ./scripts/ci/test-course-publication-concurrency.ps1 `
  -DatabaseContainer 'supabase_db_nome-local'
```

## Executar o E2E de autoria localmente

Com Supabase, fixtures e FastAPI locais ativos:

```powershell
pwsh ./scripts/ci/test-teacher-authoring-e2e.ps1 `
  -BackendUrl 'http://127.0.0.1:8000' `
  -SupabaseUrl 'http://127.0.0.1:54321' `
  -SupabaseAnonKey '<anon-local-efêmera>' `
  -SupabaseServiceRoleKey '<service-role-local-efêmera>' `
  -TeacherPassword '<senha-local-da-fixture>'
```

O script recusa URLs não locais, autentica a professora pela Auth local, cria e
repete curso, módulo, aula, bloco e publicação pela API. Os asserts finais leem
o banco local pela Data API privilegiada e exigem cardinalidade um. O curso e
os registros operacionais sintéticos são removidos no bloco `finally`.

# Decisão

**NO-GO para produção.**

Pode avançar para CI e homologação local/staging. A decisão muda somente após o
workflow unificado verde no mesmo commit, E2E do fluxo professor em staging e
aprovação humana de QA, Segurança e Produto.
