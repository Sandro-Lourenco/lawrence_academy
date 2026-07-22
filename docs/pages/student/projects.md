---
id: PAGE-STUDENT-022
name: Student Projects
route: /dashboard/projects
layout: StudentDashboardLayout
platforms: [Web, Android]
roles: [Student]
authentication: true
responsive: true
status: Draft
---

# Projetos do aluno

## Implementação canônica — fase da área de Projetos

A implementação em `features/activities/presentation/pages/projects_page.dart`
é a referência atual para a tela principal de Projetos. Ela filtra o contrato
de atividades por `ActivityType.project`, usa a estrutura autenticada do aluno
e não fabrica conteúdo para reproduzir as imagens de referência.

O provider de carregamento permanece injetável e retorna uma coleção vazia até
que a API documente um endpoint de leitura para atividades do aluno. A API atual
documenta criação e submissão, mas não uma consulta compatível com esta tela.

Desafios, inspirações, criação livre, detalhes editáveis, fotos e
compartilhamento continuam fora desta fase por ausência de contratos e regras de
permissão. Essa limitação é deliberada e evita exposição ou mutação indevida de
dados do aluno.

## Objetivo

Reunir projetos avaliativos vinculados aos cursos do aluno, permitindo
identificar status, curso de origem, prazo e próximo passo.

## Escopo inicial

- Exibir somente atividades cujo tipo canônico seja `project`.
- Reutilizar o provider e as permissões existentes de atividades.
- Não permitir criar projeto livre, publicar, compartilhar, adicionar fotos ou
  editar etapas até existirem contratos e regras de autorização próprios.

## Estados

- loading: indicador com anúncio semântico;
- success: lista ou grid responsivo;
- empty: explicar que projetos são liberados pelos cursos;
- error: mensagem humana e ação para tentar novamente;
- offline: apresentar cache quando disponível e indicar o estado;
- blocked: não renderizar dados parciais sem autorização.

## Responsividade e acessibilidade

- Mobile em uma coluna, tablet em duas e desktop em até três.
- Área de toque mínima de 48 dp e foco visível.
- Status comunicado por ícone e texto.
- Conteúdo funcional com escala de texto de 200%.

## Critérios de aceite

- A rota exige autenticação.
- Apenas itens `ActivityType.project` são exibidos.
- A tela não oferece ações sem contrato implementado.
- Loading, empty e error possuem mensagem e próximo passo.
- A grade adapta colunas sem reduzir texto.
