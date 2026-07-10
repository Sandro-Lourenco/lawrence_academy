---
trigger: always_on
---



---

# Diretrizes de Arquitetura DDD — Lawrence Academy

Este documento estabelece as regras táticas e estratégicas de design baseadas na Referência Oficial de Eric Evans. Todo o time de desenvolvimento deve seguir rigorosamente estas nomenclaturas, divisões e restrições de código para evitar o acoplamento excessivo e a degradação do software em uma "Grande Bola de Lama".

---

## 1. Design Estratégico & Linguagem Onipresente

O ecossistema da Lawrence Academy opera sob um único **Contexto Delimitado (Bounded Context)** unificado. Para garantir um design flexível e rico em conhecimento, a comunicação do time, os arquivos de documentação, os endpoints do código e os esquemas do banco de dados devem falar a mesma **Linguagem Onipresente**.

### Tabela de Tradução de Termos (Dicionário de Domínio)

| Termo de Negócio | Nome no Código (Correto) | Termo Proibido (Genérico) |
| --- | --- | --- |
| Aluno / Professor | `profile` / `profiles` | `user` / `member` |
| Aula (Conteúdo em vídeo) | `lesson` / `lessons` | `video` / `media` |
| Resumo Gerado por IA | `ai_summary` | `text_summary` / `ai_data` |
| Envio de Exercício | `task_submission` | `user_answer` / `resposta` |

> ⚠️ **Regra de Ouro:** Qualquer alteração na nomenclatura da fala ou do negócio exige uma refatoração imediata no código (classes, tabelas e métodos) para manter o modelo alinhado.
> 
> 

---

## 2. Blocos de Construção Táticos (Camada de Domínio)

Seguindo o princípio da **Arquitetura em Camadas**, isolamos completamente a lógica de negócios e o modelo de domínio de qualquer dependência de infraestrutura, interface de usuário ou persistência de banco de dados bruta.

### A. Entidades (Entities)

Objetos que possuem uma linha de identidade contínua que atravessa o tempo e o ciclo de vida, independentemente de mudanças em seus atributos.

* 
**Identificação:** Devem ser identificadas unicamente por uma chave imutável do tipo `UUID` gerada nativamente no banco de dados.


* **Regra no Projeto:** Tabelas como `public.profiles`, `public.courses` e `public.lessons` são Entidades.
* 
**Restrição de Código:** As classes de Entidades devem manter o foco na continuidade do ciclo de vida, delegando computações acessórias para funções auxiliares.



### B. Objetos de Valor (Value Objects)

Objetos que descrevem ou calculam características do domínio sem possuir identidade conceitual própria.

* 
**Imutabilidade:** São estritamente imutáveis. Toda modificação resulta na criação de uma nova instância.


* **Regra no Projeto:** O campo `ai_summary` da tabela `lessons` (contendo o JSON estruturado com o resumo executivo, passos da costura e glossário) é um Objeto de Valor.
* **Regra no Python (FastAPI):** Mapeados via esquemas do Pydantic configurados com `frozen=True` ou imutabilidade estrita.

### C. Agregados (Aggregates) & Raízes de Agregados

Grupos de Entidades e Objetos de Valor associados que devem ser tratados como uma única unidade de consistência transacional.

* 
**Raiz do Agregado (Aggregate Root):** É a única Entidade que possui acesso global e referências externas diretas. Objetos de fora do agregado nunca referenciam membros internos diretamente.


* **Limite do Agregado `Course`:** `courses` é a Raiz do Agregado de Conteúdo. Os objetos `modules` e `lessons` pertencem ao limite interno deste agregado.
* 
**Consistência Síncrona vs Assíncrona:** Regras e invariantes de integridade dentro do Agregado (ex: a ordem dos módulos de um curso) são validadas de forma estritamente síncrona. Atualizações ou impactos fora do limite do agregado (ex: gerar um certificado após concluir as lições) ocorrem de forma assíncrona.



### D. Serviços de Domínio (Domain Services)

Operações, processos ou transformações significativas do negócio que não pertencem naturalmente a uma Entidade ou Objeto de Valor específico.

* 
**Contrato Declarativo:** São definidos como interfaces ou funções autônomas que expressam o "o quê" o sistema faz, e não o "como".


* **Regra no Projeto:** O microsserviço Python/FastAPI de processamento de mídia (conversão HLS com FFmpeg, extração de texto via Whisper e estruturação cognitiva via Gemini) atua estritamente como um Serviço de Domínio de processamento de conteúdo assíncrono.

---

## 3. Práticas para um Design Flexível e Declarativo

Para garantir que o código seja adaptável e não seja sobrecarregado pelo próprio legado, aplicamos os seguintes padrões de clareza conceitual:

1. 
**Interfaces Reveladoras de Intenção:** Nomes de classes, tabelas, métodos e rotas devem descrever explicitamente seus efeitos, propósitos e pós-condições, sem expor as entranhas de como a lógica é resolvida internamente.


2. 
**Funções Livres de Efeitos Colaterais:** Toda computação complexa de validação de tarefas, progresso e notas deve ser isolada em funções puras (que retornam resultados idênticos sem alterar o estado do sistema de forma oculta). Modificações de estado (comandos) devem ser separadas em rotas de persistência direta.


3. 
**Uso Seguro de Repositórios:** O acesso ao banco de dados Supabase é encapsulado pelos Repositórios locais, que fornecem ao código a ilusão de uma coleção em memória. Consultas diretas não devem expor ou alterar propriedades internas de objetos de dentro de um agregado sem passar pela raiz correspondente, evitando a quebra de encapsulamento.



---
