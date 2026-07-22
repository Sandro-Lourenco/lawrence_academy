# PHASE_5B_LEARNING_EXPERIENCE_PLAN.md

**Versão:** 1.1.0  
**Fase:** Fase 5B — Experiência Central de Aprendizado  
**Status:** Planejamento Aprovado com Ajustes Obrigatórios  

---

## 1. Ajustes Arquiteturais da Fundação (Fase 5A)

### 1.1 Migração de Providers e Notifiers para `presentation/`
Moveremos os notifiers/providers Riverpod da camada `application/` para a camada `presentation/`:
*   `lib/features/auth/application/auth_notifier.dart`  
    → `lib/features/auth/presentation/controllers/auth_controller.dart`
*   `lib/features/courses/application/catalog_notifier.dart`  
    → `lib/features/courses/presentation/controllers/catalog_controller.dart`
*   `lib/features/courses/application/course_detail_provider.dart`  
    → `lib/features/courses/presentation/providers/course_detail_provider.dart`

A pasta `application/` conterá estritamente:
*   `use_cases/` — Casos de uso do domínio.
*   `dto/` — DTOs da aplicação.
*   `ports/` — Interfaces/contratos de comunicação.

### 1.2 Casos de Uso (UseCases)
*   **Auth (`features/auth/application/use_cases/`):**
    *   `LoginUseCase`
    *   `RegisterUseCase`
    *   `RestoreSessionUseCase`
    *   `LogoutUseCase`
    *   `RequestPasswordResetUseCase`
*   **Courses (`features/courses/application/use_cases/`):**
    *   `ListCoursesUseCase`
    *   `GetCourseDetailUseCase`

### 1.3 Isolamento do Supabase
Introdução do `SupabaseAuthDataSource` para isolar o SDK do Supabase dentro da feature Auth:
```text
AuthRepositoryImpl
  → SupabaseAuthDataSource
  → Supabase SDK
```
*Garantia:* Nenhuma outra feature acessa o Supabase diretamente.

### 1.4 Tokens e Escalas do Liquid Glass
Substituiremos os tokens únicos por escalas explícitas na classe `LawrenceTheme` (`lib/design_system/tokens/lawrence_theme.dart`):
*   **`AppGlassBlur`:**
    *   `subtle` = `8.0`
    *   `medium` = `20.0`
    *   `strong` = `40.0`
*   **`AppGlassOpacity`:**
    *   `subtle` = `0.30`
    *   `medium` = `0.72`
    *   `strong` = `0.90`
*   **`AppMotionScale`:**
    *   `pressed` = `0.97`
    *   `hover` = `1.02`
*   **`AppRadius`:**
    *   `small` = `8.0`
    *   `medium` = `16.0`
    *   `large` = `24.0`

---

## 2. Experiência Central de Aprendizado (Fase 5B)

### 2.1 Autorização Real de Lessons no Backend
*   **Garantia:** O Flutter apenas interpreta os estados retornados pelo backend: `preview`, `locked`, `available`, `subscription_required`.
*   A liberação de conteúdo nunca ocorrerá apenas por estado local.

### 2.2 Dashboard do Aluno (`features/dashboard/`)
*   Se o endpoint `GET /api/v1/student/dashboard` não existir, comporemos as chamadas aos endpoints `GET /api/v1/courses` e `GET /api/v1/students/me/progress` usando um único provider unificado para evitar múltiplas chamadas redundantes.
*   Estados explícitos: `loading`, `success`, `empty`, `error`, `offline`.

### 2.3 Lessons (`features/lessons/`)
*   Implementação de: `LessonEntity`, `LessonApiModel`, `LessonMapper`, `LessonRepository`, `LessonRepositoryImpl`.
*   Casos de uso: `GetLessonUseCase`, `ListCourseLessonsUseCase`, `CheckLessonAccessUseCase`.

### 2.4 Player HLS com Tratamento de URL Expirada (`features/player/`)
*   **Vídeo HLS Seguro:** Acessado via `GET /api/v1/courses/{course_id}/lessons/{lesson_id}/stream`.
*   **Signed URL Expirada:** O player detectará falhas de expiração no stream, solicitará automaticamente uma nova URL assinada ao backend, restaurará a posição de reprodução e retomará o vídeo (com limite de 3 retentativas).
*   **Estados do Player:** `initializing`, `loading`, `ready`, `playing`, `paused`, `buffering`, `completed`, `stream_expired`, `access_denied`, `offline`, `error`.
*   **Controles:** Fullscreen nativo, suporte a legendas, atalhos de teclado (Web), acessibilidade via `Semantics`.

### 2.5 Lesson Progress e SQLite Sync Queue (`features/lesson_progress/`)
*   **SQLite local:** Usado para persistência do progresso e da fila de sincronização offline.
*   **Sync Queue Schema:**
    *   `id` (UUID/AutoIncrement)
    *   `operation_type` (ex: `UPDATE_PROGRESS`)
    *   `entity_type` (ex: `LESSON_PROGRESS`)
    *   `entity_id` (ID da aula)
    *   `payload` (JSON string do progresso)
    *   `idempotency_key` (Chave única baseada em UUID + timestamp)
    *   `status` (`pending`, `failed`, `synced`)
    *   `retry_count`
    *   `next_retry_at`
    *   `last_error`
    *   `created_at`, `updated_at`
*   **Heartbeat Trigger:** Salva progresso no SQLite local e tenta sync em: intervalo controlado (30s), pause, conclusão (>= 90%), saída de tela, mudança de rota, background, perda e reconexão de sinal.
*   **Resolução de Conflitos (Regras):**
    1.  `completed = true` sempre prevalece sobre `completed = false`.
    2.  O maior valor de `watched_seconds` válido prevalece (não permitindo regressão).
    3.  `progress_percentage` é recalculado localmente.
    4.  Payloads inválidos são rejeitados imediatamente.
    5.  Timestamp do servidor é persistido para auditoria.

---

## 3. Cobertura de Testes Expandida

*   **Dashboard:** Estados `loading`, `success`, `empty`, `error`, `offline` e navegação de continuar curso.
*   **Lessons:** Estados `preview`, `locked`, `available`, `missing` e comportamento offline.
*   **Player:** Stream válido, expirado, acesso negado, buffering, retries, fullscreen, teclado, legendas.
*   **Progress:** Salvamento local, heartbeat, pause, background, conclusão, offline/reconexão, conflitos e idempotência.

---

## 4. Acessibilidade e Responsividade
*   **Semantics:** Rótulos semânticos explícitos em botões do player e do dashboard.
*   **Text Scaling 200%:** Testar layout usando fontes escaladas sem quebra.
*   **Reduced Motion:** Respeitar configurações de animação do sistema operacional.
*   **Responsividade:** Layouts adaptados e testados para Mobile, Tablet e Desktop.
