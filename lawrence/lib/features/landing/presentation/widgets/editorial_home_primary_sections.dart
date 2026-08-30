import 'package:flutter/material.dart';

import '../../../../design_system/motion/public_motion.dart';
import '../../../../design_system/public/public_editorial_colors.dart';
import '../../../../design_system/public/public_editorial_typography.dart';
import 'editorial_home_shared.dart';

class MaisonHeroSection extends StatelessWidget {
  const MaisonHeroSection({
    super.key,
    required this.onExplore,
    required this.onMethod,
  });

  final VoidCallback onExplore;
  final VoidCallback onMethod;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final mobile = width < publicMobileBreakpoint;

    if (mobile) {
      return ColoredBox(
        color: PublicEditorialColors.ink,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 440,
              width: double.infinity,
              child: const HoverZoomImage(
                asset: 'assets/images/maison_lawrence_hero.webp',
                semanticLabel:
                    'Costureira em vestido vinho ao lado de um manequim com seda marfim em um ateliê clássico',
                alignment: Alignment(0.62, 0),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 54, 24, 80),
              child: _HeroCopy(
                onExplore: onExplore,
                onMethod: onMethod,
                mobile: true,
              ),
            ),
          ],
        ),
      );
    }

    final textScale = MediaQuery.textScalerOf(context).scale(1);
    final heroHeight = 980.0 + ((textScale - 1).clamp(0, 1) * 300);
    return SizedBox(
      height: heroHeight,
      child: Stack(
        fit: StackFit.expand,
        children: [
          const HoverZoomImage(
            asset: 'assets/images/maison_lawrence_hero.webp',
            semanticLabel:
                'Costureira em vestido vinho ao lado de um manequim com seda marfim em um ateliê clássico',
            alignment: Alignment.center,
          ),
          ExcludeSemantics(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    PublicEditorialColors.ink,
                    PublicEditorialColors.ink.withValues(alpha: 0.94),
                    PublicEditorialColors.ink.withValues(alpha: 0.36),
                    Colors.transparent,
                  ],
                  stops: const [0, 0.35, 0.64, 1],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.centerLeft,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 730),
                child: Padding(
                  padding: EdgeInsets.only(
                    left: width < publicDesktopBreakpoint ? 48 : 72,
                    right: 32,
                    top: 80,
                  ),
                  child: _HeroCopy(
                    onExplore: onExplore,
                    onMethod: onMethod,
                    mobile: false,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            right: 58,
            bottom: 52,
            child: PublicReveal(
              delay: const Duration(milliseconds: 80),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const EditorialOrnament(onDark: true),
                  const SizedBox(height: 12),
                  Text(
                    'TÉCNICA  •  PRESENÇA  •  AUTORIA',
                    style: PublicEditorialTypography.eyebrow(
                      color: PublicEditorialColors.champagne,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroCopy extends StatelessWidget {
  const _HeroCopy({
    required this.onExplore,
    required this.onMethod,
    required this.mobile,
  });

  final VoidCallback onExplore;
  final VoidCallback onMethod;
  final bool mobile;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PublicReveal(
          child: SectionEyebrow('Maison Lawrence', onDark: true),
        ),
        const SizedBox(height: 28),
        PublicReveal(
          delay: const Duration(milliseconds: 50),
          child: Semantics(
            header: true,
            child: Text(
              'Vista o conhecimento.\nAssine a sua técnica.',
              style: PublicEditorialTypography.heroDisplay(
                context,
                color: PublicEditorialColors.ivory,
              ),
            ),
          ),
        ),
        const SizedBox(height: 28),
        PublicReveal(
          delay: const Duration(milliseconds: 90),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 570),
            child: Text(
              'Formação online em costura, modelagem e alta-costura para mulheres que desejam transformar domínio técnico em expressão própria.',
              style: PublicEditorialTypography.bodyLarge(
                color: PublicEditorialColors.ivory,
              ),
            ),
          ),
        ),
        const SizedBox(height: 34),
        PublicReveal(
          delay: const Duration(milliseconds: 130),
          child: Wrap(
            spacing: 18,
            runSpacing: 12,
            children: [
              MaisonButton(
                label: 'Explorar cursos',
                onPressed: onExplore,
                light: true,
                expand: mobile,
              ),
              EditorialTextLink(
                label: 'Conhecer o método',
                onPressed: onMethod,
                onDark: true,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class TrustRibbonSection extends StatelessWidget {
  const TrustRibbonSection({super.key});

  static const _items = [
    ('01', 'Cursos estruturados'),
    ('02', 'Projetos práticos'),
    ('03', 'Acompanhamento especializado'),
    ('04', 'Certificado por curso'),
  ];

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: PublicEditorialColors.wine,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1320),
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              spacing: 28,
              runSpacing: 20,
              children: [
                for (final item in _items)
                  SizedBox(
                    width: 260,
                    child: Row(
                      children: [
                        Text(
                          item.$1,
                          style: PublicEditorialTypography.eyebrow(
                            color: PublicEditorialColors.champagne,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            item.$2,
                            style: PublicEditorialTypography.body(
                              color: PublicEditorialColors.white,
                            ).copyWith(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class LearningPathsSection extends StatelessWidget {
  const LearningPathsSection({super.key, required this.onExplore});

  final VoidCallback onExplore;

  static const _paths = [
    (
      '01',
      'Costura',
      'Do domínio da máquina à construção de peças com acabamento preciso.',
    ),
    (
      '02',
      'Modelagem',
      'Medidas, bases e volumes para transformar intenção em forma.',
    ),
    (
      '03',
      'Alta-costura',
      'Técnicas manuais, moulage e atenção absoluta ao detalhe.',
    ),
    (
      '04',
      'Fashion & Style',
      'Repertório visual e linguagem para criar com identidade.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final mobile = MediaQuery.sizeOf(context).width < publicDesktopBreakpoint;
    final intro = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionEyebrow('Escolha o seu caminho'),
        const SizedBox(height: 26),
        Text(
          'Quatro portas.\nUma assinatura.',
          style: PublicEditorialTypography.sectionDisplay(
            size: mobile ? 54 : 78,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Comece pela técnica que acompanha o momento da sua jornada. Cada trilha conduz ao catálogo completo.',
          style: PublicEditorialTypography.bodyLarge(),
        ),
        const SizedBox(height: 28),
        EditorialTextLink(label: 'Ver todos os cursos', onPressed: onExplore),
      ],
    );

    final list = Column(
      children: [
        for (final path in _paths)
          _LearningPathRow(
            number: path.$1,
            title: path.$2,
            description: path.$3,
            onPressed: onExplore,
          ),
      ],
    );

    return EditorialSection(
      child: mobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [intro, const SizedBox(height: 58), list],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 4, child: intro),
                const SizedBox(width: 96),
                Expanded(flex: 6, child: list),
              ],
            ),
    );
  }
}

class _LearningPathRow extends StatelessWidget {
  const _LearningPathRow({
    required this.number,
    required this.title,
    required this.description,
    required this.onPressed,
  });

  final String number;
  final String title;
  final String description;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Explorar trilha $title',
      child: InkWell(
        onTap: onPressed,
        focusColor: PublicEditorialColors.antiqueRose.withValues(alpha: 0.35),
        hoverColor: PublicEditorialColors.antiqueRose.withValues(alpha: 0.18),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 8),
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(color: PublicEditorialColors.antiqueRose),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 44,
                child: Text(
                  number,
                  style: PublicEditorialTypography.eyebrow(
                    color: PublicEditorialColors.wine,
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: PublicEditorialTypography.courseTitle()),
                    const SizedBox(height: 8),
                    Text(description, style: PublicEditorialTypography.body()),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              const Padding(
                padding: EdgeInsets.only(top: 10),
                child: Icon(
                  Icons.north_east,
                  color: PublicEditorialColors.wine,
                  semanticLabel: 'Abrir trilha',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SignatureCourseSection extends StatelessWidget {
  const SignatureCourseSection({super.key, required this.onExplore});

  final VoidCallback onExplore;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final mobile = width < publicDesktopBreakpoint;
    final image = AspectRatio(
      aspectRatio: mobile ? 4 / 5 : 1.34,
      child: const HoverZoomImage(
        asset: 'assets/images/couture_draping_portrait.webp',
        semanticLabel:
            'Mãos de duas profissionais ajustando uma toile marfim em um manequim',
      ),
    );
    final copy = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SectionEyebrow('Curso em evidência', onDark: true),
        const SizedBox(height: 28),
        Text(
          'Modelagem\nque encontra o corpo.',
          style: PublicEditorialTypography.sectionDisplay(
            color: PublicEditorialColors.ivory,
            size: mobile ? 54 : 82,
          ),
        ),
        const SizedBox(height: 26),
        Text(
          'Conheça uma formação dedicada a medidas, bases e construção de volumes — do primeiro risco ao caimento consciente.',
          style: PublicEditorialTypography.bodyLarge(
            color: PublicEditorialColors.ivory,
          ),
        ),
        const SizedBox(height: 18),
        Text(
          'Cada curso possui sua própria assinatura mensal.',
          style: PublicEditorialTypography.caption(
            color: PublicEditorialColors.champagne,
          ),
        ),
        const SizedBox(height: 34),
        MaisonButton(
          label: 'Conhecer o catálogo',
          onPressed: onExplore,
          light: true,
          expand: mobile,
        ),
      ],
    );

    return EditorialSection(
      background: PublicEditorialColors.plum,
      padding: EdgeInsets.zero,
      maxWidth: double.infinity,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1440),
          child: mobile
              ? Column(
                  children: [
                    image,
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 64, 24, 84),
                      child: copy,
                    ),
                  ],
                )
              : Row(
                  children: [
                    Expanded(flex: 6, child: image),
                    Expanded(
                      flex: 5,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 72,
                          vertical: 96,
                        ),
                        child: copy,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
