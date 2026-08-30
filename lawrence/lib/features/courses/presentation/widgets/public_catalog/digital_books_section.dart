import 'package:flutter/material.dart';

import '../../../../../design_system/public/public_editorial_colors.dart';
import '../../../../../design_system/public/public_editorial_typography.dart';

class DigitalBooksSection extends StatelessWidget {
  const DigitalBooksSection({super.key});

  @override
  Widget build(BuildContext context) {
    final mobile = MediaQuery.sizeOf(context).width < 700;
    final copy = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'BIBLIOTECA DIGITAL · EM PREPARAÇÃO',
          style: PublicEditorialTypography.eyebrow(
            color: PublicEditorialColors.champagne,
          ),
        ),
        const SizedBox(height: 22),
        Text(
          'Conhecimento para continuar sobre a mesa.',
          style: PublicEditorialTypography.sectionDisplay(
            color: PublicEditorialColors.ivory,
            size: mobile ? 48 : 70,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Os Cadernos Lawrence reunirão fundamentos, processos e referências para consultar no seu ritmo. A coleção será anunciada quando estiver pronta.',
          style: PublicEditorialTypography.body(
            color: PublicEditorialColors.parchment,
          ),
        ),
      ],
    );
    final covers = Semantics(
      label: 'Prévia visual de três livros digitais Lawrence em preparação',
      child: ExcludeSemantics(
        child: SizedBox(
          height: mobile ? 320 : 410,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: const [
              Positioned(
                left: 0,
                bottom: 12,
                child: _BookCover(
                  number: 'I',
                  title: 'Fundamentos',
                  rotation: -0.07,
                ),
              ),
              Positioned(
                right: 4,
                bottom: 4,
                child: _BookCover(
                  number: 'III',
                  title: 'Acabamentos',
                  rotation: 0.07,
                ),
              ),
              Positioned(
                bottom: 24,
                child: _BookCover(
                  number: 'II',
                  title: 'Modelagem',
                  featured: true,
                ),
              ),
            ],
          ),
        ),
      ),
    );
    return ColoredBox(
      color: PublicEditorialColors.plum,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: mobile ? 24 : 64,
          vertical: mobile ? 82 : 126,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1296),
            child: mobile
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [copy, const SizedBox(height: 54), covers],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(flex: 4, child: copy),
                      const SizedBox(width: 72),
                      Expanded(flex: 6, child: covers),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class _BookCover extends StatelessWidget {
  const _BookCover({
    required this.number,
    required this.title,
    this.rotation = 0,
    this.featured = false,
  });

  final String number;
  final String title;
  final double rotation;
  final bool featured;

  @override
  Widget build(BuildContext context) => Transform.rotate(
    angle: rotation,
    child: Container(
      width: featured ? 190 : 166,
      height: featured ? 320 : 280,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: featured
            ? PublicEditorialColors.ivory
            : PublicEditorialColors.wine,
        border: Border.all(
          color: PublicEditorialColors.champagne.withValues(alpha: .72),
        ),
        boxShadow: [
          BoxShadow(
            color: PublicEditorialColors.noir.withValues(alpha: .34),
            blurRadius: 28,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'LAWRENCE ACADEMY',
            style: PublicEditorialTypography.eyebrow(
              color: featured
                  ? PublicEditorialColors.wine
                  : PublicEditorialColors.champagne,
            ).copyWith(fontSize: 9, letterSpacing: 1.4),
          ),
          const Spacer(),
          Container(
            width: 48,
            height: 1,
            color: featured
                ? PublicEditorialColors.wine
                : PublicEditorialColors.champagne,
          ),
          const SizedBox(height: 13),
          Text(
            number,
            style: PublicEditorialTypography.sectionDisplay(
              color: featured
                  ? PublicEditorialColors.wine
                  : PublicEditorialColors.ivory,
              size: 58,
            ),
          ),
          Text(
            title,
            style: PublicEditorialTypography.body(
              color: featured
                  ? PublicEditorialColors.ink
                  : PublicEditorialColors.ivory,
            ).copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            'CADERNOS LAWRENCE',
            style: PublicEditorialTypography.eyebrow(
              color: featured
                  ? PublicEditorialColors.mutedInk
                  : PublicEditorialColors.parchment,
            ).copyWith(fontSize: 8, letterSpacing: 1.2),
          ),
        ],
      ),
    ),
  );
}
