---
id: PAGE-STUDENT-023
name: Student Project Detail
route: /dashboard/projects/:projectId
layout: StudentDashboardLayout
platforms: [Web, Android]
roles: [Student]
authentication: true
responsive: true
status: Implemented
---

# Detalhe do projeto do aluno

## Objetivo

Apresentar o contexto confirmado de um projeto vinculado a curso sem expor
dados de outra atividade e sem oferecer mutações ainda não autorizadas.

## Contrato implementado

- título;
- curso;
- responsável;
- status com ícone e texto;
- prazo, quando existente;
- nota e feedback, quando existentes.

O projeto é localizado na coleção autorizada do aluno e precisa possuir
`ActivityType.project`. Um identificador ausente ou pertencente a outro tipo de
atividade produz o mesmo estado indisponível para evitar enumeração de dados.

## Estados

- loading: anúncio semântico durante a resolução;
- success: conteúdo em uma coluna no mobile e painel 2:1 no desktop;
- unavailable: mensagem neutra, sem revelar existência ou ownership;
- error: mensagem humana e nova tentativa;
- empty e offline: herdados do carregamento da coleção de atividades.

## Limites desta fase

Etapas, anexos, uploads, fotos, notas editáveis, autosave, rubricas e
compartilhamento dependem de contratos de API, RLS e validação de arquivos que
não estão confirmados. Esses controles não são simulados.

## Critérios de aceite

- A rota exige autenticação pelo guard de `/dashboard`.
- Somente um item autorizado do tipo projeto pode ser apresentado.
- A página não permite edição ou submissão sem contrato.
- Status não depende apenas de cor.
- Controles possuem tooltip e alvo mínimo definido pelo tema.
- O layout preserva leitura em mobile, tablet e desktop.
