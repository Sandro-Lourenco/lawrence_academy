# PHASE_5A_ARCHITECTURE_ADJUSTMENTS.md

**Fase:** Fase 5A (Ajustes de Pós-Validação)  
**Status:** Implementado  
**Data:** 2026-07-10  

---

## 1. Mapeamento de Ajustes Realizados

Os seguintes ajustes arquiteturais foram executados antes de prosseguir para as novas features da Fase 5B:

### 1.1 Migração de Providers e Notifiers para `presentation/`
Para garantir a pureza das camadas e desacoplar o gerenciamento de estado do framework Riverpod da lógica de negócios central:
*   Mapeado `lib/features/auth/application/auth_notifier.dart` para `lib/features/auth/presentation/controllers/auth_controller.dart`.
*   Mapeado `lib/features/courses/application/catalog_notifier.dart` para `lib/features/courses/presentation/controllers/catalog_controller.dart`.
*   Mapeado `lib/features/courses/application/course_detail_provider.dart` para `lib/features/courses/presentation/providers/course_detail_provider.dart`.

### 1.2 Restrição de `application/`
A pasta `application/` de cada feature agora contém estritamente lógica de negócio sem dependências de UI/Riverpod:
*   `use_cases/` — Classes puras contendo a lógica dos casos de uso.
*   `ports/` — Definições de interfaces.
*   `dto/` — DTOs puros.

### 1.3 Casos de Uso (UseCases) Puros Criados
*   **Auth (`features/auth/application/use_cases/`):**
    *   `LoginUseCase`
    *   `RegisterUseCase`
    *   `RestoreSessionUseCase`
    *   `LogoutUseCase`
    *   `RequestPasswordResetUseCase`
*   **Courses (`features/courses/application/use_cases/`):**
    *   `ListCoursesUseCase`
    *   `GetCourseDetailUseCase`

### 1.4 Novo Fluxo de Dados Unificado
```text
Page (Widget)
  ↓
Controller (Riverpod Notifier na camada Presentation)
  ↓
UseCase (Camada Application)
  ↓
Repository Interface (Camada Domain)
  ↓
Repository Implementation (Camada Data)
  ↓
DataSource (ex: SupabaseAuthDataSource)
```

### 1.5 Criação do SupabaseAuthDataSource
Isolamos o SDK do Supabase criando:
*   `lib/features/auth/data/datasources/supabase_auth_datasource.dart`  
    Dessa forma, o `SupabaseAuthRepository` consome o `SupabaseAuthDataSource` ao invés de acessar o SDK diretamente no repositório. O provider `supabaseClientProvider` foi removido de `lib/core/network/` e colocado como privado dentro da infraestrutura de Auth.

### 1.6 Escalas do Liquid Glass
Os valores fixos (hardcoded) foram extraídos para escalas na classe `LawrenceTheme` (`lib/design_system/tokens/lawrence_theme.dart`):
*   `AppGlassBlur`: `subtle` (8.0), `medium` (20.0), `strong` (40.0)
*   `AppGlassOpacity`: `subtle` (0.30), `medium` (0.72), `strong` (0.90)
*   `AppMotionScale`: `pressed` (0.97), `hover` (1.02)
*   `AppRadius`: `small` (8.0), `medium` (16.0), `large` (24.0)
