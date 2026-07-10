---
name: Lawrence Components Specification
version: 1.0.0
type: UI Component Specification
status: Production Ready
platforms:
  - Flutter Android
  - Flutter Web
framework:
  - Flutter
  - Dart
depends_on:
  - docs/design/DESIGN_SYSTEM.md
  - docs/design/ANIMATIONS.md
---

# Lawrence Academy — Component Specification

Este documento define as especificações de design e implementação dos componentes de interface de usuário (UI) da plataforma Lawrence Academy, garantindo fidelidade com as diretrizes do Apple Human Interface Guidelines e a estética premium.

---

## 1. PillButton

Botão no formato de pílula circular, utilizado para as principais ações de chamada (CTA) e formulários.

### Especificações Visuais
- **Altura padrão (Height):** 52px (recomenda-se variação de 44px para mobile compacto).
- **Arredondamento (Radius):** `LawrenceTheme.radiusXl` (32.0) ou pílula completa.
- **Preenchimento Horizontal (Padding):** 24px horizontal, 12px vertical.
- **Tipografia:** `bodyLarge` (15px) ou `titleLarge` (17px), peso Semibold (`w600`).

### Variações
1. **Primary Button:**
   - **Cor de Fundo:** `LawrenceTheme.primary` (`#0A84FF`).
   - **Cor de Texto:** `Colors.white` (`#FFFFFF`).
   - **Borda:** Nenhuma (`BorderSide.none`).
2. **Secondary / Outlined Button:**
   - **Cor de Fundo:** `Colors.transparent`.
   - **Cor de Texto:** `LawrenceTheme.surfaceTile1` (`#1D1D1F`).
   - **Borda:** `LawrenceTheme.borderMist` (`#E8E8ED`), largura de 1.5px.

### Comportamento & Feedback
- **Microinterações:**
  - **Pressão (Click):** Escalar suavemente de `1.00` para `0.97` usando `Duration(milliseconds: 100)`.
- **Estado de Carregamento (Loading):**
  - Desativar interatividade (`onPressed: null`).
  - Substituir/Acompanhar texto com um `CircularProgressIndicator` de tamanho 20x20px, espessura de 2.0px.

---

## 2. LiquidGlassCard

Card translúcido premium com efeito de desfoque de fundo (Liquid Glass), utilizado para agrupar conteúdos, progresso e informações de aula de forma destacada.

### Especificações Visuais
- **Cor de Fundo:** `Colors.white.withOpacity(0.72)`.
- **Borda:** `Colors.white.withOpacity(0.28)` ou `LawrenceTheme.borderColor` opcional.
- **Arredondamento (Radius):** Regra inegociável de `24.0` de raio (`BorderRadius.circular(24.0)`).
- **Efeito de Vidro (BackdropFilter):** Image blur com `sigmaX: 20` e `sigmaY: 20` encapsulado por um `ClipRRect` correspondente para não vazar o desfoque fora das bordas arredondadas.
- **Espaçamento Interno (Padding):** Padrão de 20px (baseado no Grid de 4px).

### Comportamento & Feedback
- **Interatividade:**
  - Se possuir ação ao clicar (`onTap != null`):
    - Escalar de `1.00` para `0.97` no clique (`onTapDown`) e retornar a `1.00` ao soltar (`onTapUp` / `onTapCancel`).
    - Duração da animação de escala fixada em 100ms usando curvas de transição suaves.

---

## 3. LiquidGlassContainer

Container estático genérico que implementa a mesma estética do LiquidGlassCard, porém sem detector de gestos ou microinteração de clique, servindo como base estrutural de layouts e cabeçalhos.

### Especificações Visuais
- **Configuração:** Segue as mesmas propriedades do `LiquidGlassCard` (72% de opacidade branca, borda branca de 28% de opacidade e desfoque de 20px).
- **Uso Recomendado:**
  - Painéis de cabeçalho.
  - Sidebar do dashboard (desktop).
  - Barras flutuantes inferiores de mobile.

---

## 4. LiquidGlassSidebar

Menu lateral de navegação fixo para telas desktop, servindo como a estrutura principal de acesso a rotas do aluno.

### Especificações Visuais
- **Largura padrão:** 260px.
- **Altura padrão:** `double.infinity` (ocupa toda a altura do Canvas).
- **Conteúdo interno:**
  - Logotipo textual da Lawrence Academy.
  - Lista de destinos principais (Início, Cursos, Perfil, Configurações).
  - Avatar do perfil e botão para sair/trocar conta.
- **Estilo:** Baseado no layout translúcido `LiquidGlassContainer`.
