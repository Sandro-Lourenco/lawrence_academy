---
name: Lawrence Accessibility Specification
version: 1.0.0
type: Accessibility & Inclusive Design Specification
status: Production Ready

platforms:
  - Flutter Android
  - Flutter Web

framework:
  - Flutter
  - Dart

standards:
  - WCAG 2.2 AA
  - Material Accessibility
  - Apple Accessibility

assistive_technologies:
  - TalkBack
  - VoiceOver
  - Screen Readers
  - Keyboard Navigation

depends_on:
  - docs/design/DESIGN_SYSTEM.md
  - docs/design/UI_UX_FRONTEND_SPEC.md
  - docs/design/COMPONENTS.md
  - docs/design/ANIMATIONS.md

related_skills:
  - ui-ux-designer
  - flutter-architect
  - qa-engineer
  - review-code
---

# Accessibility Specification

# 1. Objetivo

Garantir que todas as interfaces possam ser utilizadas por qualquer pessoa.

Incluindo usuários com:

- baixa visão;
- cegueira;
- daltonismo;
- limitações motoras;
- dificuldades cognitivas;
- sensibilidade a movimento;
- uso somente por teclado;
- leitores de tela.

Acessibilidade não é uma etapa final.

Ela faz parte do design.

---

# 2. Princípio principal

Toda interface deve funcionar:

```text
sem visão

sem mouse

sem áudio

com texto ampliado

com conexão ruim

com limitações motoras
```

Se uma funcionalidade depende somente de uma condição perfeita, ela deve ser revisada.

---

# 3. Regras obrigatórias

Toda página precisa validar:

```text
[ ] Contraste

[ ] Texto escalável

[ ] Navegação por teclado

[ ] Leitor de tela

[ ] Ordem de foco

[ ] Estados claros

[ ] Área de toque

[ ] Mensagens compreensíveis
```

---

# 4. Contraste

Seguir:

```text
WCAG AA
```

Mínimo:

```text
Texto normal:
4.5 : 1

Texto grande:
3 : 1

Componentes:
3 : 1
```

Nunca usar:

```text
cinza muito claro

texto transparente

opacidade baixa em informação importante
```

---

# 5. Cores

Nunca comunicar apenas usando cor.

Errado:

```text
Campo vermelho
```

Correto:

```text
Ícone

Texto

Mensagem

Cor
```

Exemplo:

```text
❌ Pagamento falhou


✔ Pagamento falhou
Não conseguimos processar seu cartão.
Tente novamente.
```

---

# 6. Baixa visão

Priorizar:

- contraste;
- tamanho confortável;
- espaçamento;
- clareza;
- foco visível.

Evitar:

- fonte pequena;
- excesso de transparência;
- blur atrás de texto;
- informações apenas por ícone.

---

# 7. Tipografia

Obrigatório:

- suportar aumento de fonte;
- evitar overflow;
- preservar hierarquia;
- manter leitura confortável.

Nunca corrigir layout reduzindo fonte.

Corrija:

- espaçamento;
- quebra;
- layout responsivo.

---

# 8. Text Scaling

Flutter deve suportar:

```dart
MediaQuery.textScalerOf(context)
```

Testar:

```text
100%

150%

200%
```

Nenhuma tela deve quebrar.

---

# 9. Touch Target

Área mínima:

```text
48 x 48 dp
```

Aplica-se:

- botões;
- ícones;
- menus;
- cards clicáveis;
- controles de vídeo.

---

# 10. Semantics Flutter

Todo elemento importante precisa de:

```dart
Semantics()
```

Exemplo:

```dart
Semantics(
 label:"Continuar aula",
 button:true,
 child: button,
)
```

Obrigatório em:

- botões customizados;
- ícones;
- cards clicáveis;
- controles;
- player;
- gráficos.

---

# 11. Imagens

Toda imagem informativa precisa descrição.

Exemplo:

```dart
Image.network(
 url,
 semanticLabel:
 "Foto do professor do curso",
)
```

Imagem decorativa:

```dart
ExcludeSemantics()
```

---

# 12. Ícones

Ícones importantes precisam:

```text
Ícone

+

Texto ou Semantics
```

Evitar:

```text
apenas ícone desconhecido
```

---

# 13. Formulários

Obrigatório:

- label visível;
- erro próximo do campo;
- indicação obrigatória;
- foco correto;
- teclado correto;
- autofill.

Nunca:

```text
placeholder como único label
```

---

# 14. Mensagens de erro

Erro deve explicar:

```text
O que aconteceu?

Como resolver?
```

Não mostrar:

```text
Exception

Stacktrace

Erro SQL
```

Exemplo correto:

```text
Não conseguimos salvar.

Verifique sua conexão e tente novamente.
```

---

# 15. Navegação por teclado

Flutter Web deve permitir:

- TAB;
- SHIFT + TAB;
- ENTER;
- ESC;
- setas quando aplicável.

Obrigatório:

```text
Foco visível
```

---

# 16. Focus Management

Após:

- abrir dialog;
- abrir bottom sheet;
- mudar página;
- erro de formulário;

o foco deve ir para o elemento correto.

Ao fechar modal:

voltar para onde estava.

---

# 17. Dialogs

Obrigatório:

- título claro;
- foco preso dentro;
- ESC fecha quando permitido;
- botão principal evidente.

Ações destrutivas:

precisam confirmação explícita.

---

# 18. Motion Accessibility

Respeitar:

```dart
MediaQuery.disableAnimationsOf(context)
```

Quando ativo:

reduzir:

- slide;
- zoom;
- parallax;
- hero;
- stagger.

Manter:

- feedback essencial.

---

# 19. Vídeo

Player precisa:

- legenda;
- controles acessíveis;
- teclado;
- descrição;
- foco visível.

Atalhos:

```text
Espaço:
Play/Pause

Setas:
Controle

ESC:
Sair fullscreen
```

---

# 20. Áudio

Não depender apenas de som.

Toda informação sonora precisa alternativa:

- texto;
- legenda;
- indicação visual.

---

# 21. Loading

Leitor de tela deve entender:

```text
Carregando cursos
```

Não apenas:

```text
spinner
```

---

# 22. Empty State

Deve informar:

```text
O que aconteceu

Por quê

Próxima ação
```

---

# 23. Gráficos

Todo gráfico precisa:

- título;
- descrição;
- resumo textual.

Exemplo:

```text
Vendas aumentaram 20% nos últimos 30 dias.
```

---

# 24. Tabelas

Obrigatório:

- cabeçalhos;
- ordem lógica;
- navegação por teclado;
- filtros acessíveis.

---

# 25. Offline

Não usar apenas:

```text
ícone vermelho
```

Usar:

```text
Você está offline.

Mostrando dados salvos.
```

---

# 26. Estados obrigatórios

Cada tela deve ter:

```text
Loading

Success

Empty

Error

Offline
```

Todos acessíveis.

---

# 27. Testes obrigatórios

Executar:

```text
Screen Reader Test

Keyboard Test

Text Scaling Test

Contrast Test

Reduced Motion Test
```

---

# 28. Flutter Tests

Criar:

```text
Semantics Test

Widget Test

Golden Test
```

Exemplo:

```dart
expect(
 tester.getSemantics(find.text("Salvar")),
 matchesSemantics(
  hasTapAction:true,
 )
);
```

---

# 29. Checklist QA

Antes de aprovar:

```text
[ ] Funciona com leitor de tela?

[ ] Funciona sem mouse?

[ ] Funciona com fonte 200%?

[ ] Funciona sem animação?

[ ] Contraste correto?

[ ] Erros são claros?

[ ] Estados existem?

[ ] Foco correto?

[ ] Touch correto?
```

---

# 30. Proibido

Nunca:

```text
❌ Texto pequeno para caber

❌ Remover foco

❌ Informação só por cor

❌ Botão sem label

❌ Ícone sem significado

❌ Placeholder como label

❌ Movimento obrigatório

❌ Blur reduzindo leitura

❌ Modal sem foco

❌ Erro técnico para usuário

❌ UI bonita mas inacessível
```

---

# Definition of Done

Uma interface só está pronta quando:

```text
[ ] Usuário comum consegue usar

[ ] Usuário com baixa visão consegue usar

[ ] Leitor de tela funciona

[ ] Teclado funciona

[ ] Texto aumentado funciona

[ ] Motion reduzido funciona

[ ] Performance continua boa
```

---

# Regra final

Acessibilidade não limita o design.

Ela aumenta a qualidade.

Uma interface premium precisa ser:

```text
Bonita

Rápida

Clara

Inclusiva
```
````

Com isso o bloco de design fica fechado:

```text
docs/design/

├── DESIGN_SYSTEM.md
├── UI_UX_FRONTEND_SPEC.md
├── COMPONENTS.md
├── ANIMATIONS.md
└── ACCESSIBILITY.md
```

Esse conjunto dá ao agente uma base de UI/UX semelhante a um time real de produto.
