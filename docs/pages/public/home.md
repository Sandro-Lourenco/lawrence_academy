---
version: 3.0.0
id: PAGE-PUBLIC-001
name: Maison Lawrence Landing Page
route: /
actor: Visitor
status: implemented
---

# Objetivo

Apresentar a Lawrence Academy como escola premium de costura, modelagem e
alta-costura, permitindo entender a proposta no primeiro viewport e chegar ao
catálogo sem ambiguidade.

# Tese

**Maison Lawrence — técnica que se transforma em assinatura.**

A home usa vinho, ameixa, marfim e fotografia editorial clássica. A linguagem
é feminina, segura e contemporânea; não usa símbolos literais de realeza,
claims não comprovados nem textos copiados de referências.

# Jornada e seções

1. Hero cinematográfico com proposta, `/courses` e atalho para o método.
2. Faixa factual: cursos estruturados, prática, acompanhamento e certificado.
3. Trilhas: Costura, Modelagem, Alta-costura e Fashion & Style.
4. Curso em evidência e explicação de assinatura individual por curso.
5. Método em três atos: Fundamento, Presença e Assinatura.
6. Manifesto com espaço negativo e imagem de modelagem.
7. Experiência: aulas, prática, acompanhamento, progresso e certificado.
8. História da criação da escola, sem credenciais ou datas não validadas.
9. FAQ com regras de produto verificadas.
10. CTA final, entrada da aluna e footer.

Depoimentos, números, marcas e biografias nominadas só entram após validação e
consentimento. Comunidade não é prometida no MVP.

# Responsividade

- Mobile `<700`: imagem e texto empilhados, CTA adaptável, sem sobreposição.
- Tablet `700–1099`: composição compacta e no máximo duas colunas.
- Desktop `>=1100`: composição assimétrica, mídia 5/7 ou 4/8 e máximo 1440 px.
- Texto suporta escala 200% sem redução artificial.

# Acessibilidade

- Um único H1; títulos em ordem; alvos mínimos 48 px.
- Contraste WCAG 2.2 AA e foco visível.
- Imagens informativas têm descrição; ornamentos são excluídos.
- FAQ funciona por teclado e expõe estado expandido.
- `disableAnimations` mostra o estado final, sem loop ou parallax.

# Estado e performance

A página usa conteúdo local versionado e não faz chamadas no primeiro
carregamento. Ausência de imagem preserva conteúdo e CTAs. Assets editoriais
usam WebP otimizado; animações se limitam a transform/opacity e não bloqueiam
interação.
