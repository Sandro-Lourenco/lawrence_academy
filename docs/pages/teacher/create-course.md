---
id: PAGE-TEACHER-002
name: Create Course
route: /teacher/courses/create
layout: TeacherDashboardLayout
platforms:
  - Web
  - Android
roles:
  - Teacher
authentication: true
responsive: true
status: Production
design-system: Lawrence Design System
navigation: Sidebar + Top Navigation
state-management: Riverpod
architecture: Clean Architecture + DDD
real-time: Supabase Realtime

wizard:
  phases: 5
  internal_steps: 13
  autosave: true
  draft: true
  publish_workflow: true
---

# Create Course

## Objetivo

A página **Create Course** é o ambiente completo para criação e publicação de cursos da Lawrence Academy.

O objetivo é permitir que qualquer professor consiga estruturar um curso completo sem dificuldades, utilizando um fluxo em formato **Wizard (Passo a Passo)** semelhante ao utilizado por plataformas como Kajabi, Thinkific, Teachable e Udemy, porém seguindo o padrão visual minimalista do Lawrence Design System.

Todo o processo deve ser intuitivo, organizado e seguro, permitindo salvar automaticamente rascunhos durante a edição.

---

# Objetivos

- Criar cursos.
- Editar cursos.
- Publicar cursos.
- Salvar rascunhos.
- Organizar módulos.
- Adicionar aulas.
- Configurar assinatura.
- Configurar SEO.

---

# Fluxo

```
Professor

↓

Criar Curso

↓

Wizard

↓

Salvar automaticamente

↓

Pré-visualização

↓

Publicar Curso
```

---

# Layout Desktop

```
--------------------------------------------------------------

Glass Header

--------------------------------------------------------------

Sidebar

|

Step Navigation

|

Wizard

|

Preview

--------------------------------------------------------------
```

---

# Layout Mobile

```
Glass Header

↓

Progress

↓

Wizard

↓

Bottom Actions
```

---

# Estrutura

```
Glass Header

↓

Course Wizard

↓

Step Navigation

↓

Step Content

↓

Preview Card

↓

Validation

↓

Publish
```

---

# Glass Header

Sticky

72px

Liquid Glass

Blur

20px

Opacity

72%

---

# Wizard

## Navegação canônica

O Studio de Autoria apresenta cinco fases ao professor, preservando treze
tarefas internas. O dashboard é a entrada da jornada e não conta como etapa do
wizard.

1. Planejamento: tipo, informações básicas e objetivos pedagógicos.
2. Apresentação e oferta: configurações comerciais e mídia.
3. Estrutura: módulos e aulas.
4. Conteúdo: blocos, materiais, “Saiba mais” e atividades.
5. Revisão e publicação: prévia, checklist e publicação.

Rascunhos podem ser salvos incompletos. Requisitos de publicação são validados
separadamente e não bloqueiam a continuidade da autoria.

### Fase 1 — Planejamento

Contrato persistente:

- `course_type`: `complete`, `quick` ou `workshop`;
- nome, slug, subtítulo, descrição curta e descrição completa;
- categoria, nível, idioma e carga horária estimada em minutos;
- pré-requisitos;
- objetivos de aprendizagem;
- público-alvo;
- materiais necessários;
- competências desenvolvidas;
- resultados esperados.

Objetivos e demais listas pedagógicas aceitam no máximo 20 itens, com um item
por linha na interface. A carga horária informada pelo professor é estimativa;
a duração processada dos vídeos permanece como fonte da duração real.

Stepper horizontal (Desktop)

Stepper vertical (Mobile)

Mostrar

```
1 Informações

2 Descrição

3 Conteúdo

4 Mídia

5 Preço

6 Configurações

7 Revisão

8 Publicação
```

---

# Etapa 1

## Informações Básicas

Campos

Título

Slug

Categoria

Subcategoria

Nível

Idioma

Professor

Imagem da Capa

Imagem Banner

---

# Etapa 2

## Descrição

Campos

Descrição Curta

Descrição Completa

Objetivos

Pré-requisitos

Público-alvo

Competências

---

Editor Rich Text

Markdown

Imagens

Links

Listas

---

# Etapa 3

## Conteúdo

Criar

Módulos

↓

Lições

↓

Atividades

↓

Materiais

Cada módulo possui

Título

Descrição

Ordem

Tempo estimado

---

Cada aula possui

Título

Descrição

Vídeo

PDF

Downloads

Legenda

Tempo

Preview Gratuito

---

Drag and Drop

Reordenação

Duplicação

Excluir

---

# Etapa 4

## Upload de Mídia

Upload

Vídeos

PDF

Imagens

Arquivos ZIP

Materiais

Áudios

---

Pipeline

Upload

↓

Supabase Storage

↓

Conversão HLS

↓

DRM

↓

Disponível

---

Status

Uploading

Processing

Ready

Error

---

Nunca armazenar MP4 público.

Todo vídeo será convertido para

HLS

AES-128

---

# Etapa 5

## Assinatura e Preço

Modelo

Assinatura Mensal

(Obrigatório)

---

Campos

Valor Mensal

Moeda

Período

Cupom

Promoção

Data início

Data fim

---

Exemplo

```
Curso

Modelagem Feminina

R$59,90/mês
```

---

# Etapa 6

## Configurações

Permitir comentários

Emitir certificado

Disponibilizar download

Ativar atividades

Ativar fórum

Curso privado

Curso público

Pré-venda

SEO

---

SEO

Título

Descrição

Keywords

Imagem Open Graph

---

# Etapa 7

## Revisão

Mostrar resumo completo

Informações

Preço

Conteúdo

Módulos

Vídeos

Materiais

Professor

Preview

---

Executar validações

---

# Etapa 8

## Publicação

Status

Rascunho

↓

Revisão

↓

Publicado

↓

Arquivado

---

Botões

Salvar

Publicar

Agendar publicação

Cancelar

---

# Preview

Painel lateral

Mostrar exatamente como o curso ficará para o aluno.

---

# APIs

POST /teacher/courses

PATCH /teacher/courses/{id}

GET /teacher/courses/{id}

POST /teacher/modules

POST /teacher/lessons

POST /teacher/upload

POST /teacher/publish

POST /teacher/draft

POST /teacher/preview

---

# Providers

courseWizardProvider

courseProvider

moduleProvider

lessonProvider

uploadProvider

draftProvider

previewProvider

publishProvider

---

# Componentes

GlassHeader

CourseWizard

StepNavigation

CourseForm

RichEditor

ModuleTree

LessonCard

UploadZone

ProgressUpload

PricingCard

SettingsCard

PreviewCard

ValidationCard

PublishCard

SkeletonLoader

Toast

---

# Estados

## Loading

Skeleton Apple Style.

---

## Salvando

Indicador discreto

```
Salvando...
```

---

## Rascunho salvo

```
Alterações salvas automaticamente.
```

---

## Upload

Progress Bar

Percentual

Tempo restante

---

## Publicado

Banner verde

```
Curso publicado com sucesso.
```

---

## Erro

Toast

Botão

Tentar novamente.

---

# Motion

Fade

Slide

Scale

Spring

Blur

Hero Animation

Progress Animation

Shared Transition

Skeleton

---

# Liquid Glass

Aplicar apenas em

Glass Header

Stepper Flutuante

Dialogs

Preview Floating

Bottom Actions

Floating Save Button

Nunca aplicar em

Editor

Cards principais

Inputs

Árvore de módulos

---

# Tipografia

Hero

36px

Heading

28px

Subheading

22px

Body

17px

Caption

13px

Micro

11px

---

# Cores

60%

White

#FFFFFF

30%

Primary Blue

#0A84FF

10%

Premium Gold

#D4AF37

Success

#30D158

Warning

#FF9F0A

Danger

#FF453A

Info

#64D2FF

Text

#1D1D1F

---

# Responsividade

## Desktop

Wizard em duas colunas.

Preview lateral fixa.

---

## Tablet

Preview recolhível.

---

## Mobile

Stepper vertical.

Safe Area.

Bottom Actions.

---

# Performance

Autosave

Lazy Loading

Background Upload

Chunk Upload

Realtime

Optimistic Update

Skeleton Loading

60 FPS

---

# Analytics

Cursos criados

Cursos publicados

Tempo médio de criação

Uploads realizados

Conversão de publicação

Abandono do Wizard

---

# Segurança

Supabase Auth

JWT

HTTPS

Supabase Storage

Row Level Security

Teacher Guard

Versionamento

Logs de Auditoria

Criptografia

---

# Acessibilidade

WCAG AA

Keyboard Navigation

TalkBack

VoiceOver

Touch Target

44x44px

Focus Visible

Escala dinâmica

Alto contraste

---

# Psicologia de Produto

## Clareza

Cada etapa deve possuir apenas as informações necessárias.

Evitar formulários longos.

---

## Progresso

Sempre mostrar o percentual concluído.

Exemplo

```
Etapa 5 de 8

63% concluído
```

---

## Segurança

Salvar automaticamente elimina o medo de perder trabalho.

---

## Controle

O professor deve visualizar exatamente como o curso ficará antes de publicar.

---

# Critérios de Aceitação

- O processo de criação deve ocorrer através de um Wizard de 8 etapas.
- O sistema deve salvar automaticamente todas as alterações como rascunho.
- Todo upload de vídeo deve utilizar Supabase Storage com conversão automática para **HLS criptografado (AES-128)**.
- O professor deve conseguir organizar módulos e aulas por Drag and Drop.
- O modelo comercial da plataforma deve permitir **apenas cursos vendidos por assinatura mensal individual**, sem venda única.
- A pré-visualização deve refletir fielmente a experiência do aluno.
- A página deve seguir integralmente o Lawrence Design System.
- O efeito **Liquid Glass** deve ser utilizado exclusivamente em elementos flutuantes.
- A experiência deve transmitir simplicidade, produtividade e controle, inspirada em Notion, Linear, Kajabi e Apple.
````
