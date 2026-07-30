---
id: PAGE-STUDENT-CATALOG
name: Explore Catalog
route: /dashboard/courses
roles:
  - Student
authentication: true
responsive: true
status: implemented
state-management: Riverpod
---

# Explore Catalog

O catálogo usa exclusivamente cursos publicados retornados por
`GET /api/v1/courses`. Busca e filtros por acesso, categoria, nível e tipo de
conteúdo são serializados na URL, permitindo recarregar ou compartilhar a
mesma visão.

## Livros Lawrence

A superfície editorial de livros está pronta no catálogo. Como ainda não
existe tabela nem contrato de livros no `SERVICE_API`, ela exibe
“Biblioteca em preparação” e não apresenta capas, autores ou títulos
fictícios.

## Estados e responsividade

- loading com skeleton;
- erro/offline com retry;
- vazio com ação para limpar filtros;
- uma coluna no mobile, duas no tablet e três no desktop;
- transições curtas são removidas quando `disableAnimations` está ativo;
- CTAs primários são azuis, retangulares e têm alvo mínimo acessível.
