---
version: 1.0.0
status: validated
last_validated: 2026-08-11
---

# Lawrence Academy — Docker runtime

## Stack padrão

- `frontend`: Flutter Web 3.44.9 compilado em estágio isolado e servido por Nginx 1.30.4 em usuário não-root.
- `backend`: FastAPI em Python 3.13.14, usuário não-root e endpoint de liveness próprio.
- `video-worker`: FFmpeg e worker Python isolados no profile `workers`.

O frontend e a API são iniciados por padrão. O worker não inicia automaticamente porque pode consumir e alterar filas de um Supabase remoto.

## Preparação

Copie `.env.example` para `.env` e preencha os valores. A chave `SUPABASE_SERVICE_ROLE_KEY`, os segredos JWT e Stripe são exclusivos do backend. Somente `SUPABASE_URL` e `SUPABASE_ANON_KEY` entram no build público do Flutter.

O build recebe o `.env` como secret mount do BuildKit. O arquivo não é copiado para a imagem, e seus valores não aparecem no histórico das camadas.

## Executar

```powershell
docker compose build --pull
docker compose up --detach backend frontend
docker compose ps
```

URLs locais:

- Aplicação: `http://localhost:18080`
- API: `http://localhost:8000`
- Liveness: `http://localhost:8000/health`
- Readiness: `http://localhost:8000/ready`

Para iniciar conscientemente o processador de vídeos:

```powershell
docker compose --profile workers up --detach video-worker
```

Para acompanhar logs:

```powershell
docker compose logs --follow backend frontend
```

Para encerrar sem remover imagens ou dados externos:

```powershell
docker compose down
```

## Garantias aplicadas

- Versões e checksum do Flutter fixados.
- Imagens oficiais Python e Nginx versionadas.
- Multi-stage builds para reduzir a superfície das imagens finais.
- Usuários não-root, `read_only`, `no-new-privileges` e capabilities removidas.
- Arquivos temporários limitados por `tmpfs`.
- Healthchecks para API, frontend e worker.
- Logs Docker com rotação.
- Portas publicadas somente em `127.0.0.1`.
- Limites de CPU e memória descritos no Compose.

## Ambiente local completo

O script `scripts/start-local.ps1` continua sendo o fluxo para Supabase local, migrations e fixtures. Ele combina `docker-compose.yml` com `docker-compose.local.yml` e mantém as mesmas URLs de frontend e backend.
