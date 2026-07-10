---
name: create-premium-flutter-screen
description: "Cria telas Flutter premium, responsivas, acessíveis e consistentes com o Lawrence Design System."
category: frontend
risk: safe
source: self
source_type: self
date_added: "2026-07-10"
version: 1.0.0
tags:
  - flutter
  - ui
  - ux
  - design-system
  - riverpod
  - responsive
  - accessibility
  - animation
tools:
  - antigravity
  - gemini

required_personas:
  - ui-ux-designer
  - flutter-architect
  - qa-engineer

optional_personas:
  - security-engineer

# Create Premium Flutter Screen

## 1. Objetivo

Criar ou refatorar uma tela Flutter com qualidade de produto premium.

A tela deve ser:

- visualmente refinada;
- simples de compreender;
- alinhada ao Lawrence Design System;
- responsiva no Android, tablet e Flutter Web;
- acessível;
- performática;
- integrada ao Riverpod e à Clean Architecture;
- completa em estados de carregamento, vazio, erro e offline;
- testável;
- composta por componentes reutilizáveis.

Esta skill não deve apenas gerar widgets.

Ela deve transformar uma especificação funcional em uma experiência de uso consistente, clara e pronta para produção.

---

## 2. Quando usar esta skill

Use quando a tarefa solicitar:

- criar uma nova tela Flutter;
- transformar uma Page Spec em código;
- melhorar uma tela visualmente fraca;
- refatorar uma tela genérica;
- criar dashboard, catálogo, perfil, checkout ou player;
- implementar interface premium;
- criar layout responsivo;
- aplicar microinterações;
- implementar estados visuais;
- revisar uma tela com baixa qualidade de UI/UX.

Para uma página comum, esta skill pode ser usada junto com:

```text
@create-page
````

Para uma funcionalidade completa que exige domínio, API e banco:

```text
@create-feature
```

---

## 3. Leitura obrigatória

Antes de escrever código, ler nesta ordem:

```text
1. AGENTS.md

2. GEMINI.md

3. .ai/personas/ui-ux-designer.md

4. .ai/personas/flutter-architect.md

5. docs/product/PED-overview.md

6. docs/design/design-system.md

7. docs/navigation/PAGES_OVERVIEW.md

8. especificação individual da página

9. docs/architecture/SYSTEM_ARCHITECTURE.md

10. docs/architecture/STATE_AND_OFFLINE_SPEC.md

11. docs/performance/PERFORMANCE_OPTIMIZATION_SPEC.md
```

Quando a página envolver conteúdo protegido, pagamento ou administração, ler também:

```text
docs/security/SECURITY_COMPLIANCE_SPEC.md
```

Nunca gerar a tela com base apenas no nome da página.

---

## 4. Regra de precedência

Em caso de conflito, seguir:

```text
1. Regras de negócio do PED

2. Arquitetura do sistema

3. Segurança

4. Lawrence Design System

5. Especificação da página

6. Esta skill

7. Skills externas
```

Skills externas como `design-it` podem inspirar composição e acabamento, mas nunca podem alterar:

* paleta oficial;
* tipografia;
* espaçamento;
* estrutura arquitetural;
* comportamento das rotas;
* modelo de assinatura;
* regras de Liquid Glass;
* acessibilidade mínima.

---

## 5. Padrão de qualidade visual

A interface deve transmitir uma combinação de:

```text
Apple
+
MasterClass
+
Duolingo
+
Linear
```

Interpretar assim:

### Apple

* clareza;
* acabamento;
* hierarquia;
* simplicidade;
* transições suaves;
* superfícies bem definidas.

### MasterClass

* valorização do conteúdo;
* apresentação editorial;
* imagens e vídeos como protagonistas;
* sensação premium.

### Duolingo

* feedback imediato;
* progresso visível;
* motivação;
* microinterações úteis.

### Linear

* precisão;
* densidade controlada;
* navegação eficiente;
* consistência.

Não copiar visualmente nenhum produto.

Aplicar apenas princípios de qualidade.

---

## 6. Processo obrigatório

Toda tela deve seguir:

```text
Entender o usuário
        ↓
Definir objetivo principal
        ↓
Mapear hierarquia visual
        ↓
Definir estados
        ↓
Planejar responsividade
        ↓
Selecionar componentes existentes
        ↓
Criar composição
        ↓
Implementar Controller e State
        ↓
Adicionar acessibilidade
        ↓
Adicionar motion
        ↓
Otimizar performance
        ↓
Criar testes
        ↓
Executar revisão visual
```

Nunca começar adicionando cards aleatórios.

---

## 7. Briefing obrigatório da tela

Antes de implementar, definir internamente:

```yaml
screen:
  name: Student Dashboard
  route: /student/dashboard
  role: student
  goal: continuar o aprendizado
  primary_action: continuar curso
  secondary_actions:
    - visualizar próximos eventos
    - abrir certificados
    - explorar novos cursos
  information_priority:
    - curso em andamento
    - progresso
    - próximas atividades
    - recomendações
  offline_behavior: partial
  responsive: true
```

Também identificar:

```text
Qual problema a tela resolve?

O que o usuário precisa fazer em menos de 5 segundos?

Qual informação deve aparecer primeiro?

O que pode ser removido?

Quais ações são frequentes?

Quais ações são críticas?

Quais dados podem estar vazios?

Quais estados podem falhar?
```

---

## 8. UX plan antes do código

Produzir um plano breve:

```text
Objetivo da tela

Perfil do usuário

Ação principal

Ações secundárias

Estrutura das seções

Comportamento mobile

Comportamento tablet

Comportamento desktop

Estados

Acessibilidade

Motion
```

Exemplo:

```text
Tela:
Dashboard do aluno

Objetivo:
Fazer o aluno retomar o curso rapidamente.

Primeira dobra:
Saudação, curso em andamento e CTA Continuar.

Segunda seção:
Próximas atividades e lives.

Terceira seção:
Recomendações e conquistas.

Mobile:
Uma coluna, CTA próximo ao polegar.

Desktop:
Sidebar, conteúdo principal e painel de agenda.
```

---

## 9. Hierarquia visual

Toda tela precisa de:

```text
1. Contexto

2. Ação principal

3. Conteúdo prioritário

4. Conteúdo secundário

5. Ações de suporte
```

Evitar:

* cinco CTAs principais;
* títulos com o mesmo peso;
* cards visualmente idênticos;
* excesso de ícones;
* informações importantes no fim da tela;
* métricas sem contexto.

A ação principal deve ser identificável em poucos segundos.

---

## 10. Estrutura de pastas

Usar a feature correspondente:

```text
lib/
└── features/
    └── dashboard/
        ├── presentation/
        │   ├── pages/
        │   │   └── student_dashboard_page.dart
        │   ├── widgets/
        │   │   ├── dashboard_header.dart
        │   │   ├── continue_learning_card.dart
        │   │   ├── progress_summary.dart
        │   │   ├── upcoming_events_section.dart
        │   │   ├── recommendation_section.dart
        │   │   ├── dashboard_skeleton.dart
        │   │   ├── dashboard_empty_state.dart
        │   │   └── dashboard_error_state.dart
        │   ├── controllers/
        │   │   └── student_dashboard_controller.dart
        │   ├── states/
        │   │   └── student_dashboard_state.dart
        │   └── animations/
        │       └── dashboard_entry_animation.dart
        │
        ├── application/
        ├── domain/
        └── data/
```

Não criar toda a feature novamente quando ela já existe.

Antes de criar widgets, procurar componentes equivalentes em:

```text
lib/design_system/
lib/shared/
```

---

## 11. Page composition

A página deve atuar como composição.

Exemplo:

```dart
class StudentDashboardPage extends ConsumerWidget {
  const StudentDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(studentDashboardControllerProvider);

    return StudentDashboardShell(
      child: state.when(
        loading: () => const StudentDashboardSkeleton(),
        error: (error, stackTrace) => StudentDashboardErrorState(
          onRetry: () {
            ref
                .read(studentDashboardControllerProvider.notifier)
                .refresh();
          },
        ),
        data: (data) {
          if (data.isEmpty) {
            return const StudentDashboardEmptyState();
          }

          return StudentDashboardContent(data: data);
        },
      ),
    );
  }
}
```

A página não deve concentrar toda a interface em um único `build`.

---

## 12. Lawrence Design System

Usar apenas tokens oficiais.

Obrigatório:

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
TextStyle(fontSize: 15)
EdgeInsets.all(21)
BorderRadius.circular(19)
```

Correto:

```dart
Container(
  padding: const EdgeInsets.all(AppSpacing.lg),
  decoration: BoxDecoration(
    color: context.colors.surface,
    borderRadius: BorderRadius.circular(AppRadius.large),
  ),
  child: Text(
    'Continue aprendendo',
    style: context.typography.headingMedium,
  ),
);
```

---

## 13. Regras de cor

A paleta oficial vence qualquer paleta externa.

Seguir a distribuição:

```text
60% Base clara ou superfície

30% Azul de ação e conteúdo estrutural

10% Dourado premium
```

Dourado deve ser reservado para:

* certificados;
* conquistas;
* premium;
* selos especiais;
* destaques raros.

Não usar dourado como cor comum de botão ou texto secundário.

Cores semânticas servem para:

```text
Success

Warning

Danger

Info
```

Não usar cor apenas como decoração.

---

## 14. Tipografia

Usar a escala oficial.

Regras:

* títulos devem estabelecer contexto;
* texto educacional deve preservar legibilidade;
* conteúdo principal não deve ficar pequeno;
* subtítulos devem ajudar a escanear a tela;
* labels precisam continuar legíveis com aumento de fonte;
* evitar excesso de bold;
* evitar três fontes diferentes;
* respeitar fallback do projeto.

Nunca reduzir texto para caber.

Ajustar layout.

---

## 15. Espaçamento e grid

Usar somente valores do sistema de espaçamento.

Preferir:

* seções com respiro;
* agrupamentos claros;
* alinhamento consistente;
* margens previsíveis;
* grids adaptativos.

Evitar:

* espaçamentos diferentes para elementos equivalentes;
* cards encostados;
* padding arbitrário;
* desalinhamento entre título, conteúdo e ação;
* telas excessivamente densas.

---

## 16. Cards

Cards devem existir apenas quando agrupam informação ou ação.

Não transformar cada texto em um card.

Um card premium deve ter:

```text
Propósito claro

Hierarquia interna

Espaçamento consistente

Ação identificável

Estado de interação

Responsividade
```

Exemplo:

```text
CourseProgressCard

Thumbnail
Título
Progresso
Próxima aula
CTA Continuar
```

Evitar:

* card dentro de card;
* borda pesada;
* sombra forte;
* todos os cards iguais;
* vinte cards em uma tela;
* glassmorphism em cards repetidos.

---

## 17. Liquid Glass

Usar apenas em superfícies flutuantes:

```text
Navigation Bar

Bottom Navigation

Sticky Header

Player Controls

Dialogs

Bottom Sheets

Floating Search

Floating CTA

Checkout Bar
```

Configuração vem do Design System.

Todo blur deve ser:

* limitado;
* encapsulado;
* performático;
* legível;
* contrastante.

Quando necessário:

```dart
RepaintBoundary(
  child: LawrenceGlassSurface(
    child: ...
  ),
);
```

Não usar Liquid Glass:

* no background inteiro;
* em listas;
* em cards de curso repetidos;
* em tabelas;
* em formulários grandes;
* atrás de texto de leitura longa.

---

## 18. Responsividade

Suportar:

```text
Mobile Android

Tablet

Desktop Web
```

Planejar antes do código.

### Mobile

* uma coluna;
* prioridade para ação principal;
* CTA próximo ao polegar;
* Bottom Navigation;
* informações secundárias recolhíveis;
* poucos elementos por linha.

### Tablet

* duas colunas quando fizer sentido;
* navegação adaptativa;
* maior aproveitamento horizontal;
* painéis auxiliares opcionais.

### Desktop

* Sidebar;
* conteúdo central;
* painéis laterais quando úteis;
* largura máxima de leitura;
* grids maiores;
* hover e teclado.

Usar:

```dart
LayoutBuilder
MediaQuery
AppBreakpoints
Slivers
ResponsiveBuilder do projeto
```

Evitar três implementações completamente separadas.

---

## 19. Navegação

Usar GoRouter centralizado.

Não usar rotas em string espalhadas.

Preferir:

```dart
context.goNamed(
  AppRoute.lesson.name,
  pathParameters: {
    'lessonId': lesson.id,
  },
);
```

A tela deve respeitar:

```text
AuthGuard

RoleGuard

PermissionGuard

SubscriptionGuard
```

A UI pode ocultar ações, mas a autorização real pertence ao backend.

---

## 20. Riverpod

Usar Riverpod para estado de negócio e dados.

Preferir:

```text
Notifier

AsyncNotifier

Provider

StreamProvider
```

Evitar:

```text
setState para estado de negócio

FutureBuilder chamando API

Singletons globais

Supabase dentro do Widget
```

O fluxo correto:

```text
Widget
 ↓
Controller
 ↓
UseCase
 ↓
Repository
```

Usar `select` quando apenas uma parte do estado é necessária.

---

## 21. Estados visuais

Toda tela assíncrona deve implementar os estados aplicáveis.

### Loading

* skeleton próximo do layout final;
* não exibir tela branca;
* evitar spinner genérico em página inteira;
* manter navegação estável.

### Success

* conteúdo real;
* transição suave;
* ação principal clara.

### Empty

* ícone ou ilustração leve;
* título humano;
* descrição curta;
* CTA útil.

### Error

* mensagem compreensível;
* ação de retry;
* preservar dados disponíveis;
* não mostrar stack trace.

### Offline

* informar conexão;
* mostrar cache;
* indicar limitações;
* permitir retry;
* não bloquear tudo sem necessidade.

### Unauthorized

* nunca renderizar conteúdo protegido;
* redirecionar ou exibir estado seguro.

Referências:

```text
docs/shared/loading.md
docs/shared/empty-state.md
docs/shared/error.md
docs/shared/offline.md
```

---

## 22. Microinterações

Adicionar motion apenas quando melhora entendimento.

Usar para:

* pressionamento de botão;
* alteração de estado;
* conclusão de aula;
* progresso;
* entrada de seção;
* navegação;
* confirmação;
* expansão;
* feedback de erro.

Permitidos:

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

Respeitar redução de movimento.

Nunca criar animação apenas para impressionar.

---

## 23. Componentes premium

Ao criar componentes, incluir:

```text
Default

Pressed

Hovered

Focused

Disabled

Loading

Error
```

quando aplicável.

Exemplo de botão:

```dart
LawrencePrimaryButton(
  label: 'Continuar aula',
  isLoading: state.isSubmitting,
  onPressed: state.canContinue
      ? controller.continueLesson
      : null,
);
```

Não criar variantes locais desnecessárias de botões existentes.

---

## 24. Imagens e mídia

Imagens devem:

* usar proporção adequada;
* ter placeholder;
* usar cache;
* ser redimensionadas;
* evitar distorção;
* possuir descrição semântica quando relevante.

Vídeos devem seguir:

```text
HLS

Zero MP4 público

Player seguro

Controles em Liquid Glass
```

Nunca usar URL MP4 pública em tela.

---

## 25. Formulários premium

Formulários devem reduzir esforço.

Aplicar:

* labels visíveis;
* validação em contexto;
* autofill quando possível;
* seleção em vez de digitação;
* agrupamento por etapas;
* mensagens de erro humanas;
* preservação de dados;
* feedback de salvamento;
* confirmação antes de descartar.

Não colocar dez campos em um único bloco sem hierarquia.

Para fluxos longos, usar:

```text
Stepper

Wizard

Progress indicator

Summary step
```

---

## 26. Dashboards

Nunca criar dashboard genérico.

Cada dashboard deve responder:

```text
O que aconteceu?

O que merece atenção?

Qual é a próxima ação?

Como estou evoluindo?
```

### Student

Priorizar:

* continuar aprendendo;
* progresso;
* próximas atividades;
* lives;
* certificados.

### Teacher

Priorizar:

* cursos;
* pendências;
* alunos;
* receita;
* atividades para corrigir.

### Admin

Priorizar:

* riscos;
* operação;
* financeiro;
* moderação;
* alertas;
* saúde do sistema.

Não adicionar gráficos apenas para preencher espaço.

---

## 27. Acessibilidade

Obrigatório:

```text
WCAG AA

TalkBack

VoiceOver

Keyboard Navigation

Focus Visible

Text Scaling

High Contrast

Touch Target mínimo

Reduce Motion
```

Regras:

* usar `Semantics`;
* labels claros;
* não depender somente de cor;
* não usar texto em imagem;
* manter contraste;
* ordem de foco lógica;
* atalhos de teclado no Web quando aplicável;
* permitir aumento de texto;
* evitar overflow;
* descrever gráficos;
* fornecer feedback não visual.

Exemplo:

```dart
Semantics(
  button: true,
  label: 'Continuar curso de Alta Costura',
  child: LawrencePrimaryButton(
    label: 'Continuar',
    onPressed: onContinue,
  ),
);
```

---

## 28. Suporte à baixa visão

Como parte da acessibilidade, validar:

* contraste forte;
* fonte legível;
* ícones maiores;
* áreas de toque confortáveis;
* não usar cinza claro em texto importante;
* não usar informação minúscula;
* evitar excesso de transparência;
* permitir zoom no Web;
* não reduzir opacidade a ponto de perder leitura;
* sempre combinar ícone com texto em ações importantes.

---

## 29. Performance

Toda tela premium precisa continuar fluida.

Obrigatório:

* `const` onde possível;
* widgets menores;
* `ListView.builder`;
* Slivers;
* imagens redimensionadas;
* cache;
* paginação;
* `ref.watch(...select())`;
* evitar rebuild global;
* encapsular blur;
* evitar animações pesadas;
* não decodificar imagens 4K em cards;
* limitar sombras;
* evitar nested scroll desnecessário.

Meta:

```text
60 FPS obrigatório

120 FPS quando disponível
```

---

## 30. Testes

Ativar:

```text
qa-engineer
```

Criar:

### Widget tests

Cobrir:

```text
Loading

Success

Empty

Error

Offline

Interações

Navegação

Permissões visuais
```

### Golden tests

Usar para:

* dashboards;
* checkout;
* player;
* componentes do Design System;
* páginas públicas principais;
* fluxos administrativos críticos.

### Accessibility tests

Verificar:

* semântica;
* touch targets;
* text scaling;
* foco;
* contraste;
* leitura por screen reader.

### Responsive tests

Validar tamanhos:

```text
Mobile

Tablet

Desktop
```

---

## 31. UI review obrigatório

Antes de concluir, revisar como `ui-ux-designer`.

Perguntas:

```text
A ação principal está clara?

A tela parece premium?

A hierarquia é imediata?

Existe espaço suficiente?

A tela funciona sem imagem?

O layout funciona com texto maior?

O usuário entende o que fazer?

Existe alguma seção sem propósito?

Os estados estão completos?

A tela parece genérica?

O Design System foi respeitado?
```

Se a tela parecer um template genérico, refatorar.

---

## 32. Flutter architecture review

Antes de concluir, revisar como `flutter-architect`.

Checklist:

```text
[ ] Feature First?

[ ] Page pequena?

[ ] Widgets reutilizáveis?

[ ] Sem regra de negócio na UI?

[ ] Sem Supabase no Widget?

[ ] Riverpod correto?

[ ] UseCases existentes?

[ ] GoRouter?

[ ] Responsividade?

[ ] Offline tratado?

[ ] Performance aceitável?

[ ] Testes adicionados?
```

---

## 33. Entregáveis esperados

Ao concluir, entregar:

```text
1. UX plan

2. Árvore da tela

3. Page Flutter

4. Widgets locais

5. Controllers e states

6. Providers

7. Integração com UseCases

8. Estados visuais

9. Responsividade

10. Acessibilidade

11. Motion

12. Testes

13. Lista de arquivos alterados

14. Pendências reais
```

Nunca afirmar que uma tela está pronta sem testar o que for possível no ambiente.

---

## 34. Proibições

Nunca:

```text
❌ Criar UI genérica

❌ Criar dashboard padrão Bootstrap

❌ Inventar cores

❌ Usar gradiente sem especificação

❌ Usar Liquid Glass em tudo

❌ Colocar API no Widget

❌ Colocar regra de negócio na tela

❌ Criar arquivo com centenas de linhas sem divisão

❌ Ignorar Loading

❌ Ignorar Empty

❌ Ignorar Error

❌ Ignorar Offline

❌ Ignorar acessibilidade

❌ Ignorar baixa visão

❌ Usar texto pequeno para caber

❌ Duplicar componentes

❌ Criar animações sem propósito

❌ Entregar apenas mobile

❌ Concluir sem testes
```

---

## 35. Exemplo de execução

Solicitação:

```text
Crie uma tela premium para o dashboard do aluno.
```

Fluxo:

```text
1. Ler dashboard.md

2. Entender objetivo do aluno

3. Definir CTA Continuar aprendendo

4. Planejar hierarquia

5. Localizar componentes existentes

6. Planejar mobile/tablet/desktop

7. Criar Controller e State

8. Criar skeleton

9. Criar conteúdo

10. Criar empty state

11. Criar error state

12. Criar offline state

13. Adicionar motion

14. Adicionar semântica

15. Criar testes

16. Revisar qualidade
```

Resultado esperado:

```text
Uma interface com foco claro,
sem excesso de cards,
com conteúdo prioritário,
navegação adaptativa,
animações sutis,
acessibilidade e código limpo.
```

---

## Regra final

Não crie uma tela apenas para parecer bonita.

Crie uma experiência que:

```text
oriente

motive

informe

responda

proteja

inclua

funcione
```

O Design System define a linguagem.

A Page Spec define a intenção.

O Flutter entrega a experiência.

A arquitetura mantém o produto sustentável.

```
```
