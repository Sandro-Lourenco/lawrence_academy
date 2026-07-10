---
name: ui-review
description: "Revisão final de UI/UX validando experiência, design system, acessibilidade, responsividade, performance e qualidade visual."
type: review
version: 1.0.0
status: production

review_owner:
  - ui-ux-designer

required_personas:
  - ui-ux-designer
  - flutter-architect
  - qa-engineer

optional_personas:
  - security-engineer

required_documents:
  - AGENTS.md
  - GEMINI.md
  - docs/product/PED-overview.md
  - docs/design/UI_UX_FRONTEND_SPEC.md
  - docs/design/DESIGN_SYSTEM.md
  - docs/design/COMPONENTS.md
  - docs/design/ANIMATIONS.md
  - docs/design/ACCESSIBILITY.md
  - docs/navigation/PAGES_OVERVIEW.md
  - docs/pages/

related_skills:
  - create-page
  - create-premium-flutter-screen
  - optimize-performance
  - review-code
---

# UI Review

## 1. Objetivo

Garantir que toda interface entregue seja:

- útil;
- clara;
- bonita;
- consistente;
- acessível;
- responsiva;
- performática;
- pronta para produção.

Esta revisão deve responder:

```text
Essa tela parece um produto profissional?

Resolve o problema do usuário?

Segue o Design System?

Está pronta para usuários reais?
````

Uma tela visualmente bonita ainda pode ser rejeitada.

---

# 2. Quando executar

Executar depois de:

```text
create-screen

create-page

alteração visual

novo componente

nova experiência

refatoração de UI
```

Obrigatório antes de:

```text
merge

release

aprovação final
```

---

# 3. Documentos obrigatórios

Antes da análise:

Ler:

```text
1. Page Spec correspondente

docs/pages/


2. Mapa de navegação

docs/navigation/PAGES_OVERVIEW.md


3. Design System

docs/design/


4. Regras de produto

PED-overview.md
```

Nunca revisar apenas olhando o código.

---

# 4. Identificação da tela

Registrar:

```yaml
review:

  screen:

  route:

  user_type:

  platform:
    - android
    - web

  objective:

  primary_action:

  risk:
    low | medium | high
```

Exemplo:

```yaml
screen:
  name: Course Player

user:
  Student

objective:
  Assistir aula

primary_action:
  Continuar aprendizado

risk:
  high
```

---

# 5. Revisão de objetivo UX

Verificar:

```text
[ ] O usuário entende onde está?

[ ] A ação principal é evidente?

[ ] A tela resolve uma necessidade real?

[ ] Existe excesso de informação?

[ ] Existe distração visual?

[ ] O fluxo tem começo e fim?
```

Bloquear:

```text
Tela bonita sem objetivo.
```

---

# 6. Primeiros 5 segundos

Um usuário novo deve entender:

```text
Onde estou?

O que posso fazer?

Qual próximo passo?
```

Se precisar explicar a tela:

```text
REPROVADO
```

---

# 7. Hierarquia visual

Validar:

```text
[ ] Título principal correto

[ ] CTA principal destacado

[ ] Conteúdo mais importante primeiro

[ ] Agrupamento lógico

[ ] Espaçamento correto

[ ] Elementos secundários reduzidos
```

Ordem esperada:

```text
Contexto

↓

Conteúdo

↓

Ação

↓

Detalhes
```

---

# 8. Consistência visual

Comparar com:

```text
DESIGN_SYSTEM.md
```

Verificar:

```text
Cores

Tipografia

Espaçamento

Radius

Sombras

Ícones

Motion
```

Bloquear:

```dart
Color(0xff121212)

fontSize: 15

EdgeInsets.all(13)
```

Tudo deve usar tokens.

---

# 9. Component Review

Consultar:

```text
COMPONENTS.md
```

Validar:

```text
[ ] Botões oficiais

[ ] Inputs oficiais

[ ] Cards oficiais

[ ] Dialogs oficiais

[ ] Loading oficial

[ ] Empty oficial

[ ] Error oficial
```

Bloquear:

```text
CustomButton

MeuCard

DefaultDialog
```

sem justificativa.

---

# 10. Qualidade visual premium

Comparar princípios de:

```text
Apple HIG

Material 3

Linear

MasterClass
```

Não copiar.

Avaliar:

```text
clareza

acabamento

espaço

consistência

fluidez
```

---

# 11. Layout

Avaliar:

```text
Alinhamento

Grid

Densidade

Espaçamento

Agrupamento

Escaneabilidade
```

Evitar:

```text
Tudo dentro de cards

Tela cheia de sombras

Muito texto

Muitos botões

Dashboard genérico
```

---

# 12. Responsividade

Obrigatório testar:

---

## Mobile

```text
[ ] Uma coluna

[ ] Touch confortável

[ ] CTA acessível

[ ] Sem overflow

[ ] Scroll correto
```

---

## Tablet

```text
[ ] Aproveita espaço

[ ] Layout adaptativo

[ ] Não parece celular esticado
```

---

## Desktop Web

```text
[ ] Sidebar correta

[ ] Hover

[ ] Keyboard

[ ] Grid adequado

[ ] Largura controlada
```

---

# 13. Estados obrigatórios

Toda página dinâmica precisa:

```text
Loading

Success

Empty

Error

Offline
```

Validar:

## Loading

```text
Skeleton preferencial

Sem tela branca
```

---

## Empty

Responder:

```text
O que aconteceu?

Qual próximo passo?
```

---

## Error

Deve:

```text
explicar

recuperar

permitir tentar novamente
```

Nunca:

```text
Exception

Erro 500

Stacktrace
```

---

## Offline

Validar:

```text
Mensagem clara

Cache quando possível

Limitações explicadas
```

---

# 14. UX Writing

Validar textos:

Bons textos:

```text
Continuar aula

Salvar alterações

Tentar novamente
```

Ruins:

```text
OK

Enviar

Erro inesperado
```

---

# 15. Acessibilidade

Executar:

```text
ACCESSIBILITY.md
```

Validar:

```text
[ ] WCAG AA

[ ] Contraste

[ ] Texto 200%

[ ] Screen Reader

[ ] Semantics

[ ] Keyboard

[ ] Focus

[ ] Touch 48dp
```

---

# 16. Baixa visão

Obrigatório validar:

```text
[ ] Fonte confortável

[ ] Alto contraste

[ ] Zoom funciona

[ ] Informação não depende de cor

[ ] Ícones possuem texto

[ ] Blur não prejudica leitura
```

---

# 17. Motion Review

Consultar:

```text
ANIMATIONS.md
```

Validar:

```text
[ ] Animação tem motivo

[ ] Usa tokens

[ ] Não distrai

[ ] Reduce Motion funciona
```

Bloquear:

```text
Efeito só porque parece legal
```

---

# 18. Liquid Glass Review

Permitido:

```text
Navigation

Dialogs

Bottom Sheets

Player Controls

Floating Actions
```

Bloquear:

```text
Página inteira em vidro

Lista com blur

Texto ilegível
```

---

# 19. Performance visual

Verificar:

```text
FPS

Rebuilds

Imagens

Listas

Blur

Memória
```

Obrigatório:

```text
ListView.builder

Sliver

Cache Image

const Widget
```

---

# 20. Fluxos críticos

## Pagamento

Validar:

```text
Preço claro

Confirmação

Erro recuperável

Segurança
```

## Exclusão

Validar:

```text
Impacto explicado

Confirmação

Possibilidade de cancelar
```

## Upload

Validar:

```text
Progresso

Estado

Erro

Retry
```

---

# 21. Critérios de bloqueio

Reprovar imediatamente:

```text
❌ Sem Page Spec

❌ Fora do Design System

❌ Não responsivo

❌ Sem acessibilidade

❌ Sem estados

❌ Texto ilegível

❌ UI genérica

❌ Performance ruim

❌ Componentes duplicados

❌ Regra de negócio na tela
```

---

# 22. Resultado esperado

Responder sempre:

```markdown
# UI Review Result


## Status

APPROVED

ou

NEEDS_CHANGES

ou

BLOCKED


## Pontos positivos

-


## Problemas encontrados


### Critical

-


### Major

-


### Minor

-


## Melhorias recomendadas

-


## Validações feitas

-
```

---

# 23. Checklist final

```text
UX

[ ] Resolve problema?

[ ] Fluxo claro?


VISUAL

[ ] Premium?

[ ] Consistente?


DESIGN SYSTEM

[ ] Tokens?

[ ] Componentes?


RESPONSIVO

[ ] Mobile?

[ ] Tablet?

[ ] Desktop?


ACESSIBILIDADE

[ ] WCAG?

[ ] Baixa visão?


QUALIDADE

[ ] Estados?

[ ] Motion?

[ ] Performance?
```

---

# Regra final

Não aprove uma tela porque ela parece bonita.

Aprove quando ela for:

```text
Útil

Clara

Rápida

Acessível

Consistente

Escalável
```

Uma boa interface desaparece.

O usuário lembra do resultado, não dos componentes.
