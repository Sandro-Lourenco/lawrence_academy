---
id: PAGE-STUDENT-008
name: Certificates
route: /dashboard/certificates
layout: StudentDashboardLayout
platforms:
  - Web
  - Android
roles:
  - Student
authentication: true
responsive: true
status: Production
design-system: Lawrence Design System
navigation: Sidebar + Bottom Navigation
state-management: Riverpod
architecture: Clean Architecture + DDD
security:
  ownership-required: true
  certificate-validation: true
---

# Certificates

## Objetivo

A página **Certificates** representa a conquista e reconhecimento do aluno dentro da Lawrence Academy.

Ela deve transformar o certificado em um momento emocional de conquista, transmitindo exclusividade, profissionalismo e valor percebido.

O certificado não deve parecer apenas um arquivo PDF.

Ele representa uma evolução profissional.

A experiência deve transmitir:

- Conquista.
- Prestígio.
- Progresso.
- Pertencimento.
- Autoridade profissional.

Inspirada em:

- Apple Education
- LinkedIn Learning Certificates
- MasterClass
- Coursera
- Apple Wallet
- Luxury Branding

---

# Objetivos

- Exibir certificados conquistados.
- Permitir visualização.
- Permitir compartilhamento.
- Permitir download seguro.
- Validar autenticidade.
- Mostrar cursos concluídos.
- Incentivar conclusão de novos cursos.

---

# Fluxo

```
Curso

↓

Aluno conclui 100%

↓

Sistema valida requisitos

↓

Certificado gerado

↓

Aluno recebe conquista

↓

Visualiza certificado

↓

Compartilha

↓

Continua aprendizado
```

---

# Layout Desktop

```
-------------------------------------------------------------

Glass Header

-------------------------------------------------------------

Sidebar

|

|

Certificate Hero

|

Certificados Conquistados

|

Cards

|

Cursos em Andamento

-------------------------------------------------------------
```

---

# Layout Mobile

```
Glass Header

↓

Resumo

↓

Certificados

↓

Card Certificado

↓

Compartilhar

↓

Cursos Pendentes

↓

Bottom Navigation
```

---

# Estrutura

```
Glass Header

↓

Certificate Hero

↓

Achievement Summary

↓

Earned Certificates

↓

Certificate Detail Modal

↓

Share Actions

↓

Verification

↓

Learning Progress

↓

Recommended Courses
```

---

# Glass Header

Sticky

72px

Liquid Glass

Blur:

20px

Opacity:

72%

---

Componentes:

- Logo
- Busca
- Notificações
- Perfil

---

# Certificate Hero

Área emocional da página.

Mostrar:

Nome do aluno.

Quantidade de certificados.

Cursos concluídos.

Horas estudadas.

Nível atual.

---

Exemplo:

```
Parabéns, Sandro!

Você conquistou

3 certificados

e completou

120 horas de aprendizado.
```

---

# Achievement Summary

Cards pequenos.

Mostrar:

## Certificados

Quantidade total.

---

## Cursos concluídos

Número.

---

## Horas estudadas

Tempo acumulado.

---

## Próxima conquista

Progresso.

---

# Certificates Grid

Desktop:

Grid 3 colunas.

---

Mobile:

Lista vertical.

---

Cada Certificate Card:

```
Imagem do certificado

Título do curso

Instrutor

Data conclusão

Carga horária

Código de validação

Botão visualizar
```

---

# Certificate Card Design

Premium.

Background:

White

Border:

Silver Mist

Radius:

24px

---

Elemento principal:

Selo dourado.

---

Uso de Gold:

Somente para:

- Conquistas.
- Selos.
- Badges.
- Certificados.

---

# Certificate Preview

Modal Fullscreen.

---

Mostrar:

Certificado completo.

Nome do aluno.

Curso.

Professor.

Data.

Assinatura digital.

Código único.

QR Code.

---

# QR Code

Permite validação pública.

Exemplo:

```
lawrenceacademy.com/verify/CERT-849302
```

---

# Compartilhamento

Ações:

Compartilhar LinkedIn.

Copiar link.

Enviar.

Salvar.

---

Mobile Android:

Usar Share API nativa.

---

# Download

Formatos:

PDF

Imagem

---

Web:

Download permitido.

---

Android:

Salvar no armazenamento protegido.

---

Arquivo gerado pelo backend.

Nunca gerar no cliente.

---

# Certificate Security

Cada certificado possui:

ID único.

Hash.

Assinatura digital.

QR Code.

Registro no banco.

---

Validar:

Usuário.

Curso.

Data.

Integridade.

---

# Courses In Progress

Mostrar cursos ainda não concluídos.

Objetivo:

Criar continuidade.

---

Card:

Imagem.

Título.

Progresso.

Aulas restantes.

Botão:

Continuar.

---

# Recommended Courses

Baseado em:

- Cursos concluídos.
- Categoria.
- Interesse.
- Histórico.

---

Exemplo:

```
Você concluiu Costura Básica.

Aprenda agora:

Modelagem Avançada.
```

---

# APIs

GET /certificates

GET /certificates/{id}

GET /certificates/{id}/verify

GET /certificates/{id}/download

GET /student/achievements

GET /courses/recommended

---

# Providers

certificatesProvider

certificateDetailProvider

achievementProvider

verificationProvider

recommendedCoursesProvider

---

# Componentes

GlassHeader

CertificateHero

AchievementCard

CertificateCard

CertificatePreview

QRCodeValidator

ShareButton

DownloadButton

ProgressCard

RecommendedCourseCard

SkeletonLoader

---

# Estados

## Loading

Skeleton Apple Style.

---

## Nenhum certificado

Mostrar:

```
Você ainda não possui certificados.

Continue estudando para conquistar sua primeira certificação.
```

CTA:

Explorar Cursos.

---

## Certificado disponível

Mostrar normalmente.

---

## Erro

Botão:

Tentar novamente.

---

# Motion

Entrada dos certificados:

Fade + Slide

---

Conquista:

Scale

Spring

---

Ao abrir certificado:

Hero Transition

---

QR Code:

Fade

---

# Liquid Glass

Aplicar apenas em:

- Glass Header.
- Floating Share Button.
- Floating Download Button.
- Modal Toolbar.
- Bottom Navigation.

---

Nunca aplicar em:

- Certificado.
- Documento.
- Texto.
- Cards principais.

---

# Tipografia

## Hero

48px

Bold

---

## Títulos

28px

Semibold

---

## Body

17px

Regular

---

## Metadata

13px

---

# Cores

## Base

60%

Pure White

#FFFFFF

---

## Interação

30%

Learning Blue

#0A84FF

---

## Premium

10%

Gold

#D4AF37

---

Sucesso

#30D158

---

Texto

#1D1D1F

---

# Responsividade

## Desktop

Sidebar fixa.

Grid de certificados.

Modal centralizado.

---

## Tablet

Grid 2 colunas.

---

## Mobile

Cards empilhados.

Preview fullscreen.

Share nativo.

Safe Area.

---

# Performance

Lazy Loading

Image Optimization

Cache

PDF carregado sob demanda

Skeleton

60 FPS

---

# Analytics

Quantidade certificados

Compartilhamentos

Downloads

Cursos concluídos

Tempo até certificação

Visualizações

---

# Segurança

Supabase Auth

JWT

HTTPS

OWASP Top 10

Ownership Guard

Certificate Validation

QR Code assinado

Links temporários

Proteção contra alteração

Auditoria

---

# Acessibilidade

WCAG AA

Keyboard Navigation

TalkBack

VoiceOver

Screen Reader

Touch Target

44x44px

Focus Visible

Alto contraste

Escala dinâmica

---

# Psicologia de Produto

## Endowment Effect

O certificado deve parecer uma conquista pessoal valiosa.

---

## Peak-End Rule

A conclusão do curso deve gerar uma experiência memorável.

Por isso:

- Animação de conquista.
- Destaque dourado.
- Mensagem positiva.
- Compartilhamento facilitado.

---

## Social Proof

Incentivar compartilhamento:

"Mostre sua nova habilidade profissional."

---

## Goal Gradient

Mostrar:

```
Faltam apenas 2 aulas para conquistar seu próximo certificado.
```

---

# Critérios de Aceitação

- O aluno deve visualizar todos os certificados conquistados.
- Cada certificado deve possuir validação pública através de QR Code.
- O sistema deve permitir visualizar, compartilhar e baixar certificados.
- O certificado deve possuir identidade premium seguindo o Lawrence Design System.
- O efeito Liquid Glass deve ser utilizado somente em elementos flutuantes.
- O uso do dourado deve ser exclusivo para conquistas e elementos premium.
- A experiência deve transmitir reconhecimento, evolução profissional e incentivo para continuar aprendendo.
- A página deve funcionar perfeitamente em Flutter Web e Android Native.
````
