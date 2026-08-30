# Alunos do curso

## Objetivo

Permitir que o professor consulte, dentro de cada curso, quem possui acesso e qual é o progresso de cada aluno.

## Rota

`/teacher/courses/:courseId/students`

## Acesso

- `teacher`: somente cursos de sua autoria.
- `super_admin`: qualquer curso.
- Demais papéis: bloqueados no backend e no roteamento autenticado.

## Conteúdo

- Quantidade de alunos cadastrados.
- Nome e e-mail.
- Situação do acesso: ativo, gratuito, pagamento pendente ou cancelado.
- Aulas concluídas, total de aulas e percentual de progresso.

## Estados obrigatórios

- Carregando com descrição semântica.
- Vazio quando ainda não existem matrículas ou progresso.
- Erro com nova tentativa.
- Lista responsiva em cartão compacto no celular e linha ampliada no desktop.

## Segurança e desempenho

O backend verifica a propriedade do curso antes de consultar matrículas. Assinaturas, perfis e progresso são carregados em consultas em lote, evitando N+1. A consulta de assinaturas possui índice parcial por curso para registros não removidos.
