---
name: forms-and-api
trigger: scoped
scope: [flutter-forms, fastapi-input, authentication]
version: 2.0.0
---

# Formulários e integração de API

## Flutter

- Widgets cuidam de apresentação, foco e mensagens; controllers/providers coordenam submissão.
- Validação local melhora UX, mas o backend valida novamente todas as entradas.
- O botão evita submissões concorrentes enquanto a operação está em andamento. Operações mutáveis também usam idempotency key quando duplicidade tem impacto.
- Tokens são enviados por uma camada de rede central e nunca entram em logs, corpo do formulário ou mensagens de erro.
- Erros de campo, globais, timeout e indisponibilidade devem ser recuperáveis e acessíveis.

## FastAPI

- Requests e responses usam DTOs Pydantic com limites explícitos e política de campos extras adequada ao contrato. Imutabilidade é aplicada quando semanticamente necessária, não de forma universal.
- O servidor deriva identidade e tenant do JWT validado; IDs de recurso enviados pelo cliente continuam permitidos, mas sempre passam por verificação de ownership/permissão para impedir BOLA.
- Preserve texto do usuário quando fizer parte do domínio. Para prevenir XSS, valide formatos e encode/escape no contexto de renderização; regex não é sanitizador HTML.
- Rotas apenas adaptam HTTP. Use cases aplicam regras; repositories acessam dados.
- Respostas de erro seguem o contrato da API e incluem um correlation ID seguro. Stack trace e detalhes de infraestrutura ficam apenas em telemetria protegida.

## Testes mínimos

Validação de limites, double submit, timeout, token ausente/expirado, role incorreta, ownership de outro usuário, campos extras, caracteres Unicode e resposta inesperada do servidor.

