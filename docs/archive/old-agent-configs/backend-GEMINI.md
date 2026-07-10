# Backend

### Propósito da pasta

Esta pasta é destinada exclusivamente aos arquivos de "back-end" e microsserviços do projeto. Aqui ficam as regras de negócio, APIs, integrações, gerenciamento de banco de dados e toda a lógica de processamento do servidor da aplicação.

### Boas práticas com Harness

- Sempre escreva testes unitários e de integração utilizando o Harness antes de considerar uma feature completa.
- Nunca faça deploy manual em ambiente de produção, utilize exclusivamente as pipelines do Harness.
- Mantenha as variáveis de ambiente sensíveis (API keys, tokens) gerenciadas como secrets no Harness, nunca no repositório.
