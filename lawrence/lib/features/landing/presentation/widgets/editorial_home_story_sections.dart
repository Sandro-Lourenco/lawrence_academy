import 'package:flutter/material.dart';

import '../../../../design_system/public/public_editorial_colors.dart';
import '../../../../design_system/public/public_editorial_typography.dart';
import 'editorial_home_shared.dart';

class LawrenceMethodSection extends StatelessWidget {
  const LawrenceMethodSection({super.key});

  static const _steps = [
    (
      '01',
      'Fundamento',
      'Você compreende medidas, materiais, ferramentas e princípios antes de avançar.',
    ),
    (
      '02',
      'Presença',
      'A técnica ganha corpo em projetos práticos, atividades e decisões de construção.',
    ),
    (
      '03',
      'Assinatura',
      'Feedback, progresso e repertório ajudam você a criar com mais autonomia.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final mobile = width < publicDesktopBreakpoint;
    return EditorialSection(
      background: PublicEditorialColors.parchment,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionEyebrow('Método Lawrence'),
          const SizedBox(height: 26),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 820),
            child: Text(
              'Aprender, praticar,\nassinar.',
              style: PublicEditorialTypography.sectionDisplay(
                size: mobile ? 56 : 92,
              ),
            ),
          ),
          SizedBox(height: mobile ? 56 : 92),
          mobile
              ? Column(
                  children: [
                    for (final step in _steps)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 42),
                        child: _MethodStep(
                          number: step.$1,
                          title: step.$2,
                          description: step.$3,
                        ),
                      ),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var index = 0; index < _steps.length; index++) ...[
                      Expanded(
                        child: _MethodStep(
                          number: _steps[index].$1,
                          title: _steps[index].$2,
                          description: _steps[index].$3,
                        ),
                      ),
                      if (index < _steps.length - 1) const SizedBox(width: 64),
                    ],
                  ],
                ),
        ],
      ),
    );
  }
}

class _MethodStep extends StatelessWidget {
  const _MethodStep({
    required this.number,
    required this.title,
    required this.description,
  });

  final String number;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 22),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: PublicEditorialColors.wine, width: 1.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            number,
            style: PublicEditorialTypography.eyebrow(
              color: PublicEditorialColors.wine,
            ),
          ),
          const SizedBox(height: 24),
          Text(title, style: PublicEditorialTypography.courseTitle()),
          const SizedBox(height: 14),
          Text(description, style: PublicEditorialTypography.body()),
        ],
      ),
    );
  }
}

class ClassicManifestoSection extends StatelessWidget {
  const ClassicManifestoSection({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final mobile = width < publicDesktopBreakpoint;
    final image = AspectRatio(
      aspectRatio: mobile ? 4 / 3 : 1.35,
      child: const HoverZoomImage(
        asset: 'assets/images/couture_pattern_table.webp',
        semanticLabel:
            'Mãos desenhando um molde sobre tecido marfim com ferramentas de alfaiataria',
      ),
    );
    final copy = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SectionEyebrow('Manifesto'),
        const SizedBox(height: 28),
        Text(
          'Clássico não é passado.\nÉ domínio.',
          style: PublicEditorialTypography.storyDisplay(),
        ),
        const SizedBox(height: 26),
        Text(
          'Quando a técnica deixa de limitar, ela se transforma em liberdade. A Lawrence existe para tornar esse caminho claro, cuidadoso e possível.',
          style: PublicEditorialTypography.bodyLarge(),
        ),
        const SizedBox(height: 34),
        const EditorialOrnament(),
      ],
    );
    return EditorialSection(
      child: mobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [copy, const SizedBox(height: 56), image],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(flex: 4, child: copy),
                const SizedBox(width: 110),
                Expanded(flex: 6, child: image),
              ],
            ),
    );
  }
}

class LearningExperienceSection extends StatelessWidget {
  const LearningExperienceSection({super.key});

  static const _features = [
    (
      Icons.play_circle_outline,
      'Aulas organizadas',
      'Conteúdo estruturado em módulos para você saber o que vem agora.',
    ),
    (
      Icons.content_cut,
      'Prática com propósito',
      'Atividades e projetos aproximam o conhecimento da construção real.',
    ),
    (
      Icons.rate_review_outlined,
      'Acompanhamento',
      'Feedback ajuda a reconhecer avanços e os próximos pontos de atenção.',
    ),
    (
      Icons.workspace_premium_outlined,
      'Progresso e certificado',
      'Sua evolução fica visível e a conclusão reconhece o percurso realizado.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final mobile = width < publicDesktopBreakpoint;
    return EditorialSection(
      background: PublicEditorialColors.ink,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionEyebrow('Experiência de aprendizagem', onDark: true),
          const SizedBox(height: 26),
          Text(
            'Uma escola que acompanha\no seu fazer.',
            style: PublicEditorialTypography.sectionDisplay(
              color: PublicEditorialColors.ivory,
              size: mobile ? 54 : 82,
            ),
          ),
          SizedBox(height: mobile ? 58 : 88),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: mobile ? 1 : 2,
              crossAxisSpacing: 72,
              mainAxisSpacing: 18,
              mainAxisExtent: 170,
            ),
            itemCount: _features.length,
            itemBuilder: (context, index) {
              final feature = _features[index];
              return _ExperienceItem(
                icon: feature.$1,
                title: feature.$2,
                description: feature.$3,
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ExperienceItem extends StatelessWidget {
  const _ExperienceItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 24),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: PublicEditorialColors.antiqueRose.withValues(alpha: 0.7),
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: PublicEditorialColors.champagne,
            size: 30,
            semanticLabel: title,
          ),
          const SizedBox(width: 22),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: PublicEditorialTypography.courseTitle(
                    color: PublicEditorialColors.ivory,
                  ).copyWith(fontSize: 34),
                ),
                const SizedBox(height: 10),
                Text(
                  description,
                  style: PublicEditorialTypography.body(
                    color: PublicEditorialColors.ivory,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class FounderStorySection extends StatelessWidget {
  const FounderStorySection({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final mobile = width < publicDesktopBreakpoint;
    final image = AspectRatio(
      aspectRatio: mobile ? 4 / 5 : 0.82,
      child: const HoverZoomImage(
        asset: 'assets/images/creator-lawrence.jpeg',
        semanticLabel: 'Retrato da criadora da Lawrence Academy',
        alignment: Alignment.topCenter,
      ),
    );
    final copy = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SectionEyebrow('Por trás da Lawrence'),
        const SizedBox(height: 26),
        Text(
          'Ensinar também\né um ofício.',
          style: PublicEditorialTypography.sectionDisplay(
            size: mobile ? 56 : 82,
          ),
        ),
        const SizedBox(height: 26),
        Text(
          'A Lawrence nasce do respeito por quem aprende fazendo: observando, tentando, ajustando e encontrando a própria linguagem. Aqui, tradição não é rigidez — é base para avançar com consciência.',
          style: PublicEditorialTypography.bodyLarge(),
        ),
        const SizedBox(height: 30),
        Text(
          'Cuidado no ensino. Precisão no método. Liberdade no resultado.',
          style: PublicEditorialTypography.body(
            color: PublicEditorialColors.wine,
          ).copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    );
    return EditorialSection(
      background: PublicEditorialColors.parchment,
      child: mobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [image, const SizedBox(height: 56), copy],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(flex: 5, child: image),
                const SizedBox(width: 110),
                Expanded(flex: 6, child: copy),
              ],
            ),
    );
  }
}

class HomeFaqSection extends StatelessWidget {
  const HomeFaqSection({super.key});

  static const _questions = [
    (
      'Preciso ter experiência para começar?',
      'Não necessariamente. O catálogo informa o nível de cada curso para você escolher uma formação compatível com o seu momento.',
    ),
    (
      'Como funciona a assinatura?',
      'Cada curso possui sua própria assinatura mensal. Você escolhe e administra cada formação de forma independente.',
    ),
    (
      'Os cursos oferecem certificado?',
      'Quando o curso possui certificado habilitado, ele é liberado após o cumprimento dos critérios de progresso e aprovação definidos para a formação.',
    ),
    (
      'Onde assisto às aulas?',
      'Depois de entrar na sua conta, os cursos assinados ficam organizados na área da aluna, com módulos, aulas, materiais e progresso.',
    ),
    (
      'Posso cancelar apenas um curso?',
      'Sim. O cancelamento afeta somente a assinatura escolhida e o acesso permanece até o fim do período já pago.',
    ),
    (
      'Posso estudar pelo celular?',
      'Sim. A experiência é responsiva para web e Android, preservando leitura, navegação e acompanhamento de progresso.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final mobile = MediaQuery.sizeOf(context).width < publicDesktopBreakpoint;
    final title = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionEyebrow('Perguntas frequentes'),
        const SizedBox(height: 26),
        Text(
          'Antes do\nprimeiro ponto.',
          style: PublicEditorialTypography.sectionDisplay(
            size: mobile ? 54 : 76,
          ),
        ),
        const SizedBox(height: 22),
        Text(
          'Respostas diretas para você escolher com segurança.',
          style: PublicEditorialTypography.bodyLarge(),
        ),
      ],
    );
    final questions = Column(
      children: [
        for (var index = 0; index < _questions.length; index++)
          _FaqTile(
            number: '${index + 1}'.padLeft(2, '0'),
            question: _questions[index].$1,
            answer: _questions[index].$2,
          ),
      ],
    );
    return EditorialSection(
      child: mobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [title, const SizedBox(height: 52), questions],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 4, child: title),
                const SizedBox(width: 90),
                Expanded(flex: 7, child: questions),
              ],
            ),
    );
  }
}

class _FaqTile extends StatelessWidget {
  const _FaqTile({
    required this.number,
    required this.question,
    required this.answer,
  });

  final String number;
  final String question;
  final String answer;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
        childrenPadding: const EdgeInsets.only(left: 54, right: 16, bottom: 24),
        collapsedIconColor: PublicEditorialColors.wine,
        iconColor: PublicEditorialColors.wine,
        shape: const Border(
          top: BorderSide(color: PublicEditorialColors.antiqueRose),
        ),
        collapsedShape: const Border(
          top: BorderSide(color: PublicEditorialColors.antiqueRose),
        ),
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 54,
              child: Text(
                number,
                style: PublicEditorialTypography.eyebrow(
                  color: PublicEditorialColors.wine,
                ),
              ),
            ),
            Expanded(
              child: Text(
                question,
                style: PublicEditorialTypography.bodyLarge().copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(answer, style: PublicEditorialTypography.body()),
          ),
        ],
      ),
    );
  }
}

class FinalInvitationSection extends StatelessWidget {
  const FinalInvitationSection({
    super.key,
    required this.onExplore,
    required this.onLogin,
  });

  final VoidCallback onExplore;
  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    final mobile = MediaQuery.sizeOf(context).width < publicMobileBreakpoint;
    return EditorialSection(
      background: PublicEditorialColors.wine,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionEyebrow('O seu lugar no ateliê', onDark: true),
          const SizedBox(height: 28),
          Text(
            'Seu próximo capítulo\ncomeça com um gesto.',
            style: PublicEditorialTypography.sectionDisplay(
              color: PublicEditorialColors.ivory,
              size: mobile ? 54 : 94,
            ),
          ),
          const SizedBox(height: 30),
          Text(
            'Escolha o curso que traduz o que você quer aprender agora.',
            style: PublicEditorialTypography.bodyLarge(
              color: PublicEditorialColors.ivory,
            ),
          ),
          const SizedBox(height: 38),
          Wrap(
            spacing: 18,
            runSpacing: 12,
            children: [
              MaisonButton(
                label: 'Escolher meu curso',
                onPressed: onExplore,
                light: true,
                expand: mobile,
              ),
              EditorialTextLink(
                label: 'Já sou aluna: entrar',
                onPressed: onLogin,
                onDark: true,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class MaisonFooter extends StatelessWidget {
  const MaisonFooter({
    super.key,
    required this.onHome,
    required this.onCourses,
    required this.onLogin,
  });

  final VoidCallback onHome;
  final VoidCallback onCourses;
  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    final mobile = MediaQuery.sizeOf(context).width < publicDesktopBreakpoint;
    final nav = Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        TextButton(onPressed: onHome, child: const Text('Início')),
        TextButton(onPressed: onCourses, child: const Text('Cursos')),
        TextButton(onPressed: onLogin, child: const Text('Entrar')),
      ],
    );
    return ColoredBox(
      color: PublicEditorialColors.noir,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            mobile ? 24 : 72,
            64,
            mobile ? 24 : 72,
            44,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              mobile
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _FooterBrand(),
                        const SizedBox(height: 40),
                        nav,
                      ],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Expanded(child: _FooterBrand()),
                        nav,
                      ],
                    ),
              const SizedBox(height: 58),
              Divider(
                color: PublicEditorialColors.antiqueRose.withValues(
                  alpha: 0.45,
                ),
              ),
              const SizedBox(height: 24),
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                spacing: 32,
                runSpacing: 14,
                children: [
                  Text(
                    '© Lawrence Academy',
                    style: PublicEditorialTypography.caption(
                      color: PublicEditorialColors.parchment,
                    ),
                  ),
                  Text(
                    'Ensino profissional de moda, costura e modelagem.',
                    style: PublicEditorialTypography.caption(
                      color: PublicEditorialColors.parchment,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FooterBrand extends StatelessWidget {
  const _FooterBrand();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'LAWRENCE',
          style: PublicEditorialTypography.sectionDisplay(
            color: PublicEditorialColors.ivory,
            size: 52,
          ),
        ),
        Text(
          'ACADEMY',
          style: PublicEditorialTypography.eyebrow(
            color: PublicEditorialColors.champagne,
          ).copyWith(letterSpacing: 4),
        ),
        const SizedBox(height: 18),
        Text(
          'Técnica que se transforma em assinatura.',
          style: PublicEditorialTypography.body(
            color: PublicEditorialColors.ivory,
          ),
        ),
      ],
    );
  }
}
