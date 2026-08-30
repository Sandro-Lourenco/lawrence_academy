---
id: PAGE-AUTH-003
name: Login
route: /login
layout: AuthLayout
platforms: [Web, Android]
roles: [Guest]
authentication: false
responsive: true
status: Production
design-system: Lawrence Design System 4.0
navigation: Replace
---

# Login

## Objetivo

Ser a entrada clara, segura e memorável da Lawrence Academy. A tela deve
permitir autenticação imediata e, ao mesmo tempo, apresentar a marca como uma
escola de ofício, técnica e autoria.

## Tese visual

**A entrada no ateliê.**

A composição traduz uma página dupla de revista de moda das décadas de 1950 e
1960 para uma interface contemporânea. A referência histórica aparece em
tipografia, fotografia, filetes, ritmo e direção de arte — nunca em fantasia,
nostalgia caricata ou perda de usabilidade.

- Paleta: marfim, vinho heráldico, ameixa-noite e ouro envelhecido ornamental.
- Imagem: mulher adulta com autonomia em um ateliê de modelagem.
- Copy-manifesto: curta, original e ligada ao domínio técnico.
- Formulário: superfície marfim, sem glassmorphism, raios excessivos ou azul SaaS.
- Uma única ação visual dominante: entrar.

## Estrutura

### Desktop (`>=1100`)

- Página dividida em arte editorial (55%) e formulário (45%).
- Imagem full-height com scrim de contraste estável.
- Marca, índice de edição, frase-manifesto e texto breve sobre a imagem.
- Formulário centralizado com largura máxima de 470 px.

### Tablet e mobile (`<1100`)

- Fluxo vertical e rolável.
- Capa editorial de 330 px seguida pelo formulário em marfim.
- A imagem permanece como parte da narrativa, com crop responsivo seguro.
- CTA ocupa a largura disponível; conteúdo não depende de sobreposição sobre a foto.

## Conteúdo e ações

- Título de login: “Bem-vindo de volta”.
- Campos: e-mail e senha, com autofill e exibição opcional da senha.
- Recuperação: “Esqueci minha senha”.
- CTA: “Entrar no ateliê”.
- Alternativa: autenticação com Google.
- Conversão secundária: cadastro.
- Modos na mesma jornada: login, cadastro e recuperação de senha.
- Retorno para a página principal sempre disponível.

## Estados

- Loading: ação bloqueada e indicador no próprio botão.
- Error: mensagem em região semântica, texto legível e filete vermelho.
- Recovery: somente e-mail e instrução explícita.
- Registration: nome, e-mail e nova senha com autofill correto.
- Offline/unauthorized: tratados pelos controllers e infraestrutura de autenticação.

## Motion

- Entrada one-shot de 420 ms com `easeOutCubic`.
- Imagem resolve escala `1.025 → 1.0`; formulário entra por fade coordenado.
- Troca de modo usa 280 ms; feedback de ação usa 180 ms.
- `disableAnimations` entrega imediatamente o estado final.
- Sem loops, parallax, blur animado ou atraso no CTA.

## Acessibilidade

- WCAG 2.2 AA; texto normal com contraste mínimo 4.5:1.
- Ordem de leitura igual à ordem lógica do formulário.
- Labels persistentes, foco visível, teclado e autofill.
- Alvos interativos mínimos de 48 dp.
- Imagem possui descrição semântica contextual.
- Erros usam `liveRegion` e não dependem somente de cor.
- Validar escala de texto 100%, 150% e 200% sem overflow.

## Segurança e arquitetura

- O widget não acessa Supabase diretamente.
- Fluxo: UI → controller Riverpod → repositório de autenticação.
- Senhas e tokens nunca entram em logs.
- Redirect pós-login aceita apenas destinos internos seguros e preserva RBAC.
- Loading impede envio duplicado.

## Performance

- Ilustração local em WebP, aproximadamente 93 KB.
- Imagem declarada no bundle e recortada com `BoxFit.cover`.
- Motion limitado a opacity/transform e executado uma vez.
- Meta: 60 FPS, LCP <2.5 s, CLS <0.1 e INP <200 ms.

## Critérios de aceitação

- Login, cadastro, recuperação e Google continuam funcionais.
- O layout é utilizável em 390 px, tablet e desktop.
- Nenhum texto funcional depende da área variável da fotografia.
- Reduced motion não agenda animações contínuas.
- Build Flutter Web release é concluído sem erro.
- Docker frontend responde em `/login` com HTTP 200.
- A interface segue o Design System Maison Lawrence e não reintroduz azul SaaS,
  card genérico ou glassmorphism ornamental.
