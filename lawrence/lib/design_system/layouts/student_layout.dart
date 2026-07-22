import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../tokens/lawrence_theme.dart';
import '../widgets/liquid_glass_sidebar.dart';

class StudentLayout extends StatelessWidget {
  final Widget body;

  const StudentLayout({super.key, required this.body});

  static const _destinations = <_StudentDestination>[
    _StudentDestination(
      label: 'Início',
      path: '/dashboard/home',
      icon: Icons.home_outlined,
      selectedIcon: Icons.home_rounded,
    ),
    _StudentDestination(
      label: 'Cursos',
      path: '/dashboard/courses',
      icon: Icons.menu_book_outlined,
      selectedIcon: Icons.menu_book_rounded,
    ),
    _StudentDestination(
      label: 'Projetos',
      path: '/dashboard/projects',
      icon: Icons.architecture_outlined,
      selectedIcon: Icons.architecture_rounded,
    ),
    _StudentDestination(
      label: 'Conquistas',
      path: '/dashboard/achievements',
      icon: Icons.emoji_events_outlined,
      selectedIcon: Icons.emoji_events_rounded,
    ),
    _StudentDestination(
      label: 'Perfil',
      path: '/dashboard/profile',
      icon: Icons.person_outline_rounded,
      selectedIcon: Icons.person_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final currentPath = GoRouterState.of(context).uri.path;
    final selectedIndex = _selectedIndex(currentPath);
    final isDesktop = LawrenceBreakpoints.isDesktop(width);
    final isTablet = LawrenceBreakpoints.isTablet(width);

    return Scaffold(
      backgroundColor: LawrenceColors.canvasParchment,
      body: SafeArea(
        child: Row(
          children: [
            if (isDesktop)
              SizedBox(
                width: 272,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: LiquidGlassSidebar(
                    currentPath: currentPath,
                    onNavigate: context.go,
                  ),
                ),
              )
            else if (isTablet)
              NavigationRail(
                selectedIndex: selectedIndex,
                groupAlignment: -0.72,
                labelType: NavigationRailLabelType.all,
                backgroundColor: Colors.white,
                indicatorColor: LawrenceColors.primary.withValues(alpha: .10),
                selectedIconTheme: const IconThemeData(
                  color: LawrenceColors.primary,
                ),
                onDestinationSelected: (index) =>
                    context.go(_destinations[index].path),
                leading: const Padding(
                  padding: EdgeInsets.only(top: 12, bottom: 20),
                  child: _BrandMark(compact: true),
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
            Expanded(child: body),
          ],
        ),
      ),
      bottomNavigationBar: LawrenceBreakpoints.isMobile(width)
          ? NavigationBar(
              selectedIndex: selectedIndex,
              height: 72,
              backgroundColor: Colors.white,
              indicatorColor: LawrenceColors.primary.withValues(alpha: .10),
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
              onDestinationSelected: (index) =>
                  context.go(_destinations[index].path),
              destinations: [
                for (final destination in _destinations)
                  NavigationDestination(
                    icon: Icon(destination.icon),
                    selectedIcon: Icon(
                      destination.selectedIcon,
                      color: LawrenceColors.primary,
                    ),
                    label: destination.label,
                    tooltip: destination.label,
                  ),
              ],
            )
          : null,
    );
  }

  int _selectedIndex(String path) {
    for (var index = 0; index < _destinations.length; index++) {
      if (path.startsWith(_destinations[index].path)) return index;
    }
    return 0;
  }
}

class _BrandMark extends StatelessWidget {
  final bool compact;

  const _BrandMark({this.compact = false});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Lawrence Academy',
      image: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: LawrenceColors.primary,
              borderRadius: BorderRadius.circular(LawrenceTheme.radiusSm),
            ),
            alignment: Alignment.center,
            child: const Text(
              'L',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          if (!compact) ...[
            const SizedBox(width: 12),
            const Text(
              'LAWRENCE\nACADEMY',
              style: TextStyle(
                color: LawrenceColors.textPrimary,
                fontSize: 13,
                height: 1.05,
                letterSpacing: 1.4,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StudentDestination {
  final String label;
  final String path;
  final IconData icon;
  final IconData selectedIcon;

  const _StudentDestination({
    required this.label,
    required this.path,
    required this.icon,
    required this.selectedIcon,
  });
}
