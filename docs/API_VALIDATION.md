# Validação de API — Fase 2

| Recurso | Contrato real | Situação |
| --- | --- | --- |
| Cursos | `GET /api/v1/courses` | Implementado |
| Dashboard | Sem endpoint agregado | Composto por perfil, cursos e progresso |
| Perfil | `GET /api/v1/profiles/me` | Implementado |
| Notificações | Sem módulo/endpoint | Bloqueado |
| Certificados | `GET /api/v1/certificates` | Implementado/autenticado |
| Assinaturas | `GET /api/v1/subscriptions` | Implementado/autenticado |

- Timeout: 15 segundos.
- JWT enviado como Bearer quando existe sessão.
- 401/403 viram falhas de autenticação; 404/500 preservam status tratado.
- Supabase Flutter v2 restaura sessão local antes de garantir refresh; eventos `tokenRefreshed` devem orientar chamadas autenticadas.
- Logout usa o SDK e remove a sessão persistida.

Evidência: 33 testes FastAPI passaram na Fase 1. O smoke test externo continua bloqueado por backend/usuário/fixtures reais; `supabase/seed.sql` é vazio.
