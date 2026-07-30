# Fixtures E2E locais

As fixtures deste documento são sintéticas e exclusivas da stack Supabase local.
O carregador recusa qualquer API diferente de `127.0.0.1:54321` ou
`localhost:54321`.

## Pré-requisitos

```powershell
docker info
npx --yes supabase@2.109.1 start
npx --yes supabase@2.109.1 db reset
```

## Iniciar aplicação completa

O comando abaixo inicia Supabase, backend, worker e frontend, compila a UI com
as URLs locais e carrega todos os dados sintéticos:

```powershell
.\scripts\start-local.ps1 `
  -StudentPassword '<senha-local-do-aluno>' `
  -TeacherPassword '<senha-local-da-professora>'
```

A aplicação fica disponível em `http://localhost:8080`.

## Carregar somente as fixtures

Escolha senhas locais e não reutilize credenciais reais:

```powershell
.\scripts\load-local-fixtures.ps1 `
  -StudentPassword '<senha-local-do-aluno>' `
  -TeacherPassword '<senha-local-da-professora>'
```

Contas padrão:

- `aluno.local@lawrence.test`
- `professora.local@lawrence.test`

O carregador cria ou atualiza as contas pela Auth Admin API local, aplica
`supabase/fixtures/local_e2e.sql` e confirma login e RLS. Ele pode ser executado
novamente com novas senhas.

## Dados criados

- dois perfis autenticáveis;
- um curso pago em andamento;
- um curso gratuito concluído;
- dois módulos e três aulas;
- uma assinatura ativa sintética;
- três registros de progresso;
- um certificado sintético.
- um vídeo HLS curto e válido, gerado pelo FFmpeg do worker e enviado ao bucket
  privado `lessons-hls`.

No ambiente local, `PAYMENT_PROVIDER=fake` ativa a assinatura imediatamente para
permitir validar cadastro, compra e reprodução sem credenciais reais do Stripe.
Produção continua exigindo o provedor e os segredos reais.

