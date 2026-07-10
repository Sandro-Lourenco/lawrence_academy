# Spec

### Propósito da pasta

Esta pasta é destinada exclusivamente a "Especificações técnicas e PRDs" (Product Requirement Document) do projeto. Aqui ficam os documentos que descrevem funcionalidades, fluxos, regras de negócio e critérios de aceite.

### Boas práticas com Harness

- Toda especificação aprovada deve ter seu ciclo de vida rastreado por uma pipeline no Harness, sinalizando quando passou de rascunho para aprovado.
- Use o Harness para acionar notificações automáticas ao time quando um novo PRD for adicionado ou atualizado nesta pasta.
- Integre as pipelines do Harness com o processo de review: nenhuma que entra em produção sem aprovação documentada e rastreada.
- Mantenha versionamento explícito nos documentos; o Harness deve acionar alertas em caso de alterações não revisadas em specs aprovados.
- Pipelines de validação no Harness devem verificar se toda spec possui objetivos, critérios de aceite, stakeholders e data de revisão.

### Convenções desta pasta

- Nomeie os arquivos no padrão: YYYY-MM-DD_nome-da-feature.md
- Todo PRD deve conter as seções: Objetivos, Contexto, Requisitos funcionais, Requisitos não funcionais, Critérios de aceite e Stakeholders.
- Especificações técnicas devem referenciar os componentes do front-end correspondentes em /hermes quando aplicável.
- Documentos obsoletos devem ser movidos para /spec/archive, nunca deletados diretamente.
