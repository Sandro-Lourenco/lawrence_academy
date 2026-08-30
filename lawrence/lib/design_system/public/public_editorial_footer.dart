import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../motion/public_motion.dart';
import 'public_editorial_colors.dart';
import 'public_editorial_typography.dart';

/// Monumental public footer inspired by mid-century fashion mastheads.
///
/// Every visible navigation item has a real destination. The supplied brand
/// artwork remains untouched and is treated as the closing signature.
class PublicEditorialFooter extends StatelessWidget {
  const PublicEditorialFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final mobile = width < 700;
    final tablet = width < 1100;

    return ColoredBox(
      color: PublicEditorialColors.noir,
      child: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                mobile ? 24 : 72,
                mobile ? 78 : 112,
                mobile ? 24 : 72,
                mobile ? 58 : 82,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1440),
                  child: tablet
                      ? const _FooterStackedContent()
                      : const _FooterDesktopContent(),
                ),
              ),
            ),
            Divider(
              height: 1,
              color: PublicEditorialColors.champagne.withValues(alpha: .32),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                mobile ? 16 : 48,
                mobile ? 34 : 48,
                mobile ? 16 : 48,
                mobile ? 28 : 36,
              ),
              child: const _MonumentalBrand(),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                mobile ? 24 : 72,
                0,
                mobile ? 24 : 72,
                mobile ? 30 : 38,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1440),
                  child: Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 28,
                    runSpacing: 18,
                    children: [
                      Text(
                        '© ${DateTime.now().year} Lawrence Academy',
                        style: PublicEditorialTypography.caption(
                          color: PublicEditorialColors.parchment,
                        ),
                      ),
                      Text(
                        'Técnica · Presença · Legado',
                        style: PublicEditorialTypography.eyebrow(
                          color: PublicEditorialColors.champagne,
                        ).copyWith(fontSize: 10),
                      ),
                      const _BackToTopButton(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MonumentalBrand extends StatelessWidget {
  const _MonumentalBrand();

  @override
  Widget build(BuildContext context) {
    final mobile = MediaQuery.sizeOf(context).width < 700;
    return Semantics(
      image: true,
      label: 'Lawrence Academy',
      child: ExcludeSemantics(
        child: SizedBox(
          height: mobile ? 190 : 330,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned.fill(
                child: SvgPicture.asset(
                  'assets/brand/lawrence-footer-signature.svg',
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: mobile ? 4 : 24),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'LAWRENCE',
                    maxLines: 1,
                    style: PublicEditorialTypography.sectionDisplay(
                      color: PublicEditorialColors.ivory,
                      size: mobile ? 98 : 230,
                    ).copyWith(height: .78, letterSpacing: mobile ? -2 : -6),
                  ),
                ),
              ),
              Positioned(
                bottom: mobile ? 12 : 22,
                child: Text(
                  'A C A D E M Y',
                  style:
                      PublicEditorialTypography.eyebrow(
                        color: PublicEditorialColors.champagne,
                      ).copyWith(
                        fontSize: mobile ? 10 : 12,
                        letterSpacing: mobile ? 4 : 8,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FooterDesktopContent extends StatelessWidget {
  const _FooterDesktopContent();

  @override
  Widget build(BuildContext context) => const Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(flex: 6, child: _FooterStatement()),
      SizedBox(width: 90),
      Expanded(flex: 5, child: _FooterNavigation()),
    ],
  );
}

class _FooterStackedContent extends StatelessWidget {
  const _FooterStackedContent();

  @override
  Widget build(BuildContext context) => const Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [_FooterStatement(), SizedBox(height: 62), _FooterNavigation()],
  );
}

class _FooterStatement extends StatelessWidget {
  const _FooterStatement();

  @override
  Widget build(BuildContext context) {
    final mobile = MediaQuery.sizeOf(context).width < 700;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'MAISON LAWRENCE · DESDE O PRIMEIRO TRAÇO',
          style: PublicEditorialTypography.eyebrow(
            color: PublicEditorialColors.champagne,
          ),
        ),
        const SizedBox(height: 26),
        Text(
          'Conhecimento que\nveste a sua assinatura.',
          style: PublicEditorialTypography.sectionDisplay(
            color: PublicEditorialColors.ivory,
            size: mobile ? 51 : 72,
          ).copyWith(height: .94),
        ),
        const SizedBox(height: 26),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Text(
            'Formação em costura, modelagem e alta-costura para transformar técnica em presença e autoria.',
            style: PublicEditorialTypography.body(
              color: PublicEditorialColors.parchment,
            ),
          ),
        ),
      ],
    );
  }
}

class _FooterNavigation extends StatelessWidget {
  const _FooterNavigation();

  @override
  Widget build(BuildContext context) => const Wrap(
    spacing: 58,
    runSpacing: 42,
    children: [
      _FooterLinkGroup(
        title: 'EXPLORE',
        links: [('Catálogo completo', '/courses'), ('Página inicial', '/')],
      ),
      _FooterLinkGroup(
        title: 'SUA JORNADA',
        links: [('Entrar', '/login'), ('Criar conta', '/register')],
      ),
    ],
  );
}

class _FooterLinkGroup extends StatelessWidget {
  const _FooterLinkGroup({required this.title, required this.links});

  final String title;
  final List<(String, String)> links;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 220,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: PublicEditorialTypography.eyebrow(
            color: PublicEditorialColors.champagne,
          ),
        ),
        const SizedBox(height: 18),
        for (final link in links) _FooterLink(label: link.$1, route: link.$2),
      ],
    ),
  );
}

class _FooterLink extends StatefulWidget {
  const _FooterLink({required this.label, required this.route});

  final String label;
  final String route;

  @override
  State<_FooterLink> createState() => _FooterLinkState();
}

class _FooterLinkState extends State<_FooterLink> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: TextButton(
        onPressed: () => context.go(widget.route),
        style: TextButton.styleFrom(
          alignment: Alignment.centerLeft,
          minimumSize: const Size(48, 48),
          padding: EdgeInsets.zero,
          foregroundColor: PublicEditorialColors.ivory,
          textStyle: PublicEditorialTypography.body(
            color: PublicEditorialColors.ivory,
          ),
        ),
        child: Row(
          children: [
            Expanded(child: Text(widget.label)),
            const SizedBox(width: 10),
            AnimatedSlide(
              duration: reduceMotion ? Duration.zero : PublicMotion.fast,
              curve: PublicMotion.entranceCurve,
              offset: _hovered ? const Offset(.18, 0) : Offset.zero,
              child: const Icon(Icons.arrow_outward_rounded, size: 16),
            ),
          ],
        ),
      ),
    );
  }
}

class _BackToTopButton extends StatelessWidget {
  const _BackToTopButton();

  @override
  Widget build(BuildContext context) => IconButton(
    onPressed: () {
      final controller = PrimaryScrollController.maybeOf(context);
      if (controller?.hasClients ?? false) {
        controller!.animateTo(
          0,
          duration: MediaQuery.disableAnimationsOf(context)
              ? Duration.zero
              : PublicMotion.slow,
          curve: PublicMotion.entranceCurve,
        );
      } else {
        context.go('/');
      }
    },
    tooltip: 'Voltar ao topo',
    constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
    style: IconButton.styleFrom(
      foregroundColor: PublicEditorialColors.noir,
      backgroundColor: PublicEditorialColors.ivory,
      side: BorderSide(
        color: PublicEditorialColors.champagne.withValues(alpha: .72),
      ),
    ),
    icon: const Icon(Icons.arrow_upward_rounded, size: 20),
  );
}
