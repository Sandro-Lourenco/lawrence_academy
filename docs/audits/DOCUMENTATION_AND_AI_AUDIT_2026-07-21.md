---
id: AUDIT-DOC-AI-2026-07-21
title: Auditoria de documentação e sistema de agentes
status: completed
owner: engineering
date: 2026-07-21
scope: docs-and-ai-configuration
---

# Auditoria de documentação e sistema de agentes

## Escopo e método

Foram inventariados 185 arquivos Markdown em `docs/` (aproximadamente 1,05 MB) e 25 arquivos originais em `.ai/`, incluindo workflows, skills, personas, reviews e rules. A análise verificou estrutura, metadados, hierarquia de títulos, code fences, referências, duplicidade de autoridade, coerência técnica e adequação para agentes.

Relatórios e arquivos arquivados foram lidos como evidência histórica, não como estado normativo. A auditoria não declara que a implementação corresponde às specs; isso exige uma auditoria separada de rastreabilidade código-documentação.

## Resultado executivo

O conteúdo cobre o produto de forma ampla, mas a documentação não estava pronta para funcionar como fonte confiável de agentes. O problema principal não era falta de texto: era excesso de documentos sem classificação, autoridade concorrente, instruções impossíveis de verificar e configurações de IA que confundiam persona, skill, workflow e review.

## Achados principais

### Críticos

- A precedência antiga colocava o prompt do usuário abaixo do código e da documentação, o que podia desviar o objetivo autorizado.
- Regras prescreviam controles inseguros ou ineficazes: “sanitização XSS por regex”, anti-tampering por DOM com logout forçado e anonimização de PII por regex como garantia.
- A camada de IA tratava personas (`@security-engineer`, `@qa-engineer`) e workflows como comandos/skills, sem contrato de execução real.

### Altos

- `AGENTS.md` apontava para `docs/design/design-system.md`, mas o arquivo canônico é `docs/design/DESIGN_SYSTEM.md`.
- Havia nomes incorretos: `security-engineery.md`, `arcteture-ddd.md` e `RULES.md.md`.
- A regra DDD afirmava um único bounded context enquanto o PED e a arquitetura descrevem vários contextos/módulos.
- Workers de mídia/IA eram classificados automaticamente como Domain Services, confundindo capacidade de negócio com processo de infraestrutura.
- `soft delete` era universal, em conflito potencial com minimização/elimção de dados pessoais e com ciclos de vida diferentes.
- Supabase/RLS era descrito de modo incompleto: RLS e grants são controles distintos; `TO authenticated` sem ownership não impede BOLA; UPDATE demanda policies compatíveis de SELECT e `WITH CHECK` quando aplicável.

### Médios

- Muitas Page Specs usam dezenas de H1; o padrão deve ser um H1 e seções H2/H3.
- Pelo menos 17 documentos apresentaram contagem ímpar de code fences no scanner estrutural e precisam de revisão editorial individual.
- Várias specs misturam requisito, inspiração visual, tutorial e explicação.
- `docs/refactor/`, relatórios na raiz e specs canônicas competiam pela percepção de “estado atual”.
- Metas como “60 FPS”, “API < 300 ms” e “TTFF < 500 ms” não declaram dispositivo, rede, dataset, percentil ou janela de medição.
- O arquivo `docs/pages/public/HMOE.md` aparenta erro de nome e deve ser renomeado somente após verificar consumidores.

## Correções aplicadas

- Criados catálogo e padrão editorial em `docs/README.md` e `docs/standards/`.
- Criada especificação de agentes com manager/orchestrator, menor privilégio, aprovação humana, guardrails, evals e auditoria.
- Reescritos o orquestrador, regras, cinco personas originais, cinco skills, quatro workflows e três reviews originais.
- Adicionados Orchestrator, DevOps/SRE, Documentation Engineer, QA Review, Performance Review e Release Review.
- Criados arquivos canônicos com grafia correta e stubs de compatibilidade para nomes antigos.
- Corrigida a referência do Design System em `AGENTS.md`.
- Criado um template uniforme para Page Specs.

## Backlog recomendado

1. Migrar as 67 Page Specs para o template, preservando semântica e corrigindo hierarquia/fences em lotes por área.
2. Consolidar relatórios soltos da raiz em uma taxonomia datada sem mover arquivos que ainda tenham consumidores.
3. Adicionar CI com markdownlint, validação de links, frontmatter e IDs duplicados.
4. Criar ADRs para bounded contexts, autoridade backend/Supabase, estratégia offline, pagamentos e pipeline de mídia/IA.
5. Executar rastreabilidade Page Spec -> rota Flutter -> endpoint -> contrato -> tabela/policy -> teste.
6. Substituir status “Production Ready” por evidência e data de verificação.

## Referências externas usadas

- [Diátaxis](https://diataxis.fr/): separa tutorial, how-to, referência e explicação.
- [Google Technical Writing](https://developers.google.com/tech-writing): clareza e escrita técnica para engenharia.
- [AGENTS.md](https://agents.md/): arquivo previsível de instruções para agentes.
- [OpenAI — A practical guide to building agents](https://openai.com/business/guides-and-resources/a-practical-guide-to-building-ai-agents/): manager pattern, handoffs e guardrails em camadas.
- [OpenAI Agents SDK — orchestration](https://openai.github.io/openai-agents-python/multi_agent/): escolha entre agentes como ferramentas e handoffs.
- [NIST AI RMF](https://www.nist.gov/itl/ai-risk-management-framework): governança e gestão de risco de IA.
- [Supabase RLS](https://supabase.com/docs/guides/database/postgres/row-level-security): RLS em schemas expostos e policies por linha.

