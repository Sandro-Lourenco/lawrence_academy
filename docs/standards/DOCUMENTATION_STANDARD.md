---
id: DOC-STANDARD-001
title: Padrão de documentação
status: active
owner: engineering
last_reviewed: 2026-07-21
review_cycle_days: 90
---

# Padrão de documentação

## Objetivo

Manter documentos claros, verificáveis, localizáveis e adequados para pessoas e agentes de IA.

## Classificação

Cada documento deve ter um único propósito principal:

- tutorial: ensina por uma jornada guiada;
- how-to: orienta uma tarefa real;
- referência: descreve contratos e fatos de forma objetiva;
- explicação: registra contexto, razões e trade-offs;
- especificação: declara comportamento normativo e critérios verificáveis;
- relatório: registra evidência datada, comandos executados e resultado.

Não misture plano, especificação e relatório no mesmo arquivo.

## Metadados mínimos

Documentos normativos novos devem declarar `id`, `title`, `status`, `owner`, `last_reviewed` e `review_cycle_days`. Valores válidos de `status`: `draft`, `active`, `deprecated`, `superseded` e `archived`. Um documento substituído deve apontar para `superseded_by`.

## Redação

- Use um único título H1 e hierarquia sem saltos.
- Escreva requisitos normativos com **DEVE**, **NÃO DEVE**, **DEVERIA** e **PODE**.
- Associe requisitos importantes a IDs estáveis e critérios de aceite observáveis.
- Diferencie estado `planejado`, `implementado` e `verificado`.
- Use links relativos para documentos locais e links diretos para fontes externas.
- Não declare teste, build, auditoria ou conformidade como concluído sem evidência reproduzível.
- Evite texto promocional, absolutos sem métrica e listas decorativas.

## Especificações de página

Toda Page Spec ativa deve conter: identificador, rota, atores, objetivo do usuário, pré-condições, fluxo principal, estados `loading/empty/error/offline/success`, permissões, acessibilidade, responsividade, eventos analíticos, contratos consumidos e critérios de aceite. Referências visuais são inspiração, não requisito verificável.

## Governança

- O owner revisa o documento no ciclo indicado.
- Links, frontmatter e Markdown devem ser validados no CI.
- Relatórios são append-only; correções materiais recebem errata.
- Segredos, tokens, dados pessoais reais e URLs privadas nunca entram em exemplos.
- Uma ADR registra contexto, decisão, alternativas, consequências e status.

