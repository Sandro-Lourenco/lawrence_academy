# Lawrence

### Propósito da pasta

Esta pasta é destinada exclusivamente aos arquivos de "front-end" do projeto. Aqui ficam componentes, páginas, estilos, assets e toda a camada de apresentação da aplicação. temos t6ambem o prompt para

### Boas práticas com Harness

- Utilize feature flags para controlar o rollout de novas funcionalidades no front-end sem necessidade de novo deploy.
- Nunca faça deploy manual em ambiente de produção, utilize exclusivamente as pipelines do Harness.
- Mantenha as variáveis de ambiente sensíveis (API keys, tokens) gerenciadas como secrets no Harness, nunca no repositório.
