# Fase 01 — relatório de baseline

Data: 22/07/2026
Commit-base observado: `19eeb35`
Worktree observado: 418 entradas modificadas ou novas no início da execução
Status: `BASELINE_AND_FIXTURES_PASS / DEVICE_RUNTIME_PENDING`

## Escopo executado

- inventário do worktree e das toolchains;
- gates estáticos e automatizados de backend e Flutter;
- reconstrução do Supabase local desde migrations;
- lint e testes SQL/RLS;
- builds Web e Android App Bundle;
- correções mínimas necessárias para tornar o gate de banco reproduzível.

Nenhuma alteração existente do usuário foi descartada, resetada ou sobrescrita.

## Evidências

| Gate | Resultado |
| --- | --- |
| Backend Ruff | aprovado, zero ocorrências |
| Backend mypy | aprovado, 116 arquivos |
| Backend pytest | aprovado, 140 testes; 4 warnings não bloqueantes |
| Flutter analyze | aprovado, zero ocorrências |
| Flutter test | aprovado, 109 testes |
| Supabase CLI da CI | `2.84.2` |
| Supabase db reset | aprovado, todas as migrations aplicadas |
| Supabase db lint | aprovado, zero erros de schema |
| SQL/RLS | aprovado, 6 arquivos executados |
| Flutter Web release | aprovado |
| Android App Bundle release | aprovado, 57,1 MB |

## Defeitos encontrados e corrigidos

1. A CI executava testes pgTAP via `psql`, mas o banco reconstruído não criava a
   extensão. Foi adicionado um bootstrap exclusivo de testes em
   `supabase/tests/00000000000000_test_setup.sql`.
2. A policy de lessons era avaliada para acesso anônimo de preview, mas `anon`
   não possuía `EXECUTE` na função protegida. A permissão foi alinhada; a função
   continua retornando verdadeiro apenas quando o argumento corresponde a
   `auth.uid()`.
3. Duas fixtures SQL antigas omitiam `courses.monthly_price`. Como zero é o
   contrato documentado para curso gratuito, os testes de curso pago produziam
   falso positivo de acesso. As fixtures agora declaram `89.90` explicitamente.

## Warnings e dívida técnica

- `pytest`: depreciação do adapter `httpx`/Starlette, dois usos de
  `logger.warn` e cache do pytest sem permissão de escrita;
- Android: atualizar Gradle `8.12.0` para `>= 8.14.0`, AGP `8.9.1` para
  `>= 8.11.1` e Kotlin `2.0.0` para `>= 2.2.20` antes de o Flutter remover
  compatibilidade;
- `file_picker` e `workmanager_android` ainda aplicam o Kotlin Gradle Plugin e
  precisarão de versões compatíveis com Built-in Kotlin;
- `supabase/config.toml` ainda usa a seção depreciada `[inbucket]` em vez de
  `[local_smtp]`.

## Pendências para encerrar a Fase 01

1. Executar smoke test autenticado contra o Backend FastAPI usando os usuários
   locais e registrar respostas dos endpoints canônicos.
2. Executar a matriz obrigatória no Android físico `R9XT207TXWX` e registrar
   screenshots/logs/FPS.
3. Executar os workflows no GitHub; os gates locais não provam permissões,
   secrets e ambiente dos runners remotos.

## Fixtures locais concluídas

- carregador: `scripts/load-local-fixtures.ps1`;
- dados: `supabase/fixtures/local_e2e.sql`;
- documentação: `docs/development/LOCAL_E2E_FIXTURES.md`;
- usuários de aluno e professora criados pela Auth Admin API local;
- duas execuções idempotentes aprovadas;
- login de ambos os papéis validado;
- leitura RLS validada para perfil da professora, assinatura do aluno e três
  registros de progresso;
- nenhuma senha ou chave efêmera persistida no repositório.

## Decisão

O código atual possui baseline e fixtures locais verdes, mas a Fase 01 não está
encerrada porque falta validação runtime no Backend e no Android físico. O status
de produção permanece bloqueado.
