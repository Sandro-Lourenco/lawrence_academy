import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/controllers/auth_controller.dart';
import '../tokens/lawrence_theme.dart';

const _ink = LawrenceColors.textPrimary;
const _ivory = LawrenceColors.canvas;
const _gold = LawrenceColors.actionPrimary;
const _headerSurface = Color(0xFFEEF2FF);

String publicAccountDestination(String? role) =>
    role == 'teacher' || role == 'super_admin' ? '/teacher' : '/dashboard/home';

class PublicLayout extends ConsumerStatefulWidget {
  final Widget child;

  const PublicLayout({super.key, required this.child});

  @override
  ConsumerState<PublicLayout> createState() => _PublicLayoutState();
}

class _PublicLayoutState extends ConsumerState<PublicLayout> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authNotifierProvider).user;
    final role = user?.appMetadata['role'] as String?;

    return LayoutBuilder(
      builder: (context, constraints) {
        final mobile = constraints.maxWidth < LawrenceBreakpoints.tablet;
        final desktop =
            constraints.maxWidth >= LawrenceBreakpoints.desktop;
        return Scaffold(
          backgroundColor: _ivory,
          drawer: mobile
              ? _PublicDrawer(
                  authenticated: user != null,
                  accountDestination: publicAccountDestination(role),
                )
              : null,
          body: Column(
            children: [
              _PublicHeader(
                searchController: _searchController,
                desktop: desktop,
                mobile: mobile,
                authenticated: user != null,
                accountDestination: publicAccountDestination(role),
                onSearch: _submitSearch,
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [widget.child, const _PublicFooter()],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _submitSearch(String query) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;
    context.go('/courses?q=${Uri.encodeQueryComponent(trimmed)}');
  }
}

class _PublicHeader extends StatelessWidget {
  final TextEditingController searchController;
  final bool desktop;
  final bool mobile;
  final bool authenticated;
  final String accountDestination;
  final ValueChanged<String> onSearch;

  const _PublicHeader({
    required this.searchController,
    required this.desktop,
    required this.mobile,
    required this.authenticated,
    required this.accountDestination,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _headerSurface,
      child: SafeArea(
        bottom: false,
        child: Container(
          height: mobile ? 72 : 82,
          padding: EdgeInsets.symmetric(horizontal: mobile ? 18 : 32),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: LawrenceColors.borderMist),
            ),
          ),
          child: Row(
            children: [
              if (mobile)
                Builder(
                  builder: (context) => IconButton(
                    tooltip: 'Abrir menu',
                    onPressed: () => Scaffold.of(context).openDrawer(),
                    icon: const Icon(Icons.menu, color: _ink),
                  ),
                ),
              Semantics(
                button: true,
                label: 'Lawrence Academy, ir para o início',
                child: InkWell(
                  onTap: () => context.go('/'),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: _BrandLockup(compact: mobile),
                  ),
                ),
              ),
              if (desktop) ...[
                const SizedBox(width: 48),
                Expanded(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 470),
                      child: SearchBar(
                        controller: searchController,
                        hintText: 'O que você quer aprender?',
                        onSubmitted: onSearch,
                        backgroundColor: WidgetStateProperty.all(
                          LawrenceColors.canvas,
                        ),
                        hintStyle: WidgetStateProperty.all(
                          const TextStyle(
                            color: LawrenceColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                        textStyle: WidgetStateProperty.all(
                          const TextStyle(color: _ink, fontSize: 14),
                        ),
                        side: WidgetStateProperty.all(
                          const BorderSide(
                            color: LawrenceColors.borderMist,
                          ),
                        ),
                        trailing: [
                          IconButton(
                            tooltip: 'Pesquisar',
                            onPressed: () => onSearch(searchController.text),
                            icon: const Icon(
                              Icons.search,
                              color: _ink,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 36),
              ] else
                const Spacer(),
              if (!mobile) ...[
                _NavLink(label: 'Início', route: '/'),
                _NavLink(label: 'Explorar catálogo', route: '/courses'),
                const SizedBox(width: 12),
              ],
              _SessionActions(
                authenticated: authenticated,
                accountDestination: accountDestination,
                compact: mobile,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BrandLockup extends StatelessWidget {
  final bool compact;

  const _BrandLockup({required this.compact});

  @override
  Widget build(BuildContext context) {
    final lineWidth = compact ? 30.0 : 54.0;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          compact ? 'L' : 'LAWRENCE',
          style: TextStyle(
            color: _ink,
            fontFamily: 'Georgia',
            fontSize: compact ? 24 : 21,
            letterSpacing: compact ? 0 : 2.1,
          ),
        ),
        if (!compact)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: lineWidth, height: 1, color: _ink),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 7),
                child: Text(
                  'ACADEMY',
                  style: TextStyle(
                    color: _gold,
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
              Container(width: lineWidth, height: 1, color: _ink),
            ],
          ),
      ],
    );
  }
}

class _NavLink extends StatelessWidget {
  final String label;
  final String route;

  const _NavLink({required this.label, required this.route});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
        foregroundColor: _ink,
        minimumSize: const Size(48, 48),
      ),
      onPressed: () => context.go(route),
      child: Text(label),
    );
  }
}

class _SessionActions extends StatelessWidget {
  final bool authenticated;
  final String accountDestination;
  final bool compact;

  const _SessionActions({
    required this.authenticated,
    required this.accountDestination,
    required this.compact,
  });

  @override
  Widget build(BuildContext context) {
    if (authenticated) {
      return FilledButton.icon(
        style: FilledButton.styleFrom(
          backgroundColor: LawrenceColors.actionPrimary,
          foregroundColor: LawrenceColors.canvas,
          minimumSize: const Size(48, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(LawrenceRadii.control),
          ),
        ),
        onPressed: () => context.go(accountDestination),
        icon: const Icon(Icons.account_circle_outlined, size: 18),
        label: Text(compact ? 'Conta' : 'Minha conta'),
      );
    }
    return Row(
      children: [
        if (!compact)
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: _ink,
              minimumSize: const Size(48, 48),
            ),
            onPressed: () => context.go('/login'),
            child: const Text('Entrar'),
          ),
        const SizedBox(width: 8),
        FilledButton(
          style: FilledButton.styleFrom(
          backgroundColor: LawrenceColors.actionPrimary,
          foregroundColor: LawrenceColors.canvas,
            minimumSize: const Size(48, 48),
            padding: EdgeInsets.symmetric(horizontal: compact ? 16 : 22),
            shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(LawrenceRadii.control),
            ),
          ),
          onPressed: () => context.go('/register'),
          child: Text(compact ? 'Começar' : 'Matricular'),
        ),
      ],
    );
  }
}

class _PublicDrawer extends StatelessWidget {
  final bool authenticated;
  final String accountDestination;

  const _PublicDrawer({
    required this.authenticated,
    required this.accountDestination,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: _ink,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'LAWRENCE',
                style: TextStyle(
                  color: _ivory,
                  fontFamily: 'Georgia',
                  fontSize: 28,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 32),
              _DrawerLink(label: 'Início', route: '/'),
              _DrawerLink(label: 'Explorar cursos', route: '/courses'),
              _DrawerLink(
                label: authenticated ? 'Minha conta' : 'Entrar',
                route: authenticated ? accountDestination : '/login',
              ),
              const Spacer(),
              const Text(
                'Costura • Modelagem • Moda & estilo',
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DrawerLink extends StatelessWidget {
  final String label;
  final String route;

  const _DrawerLink({required this.label, required this.route});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      minTileHeight: 56,
      title: Text(
        label,
        style: const TextStyle(
          color: _ivory,
          fontFamily: 'Georgia',
          fontSize: 24,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward, color: _gold),
      onTap: () => context.go(route),
    );
  }
}

class _PublicFooter extends StatelessWidget {
  const _PublicFooter();

  @override
  Widget build(BuildContext context) {
    final mobile =
        MediaQuery.sizeOf(context).width < LawrenceBreakpoints.tablet;
    return ColoredBox(
      color: _ink,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: mobile ? 24 : 64,
          vertical: 48,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1320),
            child: mobile
                ? const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _FooterBrand(),
                      SizedBox(height: 32),
                      _FooterLegal(),
                    ],
                  )
                : const Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    spacing: LawrenceSpacing.xl,
                    runSpacing: LawrenceSpacing.lg,
                    children: [_FooterBrand(), _FooterLegal()],
                  ),
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
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'LAWRENCE ACADEMY',
          style: TextStyle(
            color: _ivory,
            fontFamily: 'Georgia',
            fontSize: 20,
            letterSpacing: 1.4,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Formação em costura, modelagem, moda e estilo.',
          style: TextStyle(color: Colors.white54, fontSize: 13),
        ),
      ],
    );
  }
}

class _FooterLegal extends StatelessWidget {
  const _FooterLegal();

  @override
  Widget build(BuildContext context) {
    return const Text(
      '© 2026 Lawrence Academy  •  Privacidade  •  Termos',
      style: TextStyle(color: Colors.white54, fontSize: 12),
    );
  }
}
