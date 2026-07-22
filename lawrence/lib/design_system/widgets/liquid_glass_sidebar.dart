import 'package:flutter/material.dart';

import '../tokens/lawrence_theme.dart';

class LiquidGlassSidebar extends StatelessWidget {
  final String currentPath;
  final ValueChanged<String> onNavigate;

  const LiquidGlassSidebar({
    super.key,
    required this.currentPath,
    required this.onNavigate,
  });

  static const _items = <_SidebarItem>[
    _SidebarItem('Início', '/dashboard/home', Icons.home_outlined),
    _SidebarItem('Cursos', '/dashboard/courses', Icons.menu_book_outlined),
    _SidebarItem('Projetos', '/dashboard/projects', Icons.architecture_outlined),
    _SidebarItem(
      'Conquistas',
      '/dashboard/achievements',
      Icons.emoji_events_outlined,
    ),
    _SidebarItem('Perfil', '/dashboard/profile', Icons.person_outline_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(LawrenceTheme.radiusLg),
        side: const BorderSide(color: LawrenceColors.borderMist),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _SidebarBrand(),
            const SizedBox(height: 32),
            for (final item in _items)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _NavigationItem(
                  item: item,
                  selected: currentPath.startsWith(item.path),
                  onTap: () => onNavigate(item.path),
                ),
              ),
            const Spacer(),
            const Divider(),
            _NavigationItem(
              item: const _SidebarItem(
                'Configurações',
                '/dashboard/settings',
                Icons.settings_outlined,
              ),
              selected: currentPath.startsWith('/dashboard/settings'),
              onTap: () => onNavigate('/dashboard/settings'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SidebarBrand extends StatelessWidget {
  const _SidebarBrand();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Lawrence Academy',
      image: true,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: LawrenceColors.primary,
              borderRadius: BorderRadius.circular(LawrenceTheme.radiusSm),
            ),
            child: const Text(
              'L',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'LAWRENCE\nACADEMY',
              style: TextStyle(
                color: LawrenceColors.textPrimary,
                fontSize: 13,
                height: 1.05,
                letterSpacing: 1.4,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavigationItem extends StatelessWidget {
  final _SidebarItem item;
  final bool selected;
  final VoidCallback onTap;

  const _NavigationItem({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(LawrenceTheme.radiusSm),
        child: AnimatedContainer(
          duration: MediaQuery.disableAnimationsOf(context)
              ? Duration.zero
              : const Duration(milliseconds: 160),
          constraints: const BoxConstraints(minHeight: 48),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: selected
                ? LawrenceColors.primary.withValues(alpha: .10)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(LawrenceTheme.radiusSm),
          ),
          child: Row(
            children: [
              Icon(
                item.icon,
                color: selected
                    ? LawrenceColors.primary
                    : LawrenceColors.textSecondary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  item.label,
                  style: TextStyle(
                    color: selected
                        ? LawrenceColors.primary
                        : LawrenceColors.textPrimary,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
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

class _SidebarItem {
  final String label;
  final String path;
  final IconData icon;

  const _SidebarItem(this.label, this.path, this.icon);
}
