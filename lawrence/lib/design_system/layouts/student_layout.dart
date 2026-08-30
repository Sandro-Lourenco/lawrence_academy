import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme_controller.dart';
import '../../features/auth/presentation/controllers/auth_controller.dart';
import '../../features/profile/presentation/widgets/student_avatar.dart';
import '../icons/student_icons.dart';
import '../tokens/lawrence_theme.dart';
import '../widgets/liquid_glass_sidebar.dart';

/// Navigation shell for the authenticated student experience.
///
/// The editorial identity lives in type, photography and spacing. Navigation
/// stays deliberately quiet so the next learning action is always the focus.
class StudentLayout extends ConsumerWidget {
  const StudentLayout({super.key, required this.body});

  final Widget body;

  static const _destinations = <_StudentDestination>[
    _StudentDestination(
      label: 'Início',
      path: '/dashboard/home',
      icon: StudentIcons.home,
      selectedIcon: StudentIcons.home,
    ),
    _StudentDestination(
      label: 'Cursos',
      path: '/dashboard/courses',
      icon: StudentIcons.courses,
      selectedIcon: StudentIcons.courses,
    ),
    _StudentDestination(
      label: 'Perfil',
      path: '/dashboard/profile',
      icon: StudentIcons.profile,
      selectedIcon: StudentIcons.profile,
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = MediaQuery.sizeOf(context).width;
    final path = GoRouterState.of(context).uri.path;
    if (path.contains('/lessons/')) return body;

    final desktop = LawrenceBreakpoints.isDesktop(width);
    final tablet = LawrenceBreakpoints.isTablet(width);
    final selectedIndex = _selectedIndex(path);
    final themeMode = ref.watch(themeModeProvider);

    Future<void> signOut() async {
      await ref.read(authNotifierProvider.notifier).signOut();
      if (context.mounted) context.go('/login');
    }

    final scaffold = Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: desktop
            ? Row(
                children: [
                  SizedBox(
                    width: 236,
                    child: LiquidGlassSidebar(
                      currentPath: path,
                      onNavigate: context.go,
                    ),
                  ),
                  VerticalDivider(
                    width: 1,
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        _StudentUtilityBar(
                          themeMode: themeMode,
                          onThemeChanged: (mode) => ref
                              .read(themeModeProvider.notifier)
                              .setMode(mode),
                          onNavigate: context.go,
                          onSignOut: signOut,
                        ),
                        Expanded(child: body),
                      ],
                    ),
                  ),
                ],
              )
            : tablet
            ? Row(
                children: [
                  NavigationRail(
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    selectedIndex: selectedIndex,
                    labelType: NavigationRailLabelType.selected,
                    onDestinationSelected: (index) =>
                        context.go(_destinations[index].path),
                    leading: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: _Monogram(),
                    ),
                    destinations: [
                      for (final destination in _destinations)
                        NavigationRailDestination(
                          icon: Icon(destination.icon),
                          selectedIcon: Icon(destination.selectedIcon),
                          label: Text(destination.label),
                        ),
                    ],
                  ),
                  VerticalDivider(
                    width: 1,
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                  Expanded(child: body),
                ],
              )
            : body,
      ),
      bottomNavigationBar: LawrenceBreakpoints.isMobile(width)
          ? _StudentBottomNavigation(
              selectedIndex: selectedIndex,
              onSelected: (index) => context.go(_destinations[index].path),
            )
          : null,
    );

    // The installed Android learning experience is intentionally light. This
    // keeps downloaded lessons and assessments visually stable even when the
    // device switches theme while the student is studying.
    if (!kIsWeb && LawrenceBreakpoints.isMobile(width)) {
      return Theme(data: LawrenceTheme.lightTheme, child: scaffold);
    }
    return scaffold;
  }

  int _selectedIndex(String path) {
    if (path.startsWith('/dashboard/courses') ||
        path.startsWith('/dashboard/search') ||
        path.startsWith('/dashboard/favorites') ||
        path.startsWith('/dashboard/subscriptions') ||
        path.startsWith('/dashboard/invoices')) {
      return 1;
    }
    if (path.startsWith('/dashboard/projects') ||
        path.startsWith('/dashboard/activities') ||
        path.startsWith('/dashboard/feedbacks')) {
      return 1;
    }
    if (path.startsWith('/dashboard/profile') ||
        path.startsWith('/dashboard/settings') ||
        path.startsWith('/dashboard/achievements') ||
        path.startsWith('/dashboard/certificates') ||
        path.startsWith('/dashboard/referral')) {
      return 2;
    }
    return 0;
  }
}

class _StudentUtilityBar extends StatelessWidget {
  const _StudentUtilityBar({
    required this.themeMode,
    required this.onThemeChanged,
    required this.onNavigate,
    required this.onSignOut,
  });

  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeChanged;
  final ValueChanged<String> onNavigate;
  final Future<void> Function() onSignOut;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 28),
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border(bottom: BorderSide(color: scheme.outlineVariant)),
      ),
      child: Row(
        children: [
          Expanded(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: SearchBar(
                hintText: 'Buscar cursos e aulas',
                leading: const Icon(StudentIcons.search),
                elevation: const WidgetStatePropertyAll(0),
                backgroundColor: WidgetStatePropertyAll(
                  scheme.surfaceContainerHighest,
                ),
                side: WidgetStatePropertyAll(
                  BorderSide(color: scheme.outlineVariant),
                ),
                onSubmitted: (query) {
                  final value = query.trim();
                  if (value.isNotEmpty) {
                    onNavigate(
                      '/dashboard/courses?q=${Uri.encodeQueryComponent(value)}',
                    );
                  }
                },
              ),
            ),
          ),
          const SizedBox(width: 20),
          PopupMenuButton<_ProfileAction>(
            tooltip: 'Abrir menu da conta',
            offset: const Offset(0, 52),
            onSelected: (action) async {
              switch (action) {
                case _ProfileAction.profile:
                  onNavigate('/dashboard/profile');
                  return;
                case _ProfileAction.certificates:
                  onNavigate('/dashboard/certificates');
                  return;
                case _ProfileAction.settings:
                  onNavigate('/dashboard/settings');
                  return;
                case _ProfileAction.theme:
                  onThemeChanged(
                    themeMode == ThemeMode.dark
                        ? ThemeMode.light
                        : ThemeMode.dark,
                  );
                  return;
                case _ProfileAction.logout:
                  await onSignOut();
                  return;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: _ProfileAction.profile,
                child: _MenuLabel(StudentIcons.profile, 'Meu perfil'),
              ),
              const PopupMenuItem(
                value: _ProfileAction.certificates,
                child: _MenuLabel(StudentIcons.certificates, 'Certificados'),
              ),
              const PopupMenuItem(
                value: _ProfileAction.settings,
                child: _MenuLabel(StudentIcons.settings, 'Preferências'),
              ),
              PopupMenuItem(
                value: _ProfileAction.theme,
                child: _MenuLabel(
                  themeMode == ThemeMode.dark
                      ? Icons.light_mode_outlined
                      : Icons.dark_mode_outlined,
                  themeMode == ThemeMode.dark ? 'Tema claro' : 'Tema escuro',
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: _ProfileAction.logout,
                child: _MenuLabel(Icons.logout_rounded, 'Sair'),
              ),
            ],
            child: const StudentAvatar(radius: 21),
          ),
        ],
      ),
    );
  }
}

class _StudentBottomNavigation extends StatelessWidget {
  const _StudentBottomNavigation({
    required this.selectedIndex,
    required this.onSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return RepaintBoundary(
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: NavigationBar(
            selectedIndex: selectedIndex,
            height: 72,
            backgroundColor: scheme.surface.withValues(alpha: .94),
            indicatorColor: scheme.primary.withValues(alpha: .13),
            onDestinationSelected: onSelected,
            destinations: [
              for (final destination in StudentLayout._destinations)
                NavigationDestination(
                  icon: Icon(destination.icon),
                  selectedIcon: Icon(destination.selectedIcon),
                  label: destination.label,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuLabel extends StatelessWidget {
  const _MenuLabel(this.icon, this.label);
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
    children: [Icon(icon, size: 20), const SizedBox(width: 12), Text(label)],
  );
}

class _Monogram extends StatelessWidget {
  const _Monogram();

  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Lawrence Academy',
    image: true,
    child: Text(
      'L',
      style: Theme.of(context).textTheme.displaySmall?.copyWith(
        color: Theme.of(context).colorScheme.onSurface,
      ),
    ),
  );
}

enum _ProfileAction { profile, certificates, settings, theme, logout }

class _StudentDestination {
  const _StudentDestination({
    required this.label,
    required this.path,
    required this.icon,
    required this.selectedIcon,
  });

  final String label;
  final String path;
  final IconData icon;
  final IconData selectedIcon;
}
