---
version: 2.0.0
name: Lawrence-Academy-UI-UX-Frontend-Spec
type: Frontend Experience, Interaction & Interface Specification
status: Production Ready

platforms:
  - Flutter Web
  - Flutter Android

frontend:
  framework: Flutter
  language: Dart
  state_management: Riverpod
  navigation: GoRouter

architecture:
  - Clean Architecture
  - Feature First
  - Responsive Design
  - Adaptive Design
  - Offline First

design_system:
  source: docs/design/DESIGN_SYSTEM.md
  style:
    - Apple Human Interface Guidelines
    - Material Design 3 Adaptive
    - VisionOS Principles
    - Premium Learning Experience

accessibility:
  standard:
    - WCAG 2.2 AA
    - TalkBack
    - VoiceOver
    - Keyboard Navigation
    - Text Scaling
    - Reduced Motion

related_documents:
  - AGENTS.md
  - GEMINI.md
  - docs/product/PED-overview.md
  - docs/design/DESIGN_SYSTEM.md
  - docs/navigation/PAGES_OVERVIEW.md
  - docs/pages/
  - docs/architecture/SYSTEM_ARCHITECTURE.md
  - docs/architecture/STATE_AND_OFFLINE_SPEC.md
  - docs/performance/PERFORMANCE_OPTIMIZATION_SPEC.md
  - docs/security/SECURITY_COMPLIANCE_SPEC.md
---

# Lawrence Academy
# UI/UX Frontend Specification

## 1. Objetivo

Este documento define os padrões globais de experiência, interface, comportamento, responsividade, acessibilidade e implementação frontend da Lawrence Academy.

Ele deve orientar:

- Product Designers;
- UI Designers;
- UX Designers;
- Desenvolvedores Flutter;
- Agentes de IA;
- Revisores;
- QA;
- Product Managers.

Este documento responde:

```text
Como a experiência deve funcionar?

Como a interface deve se comportar?

Como a aplicação se adapta a cada plataforma?

Como cada tela deve comunicar prioridade?

Como o frontend deve preservar acessibilidade, performance e consistência?

Este documento não substitui:

DESIGN_SYSTEM.md, que define tokens e componentes visuais;
PAGES_OVERVIEW.md, que define navegação e rotas;
docs/pages/, que define cada página;
SYSTEM_ARCHITECTURE.md, que define organização técnica;
SERVICE_API.md, que define contratos de dados.
2. Princípios centrais

Toda interface deve seguir estes princípios:

Clareza antes de decoração

Conteúdo antes de componentes

Ação antes de distração

Consistência antes de novidade

Acessibilidade antes de estética

Performance antes de efeito

Segurança antes de conveniência

A interface deve esconder a complexidade do sistema.

O usuário deve perceber:

segurança;
orientação;
progresso;
controle;
continuidade;
confiança.

Nunca deve perceber:

arquitetura;
banco;
falhas técnicas;
complexidade de sincronização;
regras internas;
detalhes de autorização.
3. Visão de experiência

A experiência deve combinar:

Apple

Aplicar:

simplicidade;
acabamento;
espaçamento;
foco;
transições suaves;
hierarquia;
consistência.
MasterClass

Aplicar:

valorização do conteúdo;
apresentação editorial;
protagonismo de vídeo e imagem;
experiência premium.
Duolingo

Aplicar:

progresso;
feedback;
motivação;
conclusão;
microinterações;
continuidade.
Linear

Aplicar:

precisão;
densidade controlada;
navegação eficiente;
hierarquia clara;
velocidade.

Não copiar produtos.

Usar apenas princípios.

4. Usuários e necessidades
Student

Necessidades principais:

encontrar rapidamente seus cursos;
continuar de onde parou;
visualizar progresso;
concluir atividades;
receber feedback;
acessar certificados;
usar conteúdo offline;
entender pagamentos e assinaturas.

Prioridade UX:

Continuar aprendendo
Teacher

Necessidades principais:

criar e publicar cursos;
organizar módulos;
subir aulas;
acompanhar alunos;
corrigir atividades;
analisar resultados;
administrar conteúdo.

Prioridade UX:

Criar, acompanhar e corrigir
Admin

Necessidades principais:

acompanhar operação;
gerenciar usuários;
moderar cursos;
revisar pagamentos;
controlar permissões;
analisar riscos;
auditar ações.

Prioridade UX:

Entender riscos e agir com segurança
5. Hierarquia de decisão

Antes de criar qualquer tela, responder:

Quem usa?

Qual problema resolve?

Qual é a ação principal?

Quais informações vêm primeiro?

O que pode ser removido?

O que acontece se não houver dados?

O que acontece se houver erro?

O que acontece offline?

Existe risco financeiro?

Existe ação destrutiva?

Existe permissão especial?

A tela deve permitir que o usuário identifique a ação principal em até 5 segundos.

6. Arquitetura visual global

A aplicação possui quatro contextos visuais principais:

Public

Auth

Student

Teacher

Admin

Cada contexto pode possuir layout próprio, mas todos devem seguir o mesmo Design System.

7. Layouts globais
PublicLayout

Usado em:

home;
catálogo;
detalhes do curso;
pricing;
about;
blog;
contact;
FAQ.

Estrutura:

Header

Hero ou título contextual

Conteúdo principal

CTA

Footer

Características:

editorial;
inspiracional;
foco em descoberta;
forte apresentação visual;
navegação simples.
AuthLayout

Usado em:

splash;
onboarding;
login;
register;
forgot password;
reset password;
verify email.

Características:

baixa distração;
foco em uma ação;
formulário curto;
feedback imediato;
recuperação clara.
StudentLayout

Estrutura:

Desktop:
Sidebar + Header + Main Content

Mobile:
Top Bar + Main Content + Bottom Navigation

Características:

continuidade;
progresso;
ações frequentes;
acesso rápido a cursos;
suporte offline.
TeacherLayout

Estrutura:

Sidebar

Header contextual

Área de trabalho

Painéis de ação

Características:

produtividade;
clareza;
criação;
gestão;
pendências;
métricas úteis.
AdminLayout

Estrutura:

Navigation Rail ou Sidebar

Header

Main Workspace

Context Panel opcional

Características:

densidade controlada;
visibilidade operacional;
foco em risco;
confirmação forte;
auditoria;
MFA em ações críticas.
8. Responsividade

Toda tela deve funcionar em:

Mobile Android

Tablet

Desktop Web

Os breakpoints oficiais devem vir do Design System.

Referência conceitual:

Mobile:
0–599

Tablet:
600–1023

Desktop:
1024+

Não usar estes valores se o Design System definir outros.

Mobile

Regras:

uma coluna;
CTA principal visível;
ações próximas ao polegar;
Bottom Navigation;
conteúdo secundário progressivo;
filtros em Bottom Sheet;
formulários em etapas;
touch target mínimo de 48dp.
Tablet

Regras:

uma ou duas colunas;
navegação adaptativa;
Side Sheet quando útil;
mais conteúdo visível;
densidade moderada.
Desktop

Regras:

Sidebar;
header;
grids adaptativos;
largura máxima de leitura;
suporte a hover;
foco visível;
atalhos de teclado;
tabelas quando necessário.

Evitar três implementações completamente diferentes.

Preferir composição adaptativa.

9. Navegação

A navegação usa GoRouter.

Princípios:

Rotas nomeadas

Guards centralizados

Deep links suportados

Sem strings espalhadas

Sem duplicação de regras

Guards previstos:

AuthGuard;
RoleGuard;
PermissionGuard;
SubscriptionGuard.

A UI pode ocultar uma ação, mas o backend deve continuar validando.

10. Navegação mobile

Bottom Navigation recomendada para Student.

Itens possíveis:

Início

Meus Cursos

Atividades

Downloads

Perfil

Regras:

no máximo cinco itens;
ícone + label;
item selecionado evidente;
suporte a acessibilidade;
estado persistido;
não perder contexto ao trocar de aba.

Teacher e Admin podem usar Navigation Rail ou Drawer conforme largura.

11. Navegação desktop

Sidebar deve:

agrupar itens;
indicar seção atual;
suportar recolhimento;
preservar labels;
mostrar apenas itens permitidos;
respeitar role e permission;
manter largura estável;
usar scroll quando necessário.

Evitar menus longos sem agrupamento.

12. Hierarquia visual

Toda tela deve possuir:

Contexto

Ação principal

Conteúdo prioritário

Conteúdo secundário

Ações auxiliares

Regras:

apenas um CTA primário por contexto principal;
ações secundárias com menor peso;
ações destrutivas separadas;
títulos explicam a seção;
textos curtos;
conteúdo escaneável;
números sempre com contexto.

Evitar:

cinco botões primários;
cards com o mesmo peso;
excesso de badges;
métricas sem finalidade;
gráficos decorativos.
13. Design tokens

Toda interface deve usar os tokens oficiais de:

cor;
tipografia;
espaçamento;
raio;
sombra;
motion;
breakpoint;
elevação.

Exemplos esperados:

AppColors

AppTypography

AppSpacing

AppRadius

AppShadows

AppMotion

AppBreakpoints

Proibido:

Color(0xFF123456)
TextStyle(fontSize: 17)
EdgeInsets.all(19)
BorderRadius.circular(21)

Sem atualizar o Design System.

14. Cores

Aplicar regra 60-30-10:

60%:
base clara, canvas e superfícies

30%:
azul de ação e estrutura

10%:
dourado premium e destaque raro

O dourado deve ser usado apenas para:

certificados;
conquistas;
premium;
selos especiais;
reconhecimento.

Não usar dourado como cor de ação comum.

Cores semânticas:

Success

Warning

Danger

Info

Nunca usar cor sozinha para transmitir informação.

15. Tipografia

A tipografia deve:

estabelecer hierarquia;
facilitar leitura;
suportar texto ampliado;
preservar contraste;
evitar excesso de pesos;
usar estilos do Design System.

Regras:

conteúdo educacional deve priorizar legibilidade;
labels devem ser visíveis;
texto secundário não pode ficar ilegível;
não reduzir fonte para corrigir layout;
ajustar composição em vez de diminuir texto;
suportar Dynamic Type e Text Scaling.
16. Espaçamento

Usar a escala oficial do Design System.

Princípios:

elementos relacionados ficam próximos;
seções diferentes ganham respiro;
cards não encostam;
ações possuem espaço;
títulos e conteúdo mantêm alinhamento;
nenhuma tela deve parecer apertada.

Evitar valores arbitrários.

17. Cards

Cards devem agrupar informação ou ação.

Um card deve ter:

propósito claro;
hierarquia;
espaçamento;
estado de interação;
CTA definido;
comportamento responsivo.

Evitar:

card dentro de card;
sombra forte;
borda pesada;
excesso de cards;
todos os elementos em cards;
glassmorphism em listas repetidas.
18. Liquid Glass

Usar apenas em superfícies flutuantes:

navigation bars;
player controls;
dialogs;
bottom sheets;
floating search;
checkout bar;
sticky action area.

Não usar em:

background inteiro;
cards repetidos;
tabelas;
conteúdo de leitura;
formulários longos;
listas grandes.

Todo blur deve:

preservar contraste;
usar RepaintBoundary quando necessário;
respeitar performance;
não dificultar leitura.
19. Botões

Tipos:

Primary

Secondary

Tertiary

Destructive

Icon Button

Floating Action

Estados obrigatórios:

default;
hover;
pressed;
focused;
disabled;
loading.

Regras:

label com verbo claro;
área de toque mínima;
não usar texto genérico como “OK” quando a ação pode ser específica;
ações destrutivas exigem confirmação;
loading bloqueia clique duplicado.

Exemplos:

Continuar aula

Salvar alterações

Cancelar assinatura

Excluir curso
20. Inputs e formulários

Formulários devem:

reduzir digitação;
usar labels visíveis;
validar cedo;
preservar dados;
evitar perda acidental;
mostrar erro junto ao campo;
usar autofill;
usar seleção quando possível;
bloquear envio duplicado.

Fluxos longos devem usar:

Stepper

Wizard

Progress indicator

Resumo final

Nunca esconder label e depender apenas de placeholder.

21. Tabelas

Usar tabelas principalmente no desktop e contextos administrativos.

Regras:

colunas essenciais;
alinhamento consistente;
status legíveis;
ações agrupadas;
paginação;
filtros;
busca;
ordenação;
acessibilidade por teclado;
versão mobile alternativa.

No mobile, preferir:

Cards compactos

Lista detalhada

Expansion tiles
22. Gráficos

Gráficos só devem existir quando ajudam a decidir.

Todo gráfico precisa:

título;
período;
legenda;
contexto;
descrição textual;
estado vazio;
estado loading;
estado error;
acessibilidade.

Evitar gráficos decorativos.

23. Loading

Nunca mostrar tela branca.

Preferir:

skeleton;
progressive loading;
placeholders;
shimmer leve;
preservação do layout.

Spinner central apenas para:

operação bloqueante;
pagamento;
envio;
processamento crítico.

Referência:

docs/pages/shared/loading.md
24. Empty state

Todo estado vazio deve responder:

O que aconteceu?

Por que está vazio?

Qual próximo passo?

Exemplo:

Você ainda não começou nenhum curso.

Explore o catálogo e inicie sua jornada.

[Explorar cursos]

Referência:

docs/pages/shared/empty-state.md
25. Error state

Mensagens devem ser:

humanas;
curtas;
recuperáveis;
sem detalhes técnicos;
com próxima ação.

Nunca mostrar:

Exception

500 Internal Server Error

Stack trace

SQL error

Referência:

docs/pages/shared/error.md
26. Offline

Quando offline:

informar de forma discreta;
mostrar dados em cache;
manter ações possíveis;
enfileirar sincronização;
explicar limitações;
permitir retry;
não bloquear tudo.

Referência:

docs/pages/shared/offline.md
27. Dialogs

Usar apenas quando:

existe risco;
existe decisão importante;
existe perda potencial;
existe ação crítica;
o usuário precisa focar.

Preferir Bottom Sheet no mobile para ações rápidas.

Ações destrutivas devem:

explicar impacto;
indicar irreversibilidade;
usar confirmação;
separar botão destrutivo.

Referência:

docs/pages/shared/dialogs.md
28. Bottom Sheets

Usar no mobile para:

filtros;
seleção;
ações;
detalhes rápidos;
player options;
materiais;
compartilhamento.

Não usar para:

formulários longos;
fluxos críticos extensos;
operações administrativas complexas.

Referência:

docs/pages/shared/bottom-sheet.md
29. Search

Busca deve ser:

rápida;
contextual;
previsível;
acessível;
integrada a filtros;
com recentes;
com sugestões;
com empty state.

Mobile:

Full screen search
+
Bottom Sheet de filtros

Desktop:

Search bar
+
Popover ou Command Palette

Referência:

docs/pages/shared/search.md
30. Feedback

Toda ação precisa de feedback.

Exemplos:

Salvando...

Salvo.

Pagamento aprovado.

Upload em andamento.

Sincronização concluída.

Não foi possível atualizar.

Feedback deve ser proporcional à importância.

Usar:

inline;
toast;
banner;
dialog;
full screen;
progress.
31. Motion

Toda animação deve ter propósito.

Usar para:

entrada de seção;
mudança de estado;
progresso;
feedback;
navegação;
expansão;
conclusão.

Tempos:

Fast:
150–200ms

Normal:
250–350ms

Slow:
até 420ms

Respeitar:

Reduce Motion

Evitar:

movimento contínuo;
blur animado em listas;
transições longas;
excesso de bounce;
animação decorativa.
32. Microinterações

Aplicar em:

botão pressionado;
conclusão de aula;
progresso;
favorito;
download;
resposta enviada;
certificado liberado;
item salvo.

As microinterações devem:

confirmar;
orientar;
recompensar;
não atrasar a tarefa.
33. Acessibilidade

Obrigatório:

WCAG 2.2 AA

TalkBack

VoiceOver

Keyboard Navigation

Focus Visible

Text Scaling

High Contrast

Reduce Motion

Touch Target

Regras:

não depender só de cor;
ícones importantes com label;
botões com ação clara;
campos com label;
gráficos com descrição;
foco lógico;
atalhos acessíveis;
suporte a zoom;
sem overflow com texto ampliado.
34. Baixa visão

Validar:

contraste elevado;
texto legível;
foco visível;
ícone + texto;
transparência controlada;
zoom no Web;
touch targets confortáveis;
não usar cinza claro em conteúdo importante;
não esconder informação por hover;
não reduzir fonte para caber.
35. Performance frontend

Obrigatório:

usar const;
usar ListView.builder;
usar Slivers;
paginar listas;
redimensionar imagens;
limitar blur;
evitar rebuild global;
usar select no Riverpod;
cachear quando apropriado;
descarregar recursos;
evitar imagens 4K;
usar placeholders.

Metas:

60 FPS obrigatório

120 FPS quando disponível
36. Estado e Riverpod

Fluxo:

Widget
 ↓
Controller
 ↓
UseCase
 ↓
Repository

A UI pode:

observar estado;
disparar ações;
renderizar;
navegar;
mostrar feedback.

A UI não pode:

acessar Supabase diretamente;
executar SQL;
aplicar regra de negócio;
calcular pagamentos;
definir autorização;
transformar resposta HTTP bruta.
37. Estrutura de página

Toda página deve ser composicional.

Exemplo:

Page
├── Header
├── Primary Section
├── Secondary Sections
├── Loading State
├── Empty State
├── Error State
└── Offline State

Evitar arquivos gigantes.

Extrair widgets quando houver:

responsabilidade própria;
reutilização;
complexidade;
estado visual independente.
38. Padrão de implementação Flutter

Exemplo:

class StudentDashboardPage extends ConsumerWidget {
  const StudentDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(studentDashboardControllerProvider);

    return StudentShell(
      child: state.when(
        loading: () => const StudentDashboardSkeleton(),
        error: (error, stackTrace) => StudentDashboardErrorState(
          onRetry: () {
            ref
                .read(studentDashboardControllerProvider.notifier)
                .refresh();
          },
        ),
        data: (data) {
          if (data.isEmpty) {
            return const StudentDashboardEmptyState();
          }

          return StudentDashboardContent(data: data);
        },
      ),
    );
  }
}
39. Páginas e documentação

Cada tela deve possuir especificação em:

docs/pages/

Estrutura oficial:

docs/pages/
├── public/
├── auth/
├── student/
├── teacher/
├── admin/
└── shared/

Antes de implementar uma tela:

1. Ler PAGES_OVERVIEW

2. Ler a Page Spec

3. Ler o Design System

4. Ler este documento

5. Inspecionar código existente

6. Implementar

7. Testar

8. Revisar

Nunca criar tela sem procurar a especificação correspondente.

40. Critérios de aceitação globais

Toda página deve:

[ ] Cumprir o objetivo do usuário

[ ] Possuir ação principal clara

[ ] Usar Design System

[ ] Ser responsiva

[ ] Ser acessível

[ ] Implementar Loading

[ ] Implementar Empty

[ ] Implementar Error

[ ] Implementar Offline quando aplicável

[ ] Respeitar guards

[ ] Usar Riverpod

[ ] Usar GoRouter

[ ] Evitar lógica na UI

[ ] Possuir testes

[ ] Preservar performance
41. Anti-padrões proibidos

Nunca:

❌ Criar UI genérica

❌ Criar dashboard padrão Bootstrap

❌ Inventar cores

❌ Usar gradiente sem especificação

❌ Colocar Liquid Glass em tudo

❌ Chamar Supabase no Widget

❌ Colocar regra de negócio na Page

❌ Ignorar acessibilidade

❌ Ignorar baixa visão

❌ Ignorar estados

❌ Criar página enorme

❌ Duplicar componente

❌ Usar texto pequeno para caber

❌ Criar gráfico sem finalidade

❌ Criar animação sem propósito

❌ Entregar apenas mobile

❌ Marcar como pronto sem teste
42. Definition of Done

Uma tela está pronta quando:

[ ] Page Spec atendida

[ ] Design System aplicado

[ ] Responsividade validada

[ ] Acessibilidade validada

[ ] Estados completos

[ ] Navegação validada

[ ] Segurança visual validada

[ ] Performance aceitável

[ ] Testes criados

[ ] Documentação atualizada

[ ] Review aprovado
Regra final

A interface não existe para mostrar tecnologia.

Ela existe para ajudar o usuário a avançar.

Clara

Útil

Acessível

Responsiva

Consistente

Segura

Performática

O PED define o produto.

O Design System define a linguagem.

As Page Specs definem cada experiência.

O Flutter entrega a interface.

A arquitetura protege a evolução do sistema.
'''

path = Path('/mnt/data/UI_UX_FRONTEND_SPEC.md')
path.write_text(content, encoding='utf-8')
print(path)

STDOUT/STDERR
/mnt/data/UI_UX_FRONTEND_SPEC.md