---
version: 4.0.0
name: Lawrence-Design-System
type: Fashion Education Design System
status: active
platforms: [Flutter Web, Flutter Android]
principles: [Clarity First, Couture Editorial Restraint, Accessible by Default, Motion With Purpose]
---

# Lawrence Design System

Este documento é a fonte de verdade visual da Lawrence Academy. A marca une
ensino profissional, moda clássica e tecnologia contemporânea. “Premium” deve
ser percebido em hierarquia, precisão, espaço, fotografia, acessibilidade e
acabamento — nunca em excesso de efeitos.

## 1. Tese visual

**Maison Lawrence — técnica que se transforma em assinatura.**

A direção combina o rigor editorial das décadas de 1940, 1950 e início de
1960 com uma experiência digital atual. Poder feminino aparece por presença,
competência, materiais e composição; não por coroas, princesas, rosa infantil
ou símbolos literais de realeza.

## 2. Princípios

- Uma ideia dominante por seção.
- Copy curta, original e verificável.
- Espaço negativo é parte do layout.
- Fotografia e conteúdo vêm antes de caixas e ornamentos.
- Nenhum claim histórico, número ou depoimento sem fonte e autorização.
- Nenhuma referência externa deve ser copiada literalmente.
- A interface continua completa sem animação.

## 3. Paleta da marca

| Token | Valor | Uso |
| --- | --- | --- |
| `ink` | `#1A0B10` | texto principal e fundos noturnos |
| `noir` | `#100C0D` | fundo cinematográfico |
| `plum` | `#2C111B` | blocos editoriais escuros |
| `wine` | `#6B1328` | CTA, foco e identidade |
| `ruby` | `#811D3B` | hover/ênfase controlada |
| `ivory` | `#F7F0E8` | fundo e texto sobre escuro |
| `parchment` | `#E9DECF` | alternância de superfície |
| `antiqueRose` | `#CFA9A8` | filetes/superfícies; nunca texto claro |
| `antiqueGold` | `#B38A4A` | ornamento, selo e linha |
| `champagne` | `#E8D2B0` | detalhe e texto sobre ameixa |

Pares canônicos: `ink/ivory`, `ivory/wine`, `ivory/plum` e
`champagne/plum`. Ouro não é usado para texto pequeno sobre fundo claro.
Contraste mínimo: 4.5:1 para texto normal, 3:1 para texto grande e componentes.
Cores semânticas preservam significado funcional e não entram na proporção
decorativa.

## 4. Tipografia

- Display: Cormorant Garamond, peso 600.
- UI e leitura: Inter, pesos 400 e 700.
- Corpo público: 17–18 px, altura 1.58–1.65.
- Eyebrow: 12 px, caixa alta, tracking controlado.
- Hero: 44–58 px mobile; 64 px tablet; 72–108 px desktop.
- Máximo de duas famílias por tela.

Nunca reduzir texto para corrigir layout. Testar 100%, 150% e 200% de escala.

## 5. Composição pública

- Mobile `<700`, tablet `700–1099`, desktop `>=1100`.
- Conteúdo máximo 1440 px; grids de 4, 8 e 12 colunas.
- Ritmo vertical: 80 px mobile e 132 px desktop.
- Hero full-bleed exige placa/scrim com contraste estável.
- Cards genéricos não são o padrão. Preferir listas editoriais, filetes,
  fotografias, índices e blocos de mídia.
- Liquid Glass fica restrito a overlays funcionais; não pertence à home.

## 6. Imagem e ornamento

- Fotografia editorial de ateliê, mãos, moldes, seda, veludo e tweed.
- Mulheres adultas diversas, retratadas com autonomia e sem sexualização.
- Inspiração histórica deve parecer linguagem, não fantasia de época.
- Ilustrações: linhas de molde, croquis, monogramas e geometrias art déco finas.
- Imagem informativa possui descrição semântica; decorativa é excluída.

## 7. Componentes

- Alvos interativos mínimos de 48×48 dp.
- CTA: vinho com branco ou marfim com vinho.
- Foco sempre visível e com contraste de componente >=3:1.
- Controle possui rótulo explícito; ícone nunca é a única informação.
- Estados loading, empty, error, offline e success aparecem quando dados
  assíncronos existirem. Conteúdo institucional local não simula loading.

## 8. Motion

Tokens oficiais: 180 ms, 280 ms e 420 ms. Curva principal: `easeOutCubic`.
Entrada editorial usa `opacity + translateY` de no máximo 14 px. Hover usa
escala máxima 1.01 e 180 ms.

- Uma animação dominante por viewport.
- Sem scroll-jacking, rotação contínua, blur animado ou loops decorativos.
- `MediaQuery.disableAnimationsOf(context)` mostra o estado final imediato.
- Animar apenas transform e opacity quando possível.
- Superfícies animadas complexas usam `RepaintBoundary`.

Detalhes e testes: [`ANIMATIONS.md`](ANIMATIONS.md).

## 9. Acessibilidade e performance

- WCAG 2.2 AA, teclado completo, foco previsível e ordem semântica igual à
  ordem de leitura.
- LCP <2.5 s, CLS <0.1, INP <200 ms e 60 FPS.
- Imagens públicas WebP, dimensionadas para o uso e abaixo de 200 KB quando
  possível.
- O primeiro viewport não depende de API nem de animação para ser entendido.

## 10. Contextos autenticados

Áreas da aluna, professora e administração priorizam operação. Reutilizam a
mesma marca, mas reduzem cenografia e títulos monumentais. Segurança, estado,
offline e tarefas sempre vencem decoração.

## Regra final

Se uma solução for bonita, porém ilegível, genérica, não verificável,
inacessível ou lenta, ela não pertence à Lawrence Academy.
