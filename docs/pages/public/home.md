---
version: 2.0.0
id: PAGE-PUBLIC-001
name: Lawrence Academy Landing Page
route: /
actor: Visitor
status: implemented
---

# Objetivo

Apresentar a Lawrence Academy como uma escola premium de costura, modelagem,
moda e estilo e conduzir visitantes ao catálogo ou à matrícula.

# Jornada

1. Compreender a proposta de valor no primeiro viewport.
2. Explorar o catálogo por trilha.
3. Conhecer a criadora e o método.
4. Entender os resultados esperados para a comunidade de alunas.
5. Conhecer a futura biblioteca de e-books.
6. Explorar cursos ou criar uma conta.

# Conteúdo

- Navegação pública com logo, busca, Início, Cursos e ações de sessão.
- Hero editorial com CTA primário para `/courses` e secundário para a criadora.
- Identidade baseada no manual da marca: azul-marinho, marrom couro, dourado,
  amarelo-claro, preto, cinza e branco; wordmark serifado com dois traços.
- Linguagem clássico-moderna com conteúdo editorial limpo e Liquid Glass
  reservado a controles e superfícies funcionais.
- Catálogo visual, história da criadora, comunidade, biblioteca de e-books em
  preparação, método e chamada final.
- Depoimentos identificados só podem ser publicados com autorização.

# Responsividade

- Mobile abaixo de 700 px: menu em drawer, hero e seções empilhadas.
- Tablet entre 700 e 1099 px: grid adaptativo e navegação compacta.
- Desktop a partir de 1100 px: composições assimétricas e header completo.

# Acessibilidade

- Ordem semântica, botões com rótulos explícitos e alvos mínimos de 48 px.
- Contraste WCAG 2.2 AA, navegação por teclado e foco visível.
- Imagens editoriais descritas semanticamente.
- Animações e transições respeitam `disableAnimations`.

# Estados

Esta página é institucional e usa conteúdo local versionado. A ausência de um
asset visual deve preservar a mensagem e os CTAs sem bloquear a navegação.

# Performance

- Fotografias editoriais em WebP ou JPEG otimizado e empacotadas localmente.
- Sem chamadas de API no primeiro carregamento.
- Liquid Glass restrito a poucas superfícies e isolado por `RepaintBoundary`.
- Arquivos shell do Flutter são servidos com revalidação para evitar build antiga.
