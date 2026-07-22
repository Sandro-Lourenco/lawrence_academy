# QA integrado — experiência do aluno

Data: 21/07/2026
Escopo: Home, catálogo, curso público, projetos, detalhe do projeto,
conquistas, perfil/configurações, curso adquirido e aula/player.

## Resultado

- `flutter analyze --no-pub`: zero ocorrências após correções.
- `flutter test --no-pub`: 104 testes aprovados.
- Rotas principais autenticadas permanecem sob o guard de `/dashboard`.
- Rotas públicas de curso usam o padrão canônico `/courses/:slug`.

## Correções realizadas na consolidação

1. Removido `const` inválido no estado de elegibilidade do curso público.
2. Atualizada a serialização de filtros para elementos nulos seguros do Dart.
3. Ajustado callback de atualização da Home para assinatura explícita.
4. Corrigida a atualização do provider de Perfil sem descartar resultado.
5. Adicionado ancestral `Material` ao catálogo quando embutido.
6. Unificada a leitura semântica de badges e progresso com
   `excludeSemantics`, eliminando rótulos duplicados.

## Falhas encontradas e resolvidas

A primeira execução da suíte teve 98 aprovações e três falhas:

- catálogo público embutido sem ancestral `Material`;
- label semântico duplicado no badge de status;
- label semântico duplicado no indicador de progresso.

Os três cenários foram corrigidos, reexecutados isoladamente e depois
validados novamente na suíte completa.

## Limites ainda dependentes de produto e backend

- leitura real de projetos do aluno;
- gamificação e conquistas;
- edição de perfil e preferências;
- etapas, anexos, fotos e compartilhamento de projetos;
- materiais, comentários e anotações da aula;
- controles avançados do player, incluindo legenda, qualidade e tela cheia.

Essas capacidades não são simuladas na interface. Cada uma exige contrato de
API, autorização/RLS, estados e testes próprios antes de ser habilitada.
