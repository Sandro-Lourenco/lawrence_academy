---
name: create-api
description: Criar ou alterar APIs FastAPI, DTOs, use cases, repositories e contratos HTTP da Lawrence Academy.
version: 2.0.0
---

# Create API

## Entradas

Requisito aprovado, contrato atual, regra de permissão, modelo de dados e critérios de aceite.

## Procedimento

1. Ler PED, arquitetura, `SERVICE_API.md`, contratos, schema e segurança relevantes.
2. Confirmar consumidor, método, path, auth, request, response, erros, paginação e idempotência.
3. Implementar adapter HTTP -> use case -> porta de repository -> adapter de infraestrutura.
4. Validar identidade, permission/ownership e entrada no servidor; não expor modelo de persistência.
5. Adicionar testes de use case, contrato, auth, permission, erro e integração proporcionais ao risco.
6. Atualizar API/contratos e executar reviews aplicáveis.

## Saída

Arquivos alterados, contrato final, evidência de testes e riscos residuais.

