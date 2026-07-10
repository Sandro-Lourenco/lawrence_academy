---
name: create-page
description: "Cria ou refatora páginas Flutter completas a partir das especificações existentes em docs/pages."
category: frontend
risk: safe
source: self
source_type: self
date_added: "2026-07-10"
version: 2.0.0

tags:
  - flutter
  - dart
  - page
  - screen
  - riverpod
  - gorouter
  - responsive
  - accessibility
  - design-system
  - testing

tools:
  - antigravity
  - gemini

required_personas:
  - ui-ux-designer
  - flutter-architect
  - qa-engineer

optional_personas:
  - security-engineer

related_skills:
  - create-feature
  - create-premium-flutter-screen
  - review-code
  - optimize-performance
---

# Create Page

## 1. Objetivo

Esta skill define o processo obrigatório para criar, implementar ou refatorar uma página Flutter da Lawrence Academy.

A implementação deve ser baseada principalmente na especificação individual localizada em:

```text
docs/pages/
```

Exemplos:

```text
docs/pages/public/home.md

docs/pages/public/course-detail.md

docs/pages/auth/login.md

docs/pages/student/dashboard.md

docs/pages/student/my-courses.md

docs/pages/teacher/create-course.md

docs/pages/admin/users.md

docs/pages/shared/loading.md
```

A página deve ser:

- funcional;
- fiel à especificação;
- integrada à arquitetura;
- responsiva;
- acessível;
- segura;
- performática;
- testável;
- consistente com o Lawrence Design System;
- compatível com Flutter Web e Android.

Uma página não é somente um arquivo visual.

Ela é composta por:

```text
Especificação da página
+
Objetivo do usuário
+
Navegação
+
Estado
+
Componentes
+
Responsividade
+
Acessibilidade
+
Testes
```

---

# 2. Fonte oficial das páginas

Todas as especificações individuais devem estar dentro de:

```text
docs/pages/
```

Estrutura oficial:

```text
docs/
└── pages/
    ├── public/
    │   ├── home.md
    │   ├── catalog.md
    │   ├── course-detail.md
    │   ├── pricing.md
    │   ├── faq.md
    │   ├── contact.md
    │   ├── about.md
    │   └── blog.md
    │
    ├── auth/
    │   ├── splash.md
    │   ├── onboarding.md
    │   ├── login.md
    │   ├── register.md
    │   ├── forgot-password.md
    │   ├── verify-email.md
    │   └── reset-password.md
    │
    ├── student/
    │   ├── dashboard.md
    │   ├── my-courses.md
    │   ├── course-player.md
    │   ├── lesson.md
    │   ├── activities.md
    │   ├── activity-detail.md
    │   ├── teacher-feedback.md
    │   ├── certificates.md
    │   ├── downloads.md
    │   ├── favorites.md
    │   ├── notifications.md
    │   ├── profile.md
    │   ├── settings.md
    │   ├── subscription.md
    │   ├── payments.md
    │   ├── invoices.md
    │   ├── referral.md
    │   ├── achievements.md
    │   ├── calendar.md
    │   ├── live.md
    │   └── search.md
    │
    ├── teacher/
    │   ├── dashboard.md
    │   ├── create-course.md
    │   ├── edit-course.md
    │   ├── modules.md
    │   ├── lessons.md
    │   ├── upload-video.md
    │   ├── upload-material.md
    │   ├── assignments.md
    │   ├── correction.md
    │   ├── analytics.md
    │   ├── students.md
    │   ├── reports.md
    │   └── profile.md
    │
    ├── admin/
    │   ├── dashboard.md
    │   ├── users.md
    │   ├── teachers.md
    │   ├── students.md
    │   ├── categories.md
    │   ├── payments.md
    │   ├── subscriptions.md
    │   ├── reports.md
    │   ├── audit.md
    │   ├── roles.md
    │   └── settings.md
    │
    └── shared/
        ├── loading.md
        ├── empty-state.md
        ├── error.md
        ├── offline.md
        ├── dialogs.md
        ├── bottom-sheet.md
        └── search.md
```

O agente deve procurar primeiro a especificação da página nessa estrutura.

---

# 3. Quando usar esta skill

Use esta skill quando a tarefa solicitar:

- criar uma nova página Flutter;
- implementar uma página já documentada;
- transformar um arquivo de `docs/pages/` em código;
- refatorar uma página existente;
- melhorar responsividade;
- conectar uma página a providers existentes;
- implementar estados visuais;
- criar uma tela de Public, Auth, Student, Teacher ou Admin;
- ajustar uma página para Web, Tablet e Android;
- revisar uma tela que não segue a especificação.

Exemplos de solicitações:

```text
Crie a página de login.

Implemente docs/pages/student/dashboard.md.

Refatore a tela de pagamentos do administrador.

Transforme teacher/create-course.md em Flutter.

Crie a página responsiva de certificados do aluno.
```

---

# 4. Quando não usar isoladamente

Não usar esta skill isoladamente quando a página depende de:

- nova regra de negócio;
- nova tabela;
- nova migration;
- novo endpoint;
- novo contexto de domínio;
- novo fluxo de pagamento;
- nova política RLS;
- novo worker.

Nesses casos, iniciar com:

```text
@create-feature
```

Depois usar:

```text
@create-api
@create-page
```

na etapa correspondente.

---

# 5. Leitura obrigatória

Antes de alterar qualquer código, ler nesta ordem:

```text
1. AGENTS.md

2. GEMINI.md

3. .ai/personas/ui-ux-designer.md

4. .ai/personas/flutter-architect.md

5. docs/product/PED-overview.md

6. docs/architecture/SYSTEM_ARCHITECTURE.md

7. docs/design/design-system.md

8. docs/navigation/PAGES_OVERVIEW.md

9. especificação individual em docs/pages/

10. docs/architecture/STATE_AND_OFFLINE_SPEC.md

11. docs/performance/PERFORMANCE_OPTIMIZATION_SPEC.md
```

Quando a página envolver:

```text
pagamento
assinatura
administração
permissões
dados sensíveis
download protegido
vídeos premium
```

ler também:

```text
docs/security/SECURITY_COMPLIANCE_SPEC.md
```

Quando precisar entender dados ou endpoints:

```text
docs/api/SERVICE_API.md

docs/database/DATABASE_SCHEMA.md
```

---

# 6. Localização da Page Spec

O agente deve transformar o nome solicitado em um caminho dentro de `docs/pages/`.

Exemplos:

```text
Página dashboard do aluno
→ docs/pages/student/dashboard.md
```

```text
Página criar curso do professor
→ docs/pages/teacher/create-course.md
```

```text
Página usuários do administrador
→ docs/pages/admin/users.md
```

```text
Página de login
→ docs/pages/auth/login.md
```

```text
Página pública de detalhes do curso
→ docs/pages/public/course-detail.md
```

Se a especificação não existir:

1. não inventar silenciosamente;
2. verificar `docs/navigation/PAGES_OVERVIEW.md`;
3. verificar arquivos de páginas semelhantes;
4. informar que a Page Spec está ausente;
5. criar a especificação somente se a tarefa autorizar.

---

# 7. Regra de precedência

Quando houver conflito, seguir:

```text
1. PED e regras de negócio

2. SYSTEM_ARCHITECTURE

3. SECURITY_COMPLIANCE_SPEC

4. Design System

5. PAGES_OVERVIEW

6. Especificação individual em docs/pages/

7. Esta skill

8. Skills externas
```

Uma skill externa não pode substituir:

- regras de negócio;
- cores oficiais;
- tipografia;
- estrutura arquitetural;
- modelo de assinatura por curso;
- regras de segurança;
- padrão de navegação;
- políticas de acessibilidade;
- limites do Liquid Glass.

---

# 8. Processo obrigatório

Toda criação de página deve seguir:

```text
Localizar Page Spec
        ↓
Ler requisitos
        ↓
Inspecionar código existente
        ↓
Identificar feature responsável
        ↓
Mapear rota e guards
        ↓
Definir objetivo do usuário
        ↓
Planejar hierarquia visual
        ↓
Mapear estados
        ↓
Planejar responsividade
        ↓
Reutilizar componentes existentes
        ↓
Implementar Controller e State
        ↓
Implementar a página
        ↓
Adicionar acessibilidade
        ↓
Adicionar testes
        ↓
Executar revisão
```

Nunca começar escrevendo widgets antes de ler o arquivo em `docs/pages/`.

---

# 9. Etapa 1 — Inspecionar a especificação

Extrair da Page Spec:

```text
ID da página

Nome

Rota

Layout

Role

Autenticação

Guards

Objetivo

Ação principal

Ações secundárias

Seções

Componentes

Estados

APIs

Providers

Responsividade

Acessibilidade

Critérios de aceitação
```

Exemplo de contrato extraído:

```yaml
page:
  id: PAGE-STUDENT-001
  name: Student Dashboard
  route: /student/dashboard
  spec: docs/pages/student/dashboard.md
  layout: StudentDashboardLayout
  role: student
  authentication: required
  guards:
    - AuthGuard
    - RoleGuard
  offline: partial
  primary_action: continue_learning
```

---

# 10. Etapa 2 — Verificar o código existente

Antes de criar arquivos, procurar:

```text
A feature já existe?

A Page já existe?

O Controller já existe?

Os providers já existem?

Existem widgets reutilizáveis?

O Design System possui componente equivalente?

A rota já está configurada?

Os UseCases necessários já existem?
```

Não duplicar:

```text
botões
cards
inputs
dialogs
bottom sheets
providers
controllers
repositories
use cases
rotas
```

Se existir implementação parcial, evoluir a existente.

---

# 11. Etapa 3 — Identificar a feature

As páginas devem ser organizadas por domínio ou feature.

Exemplo:

```text
docs/pages/student/certificates.md
```

Pode mapear para:

```text
lib/features/certificates/
```

Exemplo:

```text
docs/pages/teacher/create-course.md
```

Pode mapear para:

```text
lib/features/courses/
```

Não criar uma feature chamada apenas:

```text
student_pages
teacher_screens
admin_views
```

quando o conteúdo pertence a um domínio claro.

Roles representam acesso.

Features representam responsabilidades do produto.

---

# 12. Estrutura de pastas Flutter

Estrutura padrão:

```text
lawrence/
└── lib/
    └── features/
        └── feature_name/
            ├── presentation/
            │   ├── pages/
            │   ├── widgets/
            │   ├── controllers/
            │   ├── states/
            │   └── animations/
            │
            ├── application/
            │   └── use_cases/
            │
            ├── domain/
            │   ├── entities/
            │   ├── value_objects/
            │   └── repositories/
            │
            └── data/
                ├── models/
                ├── datasources/
                ├── mappers/
                └── repositories/
```

Exemplo para certificados:

```text
lawrence/
└── lib/
    └── features/
        └── certificates/
            ├── presentation/
            │   ├── pages/
            │   │   └── certificates_page.dart
            │   ├── widgets/
            │   │   ├── certificate_card.dart
            │   │   ├── certificate_list.dart
            │   │   ├── certificates_skeleton.dart
            │   │   ├── certificates_empty_state.dart
            │   │   └── certificates_error_state.dart
            │   ├── controllers/
            │   │   └── certificates_controller.dart
            │   └── states/
            │       └── certificates_state.dart
            │
            ├── application/
            ├── domain/
            └── data/
```

---

# 13. Regra da camada Presentation

A camada de apresentação pode conter:

```text
Page

Widgets

Controller Riverpod

State da interface

Animações

Form controllers
```

Ela não pode conter:

```text
SQL

Supabase client

HTTP direto

SQLite direto

Cálculo financeiro

Regra de assinatura

Autorização real

Regra de certificado

Transformação de JSON

Integração com gateway
```

Fluxo obrigatório:

```text
Page
 ↓
Controller
 ↓
UseCase
 ↓
Repository Interface
 ↓
Repository Implementation
```

---

# 14. Planejamento de UX

Antes do código, responder:

```text
Quem usa essa página?

Qual é o objetivo principal?

Qual ação deve ser encontrada em até 5 segundos?

Quais informações são prioritárias?

Quais informações são secundárias?

O que pode estar vazio?

O que pode falhar?

O que muda no offline?

Existe risco financeiro?

Existe risco de perda de dados?

Existe ação destrutiva?
```

Exemplo:

```text
Página:
My Courses

Usuário:
Student

Objetivo:
Encontrar e continuar cursos assinados.

Ação principal:
Continuar o curso mais recente.

Estados:
Loading, Success, Empty, Error e Offline.

Offline:
Mostrar cursos e aulas disponíveis no dispositivo.
```

---

# 15. Hierarquia visual

Toda página deve organizar:

```text
1. Contexto da página

2. Ação principal

3. Conteúdo prioritário

4. Conteúdo secundário

5. Ações auxiliares
```

Não tratar todos os elementos com o mesmo peso.

Evitar:

- muitos CTAs primários;
- excesso de cards;
- gráficos sem propósito;
- títulos repetidos;
- ações perigosas próximas de ações comuns;
- informação essencial escondida.

---

# 16. Lawrence Design System

Usar somente tokens oficiais.

Exemplos esperados:

```text
AppColors
AppTypography
AppSpacing
AppRadius
AppShadows
AppMotion
AppBreakpoints
LawrenceTheme
```

Proibido:

```dart
Color(0xFF123456)

TextStyle(fontSize: 17)

EdgeInsets.all(19)

BorderRadius.circular(21)
```

Preferir:

```dart
padding: const EdgeInsets.all(AppSpacing.lg)
```

```dart
style: context.typography.bodyLarge
```

```dart
color: context.colors.primary
```

Nunca criar uma nova cor para resolver um caso local sem atualizar o Design System.

---

# 17. Liquid Glass

Aplicar apenas nas superfícies permitidas:

```text
Navigation

Sticky Header

Floating Search

Dialogs

Bottom Sheets

Player Controls

Floating CTA

Checkout Bar
```

Não usar em:

```text
toda a página

cards repetidos

tabelas

listas

formulários extensos

conteúdo de leitura longa
```

Blur deve ser limitado e performático.

Usar `RepaintBoundary` quando necessário.

---

# 18. Responsividade

Toda página deve considerar:

```text
Android Mobile

Tablet

Flutter Web Desktop
```

## Mobile

- uma coluna;
- ação principal visível;
- touch targets confortáveis;
- Bottom Navigation;
- ações frequentes próximas ao polegar;
- informações secundárias progressivas.

## Tablet

- uma ou duas colunas;
- navegação adaptativa;
- painéis complementares;
- melhor uso do espaço horizontal.

## Desktop

- Sidebar;
- header;
- grids adaptativos;
- largura máxima para leitura;
- hover;
- foco;
- atalhos de teclado quando aplicáveis.

Usar:

```text
LayoutBuilder

MediaQuery

AppBreakpoints

SliverList

SliverGrid
```

Evitar implementar três páginas independentes.

---

# 19. Navegação

Usar GoRouter centralizado.

A rota deve estar alinhada a:

```text
docs/navigation/PAGES_OVERVIEW.md
```

Exemplo:

```dart
context.goNamed(
  AppRoute.lesson.name,
  pathParameters: {
    'lessonId': lesson.id,
  },
);
```

Não usar strings espalhadas:

```dart
context.go('/student/lesson/${lesson.id}');
```

quando houver rota nomeada.

Verificar guards:

```text
AuthGuard

RoleGuard

PermissionGuard

SubscriptionGuard
```

---

# 20. Providers e Riverpod

Preferir:

```text
Notifier

AsyncNotifier

Provider

StreamProvider
```

Evitar:

```text
FutureBuilder chamando API

setState para estado de negócio

Singleton global

Supabase dentro do Widget
```

A página observa estado e dispara intenções.

Exemplo:

```dart
final state = ref.watch(certificatesControllerProvider);
```

Ação:

```dart
ref
    .read(certificatesControllerProvider.notifier)
    .refresh();
```

---

# 21. Estados obrigatórios

Toda página que carrega dados deve implementar os estados aplicáveis.

## Initial

Antes do primeiro carregamento, quando necessário.

## Loading

Usar skeleton semelhante ao layout final.

Referência:

```text
docs/pages/shared/loading.md
```

## Success

Mostrar conteúdo real.

## Empty

Explicar o vazio e orientar o próximo passo.

Referência:

```text
docs/pages/shared/empty-state.md
```

## Error

Mostrar mensagem humana e recuperação.

Referência:

```text
docs/pages/shared/error.md
```

## Offline

Mostrar conteúdo em cache e limitações.

Referência:

```text
docs/pages/shared/offline.md
```

## Unauthorized

Nunca mostrar conteúdo protegido parcialmente.

## Forbidden

Informar falta de permissão sem revelar informações privadas.

---

# 22. Padrão de State

Pode usar `AsyncValue` ou estados selados.

Exemplo:

```dart
sealed class CertificatesState {
  const CertificatesState();
}

final class CertificatesInitial extends CertificatesState {
  const CertificatesInitial();
}

final class CertificatesLoading extends CertificatesState {
  const CertificatesLoading();
}

final class CertificatesLoaded extends CertificatesState {
  const CertificatesLoaded({
    required this.certificates,
    required this.isOffline,
  });

  final List<Certificate> certificates;
  final bool isOffline;
}

final class CertificatesEmpty extends CertificatesState {
  const CertificatesEmpty();
}

final class CertificatesFailure extends CertificatesState {
  const CertificatesFailure(this.failure);

  final Failure failure;
}
```

Os estados devem representar a experiência, não detalhes HTTP.

---

# 23. Estrutura da Page

A página deve permanecer pequena e composicional.

Exemplo:

```dart
class CertificatesPage extends ConsumerWidget {
  const CertificatesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(certificatesControllerProvider);

    return StudentShell(
      child: state.when(
        loading: () => const CertificatesSkeleton(),
        error: (error, stackTrace) => CertificatesErrorState(
          onRetry: () {
            ref
                .read(certificatesControllerProvider.notifier)
                .refresh();
          },
        ),
        data: (certificates) {
          if (certificates.isEmpty) {
            return const CertificatesEmptyState();
          }

          return CertificatesContent(
            certificates: certificates,
          );
        },
      ),
    );
  }
}
```

A Page deve:

- montar o layout;
- observar estado;
- exibir estados;
- delegar partes visuais;
- disparar ações;
- navegar.

---

# 24. Componentização

Extrair widgets quando houver:

- responsabilidade visual própria;
- reutilização;
- estado independente;
- comportamento isolado;
- complexidade;
- bloco significativo da tela.

Exemplo:

```text
DashboardPage
├── DashboardHeader
├── ContinueLearningCard
├── ProgressSection
├── UpcomingLivesSection
└── RecommendedCoursesSection
```

Evitar:

- Page com 800 linhas;
- widget para cada `Padding`;
- fragmentação artificial;
- componentes duplicados do Design System.

---

# 25. Formulários

Páginas com formulário devem:

- usar labels visíveis;
- validar campos;
- indicar obrigatoriedade;
- preservar dados;
- bloquear envio duplicado;
- mostrar loading no botão;
- avisar antes de descartar alterações;
- mapear erros do backend;
- suportar teclado;
- suportar autofill quando aplicável.

Fluxos longos devem usar:

```text
Stepper

Wizard

Etapas

Resumo final
```

Exemplo:

```text
docs/pages/teacher/create-course.md
```

---

# 26. Ações destrutivas

Para:

```text
Excluir

Cancelar assinatura

Bloquear usuário

Remover curso

Reembolsar pagamento

Alterar permissão
```

usar:

```text
docs/pages/shared/dialogs.md
```

ou:

```text
docs/pages/shared/bottom-sheet.md
```

conforme plataforma e criticidade.

Ações críticas devem informar:

- o que acontecerá;
- qual recurso será afetado;
- se é reversível;
- quando o acesso termina;
- necessidade de senha ou MFA.

---

# 27. Segurança da página

A UI pode:

- esconder ação sem permissão;
- mostrar bloqueio de assinatura;
- redirecionar;
- exibir estado apropriado.

A UI não pode ser a única proteção.

Verificar:

```text
Role

Permission

Ownership

Subscription

Authentication
```

Exemplos:

```text
Student não acessa /admin.

Teacher não edita curso de outro professor.

Aluno sem assinatura ativa não abre aula premium.

Admin sem MANAGE_PAYMENTS não vê reembolso.
```

---

# 28. Offline

Quando a Page Spec permitir offline:

- consultar cache local;
- indicar estado offline;
- preservar ações localmente;
- enfileirar sincronização;
- não bloquear conteúdo disponível;
- respeitar licença offline;
- não contornar assinatura.

Referência:

```text
docs/architecture/STATE_AND_OFFLINE_SPEC.md
```

Não inventar suporte offline para páginas que dependem necessariamente de conexão, como:

```text
checkout

reembolso

admin financeiro

upload de vídeo
```

---

# 29. Acessibilidade

Obrigatório:

```text
WCAG AA

TalkBack

VoiceOver

Keyboard Navigation

Focus Visible

Text Scaling

High Contrast

Touch Targets

Reduce Motion
```

Verificar:

- `Semantics`;
- labels claros;
- contraste;
- ordem de foco;
- texto ampliado;
- overflow;
- ícones com descrição;
- ações importantes com texto;
- mensagens de erro associadas aos campos;
- navegação por teclado no Web.

Para baixa visão:

- não usar texto pequeno;
- não usar cinza claro em conteúdo importante;
- evitar transparência excessiva;
- manter foco visível;
- usar ícone + texto em ações críticas;
- preservar zoom no Web.

---

# 30. Motion

Animações devem explicar transições e feedback.

Usar:

```text
Fade

Slide

Scale

AnimatedSwitcher

Hero

Spring Press

Progress Animation
```

Tempos:

```text
Fast:
150–200ms

Normal:
250–350ms

Slow:
até 420ms
```

Não usar:

- animação sem propósito;
- movimento contínuo;
- blur pesado animado;
- transição longa;
- animação incompatível com Reduce Motion.

---

# 31. Performance

Verificar:

```text
const widgets

ListView.builder

SliverList

SliverGrid

ref.watch(...select())

imagens redimensionadas

cache

paginação

rebuilds

controllers descartados
```

Evitar:

```dart
Column(
  children: items.map(...).toList(),
);
```

para listas grandes.

Evitar carregar:

- todos os cursos;
- todos os usuários;
- todos os pagamentos;
- todas as notificações;
- imagens em resolução original.

---

# 32. Testes obrigatórios

Ativar:

```text
qa-engineer
```

Criar testes para:

```text
Loading

Success

Empty

Error

Offline

Unauthorized

Interações

Navegação

Responsividade

Acessibilidade
```

## Widget tests

Validar renderização e ações.

## Golden tests

Usar para páginas críticas:

```text
home

dashboard

course-detail

checkout

player

admin dashboard

payments
```

## Responsive tests

Testar:

```text
Mobile

Tablet

Desktop
```

## Accessibility tests

Testar:

- semantics;
- escala de texto;
- foco;
- touch target;
- contraste quando houver ferramenta.

---

# 33. Atualização da rota

Quando criar uma página nova:

1. verificar `docs/navigation/PAGES_OVERVIEW.md`;
2. adicionar ou ajustar rota no GoRouter;
3. aplicar layout;
4. aplicar guards;
5. validar deep link;
6. criar teste de navegação;
7. não duplicar nome de rota.

---

# 34. Atualização da documentação

Quando a implementação revelar necessidade de alteração:

- atualizar a Page Spec em `docs/pages/`;
- atualizar `PAGES_OVERVIEW.md`;
- atualizar API mapping;
- atualizar provider mapping;
- atualizar critérios de aceitação;
- registrar pendências reais.

Código não pode divergir silenciosamente da documentação.

---

# 35. Entregáveis esperados

Ao concluir, fornecer:

```text
1. Page criada ou alterada

2. Widgets locais

3. Controller

4. State

5. Providers

6. Rotas

7. Integração com UseCases

8. Estados visuais

9. Responsividade

10. Acessibilidade

11. Motion

12. Testes

13. Arquivos alterados

14. Validações executadas

15. Pendências reais
```

---

# 36. Checklist final

```text
DOCUMENTAÇÃO

[ ] Localizou a Page Spec em docs/pages/?
[ ] Leu PAGES_OVERVIEW?
[ ] Leu Design System?
[ ] Atendeu critérios de aceitação?

ARQUITETURA

[ ] Feature correta?
[ ] Page pequena?
[ ] Controller separado?
[ ] State separado?
[ ] Sem API no Widget?
[ ] Sem regra de negócio na UI?

INTERFACE

[ ] Ação principal clara?
[ ] Hierarquia correta?
[ ] Design System?
[ ] Liquid Glass usado corretamente?
[ ] Componentes reutilizados?

ESTADOS

[ ] Loading?
[ ] Success?
[ ] Empty?
[ ] Error?
[ ] Offline?
[ ] Unauthorized ou Forbidden quando aplicável?

PLATAFORMAS

[ ] Mobile?
[ ] Tablet?
[ ] Desktop?
[ ] Web keyboard?
[ ] Android touch?

QUALIDADE

[ ] Acessibilidade?
[ ] Baixa visão?
[ ] Performance?
[ ] Testes?
[ ] Navegação?
[ ] Documentação atualizada?
```

---

# 37. Proibições

Nunca:

```text
❌ Criar página sem procurar docs/pages/

❌ Inventar requisitos ausentes

❌ Chamar Supabase diretamente no Widget

❌ Colocar regra de negócio na Page

❌ Criar cores aleatórias

❌ Criar espaçamentos aleatórios

❌ Usar Liquid Glass em toda a interface

❌ Criar página gigante

❌ Duplicar componentes

❌ Ignorar estados

❌ Ignorar responsividade

❌ Ignorar acessibilidade

❌ Ignorar baixa visão

❌ Criar navegação com strings espalhadas

❌ Entregar somente happy path

❌ Marcar como concluído sem testes
```

---

# 38. Exemplo de execução

Solicitação:

```text
Crie a página de certificados do aluno.
```

Execução esperada:

```text
1. Abrir docs/pages/student/certificates.md.

2. Abrir docs/navigation/PAGES_OVERVIEW.md.

3. Abrir docs/design/design-system.md.

4. Verificar feature certificates existente.

5. Verificar rota /student/certificates.

6. Verificar provider e UseCase existentes.

7. Definir Loading, Success, Empty, Error e Offline.

8. Planejar Mobile, Tablet e Desktop.

9. Criar CertificatesPage.

10. Criar CertificateCard.

11. Criar CertificatesSkeleton.

12. Criar CertificatesEmptyState.

13. Criar CertificatesErrorState.

14. Integrar Riverpod.

15. Adicionar acessibilidade.

16. Criar testes.

17. Executar review-code.
```

---

# Regra final

A especificação em:

```text
docs/pages/
```

define o comportamento esperado da página.

O Design System define sua linguagem visual.

O PAGES_OVERVIEW define sua navegação.

O Flutter entrega a experiência.

A arquitetura impede que a página se transforme em regra de negócio.