---
id: PAGE-STUDENT-009
name: Downloads
route: /dashboard/downloads
layout: StudentDashboardLayout
platforms:
  - Android
roles:
  - Student
authentication: true
responsive: true
status: Production
design-system: Lawrence Design System
navigation: Bottom Navigation + Sidebar
state-management: Riverpod
architecture: Clean Architecture + DDD
security:
  encrypted-storage: true
  drm: true
  offline-only: true
---

# Downloads

## Objetivo

A página **Downloads** é responsável por gerenciar todas as aulas disponíveis para visualização offline no aplicativo Android da Lawrence Academy.

Ela não é apenas um gerenciador de arquivos.

É uma biblioteca offline inteligente.

Toda a experiência deve transmitir segurança, simplicidade e continuidade do aprendizado.

Inspirada em:

- Apple TV Downloads
- Netflix Downloads
- Spotify Downloads
- YouTube Premium
- MasterClass
- Apple Podcasts

O usuário nunca verá arquivos físicos (.mp4).

Todo o conteúdo permanece criptografado dentro do sandbox da aplicação.

---

# Objetivos

- Gerenciar downloads offline.
- Exibir progresso dos downloads.
- Organizar cursos baixados.
- Mostrar espaço ocupado.
- Permitir excluir downloads.
- Permitir atualizar downloads.
- Garantir segurança dos vídeos.

---

# Disponibilidade

## Android

Disponível.

---

## Flutter Web

A página não existe.

Caso acessada diretamente:

```
Downloads Offline

Esta funcionalidade está disponível exclusivamente no aplicativo Android.

Baixe o aplicativo para assistir às aulas sem internet.
```

Botão

```
Baixar Aplicativo
```

---

# Fluxo

```
Curso

↓

Aluno seleciona

↓

Baixar Aula

↓

Download HLS

↓

Criptografia

↓

Sandbox Android

↓

Disponível Offline

↓

Assistir

↓

Sincronizar progresso
```

---

# Layout Desktop (Flutter Web)

```
------------------------------------------------------

Mensagem

Downloads disponíveis apenas no App

↓

QR Code

↓

Botão Download App

------------------------------------------------------
```

---

# Layout Android

```
Glass Header

↓

Storage Summary

↓

Downloads em andamento

↓

Cursos Baixados

↓

Espaço Utilizado

↓

Bottom Navigation
```

---

# Estrutura

```
Glass Header

↓

Storage Summary

↓

Active Downloads

↓

Downloaded Courses

↓

Downloaded Lessons

↓

Storage Manager

↓

Recommendations

↓

Footer
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

Componentes

Logo

Pesquisar

Downloads

Perfil

---

# Storage Summary

Card superior.

Mostrar:

Espaço utilizado.

Espaço livre.

Quantidade de cursos.

Quantidade de aulas.

---

Exemplo

```
Armazenamento

8,2 GB utilizados

31 GB livres

12 cursos

84 aulas
```

---

Mostrar barra circular.

---

# Downloads em Andamento

Lista.

Cada item possui:

Miniatura

Título

Curso

Progresso

Velocidade

Tempo restante

Botão

Pausar

Cancelar

Retomar

---

Barra azul.

Animação suave.

---

# Downloaded Courses

Grid.

Cada card possui:

Imagem

Título

Professor

Categoria

Progresso do curso

Última visualização

Tamanho ocupado

Botão

Abrir

---

Botão secundário

Gerenciar

---

# Downloaded Lessons

Dentro do curso.

Lista.

Cada item

Check

Título

Duração

Data download

Versão

Status

---

Status

Disponível

Atualizando

Corrompido

Expirado

---

# Offline Player

Caso sem internet.

Abrir diretamente.

Sem autenticação online.

Usa licença local.

---

# Atualizações

Caso o professor publique nova versão.

Mostrar

```
Nova versão disponível

Atualizar agora
```

---

Download diferencial.

---

# Storage Manager

Mostrar

Espaço disponível

Espaço utilizado

Maior curso

Maior vídeo

Últimos downloads

---

Botões

Excluir curso

Excluir aula

Excluir tudo

---

Sempre solicitar confirmação.

---

# Recommendation

Caso espaço esteja acabando.

Mostrar

```
Você pode liberar 3,2GB removendo cursos concluídos.
```

---

# Download Settings

Configurações.

Permitir

Download apenas Wi-Fi

↓

Download usando dados móveis

↓

Qualidade

Alta

Média

Baixa

↓

Downloads automáticos

↓

Excluir após concluir curso

↓

Sincronizar apenas no Wi-Fi

---

# Pesquisa

Pesquisar

Curso

Professor

Categoria

---

# APIs

GET /downloads

GET /downloads/storage

GET /downloads/active

POST /downloads/start

POST /downloads/pause

POST /downloads/resume

DELETE /downloads/{id}

POST /downloads/update

GET /downloads/settings

PATCH /downloads/settings

---

# Providers

downloadsProvider

storageProvider

activeDownloadsProvider

downloadSettingsProvider

offlinePlayerProvider

---

# Componentes

GlassHeader

StorageSummaryCard

DownloadProgressCard

DownloadedCourseCard

LessonDownloadCard

StorageManagerCard

RecommendationCard

SettingsCard

SkeletonLoader

EmptyState

---

# Estados

## Loading

Skeleton Apple Style.

---

## Nenhum download

Mostrar ilustração.

Mensagem

```
Você ainda não possui aulas baixadas.

Baixe cursos para assistir mesmo sem internet.
```

Botão

Explorar Cursos

---

## Download em andamento

Mostrar progresso.

---

## Sem internet

Abrir normalmente.

---

## Espaço insuficiente

Banner amarelo.

Sugestão automática.

---

## Erro

Botão

Tentar novamente.

---

# Motion

Fade

Scale

Slide

Progress Animation

Spring

Hero Animation

Blur

Shared Transition

---

# Liquid Glass

Aplicar apenas em

Glass Header

Floating Buttons

Bottom Navigation

Download Toolbar

Modal

Nunca aplicar em

Cards

Texto

Lista

Player

Conteúdo

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

Sucesso

#30D158

Aviso

#FF9F0A

Erro

#FF453A

---

# Responsividade

## Android

Tela otimizada.

Cards.

Safe Area.

Bottom Navigation.

FAB opcional.

---

## Tablets

Grid com duas colunas.

---

## Flutter Web

Página informativa.

Sem downloads.

---

# Performance

Downloads paralelos

Fila inteligente

Download resumível

Lazy Loading

SQLite

Hive Cache

Background Service

Foreground Notification

60 FPS

---

# Analytics

Cursos baixados

Aulas baixadas

Espaço ocupado

Tempo offline

Downloads concluídos

Downloads cancelados

Qualidade utilizada

---

# Segurança

Todos os vídeos utilizam:

HLS

AES-128

DRM

Tokens temporários

Sandbox Android

Sem MP4

Sem acesso externo

Device Binding

Validação da assinatura

Proteção contra Root

Proteção contra engenharia reversa

Bloqueio de Screen Recording (quando suportado)

Licença offline com expiração configurável

Renovação automática da licença quando conectado

---

# Acessibilidade

WCAG AA

TalkBack

VoiceOver

Touch Target

44x44px

Keyboard Navigation (tablets)

Focus Visible

Escala dinâmica

---

# Psicologia de Produto

## Peace of Mind

O aluno deve sentir segurança de que poderá estudar sem internet.

---

## Progress

Mostrar sempre:

- Quantidade baixada.
- Espaço restante.
- Cursos disponíveis.

---

## Organização

Agrupar automaticamente por:

- Curso
- Último acesso
- Mais assistidos
- Recentemente baixados

---

## Continuidade

Ao reconectar à internet:

- Sincronizar progresso.
- Atualizar licenças.
- Buscar novas versões.
- Enviar estatísticas.

Tudo em segundo plano.

---

# Critérios de Aceitação

- A página deve estar disponível apenas no aplicativo Android.
- Os vídeos devem permanecer criptografados utilizando HLS + DRM e armazenados exclusivamente no sandbox da aplicação.
- Nenhum arquivo MP4 ou mídia original deve ficar acessível ao usuário.
- O sistema deve suportar downloads resumíveis, pausáveis e atualizações diferenciais.
- O aluno deve visualizar espaço utilizado, progresso dos downloads e cursos disponíveis offline.
- Todo o progresso assistido offline deve ser sincronizado automaticamente quando houver conexão.
- A interface deve seguir integralmente o Lawrence Design System, utilizando Liquid Glass apenas em elementos flutuantes.
- A experiência deve transmitir a sensação de uma biblioteca offline premium, rápida, organizada e extremamente segura.