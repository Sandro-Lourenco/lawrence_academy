# Auditoria crítica da experiência do aluno

Data: 2026-08-10

Escopo: início, catálogo, detalhe do curso, decisão de compra e checkout

Critério: simplicidade, psicologia cognitiva, persuasão ética, acessibilidade e percepção de marca premium

## Veredito

A experiência é funcional, mas ainda não comunica uma academia de moda poderosa. Ela parece a soma de componentes competentes, não a expressão de uma marca única. Há três linguagens concorrentes — SaaS educacional azul, editorial preto/dourado e glassmorphism — e nenhuma domina o produto inteiro.

O principal problema não é falta de decoração. É falta de edição. Existem informação, bordas, ícones, chamadas e estilos demais competindo pela atenção. Marcas premium removem ruído, estabelecem ritmo e fazem poucas decisões parecerem inevitáveis.

Nota atual estimada:

| Dimensão | Nota | Diagnóstico |
| --- | ---: | --- |
| Clareza | 6/10 | As funções existem, mas a prioridade muda entre telas. |
| Beleza e assinatura | 5/10 | Há bons elementos isolados, sem direção visual totalmente coerente. |
| Facilidade de compra | 6/10 | O fluxo é seguro, porém excessivamente explicativo e pouco orientado a valor. |
| Persuasão ética | 5/10 | Benefícios concretos e prova estão fracos; segurança técnica ocupa espaço demais. |
| Consistência | 4/10 | Tokens, raios, cores e tipografia divergem entre documentação e implementação. |
| Acessibilidade | 7/10 | A base é boa, mas textos de 12–15 px e alguns contrastes/estados exigem revisão. |
| Percepção premium | 5/10 | O dourado é usado como estilo; ainda não como um sistema de significado. |

## Problemas críticos

### 1. A identidade visual está fragmentada

O sistema documental define azul de ação e navy de marca, enquanto a implementação recente transforma navy em ação primária e dourado em CTA global. A tipografia também migrou de SF Pro/Inter para Playfair Display/Montserrat. Isso pode ser uma boa direção editorial, mas hoje é uma ruptura sem regra clara.

Consequência psicológica: inconsistência aumenta a carga cognitiva e reduz a sensação de controle. O aluno não precisa identificar conscientemente a divergência; ele apenas sente que o produto é menos sólido.

Mudança:

- escolher uma direção canônica para a área do aluno;
- usar navy como estrutura e texto, branco/pergaminho como respiro e dourado somente para valor, marcos e momentos de decisão;
- evitar dourado em todo botão comum;
- reservar Playfair para títulos editoriais curtos e usar uma sans legível no conteúdo e nos controles;
- consolidar raio, borda, elevação e estado de foco em um único conjunto de tokens.

### 2. “Premium” está sendo confundido com efeito visual

Glass, sombras metálicas, bordas douradas e serifas não tornam o produto premium sozinhos. Quando aplicados sem hierarquia, tornam a interface teatral e menos moderna. Luxo contemporâneo é silêncio visual: proporção, tipografia, fotografia, matéria e acabamento.

Mudança:

- remover glass de cards repetidos e manter somente em navegação ou overlay funcional;
- reduzir sombras e bordas decorativas;
- criar grandes blocos de espaço negativo;
- usar fotografia de ateliê com enquadramento editorial consistente;
- permitir apenas um gesto visual forte por tela.

### 3. A Home ainda corre o risco de parecer dashboard

O aluno entra para continuar uma transformação profissional, não para administrar métricas. Resumos, atalhos e cards têm menos importância do que a próxima ação de aprendizagem.

Nova ordem:

1. “Continue de onde parou” com aula, duração restante e CTA único;
2. próximo compromisso real, somente se houver;
3. cursos ativos;
4. progresso e conquistas como evidência secundária;
5. descoberta de novos cursos fora do núcleo de retomada.

Remover da primeira dobra tudo que não responda a uma destas perguntas: “onde eu estava?”, “o que faço agora?” e “quanto falta?”.

### 4. O catálogo não conduz uma decisão

Um grid de cursos transfere o trabalho de comparação ao aluno. A Lei de Hick indica que opções sem estrutura aumentam o tempo de decisão. Filtros demais, cards com metadados equivalentes e preços sem contexto criam paralisia.

Mudança:

- começar com uma pergunta de intenção: “O que você quer dominar agora?”;
- oferecer poucas trilhas legíveis: começar do zero, aperfeiçoar técnica, criar coleção, profissionalizar carreira;
- mostrar filtros progressivamente, não todos de uma vez no mobile;
- diferenciar visualmente curso completo, curso rápido e workshop;
- limitar cada card a título, resultado, nível, carga horária, professor e preço mensal;
- tornar o card inteiro clicável apenas quando houver um único destino;
- usar “Ver formação” como ação neutra e reservar “Assinar curso” para o detalhe.

### 5. A página de curso informa, mas ainda vende pouco

A decisão de compra precisa reduzir cinco incertezas: “é para mim?”, “o que vou conseguir fazer?”, “quem ensina?”, “quanto esforço exige?” e “como funciona a cobrança?”. Hoje detalhes técnicos e avisos de segurança aparecem próximos do CTA, mas a transformação e a prova são insuficientes.

Nova arquitetura:

1. categoria e nível;
2. promessa específica, sem exagero;
3. imagem editorial do resultado ou processo;
4. professor e prova de autoridade verificável;
5. “ao final, você será capaz de…”;
6. projeto final ou resultado observável;
7. currículo em disclosure;
8. materiais e pré-requisitos;
9. preço mensal, recorrência e cancelamento em linguagem direta;
10. CTA persistente no mobile, sem esconder conteúdo.

Não inventar avaliações, número de alunos, escassez, contagem regressiva ou vagas limitadas. Persuasão deve vir de clareza, especificidade e prova real.

### 6. O checkout fala demais sobre segurança e pouco sobre a decisão

“Pagamento protegido”, “autorização validada” e explicações sobre Stripe são úteis, mas repetidas viram ansiedade induzida. Segurança deve tranquilizar silenciosamente, não sugerir que há algo a temer.

O resumo também usa “Total” para uma cobrança recorrente. Isso é semanticamente fraco: pode ser interpretado como preço único.

Mudança:

- título: “Revise sua assinatura”;
- linha financeira: “R$ X por mês”;
- texto adjacente: “Cobrança mensal deste curso. Cancele quando quiser; o acesso continua até o fim do período pago.”;
- CTA: “Continuar para o pagamento”;
- apresentar em uma única linha discreta: “Pagamento processado com segurança pelo Stripe”;
- eliminar ícones e textos repetidos que não alteram a decisão;
- manter o resumo e o CTA visíveis juntos no mobile;
- explicar claramente que cada curso possui assinatura própria;
- mostrar promoção somente quando houver preço original, preço vigente e período reais.

### 7. A microcopy ainda tem voz de sistema

Expressões como “autorização”, “elegibilidade”, “ambiente seguro”, “conteúdo liberado” e “assinatura indisponível” refletem o backend, não o modelo mental do aluno.

Princípio: a interface deve falar de aprender, continuar, praticar, concluir, pagar e cancelar. Termos técnicos pertencem a estados de suporte ou detalhes expandíveis.

Exemplos:

| Atual | Melhor |
| --- | --- |
| Verificando acesso ao curso | Confirmando sua assinatura… |
| Ir para pagamento seguro | Continuar para o pagamento |
| Curso indisponível | Este curso não está aceitando novas assinaturas agora |
| Gerenciar assinatura | Ver cobrança e cancelamento |
| Acesso liberado | Começar curso |

## Direção visual recomendada

Conceito: **Ateliê editorial contemporâneo**.

Não copiar Chanel, Hermès, Apple ou MasterClass. Adotar os princípios que fazem marcas fortes funcionarem: disciplina, reconhecimento imediato, qualidade de imagem, hierarquia e repetição consistente.

- Base: branco quente e pergaminho muito sutil.
- Estrutura: navy profundo, usado com parcimônia.
- Acento: dourado fosco, nunca amarelo brilhante em massa.
- Tipografia: serif editorial em títulos de campanha e sans funcional em todo o produto.
- Fotografia: textura de tecido, mãos, construção, moulage, detalhe e processo; evitar banco de imagem genérico.
- Cards: superfícies planas, borda silenciosa, raio coerente, sem sombra pesada.
- Motion: 180–280 ms, usado para continuidade, seleção e confirmação; respeitar reduce motion.
- Ícones: poucos, consistentes e sempre subordinados ao texto.

## Regras psicológicas aplicadas

- Lei de Hick: reduzir escolhas simultâneas e revelar filtros progressivamente.
- Lei de Fitts: CTA principal grande, próximo do conteúdo que motiva a ação e com alvo mínimo de 48 dp.
- Efeito de posição serial: colocar valor principal no início e preço/CTA no fechamento.
- Carga cognitiva: agrupar informação por decisão, não por disponibilidade de dados.
- Fluência cognitiva: usar linguagem curta e padrões repetidos; o que é fácil de compreender parece mais confiável.
- Efeito de progresso: mostrar avanço real e próximo passo, sem pontos ou sequências artificiais.
- Aversão à perda: não usar ameaça ou culpa; explicar de forma honesta o que acontece ao cancelar.
- Prova social: somente dados reais, verificáveis e relevantes.
- Peak-end rule: fazer o primeiro contato e a confirmação de compra serem os momentos mais bem acabados do fluxo.

## Plano de melhoria

### P0 — coerência e compra

- consolidar tokens e remover divergências entre fundação e tema;
- simplificar detalhe e checkout;
- tornar recorrência, cancelamento e assinatura por curso impossíveis de interpretar errado;
- corrigir textos menores que o padrão educacional de 17 px onde aplicável;
- validar contraste, foco, teclado e texto a 200%.

### P1 — descoberta e retomada

- redesenhar a primeira dobra da Home em torno da próxima aula;
- reorganizar catálogo por intenção e resultado;
- criar uma anatomia única de card de curso;
- padronizar fotografia e proporções de imagem;
- preservar filtros e scroll ao voltar do detalhe.

### P2 — acabamento de marca

- definir direção fotográfica e guidelines de conteúdo;
- adicionar transições discretas e estados de interação consistentes;
- criar golden tests nos breakpoints 360, 700, 1100 e 1440 px;
- instrumentar funil: catálogo → detalhe → checkout → pagamento → primeira aula.

## Critérios de aceite

- o aluno identifica a próxima ação da Home em até 3 segundos;
- preço mensal e recorrência são compreendidos sem abrir ajuda;
- nenhuma tela possui mais de uma ação primária por região visual;
- o fluxo catálogo → detalhe → checkout exige o mínimo de decisões intermediárias;
- toda informação persuasiva é factual e rastreável;
- todas as telas suportam teclado, foco visível, leitor de tela e texto a 200%;
- a linguagem visual permanece reconhecível em Home, catálogo, detalhe e checkout;
- nenhum efeito visual compromete 60 FPS ou leitura.

## Decisão recomendada

Não adicionar mais componentes agora. Primeiro consolidar a linguagem visual e remover ruído. A próxima implementação deve começar pelo checkout e pela página de curso, porque são os pontos onde clareza, confiança e receita se encontram; depois Home e catálogo.
