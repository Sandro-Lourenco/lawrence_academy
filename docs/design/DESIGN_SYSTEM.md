Analisei o arquivo enviado. Ele já está bem completo, então eu não removeria conteúdo. Eu faria uma **refatoração de arquitetura de documentação** para transformar ele de um arquivo de regras misturadas em um **Design System profissional**, mais fácil para o Antigravity/Emergent interpretar. O arquivo atual já define claramente tokens como cores, tipografia, grid, radius, shadows, Liquid Glass e motion. 

Eu reestruturaria assim:

```markdown
---
version: 3.0.0
name: Lawrence-Design-System
type: Premium Education Design System
platform:
  - Flutter Web
  - Flutter Android

architecture:
  frontend: Flutter
  backend: Python FastAPI
  database: Supabase PostgreSQL
  storage: Supabase Storage
  auth: Supabase Auth

state_management: Riverpod
design_language:
  - Apple Human Interface Guidelines
  - VisionOS
  - Material 3 Adaptive

principles:
  - Clarity First
  - Content First
  - Premium Learning Experience
  - Motion With Purpose
---

# Lawrence Design System

> Para telas da área do aluno, as decisões consolidadas de paleta semântica,
> breakpoints, raios e funcionalidades bloqueadas estão em
> [`STUDENT_EXPERIENCE_FOUNDATION.md`](STUDENT_EXPERIENCE_FOUNDATION.md). Em caso
> de divergência dentro desse escopo, essa especialização deve ser aplicada sem
> substituir regras de produto, segurança ou negócio.

## Objetivo

Este documento é a fonte oficial de verdade visual da plataforma Lawrence Academy.

Toda tela, componente e fluxo deve seguir estas regras.

O Design System controla:

- Identidade visual
- Tokens
- Componentes
- Estados
- Motion
- Acessibilidade
- Experiência de aprendizado
- Segurança visual

---

# 1. Design Philosophy

A interface deve desaparecer para o conteúdo aparecer.

O foco principal da plataforma é:

- aulas
- tecidos
- moldes
- vídeos
- evolução do aluno

A UI nunca compete com o conteúdo.

---

# 2. Design Principles

## Clarity First

Priorizar:

- clareza
- leitura confortável
- hierarquia visual

Evitar:

- excesso visual
- elementos decorativos sem função


---

## Premium Learning Experience

Sensação esperada:

Apple

+

Alta Costura

+

Educação Premium


Cada detalhe comunica valor.


---

## Motion With Purpose

Toda animação deve existir para:

- indicar estado
- orientar atenção
- confirmar ação

Nunca apenas decorar.

---

# 3. Color System

## Regra 60-30-10


60%

Base:

Pure White

#FFFFFF


Parchment

#F8F9FB


Uso:

- fundos
- leitura
- páginas públicas


---


30%

Action Blue

#0A84FF


Uso:

- CTA
- links
- progresso
- seleção


---


10%

Premium Gold

#D4AF37


Uso exclusivo:

- certificados
- conquistas
- badges premium

---

# Tokens

## Primary

primary:

#0A84FF


primary-focus:

#0071E3


primary-dark:

#2997FF


---

## Surface

canvas:

#FFFFFF


surface:

#FAFAFC


black:

#000000


---

## Semantic

Success

#30D158


Warning

#FF9F0A


Danger

#FF453A


Info

#64D2FF


---

# 4. Typography System

Font Family:

SF Pro

Fallback:

Inter

System UI


---

# Escala


Hero XL

64px

700

-0.4px


Uso:

Landing Pages


---


Display L

48px

600


---


Heading L

28px

600


---


Body Principal

17px

400


OBRIGATÓRIO:

Todo conteúdo educacional usa 17px.


Nunca usar:

16px


---

# Font Rules

Permitido:

400 Regular

600 Semibold

700 Bold


Proibido:

500 Medium


---

# 5. Spacing System

Base:

4px grid


Escala:

4

8

12

16

24

32

48

64


Nunca criar valores aleatórios.


---

# 6. Radius System


Small:

10px


Medium:

16px


Large:

24px


Extra:

32px


Pill:

9999px


---

# 7. Liquid Glass System


## Objetivo

Criar profundidade, não decoração.


Config:

Blur:

20px


Opacity:

72%


Border:

white 28%


---

# Permitido usar em:


✔ Navigation Bar

✔ Player Controls

✔ Dialogs

✔ Bottom Sheets

✔ Checkout Floating Bar

✔ Profile Header


---

# Proibido:


❌ Cards normais

❌ Textos

❌ Background página

❌ Formulários grandes


---

# Flutter Implementation


BackdropFilter

+

ClipRRect

+

Opacity 0.72


---

# 8. Motion System


Fast:

180ms


Normal:

280ms


Slow:

420ms


---

Clique:

scale(0.97)


Hover:

scale(1.02)


Transições:

Spring Physics


---

# 9. Component Foundation


Componentes seguem Atomic Design.


```

Atoms

↓

Molecules

↓

Organisms

↓

Pages

---

# Buttons


## Primary Button


Height:

52px


Radius:

Pill


Color:

#0A84FF


Text:

17px / 600


---

# Cards


Radius:

24px


Border:

#E8E8ED


Padding:

24px


Shadow:

Somente quando necessário.


---

# Inputs


Height:

52px


Radius:

16px


Focus:

2px Blue Ring


---

# Navigation


Desktop:

Sidebar

+

Header


Mobile:

Bottom Navigation


---

# 10. Media Design


## Video Player


Background:

#000000


Ratio:

16:9


Controls:

Liquid Glass


---

# Segurança


Nunca:

.mp4 público


Obrigatório:

HLS

AES-128

DRM Ready


---

# Offline Android


Salvar:

HLS encrypted chunks


Local:

App Sandbox


Nunca:

Galeria pública

Downloads


---

# 11. States System


Toda tela possui:

Loading

Empty

Error

Success

Offline


Usar arquivos:

shared/loading.md

shared/error.md

shared/offline.md

---

# 12. Accessibility


Obrigatório:


WCAG AA


Touch:

44x44px


Keyboard:

Focus Visible


Screen Readers:

TalkBack

VoiceOver


Closed Captions:

.vtt


---

# 13. Performance


Flutter:


60 FPS


Usar:


const Widgets

Lazy Loading

Image Cache

Riverpod Select


Evitar:


Rebuild global


---

# 14. Design Rules For AI


## ALWAYS


Criar interfaces limpas.


Priorizar conteúdo.


Usar espaçamento.


Seguir tokens.


Usar componentes existentes.



---

## NEVER


Criar cores novas.


Criar gradientes.


Colocar Liquid Glass em tudo.


Usar fonte pequena.


Expor mídia insegura.


Criar componentes duplicados.


---

# Final Rule


Se existir conflito entre uma página e este documento:


O DESIGN SYSTEM VENCE.

```

Eu também removeria do `design-system.md` coisas muito específicas como **player detalhado, tarefas, checkout e cards de cursos** e colocaria em arquivos próprios:

```text
docs/

design-system.md      ← regras globais

components/

 buttons.md
 cards.md
 inputs.md
 video-player.md
 navigation.md

shared/

 loading.md
 error.md
 offline.md
 dialogs.md
```

