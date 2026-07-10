---
name: Lawrence Animations Specification
version: 1.0.0
type: Motion Design & Interaction Specification
status: Production Ready

platforms:
  - Flutter Android
  - Flutter Web

framework:
  - Flutter
  - Dart

depends_on:
  - docs/design/DESIGN_SYSTEM.md
  - docs/design/UI_UX_FRONTEND_SPEC.md
  - docs/design/COMPONENTS.md
  - docs/performance/PERFORMANCE_OPTIMIZATION_SPEC.md
  - docs/accessibility/ACCESSIBILITY.md

architecture:
  - Motion With Purpose
  - Accessible Motion
  - Performance First
  - Component Driven Animation

related_skills:
  - .ai/skills/create-page/SKILL.md
  - .ai/skills/create-premium-flutter-screen/SKILL.md
  - .ai/skills/optimize-performance/SKILL.md
  - .ai/skills/review-code/SKILL.md
---

# Lawrence Academy
# Animations & Motion Design Specification

## 1. Objetivo

Este documento define o sistema oficial de animações, transições, microinterações e feedback visual da Lawrence Academy.

Ele deve orientar:

- Product Designers;
- Motion Designers;
- Desenvolvedores Flutter;
- Agentes de IA;
- Revisores de UI;
- QA;
- Especialistas de acessibilidade.

As animações devem:

- explicar mudanças;
- orientar atenção;
- confirmar ações;
- indicar progresso;
- reduzir sensação de espera;
- reforçar continuidade;
- melhorar compreensão.

Animação não deve existir apenas para decoração.

---

# 2. Princípio central

Toda animação deve responder pelo menos uma destas perguntas:

```text
O que mudou?

De onde veio?

Para onde foi?

A ação foi concluída?

Algo está carregando?

Existe erro?

Existe progresso?

O usuário precisa prestar atenção?
```

Se a animação não responder nenhuma dessas perguntas, ela provavelmente não é necessária.

---

# 3. Filosofia de motion

O sistema segue:

```text
Motion With Purpose

Clarity First

Performance First

Accessibility First

Consistency First
```

Regra principal:

```text
A interface deve parecer viva,
mas nunca inquieta.
```

---

# 4. Objetivos do motion

As animações podem ser usadas para:

## Orientação espacial

Mostrar relação entre telas, painéis e elementos.

Exemplo:

```text
Card de curso
        ↓
Hero transition
        ↓
Detalhes do curso
```

## Mudança de estado

Exemplo:

```text
Loading
   ↓
Success
```

## Confirmação

Exemplo:

```text
Aula concluída
   ↓
Check animado
```

## Progresso

Exemplo:

```text
Upload
   ↓
Barra de progresso
```

## Feedback de interação

Exemplo:

```text
Pressionar botão
   ↓
Scale 0.97
```

## Atenção

Exemplo:

```text
Erro de pagamento
   ↓
Mensagem inline com fade
```

---

# 5. Escala oficial de duração

Usar estes tokens:

```text
Instant:
0–100ms

Fast:
150–200ms

Normal:
250–350ms

Slow:
380–420ms
```

Referência recomendada:

```dart
abstract final class AppMotionDuration {
  static const instant = Duration(milliseconds: 100);
  static const fast = Duration(milliseconds: 180);
  static const normal = Duration(milliseconds: 280);
  static const slow = Duration(milliseconds: 420);
}
```

Não criar tempos aleatórios por tela.

---

# 6. Curvas oficiais

Curvas recomendadas:

```text
Standard:
Curves.easeOutCubic

Entrance:
Curves.easeOut

Exit:
Curves.easeIn

Emphasized:
Curves.easeInOutCubic

Spring:
SpringDescription controlada
```

Exemplo:

```dart
abstract final class AppMotionCurve {
  static const standard = Curves.easeOutCubic;
  static const entrance = Curves.easeOut;
  static const exit = Curves.easeIn;
  static const emphasized = Curves.easeInOutCubic;
}
```

Evitar:

- bounce exagerado;
- elastic excessivo;
- curvas diferentes sem motivo;
- overshoot em ações críticas.

---

# 7. Tokens de motion

O projeto deve centralizar:

```text
Duration

Curve

Scale

Opacity

Offset

Blur

Spring
```

Exemplo:

```dart
abstract final class AppMotion {
  static const buttonPressedScale = 0.97;
  static const cardHoverScale = 1.01;
  static const modalEntryScale = 0.96;
  static const fadeStartOpacity = 0.0;
  static const slideDistance = 16.0;
}
```

Não codificar valores diretamente em cada widget.

---

# 8. Categorias de animação

O sistema possui:

```text
Microinteractions

State Transitions

Navigation Transitions

Content Entrance

Feedback Animations

Progress Animations

Overlay Animations

Media Animations
```

---

# 9. Microinterações

Microinterações devem ser sutis.

Aplicar em:

- botões;
- cards;
- chips;
- toggles;
- favoritos;
- download;
- conclusão;
- seleção;
- expansão.

## Button press

Padrão:

```text
Scale:
1.00 → 0.97 → 1.00

Duration:
150–180ms
```

Exemplo:

```dart
AnimatedScale(
  scale: isPressed ? AppMotion.buttonPressedScale : 1,
  duration: AppMotionDuration.fast,
  curve: AppMotionCurve.standard,
  child: child,
)
```

## Hover

Desktop apenas.

Padrão:

```text
Scale:
1.00 → 1.01

Elevation:
aumenta levemente

Duration:
180ms
```

Nunca mover o layout.

## Toggle

Transição:

```text
Color + Position + Scale
```

Duração:

```text
180–220ms
```

---

# 10. Entrada de conteúdo

Use para:

- seções;
- cards principais;
- listas curtas;
- estados;
- cabeçalhos.

Padrão recomendado:

```text
Fade
+
Slide vertical de 8–16px
```

Exemplo:

```dart
TweenAnimationBuilder<double>(
  tween: Tween(begin: 0, end: 1),
  duration: AppMotionDuration.normal,
  curve: AppMotionCurve.entrance,
  builder: (context, value, child) {
    return Opacity(
      opacity: value,
      child: Transform.translate(
        offset: Offset(0, (1 - value) * AppMotion.slideDistance),
        child: child,
      ),
    );
  },
  child: content,
)
```

Não animar dezenas de itens simultaneamente.

---

# 11. Staggered animation

Permitida em:

- onboarding;
- listas curtas;
- dashboards;
- hero sections;
- cards de destaque.

Regras:

```text
Máximo recomendado:
6–8 itens

Delay entre itens:
40–80ms

Duração individual:
180–280ms
```

Evitar em:

- listas longas;
- tabelas;
- grids com muitos itens;
- scroll infinito;
- telas administrativas densas.

---

# 12. Transições entre estados

Usar `AnimatedSwitcher` para:

```text
Loading → Success

Loading → Error

Empty → Content

Offline → Online

Collapsed → Expanded
```

Exemplo:

```dart
AnimatedSwitcher(
  duration: AppMotionDuration.normal,
  switchInCurve: AppMotionCurve.entrance,
  switchOutCurve: AppMotionCurve.exit,
  child: currentStateWidget,
)
```

O `Key` dos estados deve ser estável e explícito.

---

# 13. Loading animations

## Skeleton

Preferir skeleton em:

- dashboards;
- cards;
- listas;
- detalhes;
- catálogo.

Regras:

- preservar layout;
- não piscar;
- shimmer leve;
- contraste controlado;
- duração moderada;
- respeitar Reduce Motion.

## Spinner

Usar apenas em:

- botão;
- ação bloqueante;
- envio;
- pagamento;
- processamento curto;
- operações sem layout previsível.

## Progress bar

Usar quando houver progresso real:

```text
Download

Upload

Processamento de vídeo

Sincronização

Geração de certificado
```

Nunca simular porcentagem falsa.

---

# 14. Success animations

Use para:

- aula concluída;
- curso concluído;
- pagamento aprovado;
- certificado emitido;
- upload finalizado;
- tarefa enviada.

Padrão:

```text
Scale leve
+
Fade
+
Check
```

Duração:

```text
280–420ms
```

A animação deve ser curta.

Não bloquear navegação.

---

# 15. Error animations

Erros devem ser claros sem agressividade.

Permitido:

```text
Fade

Color transition

Small horizontal shake

Inline expansion
```

Shake:

```text
Máximo:
4–8px

Duração:
180–240ms

Repetições:
1
```

Nunca:

- shake contínuo;
- piscar;
- vermelho pulsante;
- movimento forte;
- animação que dificulte leitura.

---

# 16. Empty state animations

Empty states podem usar:

```text
Fade

Gentle scale

Illustration entrance
```

Não usar animação infinita sem propósito.

A ação principal deve aparecer rapidamente.

---

# 17. Offline animations

Usar:

- banner com slide suave;
- ícone estático;
- transição quando conexão retorna;
- sincronização com progresso real.

Fluxo:

```text
Online
  ↓
Offline Banner
  ↓
Connection Restored
  ↓
Sync Indicator
  ↓
Success Feedback
```

Não usar animação que bloqueie conteúdo em cache.

---

# 18. Page transitions

Transições de página devem preservar contexto.

## Mobile

Padrão:

```text
Push:
Slide horizontal + Fade

Modal:
Slide Up

Back:
Reverse transition
```

## Desktop

Padrão:

```text
Fade

Subtle Scale

Content Swap
```

Evitar slides horizontais longos em desktop.

## Navigation tabs

Usar:

```text
Crossfade

Shared axis
```

Não reiniciar animações pesadas ao trocar aba.

---

# 19. GoRouter transitions

As transições devem ser centralizadas.

Exemplo:

```dart
CustomTransitionPage<void>(
  key: state.pageKey,
  transitionDuration: AppMotionDuration.normal,
  reverseTransitionDuration: AppMotionDuration.fast,
  child: child,
  transitionsBuilder: (
    context,
    animation,
    secondaryAnimation,
    child,
  ) {
    final fade = CurvedAnimation(
      parent: animation,
      curve: AppMotionCurve.entrance,
    );

    return FadeTransition(
      opacity: fade,
      child: child,
    );
  },
)
```

Não definir transição diferente em cada página sem necessidade.

---

# 20. Hero animations

Usar Hero em:

- thumbnail do curso;
- avatar;
- certificado;
- imagem principal;
- capa editorial.

Regras:

- origem e destino claros;
- proporção compatível;
- tag única;
- não usar em listas gigantes;
- respeitar Reduce Motion;
- evitar Hero em conteúdo sensível.

---

# 21. Dialog animations

Padrão:

```text
Fade backdrop
+
Scale 0.96 → 1.00
```

Duração:

```text
Entrada:
250–280ms

Saída:
150–180ms
```

Ações críticas devem priorizar clareza, não espetáculo.

---

# 22. Bottom Sheet animations

Padrão:

```text
Slide Up
+
Backdrop Fade
```

Duração:

```text
Entrada:
280ms

Saída:
180ms
```

Gestos:

- swipe down;
- resistência controlada;
- snap points quando aplicável.

Não permitir swipe down durante:

- pagamento;
- upload crítico;
- operação não cancelável;
- dados não salvos sem confirmação.

---

# 23. Toast animations

Padrão:

```text
Fade
+
Slide vertical curto
```

Duração:

```text
Entrada:
180ms

Saída:
150ms
```

Tempo de permanência:

```text
Informativo:
2–3s

Erro:
4–6s

Ação disponível:
até 6s
```

Toasts não devem conter informação crítica única.

---

# 24. Navigation animations

## Bottom Navigation

Usar:

- mudança de cor;
- leve scale;
- indicador animado;
- sem movimentação exagerada.

## Sidebar

Usar:

- width transition;
- opacity;
- label reveal;
- duration 220–280ms.

## Active item

A transição deve preservar leitura.

Não usar movimento contínuo.

---

# 25. Card animations

Cards podem usar:

```text
Hover elevation

Press scale

Image fade-in

Progress transition
```

Não usar:

- rotação;
- perspectiva exagerada;
- bounce;
- glass animado;
- brilho contínuo.

---

# 26. Progress animations

Usar para:

- curso;
- módulo;
- upload;
- download;
- sincronização;
- processamento.

Regras:

- valor real;
- transição suave;
- não reiniciar ao rebuild;
- respeitar estado persistido;
- atualizar sem saltos abruptos.

Exemplo:

```dart
TweenAnimationBuilder<double>(
  tween: Tween(
    begin: previousProgress,
    end: currentProgress,
  ),
  duration: AppMotionDuration.normal,
  curve: AppMotionCurve.standard,
  builder: (context, value, child) {
    return LinearProgressIndicator(value: value);
  },
)
```

---

# 27. Video player animations

Permitido:

- fade dos controles;
- barra de progresso;
- buffering;
- entrada e saída de legenda;
- feedback de play/pause;
- troca de qualidade;
- fullscreen transition.

Regras:

```text
Controls fade:
180–250ms

Auto-hide:
2–4s sem interação

Buffering:
indicador discreto

Subtitle:
sem animação agressiva
```

Nunca animar o conteúdo do vídeo com efeitos externos.

---

# 28. Download animations

Estados:

```text
Idle

Queued

Downloading

Paused

Completed

Failed
```

Feedback:

- progresso real;
- ícone de estado;
- texto;
- opção de pausar;
- opção de retomar;
- erro recuperável.

Não usar apenas cor.

---

# 29. Upload animations

Fluxo:

```text
Select File
  ↓
Validation
  ↓
Uploading
  ↓
Processing
  ↓
Ready
```

Cada etapa deve ser visualmente distinta.

Não apresentar 100% antes de concluir processamento.

---

# 30. AI processing animations

Para IA:

```text
Queued

Processing

Validating

Ready

Failed
```

Não usar animação falsa de “pensamento”.

Mostrar estado real.

Exemplo:

```text
Gerando resumo da aula...

Validando conteúdo...

Resumo pronto.
```

---

# 31. Data visualization animations

Gráficos podem animar entrada apenas uma vez.

Regras:

- duração até 420ms;
- sem repetição;
- dados permanecem legíveis;
- não animar atualização contínua;
- respeitar Reduce Motion.

---

# 32. Accessibility and reduced motion

O sistema deve respeitar:

```dart
MediaQuery.disableAnimationsOf(context)
```

Quando animações estiverem desativadas:

- remover slides;
- reduzir scale;
- manter fades mínimos;
- evitar Hero;
- evitar stagger;
- remover parallax;
- evitar loops.

Exemplo:

```dart
final disableAnimations =
    MediaQuery.disableAnimationsOf(context);

final duration = disableAnimations
    ? Duration.zero
    : AppMotionDuration.normal;
```

A experiência deve continuar compreensível sem animação.

---

# 33. Vestibular and motion sensitivity

Evitar:

- parallax intenso;
- zoom rápido;
- fundo em movimento;
- rotação;
- movimento contínuo;
- mudança brusca de escala;
- animações em tela cheia.

Usuários sensíveis ao movimento devem conseguir usar toda a plataforma.

---

# 34. Acessibilidade cognitiva

Motion deve:

- reduzir ambiguidade;
- não competir com texto;
- não atrasar ação;
- não esconder conteúdo;
- manter previsibilidade;
- preservar foco.

Nunca animar múltiplas áreas importantes simultaneamente.

---

# 35. Foco e teclado

No Web:

- foco deve acompanhar navegação;
- dialogs devem mover foco;
- fechamento deve restaurar foco;
- transições não devem perder foco;
- animações não devem bloquear teclado.

---

# 36. Performance

Toda animação deve preservar:

```text
60 FPS obrigatório

120 FPS quando disponível
```

Evitar:

- animar blur;
- animar sombras pesadas;
- rebuild por frame;
- listas inteiras;
- imagens grandes;
- múltiplos controllers desnecessários.

Preferir:

```text
Implicit animations

AnimatedSwitcher

FadeTransition

SlideTransition

ScaleTransition

TweenAnimationBuilder
```

Usar `RepaintBoundary` em:

- Liquid Glass;
- player controls;
- animações isoladas;
- componentes complexos.

---

# 37. AnimatedBuilder e controllers

Usar `AnimationController` apenas quando necessário.

Obrigatório:

- `dispose`;
- `TickerProvider`;
- duração centralizada;
- curva centralizada;
- teste;
- suporte a Reduce Motion.

Preferir implicit animations para casos simples.

---

# 38. Lottie, Rive e animações externas

Usar somente quando:

- houver valor claro;
- arquivo estiver otimizado;
- animação tiver fallback;
- licença estiver validada;
- performance estiver medida;
- acessibilidade estiver preservada.

Não usar para:

- loading genérico;
- decoração;
- preencher espaço;
- substituir feedback simples.

---

# 39. Naming conventions

Exemplos:

```text
CourseCardEntryAnimation

LessonCompletionAnimation

DashboardSectionTransition

PaymentSuccessMotion

OfflineBannerTransition
```

Evitar:

```text
CoolAnimation

FancyEffect

MagicTransition
```

---

# 40. Estrutura Flutter recomendada

```text
lib/
└── design_system/
    └── motion/
        ├── app_motion.dart
        ├── app_motion_duration.dart
        ├── app_motion_curve.dart
        ├── app_page_transitions.dart
        ├── reduced_motion.dart
        └── widgets/
            ├── fade_slide_in.dart
            ├── press_scale.dart
            ├── staggered_list.dart
            └── state_animated_switcher.dart
```

Animações específicas de feature ficam em:

```text
lib/features/<feature>/presentation/animations/
```

---

# 41. Componentes de motion recomendados

## LawrencePressScale

Uso:

- botões;
- cards;
- ícones interativos.

## LawrenceFadeSlideIn

Uso:

- entrada de conteúdo;
- seções;
- empty states.

## LawrenceStateSwitcher

Uso:

- Loading;
- Empty;
- Error;
- Success;
- Offline.

## LawrenceProgressMotion

Uso:

- progresso;
- upload;
- download.

## LawrenceModalTransition

Uso:

- dialogs;
- overlays.

---

# 42. Testes

Toda animação global deve possuir:

```text
Widget Test

Golden Test quando relevante

Reduced Motion Test

State Transition Test
```

Testar:

- duração;
- estado inicial;
- estado final;
- sem overflow;
- sem erro;
- foco;
- Reduce Motion;
- acessibilidade.

Exemplo:

```dart
testWidgets(
  'disables entry animation when reduced motion is enabled',
  (tester) async {
    // ...
  },
);
```

---

# 43. QA checklist

```text
[ ] A animação tem propósito?

[ ] Usa token oficial?

[ ] Respeita Reduce Motion?

[ ] Mantém 60 FPS?

[ ] Não bloqueia interação?

[ ] Não atrasa conteúdo?

[ ] Preserva foco?

[ ] Não depende apenas de movimento?

[ ] Funciona em mobile e web?

[ ] Possui fallback?

[ ] Foi testada?
```

---

# 44. Code review checklist

```text
[ ] Duração centralizada?

[ ] Curva centralizada?

[ ] Controller descartado?

[ ] Sem rebuild global?

[ ] Sem blur animado?

[ ] Sem animação infinita?

[ ] Sem valores aleatórios?

[ ] Reduced Motion tratado?

[ ] Sem regressão visual?

[ ] Testes adicionados?
```

---

# 45. Proibições

Nunca:

```text
❌ Criar animação sem objetivo

❌ Usar bounce em toda interação

❌ Animar toda lista grande

❌ Usar blur animado em scroll

❌ Criar movimento contínuo

❌ Ignorar Reduce Motion

❌ Esconder conteúdo durante animação

❌ Bloquear interação sem motivo

❌ Criar transição diferente por página

❌ Usar Lottie para tudo

❌ Usar duração aleatória

❌ Criar motion que prejudique baixa visão

❌ Sacrificar performance por efeito
```

---

# 46. Critérios de aceitação

Uma animação está pronta quando:

```text
[ ] Explica uma mudança

[ ] Usa tokens oficiais

[ ] Respeita acessibilidade

[ ] Funciona sem motion

[ ] Mantém performance

[ ] Não atrasa o usuário

[ ] Possui teste

[ ] Segue este documento
```

---

# 47. Definition of Done

```text
[ ] Objetivo definido

[ ] Motion plan criado

[ ] Tokens usados

[ ] Reduce Motion implementado

[ ] Mobile validado

[ ] Tablet validado

[ ] Desktop validado

[ ] Performance verificada

[ ] Acessibilidade verificada

[ ] Testes criados

[ ] Review aprovado
```

---

# Regra final

Motion não existe para impressionar.

Motion existe para explicar.

```text
Oriente.

Confirme.

Conecte.

Simplifique.

Não distraia.
```

O Design System define a linguagem.

Os componentes aplicam o comportamento.

As animações dão continuidade.

A acessibilidade garante inclusão.

A performance preserva qualidade.
