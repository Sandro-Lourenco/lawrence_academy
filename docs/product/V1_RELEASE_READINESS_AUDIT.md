# Lawrence Academy — auditoria de prontidão da V1

## Objetivo da primeira versão

Permitir que um usuário final conclua sem ajuda a jornada: entrar, descobrir um
curso, comprar/acessar, assistir, acompanhar progresso, participar de evento,
entregar atividade, editar perfil e obter certificado quando elegível.

## Corrigido nesta rodada

- Catálogo público voltou a possuir rolagem própria e teste de regressão real.
- Perfil espera o carregamento assíncrono, oferece erro/tentar novamente e não
  abre mais um formulário vazio.
- Perfil valida nome, username, data e URLs antes do envio.
- CTA e progresso do perfil usam o sistema dourado 60/30/10.
- Paleta canônica: `#FAD643`, `#EDC531`, `#DBB42C`, `#C9A227`, `#A47E1B`.
- Botões Material recebem fallback dourado; CTAs principais usam foil em gradiente.

## Como publicar uma live na V1

O produto deve usar YouTube Live como infraestrutura de transmissão:

1. O professor cria/agende a transmissão no YouTube Studio.
2. Em **Studio do Professor > Eventos > Novo evento**, informa título, data e
   fuso, duração, instrutor, capa e URL HTTPS do YouTube.
3. O evento fica em rascunho; ao publicar, aparece em **Painel > Eventos**.
4. O aluno vê horário local, status e contagem regressiva; no horário, **Entrar
   na live** abre somente hosts permitidos do YouTube.
5. Ao terminar, o professor marca como encerrada e pode manter a gravação.

Essa tela administrativa e seu contrato ainda não existem. Antes de liberá-la,
criar `live_events`, migration, RLS/RBAC, API e testes. Não inserir links
diretamente no código nem transmitir vídeo pelo backend da Lawrence na V1.

## Implementação concluída

- CRUD de Lives com gestão do professor, agenda do aluno e URLs YouTube.
- Submissões de atividades reais, autenticadas e idempotentes.
- Certificados fail-closed com elegibilidade e assinatura HMAC reais.
- Perfil reativo, validações, senha, avatar seguro e formação acadêmica.
- Design couture transversal, motion reduzível e componentes dourados.

## Bloqueadores operacionais de lançamento

### P0

- Aplicar as novas migrations em Supabase local/staging e validar RLS/RBAC.
- Executar E2E: login → checkout Stripe test → acesso → player → atividade →
  certificado, incluindo professor → Live → aluno.

### P1

- Validar HLS real, renovação de token, retomada e sincronização offline.
- Validar Android físico, staging, webhooks Stripe e migrações aplicadas.

## Critério para gerar o pacote de teste final

Não gerar um RC para usuário final enquanto qualquer P0 estiver aberto. Após os
P0: `flutter analyze`, suíte completa, testes responsivos e acessíveis, smoke dos
containers `/health` e `/ready`, APK/AAB assinado de staging e roteiro de teste
com rollback.
