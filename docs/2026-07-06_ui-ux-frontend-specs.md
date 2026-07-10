---
version: 1.0.0
name: UI/UX Frontend Specifications
date: 2026-07-06
type: UI/UX Component Architecture & Detailed Layout Specification
---

# Especificação de Interface UI/UX — Lawrence Academy

## Objetivos
Definir com precisão absoluta a disposição visual, a arquitetura de componentes e os fluxos de exceção para as três telas críticas do frontend da Lawrence Academy (Player de Vídeo, Dashboard do Aluno e Catálogo de Cursos). Esta especificação serve como guia definitivo de implementação na ausência de protótipos no Figma, garantindo a fidelidade ao Lawrence Apple Design System.

## Contexto
A Lawrence Academy oferece uma experiência educacional premium de alta costura e modelagem. Para assegurar que o design seja limpo e focado no conteúdo (photography-first), o design system impõe uma proporção rígida de cores (60-30-10) e uso restrito de Liquid Glass. Este documento consolida as decisões tomadas em conjunto com a arquitetura de UI/UX para evitar ambiguidades no código do frontend.

---

## Requisitos Funcionais & Disposição Visual

### 1. Tela do Player de Curso (`dashboard.lesson.show`)

#### Layout e Disposição
* **Estrutura de Três Colunas (Desktop):**
  1. **Coluna Esquerda (Navegação Rail):** Barra compacta de 80–88px de largura, com ícones de navegação globais. Fundo em vidro (Liquid Glass). Destaque azul primário no ícone ativo e atalho premium fixo na base.
  2. **Área Central (Conteúdo Principal - 70-75% da largura restante):**
     * Player de vídeo centralizado em proporção `16:9`.
     * Título da lição em destaque (`Heading M`).
     * Metadados da lição (módulo, instrutor, número da aula).
     * Seção de Abas (`Overview`, `Materials`, `Notes`, `Exercises`, `Comments`), exibindo uma por vez.
     * Barra de Ação Inferior fixa horizontalmente com botões: Aula Anterior, Materiais, Anotações, Exercício e Próxima Aula (CTA primário em pílula azul).
  3. **Coluna Direita (Sidebar Fixa - 360px):**
     * Barra de progresso geral do curso.
     * Acordeão expansível de módulos e lista de lições.
     * Indicador visual da lição atual em destaque.
     * Ícones de check dourados/azuis para lições concluídas e cadeados cinzas para lições bloqueadas.
     * Botão para download de materiais complementares fixado ao final.

#### Fluxo de Exceção e Tratamento de Erros
* **Falha de Carregamento de Vídeo / Erro de DRM / Perda de Conexão:**
  * O erro deve ser renderizado **dentro do próprio contêiner 16:9 do player**, sem quebrar o layout da página ou a sidebar.
  * O contêiner exibe um painel translúcido em Liquid Glass com texto na cor `semantic-danger` (`#FF453A`) detalhando o erro (ex: "Conexão perdida com o servidor de mídia" ou "Falha na validação de DRM") e um botão de ação rápida (Pill CTA) para "Tentar Novamente".

---

### 2. Dashboard do Aluno (`dashboard.home`)

#### Layout e Disposição
* **Estrutura Assimétrica de 2 Colunas (Desktop - Max Width 1440px):**
  1. **Coluna da Esquerda (70%):**
     * Cabeçalho de Boas-Vindas (`Welcome Hero`) dinâmico.
     * Seção principal "Continuar Assistindo" apresentando o card de destaque do curso em andamento (capa do curso, título, progresso detalhado com frase motivacional, progresso com mola animada, lições restantes e botão CTA "Continuar").
     * Grade de "Cursos em Progresso" e "Cursos Recomendados".
     * Filtros rápidos por categoria.
  2. **Coluna da Direita (30%):**
     * Widget de próximas Lives/Consultorias com contagem regressiva e badge pulsante `LIVE` (verde `#30D158`) se o evento estiver ativo.
     * Calendário de eventos.
     * Card de indicação de alunos (Referral Program) com borda dourada (`#D4AF37`).
     * Certificados obtidos e ações rápidas.

#### Fluxo de Exceção e Casos de Borda
* **Novo Usuário (Sem Cursos Iniciados):**
  * O widget grande de "Continuar Assistindo" é substituído por um **Banner de Boas-Vindas Onboarding** estilizado que convida o aluno a iniciar sua jornada e destaca o primeiro curso recomendado da formação base (ex: "Introdução à Alta Costura") com um botão proeminente.
* **Falha de Comunicação / Banco de Dados Fora do Ar:**
  * **Recuperação Graciosa (Cache):** Se houver dados locais cacheados, exibe a interface normalmente e apresenta um banner fino em Liquid Glass com texto em `semantic-warning` (`#FF9F0A`) no topo: *"Você está no modo offline. Algumas informações podem estar desatualizadas."*
  * **Sem Cache Local:** Exibe uma tela ou widget centralizado de erro com ilustração minimalista em traço fino e botão "Tentar Conectar".

---

### 3. Catálogo de Cursos (`course.index`)

#### Layout e Disposição
* **Estrutura Híbrida de Navegação e Filtros:**
  * **Topo Horizontal:** Barra de pesquisa esférica acompanhada por chips horizontais de categorias rápidas (ex: Costura, Modelagem, Alfaiataria).
  * **Coluna Lateral Esquerda (240px):** Filtros avançados de Nível, Preço, Categoria Secundária e Ordenação. Esta coluna pode ser ocultada no desktop para maximizar a área visual e é colapsada em um drawer flutuante no mobile.
  * **Grade Central de Cursos (CourseGrid):** Grid de 12 colunas renderizando cartões de curso com imagem 16:9, título da aula, instrutor, badge de nível e preço/recorrência.

#### Comportamento e Interatividade
* **Navegação:** O clique em qualquer cartão do catálogo realiza um redirecionamento direto e fluido para a Landing Page de detalhes do curso (`/course/:slug`).
* **Estados de Carregamento:** Shimmer dinâmico cinza claro (`#E8E8ED`) nos cards enquanto os dados são obtidos.
* **Busca Sem Resultados (Empty State):** Exibição do `EmptyStateWidget` contendo uma ilustração minimalista de traço fino de costura/croqui, mensagem elegante ("Nenhum curso encontrado com esses filtros") e um botão Pill CTA "Limpar Filtros" para redefinir as opções.

---

## Requisitos Não Funcionais & Regras de Ouro de Acessibilidade

1. **Regra de Cores (60-30-10):** A cor azul (`#0A84FF`) indica estritamente interatividade. O dourado (`#D4AF37`) é reservado para conquistas, certificados e badges de nível premium.
2. **Liquid Glass de Profundidade:** Restrito a cabeçalhos persistentes, barra de checkout flutuante, modais e controles do player. Cartões e seções comuns usam fundo sólido branco puro (`#FFFFFF`).
3. **Tipografia Premium:** Corpo editorial fixado em **17px** (`body-l`) para redução de fadiga ocular. Tracking negativo obrigatório em títulos grandes. Peso 500 (Medium) banido; usa-se apenas 400 (Regular), 600 (Semibold) e 700 (Bold).
4. **Touch Targets e a11y:** Mínimo de 44x44 pixels para botões interativos e anel de foco visível azul (`#0071E3`) com offset de 2px para navegação por teclado.

## Decisões Arquiteturais & Integrações de Negócio

### 1. Fluxo de Pagamentos & Indicações (Stripe + Referral)
* **Regra de Desconto:**
  * **Indicado (Aluno B):** Ganha 10% de desconto automático na primeira fatura da assinatura.
  * **Indicador (Aluno A):** Recebe um crédito fixo de desconto (ex: R$ 20,00 ou equivalente) aplicado de forma única em sua próxima fatura do Stripe, assim que o indicado efetuar o primeiro pagamento com sucesso.

### 2. Controle de Segurança de Acesso Admin (MFA Step-Up)
* **Regra de Verificação:** A API administrativa (`/api/v1/admin/*`) exige obrigatoriamente um token JWT com claim `aal2` (segundo fator verificado).
* **Comportamento do Frontend:** Se o backend retornar erro HTTP 403 (`MFA_REQUIRED`), a tela do painel administrativo é bloqueada instantaneamente e um modal de segundo fator (TOTP) é exibido para o usuário elevar sua autenticação antes de prosseguir.

### 3. Esteira de Processamento de Vídeo (Pipeline Worker)
* **Fluxo de Acionamento:** O upload do vídeo bruto (raw) no bucket do Supabase aciona uma trigger/Edge Function nativa, que repassa a demanda HTTP POST para o Worker Python de forma assíncrona.
* **Sincronização:** O frontend não interage diretamente com o Worker de vídeo; ele monitora as alterações no banco de dados através do canal Supabase Realtime, atualizando o status da lição de `reviewing` para `published` assim que o processamento HLS/IA é concluído.

### 4. Proteção Avançada Anti-Pirataria
* **No Mobile:** Uso nativo de `FLAG_SECURE` para impedir capturas e gravações de tela no player de vídeo e arquivos baixados de forma isolada/criptografada em AES-128.
* **Na Web:** Exibição de uma marca d'água dinâmica flutuante (E-mail + IP + Timestamp) mudando de posição aleatoriamente a cada 30 segundos.
* **Integridade do DOM (Web):** Um `MutationObserver` monitora a árvore do DOM no frontend. Se o usuário tentar excluir, ocultar (ex: `display: none`) ou manipular a marca d'água usando ferramentas de desenvolvedor (F12/Inspecionar), a reprodução do player de vídeo é cancelada imediatamente e a sessão é deslogada.

### 5. Assistente de Anotações Inteligentes (Smart Notes)
* **Gatilho de IA:** A chamada para a API cognitiva (Gemini) ocorre exclusivamente por ação explícita do aluno ao clicar nos botões "Polir", "Aprofundar" ou "Resumir este Instante". O fluxo de digitação tradicional é mantido 100% local sem latência ou consumo de tokens.

### 6. Sistema de Notificações
* **Central In-App:** Uma aba/ícone de sino no cabeçalho do painel do aluno e do professor gerencia e lista notificações persistentes (notas de tarefas, novas submissões, faturas e avisos de lives).
* **Canais Externos:** Alertas críticos de cobrança e lives enviadas por e-mail em paralelo.

---

## Critérios de Aceite
* O layout das três telas críticas deve implementar precisamente as colunas e hierarquias descritas.
* Os estados de erro ou ausência de dados não devem exibir telas brancas ou pop-ups intrusivos, utilizando as diretrizes de design definidas.
* O player deve se manter no modo escuro absoluto e tratar falhas de mídia internamente no container de vídeo.
* O MutationObserver de marca d'água deve invalidar a reprodução web caso o elemento DOM seja modificado ou deletado.

## Stakeholders
* Ariane (Diretora Criativa & Instrutora Chefe)
* Lawrence Academy UX Team
* Equipe de Engenharia de Frontend (Hermes / Lawrence)
