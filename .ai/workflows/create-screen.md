---
name: create-screen
description: "Workflow para criação de telas Flutter premium seguindo Page Specs, Design System, UX, acessibilidade e arquitetura."
type: workflow
version: 1.0.0
status: production

required_personas:
  - ui-ux-designer
  - flutter-architect
  - qa-engineer

optional_personas:
  - security-engineer

required_skills:
  - create-page
  - create-premium-flutter-screen
  - optimize-performance
  - review-code
---

# Workflow: Create Screen


# 1. Objetivo

Criar uma tela Flutter completa seguindo:

- documentação;
- experiência premium;
- arquitetura;
- responsividade;
- acessibilidade;
- performance;
- testes.


Uma tela não é apenas um Widget.

Uma tela é:

```text
Objetivo do usuário

+

Layout

+

Estado

+

Interação

+

Acessibilidade

+

Performance
```

---

# 2. Antes de criar qualquer tela


Obrigatório ler:


```text
AGENTS.md

GEMINI.md


docs/product/PED-overview.md


docs/design/UI_UX_FRONTEND_SPEC.md

docs/design/DESIGN_SYSTEM.md

docs/design/COMPONENTS.md

docs/design/ANIMATIONS.md

docs/design/ACCESSIBILITY.md


docs/navigation/PAGES_OVERVIEW.md


docs/pages/
```

Nunca iniciar pelo código.

---

# 3. Encontrar Page Spec


Primeiro localizar:

```text
docs/pages/
```


Exemplo:


Solicitação:

```text
Criar tela dashboard aluno
```


Procurar:

```text
docs/pages/student/dashboard.md
```


Solicitação:

```text
Criar tela login
```


Procurar:

```text
docs/pages/auth/login.md
```


Se não existir:

```text
STOP
```

Perguntar ou criar especificação antes.

Não inventar tela.

---

# 4. Entender usuário


Responder:


```yaml
screen:

  name:

  user:

  role:

  objective:

  primary_action:

  secondary_actions:

  risk_level:
```


Exemplo:


```yaml
screen:

 name: Course Player

 user: Student

 objective:
   Assistir aula

 primary_action:
   Continuar aprendizado

 risks:
   - subscription
   - offline
```

---

# 5. Planejamento UX


Antes do Flutter:


Definir:


```text
O que aparece primeiro?

Qual ação principal?

Qual informação é crítica?

Qual informação pode esperar?

Como fica vazio?

Como fica erro?

Como fica offline?
```


Hierarquia:


```text
Header

↓

Primary Content

↓

Secondary Content

↓

Actions
```

---

# 6. Aplicar Design System


Usar:


```text
AppColors

AppTypography

AppSpacing

AppRadius

AppMotion

AppTheme
```


Nunca:


```dart
Color(0xff000000)

fontSize:17

padding:19
```


Tudo vem dos tokens.

---

# 7. Usar componentes oficiais


Consultar:

```text
docs/design/COMPONENTS.md
```


Antes de criar:


```text
Button

Input

Card

Dialog

BottomSheet

Loading

Table

Video Player
```


Fluxo:


```text
Existe componente?

SIM
 ↓
Usar


NÃO
 ↓
Criar no Design System
```

---

# 8. Estrutura Flutter


Seguir:


```text
feature/

├── presentation/

│   ├── pages/

│   ├── widgets/

│   ├── controllers/

│   ├── states/

│   └── animations/
```


Exemplo:


```text
courses/

presentation/

├── pages/

│   └── course_detail_page.dart


├── widgets/

│   ├── course_header.dart

│   └── course_card.dart


├── controller/

└── state/
```

---

# 9. Criar Page


A Page apenas:


```text
Monta layout

Observa estado

Renderiza estados

Dispara ações
```


Nunca:


```text
Regra negócio

API

SQL

Pagamento

Permissão real
```


Fluxo:


```text
Page

↓

Controller

↓

UseCase

↓

Repository
```

---

# 10. Estados obrigatórios


Toda tela precisa:


## Loading


Usar:

```text
Skeleton
```


Referência:


```text
docs/pages/shared/loading.md
```


---


## Empty


Usar:


```text
docs/pages/shared/empty-state.md
```


---


## Error


Usar:


```text
docs/pages/shared/error.md
```


---


## Offline


Quando permitido:


```text
docs/pages/shared/offline.md
```

---

# 11. Responsividade


Criar para:


```text
Mobile

Tablet

Desktop
```


Não criar:


```text
MobileScreen

DesktopScreen
```


Criar composição:


```text
AdaptiveLayout()
```

---

# 12. Mobile


Prioridade:


```text
Uma coluna

Ação principal visível

Bottom Navigation

Thumb friendly
```


Evitar:


```text
Tabela grande

Texto pequeno

Muitos cards
```

---

# 13. Tablet


Usar:


```text
Duas colunas

Painéis

Mais contexto
```

---

# 14. Desktop


Usar:


```text
Sidebar

Grid

Hover

Keyboard

Shortcuts
```

---

# 15. Motion


Consultar:


```text
docs/design/ANIMATIONS.md
```


Permitido:


```text
Fade

Slide

Hero

AnimatedSwitcher

Progress
```


Evitar:


```text
Animação decorativa

Blur pesado

Movimento infinito
```

---

# 16. Liquid Glass


Permitido:


```text
Navigation

Dialogs

Bottom Sheets

Player Controls

Floating Elements
```


Proibido:


```text
Toda página

Lista grande

Cards repetidos
```

---

# 17. Acessibilidade


Consultar:


```text
docs/design/ACCESSIBILITY.md
```


Validar:


```text
Semantics

Contraste

Texto 200%

Keyboard

Screen Reader

Focus

Touch Target
```

---

# 18. Performance


Validar:


```text
const widgets

ListView.builder

Slivers

Cache images

Poucos rebuilds

Riverpod select
```


Nunca:


```dart
Column(
 children: lista.map()
)
```


para listas grandes.

---

# 19. Testes


Criar:


```text
Widget Test

Golden Test

Responsive Test

Accessibility Test
```


Testar:


```text
Loading

Success

Empty

Error

Offline
```

---

# 20. Executar revisão


Ao terminar executar:


```text
@review-code
```


Validar:


```text
Arquitetura

UX

Acessibilidade

Performance

Testes
```

---

# 21. Entrega esperada


Responder:


```text
Tela criada:

✔ Page

✔ Widgets

✔ State

✔ Controller

✔ Responsivo

✔ Acessível

✔ Testado


Arquivos:

listar alterações


Pendências:

listar riscos
```

---

# 22. Proibido


Nunca:


```text
❌ Criar tela sem docs/pages

❌ Ignorar Design System

❌ Criar CustomButton

❌ Usar cor fixa

❌ Criar UI genérica

❌ Misturar API na tela

❌ Ignorar estados

❌ Ignorar acessibilidade

❌ Ignorar mobile

❌ Ignorar web

❌ Ignorar testes
```

---

# Regra final


Tela premium nasce assim:


```text
Page Spec

↓

UX

↓

Design System

↓

Componentes

↓

Flutter

↓

Teste

↓

Review
```


Não crie apenas telas bonitas.

Crie experiências completas.
````

Agora sua parte de workflow fica:

```text
.ai/workflows/

├── new-feature.md
└── create-screen.md ⭐
```

Esse `create-screen` vai ser o que mais aproxima seu Antigravity/Gemini de um **designer Flutter sênior + frontend engineer**, porque ele força a IA a pensar antes de gerar Widget.
