# Tech Debt Backlog

Este documento registra as pendências tecnológicas e melhorias não bloqueantes identificadas durante as fases de refatoração do Lawrence Academy.

## Backend (Identificado na Fase 4)

- **TD-BACKEND-001**: eliminar 116 erros do mypy;
- **TD-BACKEND-002**: remover create_checkout_use_case legado;
- **TD-BACKEND-003**: migrar webhook do Stripe Dashboard para /api/v1;
- **TD-BACKEND-004**: remover rotas legadas após migração do Flutter;
- **TD-BACKEND-005**: revisar status 500 do gateway para 502/503;
- **TD-BACKEND-006**: separar testes de acesso e checkout no grace period;
- **TD-BACKEND-007**: padronizar atualização do perfil sem /update.
