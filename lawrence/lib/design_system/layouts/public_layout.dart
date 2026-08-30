import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/controllers/auth_controller.dart';
import '../motion/public_motion.dart';
import '../public/public_editorial_colors.dart';
import '../public/public_glass_button.dart';
import '../public/public_refractive_glass.dart';
import '../public/public_editorial_typography.dart';

String publicAccountDestination(String? role) =>
    role == 'teacher' || role == 'super_admin' ? '/teacher' : '/dashboard/home';

class PublicLayout extends ConsumerStatefulWidget {
  const PublicLayout({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<PublicLayout> createState() => _PublicLayoutState();
}

class _PublicLayoutState extends ConsumerState<PublicLayout> {
  bool _scrolled = false;

  bool _handleScroll(ScrollNotification notification) {
    if (notification.depth != 0) return false;
    final next = notification.metrics.pixels > 18;
    if (next != _scrolled) setState(() => _scrolled = next);
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authNotifierProvider).user;
    final role = user?.appMetadata['role'] as String?;
    final authenticated = user != null;
    final accountDestination = publicAccountDestination(role);

    return Scaffold(
      backgroundColor: PublicEditorialColors.noir,
      body: Stack(
        children: [
          Positioned.fill(
            child: NotificationListener<ScrollNotification>(
              onNotification: _handleScroll,
              child: widget.child,
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _PublicHeader(
              authenticated: authenticated,
              accountDestination: accountDestination,
              scrolled: _scrolled,
              onMenuPressed: () => _openNavigation(
                context,
                authenticated: authenticated,
                accountDestination: accountDestination,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openNavigation(
    BuildContext context, {
    required bool authenticated,
    required String accountDestination,
  }) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    return showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Fechar navegação principal',
      barrierColor: PublicEditorialColors.noir.withValues(alpha: 0.64),
      transitionDuration: reduceMotion ? Duration.zero : PublicMotion.standard,
      pageBuilder: (dialogContext, _, _) => _NavigationDialog(
        authenticated: authenticated,
        accountDestination: accountDestination,
      ),
      transitionBuilder: (context, animation, _, child) {
        if (reduceMotion) return child;
        final curved = CurvedAnimation(
          parent: animation,
          curve: PublicMotion.entranceCurve,
          reverseCurve: PublicMotion.exitCurve,
        );
        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.985, end: 1).animate(curved),
            alignment: Alignment.topRight,
            child: child,
          ),
        );
      },
    );
  }
}

class _PublicHeader extends StatelessWidget {
  const _PublicHeader({
    required this.authenticated,
    required this.accountDestination,
    required this.onMenuPressed,
    required this.scrolled,
  });

  final bool authenticated;
  final String accountDestination;
  final VoidCallback onMenuPressed;
  final bool scrolled;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final compact = width < 900;
    return SafeArea(
      bottom: false,
      child: PublicRefractiveGlass(
        elevated: scrolled,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 72),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: compact ? 20 : 48),
            child: Row(
              children: [
                _BrandButton(onPressed: () => context.go('/')),
                const Spacer(),
                if (!compact) ...[
                  _HeaderLink(
                    label: 'CURSOS',
                    onPressed: () => context.go('/courses'),
                  ),
                  const SizedBox(width: 6),
                  _HeaderLink(
                    label: authenticated ? 'MINHA CONTA' : 'ENTRAR',
                    onPressed: () => context.go(
                      authenticated ? accountDestination : '/login',
                    ),
                  ),
                  const SizedBox(width: 12),
                  PublicGlassButton(
                    label: 'Explorar cursos',
                    onPressed: () => context.go('/courses'),
                  ),
                  const SizedBox(width: 10),
                ],
                IconButton(
                  onPressed: onMenuPressed,
                  tooltip: 'Abrir menu',
                  constraints: const BoxConstraints(
                    minWidth: 48,
                    minHeight: 48,
                  ),
                  color: PublicEditorialColors.ink,
                  icon: const Icon(Icons.menu_rounded),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BrandButton extends StatelessWidget {
  const _BrandButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Ir para o início da Lawrence Academy',
      child: InkWell(
        onTap: onPressed,
        focusColor: PublicEditorialColors.antiqueRose,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'LAWRENCE',
                style: PublicEditorialTypography.sectionDisplay(
                  color: PublicEditorialColors.ink,
                  size: 25,
                ),
              ),
              Text(
                'ACADEMY',
                style: PublicEditorialTypography.eyebrow(
                  color: PublicEditorialColors.wine,
                ).copyWith(fontSize: 9, letterSpacing: 3.2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderLink extends StatefulWidget {
  const _HeaderLink({
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  State<_HeaderLink> createState() => _HeaderLinkState();
}

class _HeaderLinkState extends State<_HeaderLink> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: reduceMotion ? Duration.zero : PublicMotion.fast,
        curve: PublicMotion.entranceCurve,
        decoration: BoxDecoration(
          color: _hovered
              ? PublicEditorialColors.wine.withValues(alpha: 0.07)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(2),
        ),
        child: TextButton(
          onPressed: widget.onPressed,
          style: TextButton.styleFrom(
            minimumSize: const Size(74, 48),
            padding: const EdgeInsets.symmetric(horizontal: 18),
            foregroundColor: PublicEditorialColors.ink,
            overlayColor: PublicEditorialColors.wine.withValues(alpha: 0.08),
            textStyle: PublicEditorialTypography.buttonLabel(
              color: PublicEditorialColors.ink,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(widget.label),
              const SizedBox(height: 3),
              AnimatedContainer(
                duration: reduceMotion ? Duration.zero : PublicMotion.fast,
                curve: PublicMotion.entranceCurve,
                width: _hovered ? 22 : 4,
                height: 1,
                color: PublicEditorialColors.wine.withValues(
                  alpha: _hovered ? 0.88 : 0.34,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavigationDialog extends StatelessWidget {
  const _NavigationDialog({
    required this.authenticated,
    required this.accountDestination,
  });

  final bool authenticated;
  final String accountDestination;

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      backgroundColor: PublicEditorialColors.noir,
      child: SafeArea(
        child: FocusTraversalGroup(
          policy: OrderedTraversalPolicy(),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 18, 24, 34),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'NAVEGAÇÃO',
                      style: PublicEditorialTypography.eyebrow(
                        color: PublicEditorialColors.champagne,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      autofocus: true,
                      onPressed: () => Navigator.of(context).pop(),
                      tooltip: 'Fechar navegação principal',
                      constraints: const BoxConstraints(
                        minWidth: 48,
                        minHeight: 48,
                      ),
                      color: PublicEditorialColors.ivory,
                      icon: const Icon(Icons.close, size: 30),
                    ),
                  ],
                ),
                const Spacer(),
                _DialogLink(label: 'Início', route: '/'),
                _DialogLink(label: 'Cursos', route: '/courses'),
                _DialogLink(
                  label: authenticated ? 'Minha conta' : 'Entrar',
                  route: authenticated ? accountDestination : '/login',
                ),
                const Spacer(),
                Text(
                  'Técnica que se transforma em assinatura.',
                  style: PublicEditorialTypography.body(
                    color: PublicEditorialColors.champagne,
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

class _DialogLink extends StatelessWidget {
  const _DialogLink({required this.label, required this.route});

  final String label;
  final String route;

  @override
  Widget build(BuildContext context) {
    final size = (MediaQuery.sizeOf(context).width * 0.14).clamp(52.0, 84.0);
    return Semantics(
      button: true,
      child: InkWell(
        onTap: () {
          Navigator.of(context).pop();
          context.go(route);
        },
        focusColor: PublicEditorialColors.antiqueRose.withValues(alpha: 0.5),
        hoverColor: PublicEditorialColors.antiqueRose.withValues(alpha: 0.24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 64),
          child: Text(
            label,
            style: PublicEditorialTypography.sectionDisplay(
              color: PublicEditorialColors.ivory,
              size: size,
            ),
          ),
        ),
      ),
    );
  }
}
