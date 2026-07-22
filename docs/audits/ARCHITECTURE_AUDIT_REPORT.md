# Architecture Audit Report
**Date:** 2026-07-11
**Context:** Lawrence Academy Project

## 1. Arquitetura e Qualidade (Clean Architecture, DDD, SOLID)

### **Problema:** Presença de Mocks em Camadas de Produção
- **Descrição:** Foi identificada a presença de lógica "mockada" dentro dos casos de uso e rotas da API que deveriam estar limpos para produção. Em `SubmitTaskUseCase`, há comentários indicando "mock logic para agora via repository" em um upsert. Nas rotas de Stripe (`payments/interface/api/routes.py`), sessões mockadas são retornadas quando há falha de chaves de API, mascarando falhas reais no ambiente `test`. No Flutter, há "Mock das próximas lives" em `dashboard_controller.dart`.
- **Impacto:** Quebra a autoridade e integridade do backend. Pode vazar sessões falsas para o cliente, causando inconsistências em relatórios e logs.
- **Arquivos:** `submit_task_use_case.py`, `supabase_course_repository.py`, `routes.py` (payments), `dashboard_controller.dart`.
- **Recomendação:** Remover qualquer fallback de mocks para produção e injetar dependências corretas usando fakes apenas no test suit. 
- **Prioridade:** High
- **Estimativa:** 1 dia (Task separada)

### **Problema:** Dependência de Módulo Quebrada (Video Worker Tests)
- **Descrição:** Os testes no `video_worker` falham com `AttributeError: module 'main' has no attribute 'process_job'`. Há um shadowing de módulo ou conflito de nomenclatura no Python, onde `main.py` de fora está sobrescrevendo o `worker_main`.
- **Impacto:** O pipeline de CI ficará bloqueado. Impede validação automática contínua de um módulo crítico.
- **Arquivos:** `tests/test_video_worker.py`
- **Recomendação:** Refatorar a importação de `main` no worker e nos testes, preferivelmente movendo o script de worker para um pacote nomeado corretamente (ex: `src/workers/video_worker.py`).
- **Prioridade:** Medium
- **Estimativa:** 4 horas

## 2. Flutter e UI/UX

### **Problema:** Depreciação de API do Dart (`withOpacity`)
- **Descrição:** O `flutter analyze` indicou mais de 248 ocorrências de warning por depreciação. O método `.withOpacity()` não deve ser mais usado, substituído por `.withValues()` devido a perda de precisão de cores no novo motor gráfico Impeller.
- **Impacto:** Gera logs sujos. Risco de perda de fidelidade de cor (Aesthetics).
- **Arquivos:** Múltiplos (ex: `dashboard_layout.dart`, `task_execution_page.dart`, `theme.dart`).
- **Recomendação:** Executar regex replacement em toda a lib substituindo a antiga chamada pelo padrão atualizado.
- **Prioridade:** Low
- **Estimativa:** 2 horas

## 3. Segurança e Autorização (Zero Trust)

### **Problema:** Inconsistência de Supabase Auth x RLS
- **Descrição:** O backend agora impõe políticas via `AuthorizationError`, o que protege a API. No entanto, o DB precisa garantir que o "Role" ou permissões estejam vinculados ao `auth.uid()`. A documentação aponta a necessidade de revisar políticas de storage (HLS).
- **Impacto:** Acesso direto à CDN/Bucket de vídeos sem credencial (se vazada a url) pode onerar banda do Storage.
- **Arquivos:** Storage buckets.
- **Recomendação:** Implementar tokens de curta duração via JWT acoplados à URL pre-signed para o streaming HLS (Ticket pattern).
- **Prioridade:** Critical
- **Estimativa:** 2 dias

## 4. Documentação e Processos

- **Status Geral:** A documentação está excelente e o uso de workflows, personas e master plan vem sendo aplicado com rigor.
- O backlog `IMPLEMENTATION_BACKLOG.md` deve englobar agora as correções encontradas neste Audit.

---
**Resultado:** Foram abertas novas pendências de Tech Debt no `TECH_DEBT_BACKLOG.md`. A próxima etapa de execução (Phase 6B) pode continuar após o saneamento ou paralelamente a ele.
