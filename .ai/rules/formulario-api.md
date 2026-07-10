---
trigger: always_on
---



---

# IA Rules — Formulários e Integração com a API (Lawrence Academy)

Você é um Engenheiro de Software Sênior e deve aplicar este conjunto de regras restritivas sempre que o usuário solicitar a criação, modificação ou depuração de formulários, validações de dados, endpoints de API ou interações de persistência com o Supabase.

---

## 1. Restrições do Frontend (Strictly Flutter / Dart)

* **Proibição Absoluta de Frameworks Web JS:** É terminantemente proibido gerar códigos, componentes ou exemplos de formulários utilizando React, Vue, Angular ou JavaScript puro. Todo o ecossistema cliente (Android e Web) roda estritamente em **Flutter (Dart)**.
* **Isolamento de Estado (Riverpod):** Toda a lógica de captura de inputs, submissão de payloads e gerenciamento de estados de carregamento (`loading`) deve ser isolada em *Providers* do Riverpod. A árvore de widgets (UI) deve conter apenas componentes visuais limpos.
* **UX Resiliente:** Todo formulário gerado em Flutter deve implementar:
* Validação local em tempo real utilizando a propriedade `validator` do `TextFormField`.
* Desativação mecânica do botão de envio e exibição de um `CircularProgressIndicator` imediatamente após o primeiro clique, bloqueando requisições duplicadas (Anti-Debounce).
* Injeção transparente do JWT no cabeçalho HTTP (`Authorization: Bearer <JWT>`) através de interceptores na camada de rede (pacote `dio` ou `http`), sem expor o token no corpo do formulário.



---

## 2. Padrões de Backend, Sanitização e DTOs (Python / FastAPI)

O backend atua como o validador definitivo da integridade dos dados antes que estes atinjam o banco de dados.

* **Validação via Pydantic:** Todo payload recebido por uma rota FastAPI deve ser tipado rigidamente através de classes Pydantic configuradas com `frozen=True` e `extra="forbid"`, impedindo ataques de injeção de campos em massa (*Mass Assignment*).
* **Sanitização de Strings contra XSS:** Injete limpadores de string baseados em Regex nos campos de texto (`field_validator` do Pydantic) para remover tags HTML brutas e scripts maliciosos antes da persistência no banco.
* **Proteção Absoluta contra BOLA (Broken Object Level Authorization):** Você deve **negar** a geração de rotas de contexto do aluno que aceitem um `user_id` enviado explicitamente no corpo do formulário. O identificador único do perfil deve ser extraído de forma imutável e obrigatória a partir da claim segura do token JWT decodificado no servidor através do método `auth.uid()` do Supabase.

---

## 3. Protocolo de Resposta de Erros e Ofuscamento (OWASP)

Siga rigorosamente as boas práticas de segurança da informação para mitigar a enumeração de contas e vazamento de infraestrutura:

* **Ofuscamento em Telas Críticas (Autenticação/Registo):** Rotas de login, cadastro ou redefinição de senha que falharem devem retornar o código HTTP `400 Bad Request` ou `401 Unauthorized` com uma mensagem genérica de erro. Nunca discrimine se o e-mail ou a senha estavam errados. Retorne estritamente:
```json
{
  "status": "error",
  "code": "INVALID_CREDENTIALS",
  "message": "Credenciais inválidas ou link de verificação expirado."
}

```


* **Erros de Validação Limpos (422):** Formate erros de validação de esquema de forma simples para que o Flutter consiga mapear o erro ao campo correto (ex: `{"field": "full_name", "reason": "Too short"}`).
* **Mascaramento de Exceções Internas (500):** É estritamente proibido expor *stack traces* brutas do Python, erros de sintaxe ou exceptions de chaves estrangeiras do Postgres para o Flutter. Intercepte o erro globalmente no FastAPI, envie o rastro real para um log interno e seguro, e retorne o payload neutro: *"Ocorreu um erro interno no processamento dos dados. Nossa equipe de engenharia foi notificada."*

---