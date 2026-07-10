# PHASE_5_FLUTTER_REFACTOR_PLAN.md

**Versão:** 1.0.0  
**Fase:** Fase 5A — Fundação Flutter  
**Status:** Planejamento  

---

## 1. Escopo da Fase 5A

Este plano de refatoração visa estabelecer a fundação do frontend Flutter de acordo com o padrão Clean Architecture, Feature-First, GoRouter, Riverpod e o Lawrence Design System.

### Itens Incluídos:
1. **App Shell:** Estrutura e navegação principal com design unificado.
2. **GoRouter centralizado:** Rotas estruturadas, guards de autenticação e permissões.
3. **Lawrence Design System:** Cores (60-30-10), tipografia (Inter/Outfit), espaçamentos baseados em grid de 4px e componentes Liquid Glass.
4. **Configuração por ambientes:** Estrutura para tratar endpoints de DEV/STAGE/PROD.
5. **Network Layer para /api/v1:** Cliente HTTP seguro consumindo apenas endpoints `/api/v1/`.
6. **Auth:** Fluxo de autenticação completo (Login, Registro, Recuperação, Log out) sem Supabase direto em Widgets.
7. **Courses/Catalog:** Listagem de cursos disponíveis.
8. **Course Detail:** Detalhes de um curso individual baseado no slug/ID.

### Itens Excluídos (Não migrar ainda):
Dashboard (Aluno), Lessons, Player, Lesson Progress, Subscriptions, Payments, Downloads, Teacher, Admin.

---

## 2. Mapeamento de Implementações Duplicadas (Higiene)

Identificamos duplicações de arquivos entre as pastas legadas `lib/ui/` e `lib/presentation/`:

| Componente/Página | Arquivo Legado A (`lib/ui/`) | Arquivo Legado B (`lib/presentation/`) | Ação Planejada |
|---|---|---|---|
| **Theme** | [theme.dart](file:///c:/Users/sandr/Documents/site%20ariane/lawrence/lib/ui/theme.dart) | [theme.dart](file:///c:/Users/sandr/Documents/site%20ariane/lawrence/lib/core/theme.dart) | Unificar no design system oficial `lib/design_system/lawrence_theme.dart` seguindo a paleta 60-30-10 |
| **Catalog Page** | [catalog_page.dart](file:///c:/Users/sandr/Documents/site%20ariane/lawrence/lib/ui/catalog/catalog_page.dart) | [catalog_page.dart](file:///c:/Users/sandr/Documents/site%20ariane/lawrence/lib/presentation/catalog/views/catalog_page.dart) | Migrar para `lib/features/courses/presentation/pages/catalog_page.dart` consumindo a API v1 |
| **Course Detail** | [course_detail_page.dart](file:///c:/Users/sandr/Documents/site%20ariane/lawrence/lib/ui/public/course_detail_page.dart) | [course_detail_page.dart](file:///c:/Users/sandr/Documents/site%20ariane/lawrence/lib/presentation/catalog/views/course_detail_page.dart) | Migrar para `lib/features/courses/presentation/pages/course_detail_page.dart` |
| **Router** | [router.dart](file:///c:/Users/sandr/Documents/site%20ariane/lawrence/lib/core/router.dart) | — | Atualizar e mover para `lib/app/router/app_router.dart` |
| **Auth View** | — | [login_page.dart](file:///c:/Users/sandr/Documents/site%20ariane/lawrence/lib/presentation/auth/views/login_page.dart) | Mover para `lib/features/auth/presentation/pages/login_page.dart` |

*Nota:* Os arquivos sob `lib/ui/` **não** serão excluídos imediatamente para evitar quebras nos módulos que ainda não estão sob refatoração (Dashboard, Player, etc.). Eles serão depreciados progressivamente.

---

## 3. Nova Estrutura de Pastas Oficial

```text
lib/
├── app/
│   ├── config/              # Configurações de ambiente (env_config.dart)
│   ├── router/              # Configurações do GoRouter (app_router.dart)
│   └── app.dart             # Widget principal (MaterialApp)
├── core/
│   ├── errors/              # Classes de exceções e tratamento de erros
│   └── network/             # Cliente HTTP para /api/v1 (network_client.dart)
├── design_system/
│   ├── tokens/              # Cores, tipografia, bordas e espaçamentos
│   ├── widgets/             # Liquid Glass Card, Buttons, Containers
│   └── layouts/             # AppShell (Public & Student)
├── shared/
│   └── domain/              # Modelos ou DTOs compartilhados (User, etc.)
└── features/
    ├── auth/
    │   ├── domain/          # Entidades (UserSession) e Interfaces de repositório
    │   ├── application/     # Riverpod Notifiers (auth_notifier.dart)
    │   ├── data/            # SupabaseAuthRepository consumindo API / SDK seguro
    │   └── presentation/    # Login/Register Pages, Widgets
    └── courses/
        ├── domain/          # Course, Module, Lesson Entities
        ├── application/     # CatalogNotifier, CourseDetailNotifier
        ├── data/            # CourseRepository usando Network Client (/api/v1/courses)
        └── presentation/    # CatalogPage, CourseDetailPage
```

---

## 4. Estratégia de Preservação: Liquid Glass

O efeito **Liquid Glass** (efeito translúcido premium) define a estética visual da Lawrence Academy e será rigorosamente mantido e refatorado em `lib/design_system/widgets/`:

*   **Efeito Blur:** BackdropFilter com `sigmaX: 20, sigmaY: 20` ou superior.
*   **Bordas:** `Border.all(color: Colors.white.withOpacity(0.28))` e raio de curvatura `radiusLg = 24.0` inegociável para cartões principais.
*   **Feedbacks táteis/visuais:** Animações sutis (escala `0.97` em botões e cartões interativos ao pressionar).

---

## 5. Abstração de Dependências e Segurança

1.  **Sem Supabase nos Widgets:** Nenhum widget consumirá diretamente o SDK do Supabase. Toda a interação será delegada a um Repositório injetado via Riverpod.
2.  **Segurança e Secrets:** Nenhuma chave de API privada (`service_role`) será armazenada no Flutter. As chamadas à API v1 serão autenticadas via JWT do Supabase Auth.
3.  **Ambiente / URL base:** O cliente HTTP consome dinamicamente a URL base baseada na configuração de ambiente ativa (DEV/STAGE/PROD).

---

## 6. Plano de Verificação

Após as alterações, realizaremos:
```bash
flutter pub get
dart format --set-exit-if-changed .
flutter analyze
flutter test
flutter build web
flutter build apk --debug
```

### Testes de Caracterização
*   Testar comportamento do `GoRouter` redirecionando `/` para `/login` (ou `/dashboard` se logado).
*   Testar injeção do `NetworkClient` e parsing correto de respostas `/api/v1/courses/`.
*   Testar estados do `AuthNotifier` (Loading, Success, Error).
