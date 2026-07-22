# Fixtures E2E locais

As fixtures deste documento são sintéticas e exclusivas da stack Supabase local.
O carregador recusa qualquer API diferente de `127.0.0.1:54321` ou
`localhost:54321`.

## Pré-requisitos

```powershell
docker info
npx --yes supabase@2.84.2 start
npx --yes supabase@2.84.2 db reset
```

## Carregar

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

Os caminhos HLS são marcadores locais. A reprodução de vídeo somente funcionará
depois que objetos de teste forem enviados ao Storage pelo pipeline autorizado.

