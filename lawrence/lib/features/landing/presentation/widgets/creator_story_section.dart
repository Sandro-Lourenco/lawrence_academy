import 'package:flutter/material.dart';

import '../../../../design_system/tokens/lawrence_theme.dart';
import '../../../../design_system/widgets/liquid_glass_container.dart';
import 'tailor_grid_painter.dart';

const _ivory = Color(0xFFF4F3EF); // Editorial Bone
const _gold = Color(0xFFD4AF37);  // Classic Gold
const _paper = Color(0xFFC5A880); // Champagne Gold

final creatorStoryKey = GlobalKey();

class CreatorStorySection extends StatelessWidget {
  final bool mobile;

  const CreatorStorySection({required this.mobile, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      key: creatorStoryKey,
      color: const Color(0xFF141416), // Charcoal
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: TailorGridPainter(dark: true),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: mobile ? 24 : 64,
              vertical: mobile ? 90 : 130,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1240),
                child: mobile
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _CreatorPortrait(mobile: mobile),
                          const SizedBox(height: 48),
                          const _CreatorCopy(mobile: true),
                        ],
                      )
                    : const SizedBox(
                        height: 680,
                        child: Row(
                          children: [
                            Expanded(
                              flex: 5,
                              child: _CreatorPortrait(mobile: false),
                            ),
                            SizedBox(width: 80),
                            Expanded(flex: 6, child: _CreatorCopy(mobile: false)),
                          ],
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CreatorPortrait extends StatelessWidget {
  final bool mobile;

  const _CreatorPortrait({required this.mobile});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: mobile ? 520 : double.infinity,
      width: double.infinity,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: mobile ? 14 : 22,
            right: mobile ? -8 : -22,
            top: mobile ? 14 : 22,
            bottom: mobile ? -14 : -22,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: const Color(0x1AFFE6A6), // subtle gold outline backing
                borderRadius: BorderRadius.circular(36),
                border: Border.all(color: const Color(0x33E9A126)),
              ),
            ),
          ),
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(36),
              child: Semantics(
                image: true,
                label:
                    'Criadora da Lawrence Academy sorrindo, sentada em uma poltrona.',
                child: Image.asset(
                  'assets/images/creator-lawrence.jpeg',
                  fit: BoxFit.cover,
                  alignment: const Alignment(0, -0.2),
                  errorBuilder: (_, _, _) =>
                      const ColoredBox(color: Color(0xFF0F1E2E)),
                ),
              ),
            ),
          ),
          Positioned(
            left: 18,
            right: 18,
            bottom: 18,
            child: RepaintBoundary(
              child: LiquidGlassContainer(
                blurSigma: LawrenceTheme.AppGlassBlurSubtle,
                borderRadius: 26,
                padding: const EdgeInsets.fromLTRB(22, 18, 22, 18),
                backgroundColor: const Color(0x1A000000), // darker glass backing
                fallbackColor: const Color(0xE6071420),
                borderColor: const Color(0x33FFFFFF),
                child: Stack(
                  children: [
                    Positioned(
                      top: -28,
                      right: -10,
                      child: IgnorePointer(
                        child: Container(
                          width: 120,
                          height: 64,
                          decoration: const BoxDecoration(
                            gradient: RadialGradient(
                              colors: [Color(0x20FFFFFF), Color(0x00FFFFFF)],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'CRIADORA & FUNDADORA',
                          style: TextStyle(
                            color: Color(0xFFFFD875),
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.7,
                          ),
                        ),
                        SizedBox(height: 7),
                        Text(
                          'Lawrence Academy',
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Georgia',
                            fontSize: 25,
                            height: 1.1,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CreatorCopy extends StatelessWidget {
  final bool mobile;

  const _CreatorCopy({required this.mobile});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'QUEM ESTÁ POR TRÁS DA LAWRENCE',
          style: TextStyle(
            color: _paper,
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.8,
          ),
        ),
        const SizedBox(height: 22),
        Text(
          'Uma escola criada por quem conhece o caminho entre a ideia e a peça.',
          style: TextStyle(
            color: _ivory,
            fontFamily: 'Georgia',
            fontSize: mobile ? 42 : 58,
            height: 1.04,
            letterSpacing: -1.7,
          ),
        ),
        const SizedBox(height: 28),
        const Text(
          'A Lawrence nasce de uma convicção simples: técnica não limita a '
          'criatividade — ela dá forma, precisão e liberdade ao que você imagina.',
          style: TextStyle(
            color: Color(0xFFD0D6DC),
            fontSize: 17,
            height: 1.65,
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          'Em cada aula, sua criadora traduz o olhar do ateliê em um método '
          'claro, próximo e aplicável, para que você compreenda cada escolha e '
          'desenvolva uma assinatura própria.',
          style: TextStyle(
            color: Color(0xFFD0D6DC),
            fontSize: 17,
            height: 1.65,
          ),
        ),
        const SizedBox(height: 30),
        const DecoratedBox(
          decoration: BoxDecoration(
            border: Border(left: BorderSide(color: _gold, width: 3)),
          ),
          child: Padding(
            padding: EdgeInsets.only(left: 22),
            child: Text(
              '“Não ensino apenas a fazer uma roupa. Ensino a enxergar o que '
              'ela pode se tornar.”',
              style: TextStyle(
                color: _paper,
                fontFamily: 'Georgia',
                fontSize: 22,
                fontStyle: FontStyle.italic,
                height: 1.45,
              ),
            ),
          ),
        ),
        const SizedBox(height: 34),
        const Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _ExpertiseChip('Costura'),
            _ExpertiseChip('Modelagem'),
            _ExpertiseChip('Estilo'),
          ],
        ),
      ],
    );
  }
}

class _ExpertiseChip extends StatelessWidget {
  final String label;

  const _ExpertiseChip(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0x52FFFFFF)),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: _paper,
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
