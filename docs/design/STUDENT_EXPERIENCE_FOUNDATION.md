---
name: Lawrence Student Experience Foundation
version: 2.0.0
status: Active
scope: Student Experience
platforms: [Flutter Android, Flutter Web]
depends_on:
  - docs/product/PED-overview.md
  - docs/design/DESIGN_SYSTEM.md
  - docs/design/ACCESSIBILITY.md
  - docs/navigation/PAGES_OVERVIEW.md
---

# Fundação da experiência do aluno

## Propósito

Este documento consolida as decisões da Fase 01 de padronização das telas do
aluno. Ele especializa o Design System sem substituir regras de produto,
segurança, acesso ou negócio.

## Decisões confirmadas

| Tema | Decisão |
| --- | --- |
| Plataformas | Flutter Android e Flutter Web |
| Monetização | Assinatura mensal individual por curso |
| Certificado | Exige 100% de progresso e aprovação obrigatória |
| Vídeo | HLS protegido; MP4 público é proibido |
| Navegação | Início, Cursos, Projetos, Agenda e Perfil |
| Projetos iniciais | Apenas projetos avaliativos vinculados a cursos |
| Offline | Suporte parcial no Android conforme a spec de estado/offline |
| Acessibilidade | WCAG 2.2 AA, teclado Web e texto até 200% |

## Funcionalidades bloqueadas

Não devem ser apresentadas como disponíveis até existirem regra de negócio,
contrato, autorização e Page Spec aprovados:

- criação de projeto livre;
- galeria pública, inspirações e comunidade;
- compartilhamento público de projeto;
- desafio semanal;
- pontos, níveis, sequência e ranking;
- assinatura global ou “Lawrence Premium”.

Conquistas básicas derivadas de eventos confirmados, como conclusão, aprovação
e emissão de certificado, podem existir sem introduzir o sistema avançado.

## Paleta semântica canônica

| Token | Valor | Uso |
| --- | --- | --- |
| `brandWine` | `#6B1328` | Marca e CTA no modo claro |
| `actionPrimary` | `#6B1328` | CTA funcional, link e navegação selecionada |
| `actionPrimaryHover` | `#811D3B` | Hover no Web |
| `actionPrimaryPressed` | `#4B0C1B` | Estado pressionado |
| `focusRing` | `#A63B5E` | Indicador de foco visível |
| `practice` | `#C92C73` | Projetos e prática |
| `success` | `#168447` | Conclusão e sucesso |
| `warning` | `#9A5B00` | Atenção e prazo |
| `danger` | `#BA1A1A` | Erro, atraso e ação destrutiva |
| `info` | `#075E9E` | Informação neutra |
| `textPrimary` | `#181315` | Texto principal no modo claro |
| `textSecondary` | `#62565A` | Texto secundário no modo claro |
| `canvas` | `#F7F0E8` | Fundo marfim do modo claro |
| `darkCanvas` | `#0C0C0E` | Fundo preto-carvão do modo escuro |
| `darkSurface` | `#151518` | Superfície do modo escuro |
| `darkElevated` | `#1D1D21` | Superfície elevada do modo escuro |
| `darkTextPrimary` | `#F6F3EF` | Texto principal no modo escuro |
| `darkTextSecondary` | `#BEB8B4` | Texto secundário no modo escuro |
| `darkAction` | `#A63B5E` | Ação vinho legível no modo escuro |
| `borderMist` | `#D8C8BA` | Bordas e divisores do modo claro |
| `darkBorder` | `#34343A` | Bordas e divisores do modo escuro |

As cores usadas como texto sobre branco foram verificadas com contraste entre
4,75:1 e 14,87:1. Isso não autoriza combinações diferentes sem nova medição.
Informação de estado deve usar cor, ícone e texto.

### Direção editorial canônica

A área do aluno segue o conceito **Ateliê editorial contemporâneo**:

- carvão organiza estrutura e superfícies no modo escuro;
- vinho identifica ações, foco e seleção sem tingir todo o fundo;
- branco quente e pergaminho criam espaço negativo;
- dourado não pertence à experiência autenticada da aluna;
- Playfair Display é usado somente em títulos editoriais curtos;
- Montserrat é usada em controles, metadados e conteúdo funcional;
- glass permanece restrito a navegação e overlays com função clara.

O botão primário é retangular, vinho, com texto branco e seta final. O reflexo
superior é discreto e neutro. Certificados e marcos usam vinho, ícone e texto;
nunca dourado como atalho para valor.

## Espaçamento

Escala baseada em 4 px:

```text
4, 8, 12, 16, 24, 32, 48, 64
```

- 8 px: separação interna mínima;
- 16 px: padding padrão de controles e cards compactos;
- 24 px: padding de seção e cards destacados;
- 32–64 px: separação de seções conforme viewport.

## Raios

| Token | Valor | Uso |
| --- | ---: | --- |
| `control` | 2 px | Botões e controles editoriais |
| `card` | 0 px | Cards e listas de conteúdo |
| `featured` | 0 px | Hero e painéis destacados |
| `pill` | 999 px | Badge e botão realmente pill |

Não criar raios intermediários por tela.

## Breakpoints

| Faixa | Largura | Comportamento |
| --- | --- | --- |
| Mobile compacto | 320–389 px | Uma coluna, ações empilhadas |
| Mobile amplo | 390–699 px | Uma coluna, maior respiro |
| Tablet | 700–1099 px | Navigation rail e até duas colunas |
| Desktop | ≥1100 px | Sidebar, grids e painéis contextuais |

Breakpoints indicam mudança de composição, não tipo de dispositivo.

## Navegação

- Telas-raiz utilizam a navegação global adaptativa.
- Detalhes exibem voltar e preservam scroll, filtros e tab anterior.
- Player pode reduzir a navegação global para priorizar aprendizagem.
- Rotas protegidas validam autenticação e autorização antes de renderizar dados.
- Pesquisa e filtros relevantes devem permanecer serializáveis em deep links.

## Regras de composição

- Uma ação primária por região visual.
- Métricas nunca precedem a principal tarefa do usuário no mobile.
- Cards inteiros só são clicáveis quando possuem um destino único.
- Listas e grids devem suportar texto a 200% sem reduzir fonte.
- Blur é permitido somente em overlay ou elemento flutuante com função clara.
- Sombras não podem ser o único delimitador de um componente.

## Migração

`LawrenceColors` é a paleta canônica da experiência do aluno. `LiquidTheme`
permanece apenas em superfícies legadas fora deste escopo e não deve ser usado
em novas telas do aluno. Aliases antigos permanecem temporariamente para uma
migração incremental e devem ser removidos após a conversão das telas.

