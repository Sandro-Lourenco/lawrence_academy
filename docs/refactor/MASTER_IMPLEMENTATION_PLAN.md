# MASTER_IMPLEMENTATION_PLAN.md

# Lawrence Academy - Plano Diretor Oficial de Execução

Este documento é a **Fonte de Verdade Absoluta** para o planejamento e execução do projeto Lawrence Academy. Todas as próximas sprints, tarefas e implementações devem ser guiadas estritamente por este plano.

Nenhuma implementação pode contrariar ou pular as fases estipuladas aqui sem prévia revisão.

---

## 1. Visão Geral do Projeto

- **Descrição:** A Lawrence Academy é uma plataforma SaaS educacional premium focada no ensino profissional de moda (Corte, Costura, Modelagem, Alta Costura, Fashion Design, Style Design).
- **Objetivos:** Democratizar o acesso ao ensino profissional de moda, criando uma experiência premium para estudantes (aprendizado) e professores (gestão e monetização).
- **Escopo:** Catálogo de cursos, player de vídeo seguro via HLS, sistema de assinaturas independentes por curso (Stripe), atividades interativas, certificados gerados dinamicamente e acesso offline no mobile (Android).

### Estado Atual
O projeto está em transição de uma arquitetura legada para uma arquitetura limpa rigorosa. A fundação de **Auth**, **Cursos** e **Pagamentos** foi estabelecida, mas as funcionalidades principais de **Player/HLS**, **Atividades**, **Offline** e o **Portal do Professor** estão ausentes ou incompletas.

### Percentual de Conclusão Global
- **Percentual Geral do Projeto:** 42%

### Percentual por Módulo
- Auth: 90%
- Profiles/Users: 80%
- Courses: 60%
- Payments/Subscriptions: 50%
- Player/Lessons: 30%
- Teacher Portal: 10%
- Activities/Certificates: 0%
- Offline/Sync: 0%

---

## 2. Arquitetura

A arquitetura do projeto rege-se pelos princípios: **Clean Architecture**, **DDD (Domain-Driven Design)**, **SOLID** e **Feature First**.

- **Backend (FastAPI):**
  - O sistema é um *Modular Monolith*. Os bounded contexts estão separados em `src/modules/` (ex: `auth`, `courses`, `payments`).
  - **Avaliação:** Estrutura bem definida (`application`, `domain`, `infrastructure`, `interface`). Faltam eventos de domínio puros para desacoplar ações (ex: ao assinar, disparar evento em vez de chamar o repositório vizinho).
- **Flutter (Android/Web):**
  - **Riverpod** para injeção de dependência e controle de estado; **GoRouter** para navegação.
  - **Avaliação:** A estrutura `features/` está correta. Faltam implementações sólidas do repositório local (SQLite/Hive) para suportar o estado offline de forma transparente no `Riverpod`.
- **Banco (Supabase):**
  - Utiliza UUID, Timestamps (created_at, updated_at, deleted_at) e RLS (Row Level Security).
  - **Avaliação:** Schema inicial bem feito. Precisará de triggers automáticas para lidar com concorrência em expiração de assinaturas e sincronização offline.
- **Workers:**
  - FFmpeg para HLS (Video) e processamento em background (Filas).
  - **Avaliação:** A arquitetura prevê workers, mas eles precisam ser amarrados via fila (RabbitMQ ou Supabase Realtime) para garantir que não hajam gargalos no FastAPI.
- **Eventos / Webhooks:**
  - Dependência altíssima dos Webhooks do Stripe.
  - **Avaliação:** Webhooks devem ser refatorados para garantir idempotência total (para não assinar duas vezes caso o webhook seja reenviado).

---

## 3. Estado Atual dos Módulos

### Autenticação (Auth)
- **Status:** ✅ Concluído (Base)
- **Dependências:** Supabase Auth
- **Riscos:** Perda de token no client
- **Próximas ações:** Implementar silent refresh robusto e sync de sessões multidevice.

### Profiles & Users (Admin)
- **Status:** 🟡 Parcial
- **Dependências:** Auth, RBAC Roles
- **Riscos:** Escalada de privilégios (Bypass de RBAC)
- **Próximas ações:** Fechar endpoints de manipulação de roles (Admin).

### Courses & Catalog
- **Status:** 🟡 Parcial
- **Dependências:** Nenhuma direta.
- **Riscos:** Cache de catálogo pesado (impacto de performance).
- **Próximas ações:** Implementar Redis/cache no backend e lazy loading real.

### Payments & Subscriptions
- **Status:** 🟡 Parcial
- **Dependências:** Auth, Stripe Webhooks
- **Riscos:** Crítico financeiro. Assinaturas fantasmas.
- **Próximas ações:** Refatoração de casos de uso (tech debt), implementar idempotência de webhook.

### Player & Lessons
- **Status:** 🟡 Parcial
- **Dependências:** Subscriptions, Video Worker (HLS)
- **Riscos:** Pirataria de MP4.
- **Próximas ações:** Criar emissão de token de streaming (JWT de curta duração) e player nativo no Flutter.

### Teacher Portal (Uploads)
- **Status:** 🔴 Não iniciado
- **Dependências:** Cursos, Vídeo Worker
- **Riscos:** Sobrecarga de upload corrompendo a rede/infra.
- **Próximas ações:** Criar upload com pre-signed URLs via Supabase Storage.

### Activities & Certificates
- **Status:** 🔴 Não iniciado
- **Dependências:** Player, Progress, Cursos
- **Riscos:** UX confusa na validação das respostas.
- **Próximas ações:** Modelagem de tabelas de perguntas/respostas/submissões.

### Offline & Sync
- **Status:** 🔴 Não iniciado
- **Dependências:** Toda a base de dados
- **Riscos:** Conflitos de edição (Merge conflicts de progresso).
- **Próximas ações:** Modelar API `/offline/sync` e fila local no Flutter.

---

## 4. Backend

- **Módulos Atuais:** `assessments`, `auth`, `courses`, `invoices`, `payments`, `profiles`, `students`, `subscriptions`.
- **Endpoints:** Faltam CRUDs avançados para Teachers (gerir alunos), Admin (gerir roles), `/offline/sync` e `/certificates/generate`.
- **Repositories:** Classes Supabase (ex: `supabase_course_repository.py`) estão implementadas para os módulos base. Faltam repositórios de cache.
- **UseCases:** Os casos de uso de leitura estão maduros. Faltam casos complexos de validação de elegibilidade e estorno financeiro.
- **Workers / Background Jobs:** `video-worker` existe em estrutura base. Precisa ser expandido para notificar o backend do progresso da compressão via Webhook interno/Fila.
- **Integrações:** Stripe. Falta padronizar o Stripe SDK e abstraí-lo totalmente para não sujar o domínio de Subscriptions.

---

## 5. Flutter

- **Features Presentes:** `auth`, `courses`, `dashboard`, `invoices`, `lessons`, `lesson_progress`, `player`, `subscriptions`.
- **Features Faltantes:** `teacher`, `admin`, `offline_downloads`, `activities`, `certificates`.
- **Controllers & Providers:** Arquitetura do Riverpod montada.
- **Widgets Compartilhados:** Catálogo e UI base prontas (`lawrence/lib/shared/widgets/`). Faltam componentes complexos: Player HLS customizado e Quizzes.
- **Offline / Downloads:** Completamente pendente. Depende de SQLite/Hive e background fetch no Android.

---

## 6. Banco (Supabase)

- **Schema:** Focado nas tabelas de Profile e Course. O documento `DATABASE_SCHEMA.md` lista permissões.
- **Migrations:** Ausentes no repositório analisado. Faltam os scripts reais de UP e DOWN (necessário versionar em `supabase/migrations/`).
- **RLS e Policies:** Iniciado, porém crítico. Cada tabela *deve* ter políticas precisas e auditáveis, especialmente em Subscriptions e Lessons.
- **Constraints / Triggers:** Apenas `create_profile` listado no schema. Falta auditoria geral.
- **Índices:** Básicos (`idx_profiles_email`). Precisa de índices para queries pesadas do Admin.

---

## 7. Segurança

- **OWASP:** Prevenções CSRF não aplicáveis (tokens no header), mas Rate Limiting é mandatório e ainda não implementado no FastAPI.
- **JWT:** Funcionando via Supabase Auth.
- **RBAC:** Roles documentadas (`student`, `teacher`, `admin`), mas o cruzamento dessas roles nas dependências do FastAPI precisa de refatoro rigoroso (Zero Trust).
- **Uploads:** O Teacher não deve mandar MP4 direto pelo backend, mas usar Presigned URL para evitar timeout de servidor.
- **Secrets:** Todo segredo (Stripe Keys, Supabase Service Role) deve ficar isolado no `.env` e NUNCA tocar o Flutter.

---

## 8. Performance

- **Flutter:** Faltam Lazy Loading (infinite scroll) nos cursos. 
- **Backend:** Ausência de Redis. Queries estão buscando no banco toda vez. Necessário cache na rota `/courses`.
- **Banco:** `auth.users` associado a `profiles` via views ou joins. Em alta escala, precisa de denormalização (materlized views).
- **Streaming:** O HLS exige CDN. O backend não deve servir vídeos, apenas redirecionar / assinar URLs.

---

## 9. Testes

- **Cobertura Atual:** < 20%
- **Cobertura Ideal (Mínimo Aceitável):** 70% Global (90% no domínio Financeiro/Autenticação).
- **Unitários:** Devem mockar completamente Supabase e Stripe (Tech Debt existente).
- **Integração:** Mock Webhooks é mandatório antes da fase 5C.
- **Flutter:** Faltam Widget Tests para os formulários e E2E via `integration_test` (essencial para fluxos críticos como Checkout).

---

## 10. Roadmap Completo (Planejamento em Fases Executáveis)

### Fase 5C: Estabilização Financeira e Base
- **Lote 1:** Eliminação do Tech Debt Backend (Stripe Webhooks em `/api/v1`, testes de elegibilidade, limpeza de UseCases obsoletos).
- **Lote 2:** Refatoração de Roles/RBAC no Supabase RLS.
- **Lote 3:** Widgets E2E e cobertura unitária de Pagamentos (Flutter & Backend).

### Fase 5D: Módulo do Professor (Teacher Portal)
- **Lote 1:** CRUD avançado de Cursos e Módulos (Frontend e Backend).
- **Lote 2:** Video Upload Pipeline (Presigned URL + FFmpeg Worker).
- **Lote 3:** Gestão de Alunos (Visualização de progressos e assinaturas).

### Fase 5E: Ensino & Interatividade
- **Lote 1:** Activities (Modelagem do banco, API e UI de múltipla escolha e texto).
- **Lote 2:** Respostas e Correções (Interface de submissão do aluno e feedback do professor).
- **Lote 3:** Motor de Certificados (Geração dinâmica e validação via código público).

### Fase 6: Infraestrutura Offline & Mobile
- **Lote 1:** Infraestrutura Local Flutter (SQLite para relational, Hive para cache rápido).
- **Lote 2:** API de Sincronização Bidirecional (`/offline/sync`).
- **Lote 3:** Download seguro de HLS e gestão de storage no dispositivo (Android).

### Fase 7: Segurança, Admin & Performance (Release Candidate)
- **Lote 1:** Super Admin Dashboard.
- **Lote 2:** Otimização pesada (Redis, CDN caching, Paginação refinada).
- **Lote 3:** QA e Testes de Carga / OWASP.

---

## 11. Mapa de Dependências entre Módulos

```text
Infra (Supabase Auth/DB) 
 ↓
Profiles & RBAC (Segurança Global)
 ↓
Courses (Domínio Base)
 ↓
Subscriptions & Payments (Catraca de Acesso)
 ↓
Lessons & Player (Conteúdo Premium) -> [Depende de: Video Worker (FFmpeg)]
 ↓
Activities (Engajamento)
 ↓
Certificates (Conclusão)
 ↓
Offline Sync (Funcionalidade Mobile Extra)
```
*A implementação DEVE seguir o fluxo de cima para baixo.*

---

## 12. Priorização

1. **CRÍTICA:** Estabilizar o financeiro e fluxos de webhook (Pagamentos / Assinaturas) - Sem isso não há negócio SaaS.
2. **ALTA:** Pipeline de Upload de Vídeo e Portal do Professor - Necessário para criar o conteúdo do MVP.
3. **MÉDIA:** Certificados e Atividades interativas - Pode ser mitigado no curto prazo.
4. **BAIXA:** Modo Offline Android e Painel Super Admin (pode operar via Supabase Studio temporariamente).

---

## 13. Dívida Técnica (Resumo para TECH_DEBT_BACKLOG.md)

*(O documento `TECH_DEBT_BACKLOG.md` foi atualizado de forma segregada baseada nestes itens).*
- **Backend:** Eliminar erros do mypy, remover rotas velhas, padronizar códigos de erro HTTP (502/503).
- **Flutter:** Limpar acoplamento visual de regras de negócios puras, melhorar componentização do catálogo.
- **Infra:** Melhorar CI/CD e criar mock real do Stripe.
- **Segurança:** Implementar Rate Limit Global no FastAPI, isolar Service Role.

---

## 14. Riscos

- **Arquitetura:** Inconsistência de estado entre o Flutter e o Backend em cenários de rede instável (ex: compra aprovada, mas UI não atualizou).
- **Financeiro:** Assinaturas que expiram no Stripe mas não cancelam no Supabase devido a Webhook perdido.
- **Segurança:** Downloads não autorizados (Scraping de vídeo) através de falhas de autenticação do HLS.
- **Deploy:** Quebra de produção por ausência de um pipeline CI com testes automatizados rígidos de banco e migrations (downtime zero).

---

## 15. Plano de Execução (Guia Padrão por Fase)

Cada **Lote** das Fases deve ser executado respeitando o seguinte fluxo:
1. **Objetivo & Escopo:** Definidos pela Fase.
2. **Pré-requisitos:** Todos os lotes anteriores devem estar concluídos (sem bugs críticos).
3. **Personas Envolvidas:** `Backend Architect`, `Flutter Architect`, `Security Engineer`, `QA Engineer`.
4. **Documentação Necessária:** As respectivas `Page Specs` (`docs/pages/`), `API Specs` e `DB Schema`.
5. **Testes Obrigatórios:** TDD ou criação imediata de Unit Tests após a implementação do Repository/UseCase.
6. **Reviews Obrigatórios:** Architecture Review, Security Review e UI Review (quando front).
7. **Critérios de Aceite:** API retorna status esperado, frontend reage aos estados de Loading/Error/Success, cobertura mínima atingida.

---

## 16. Cronograma & Sequência Lógica

1. Mês 1: Correção de todos os Tech Debts de base e finalização absoluta das Assinaturas/Stripe. (Fase 5C)
2. Mês 2: Portal do Professor e Engine de Processamento de Vídeo em HLS. (Fase 5D)
3. Mês 3: Atividades e Certificação. (Fase 5E)
4. Mês 4: Infraestrutura Offline (Mobile). (Fase 6)
5. Mês 5: Refino de Performance, Admin Portal e Soft Launch. (Fase 7)

---

## 17. MVP e Versões

- **MVP:** Autenticação, Compra de Curso, Player HLS Básico (Online), Portal Básico do Professor.
- **MVP+:** Adição de Atividades (Quizzes) e Certificados.
- **Versão 1.0 (Soft Launch):** Funcionalidades do MVP+ com segurança OWASP auditada e admin dashboard.
- **Versão 2.0 (Mobile Flagship):** Modo Offline Total no Android e integrações avançadas de comunidade (Fora do escopo atual).

---

## 18. Status Global Final

- **Percentual Geral do Projeto: 42%**
  - Percentual Backend: 60%
  - Percentual Flutter: 40%
  - Percentual Banco: 70%
  - Percentual Infra: 50%
  - Percentual Documentação: 90%
  - Percentual Testes: 20%
  - Percentual Segurança: 60%
  - Percentual Performance: 30%
