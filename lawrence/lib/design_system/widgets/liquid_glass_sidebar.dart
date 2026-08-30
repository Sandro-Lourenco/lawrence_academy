import 'package:flutter/material.dart';

import '../icons/student_icons.dart';

/// Kept under the original public name to avoid breaking callers.
/// Content surfaces are now opaque and calm; translucency is reserved for the
/// compact mobile navigation where it provides spatial continuity.
class LiquidGlassSidebar extends StatelessWidget {
  const LiquidGlassSidebar({
    super.key,
    required this.currentPath,
    required this.onNavigate,
    this.showBrand = true,
  });

  final String currentPath;
  final ValueChanged<String> onNavigate;
  final bool showBrand;

  static const _primaryItems = <_SidebarItem>[
    _SidebarItem('Início', '/dashboard/home', StudentIcons.home),
    _SidebarItem('Cursos', '/dashboard/courses', StudentIcons.courses),
  ];

  static const _accountItems = <_SidebarItem>[
    _SidebarItem('Perfil', '/dashboard/profile', StudentIcons.profile),
    _SidebarItem('Configurações', '/dashboard/settings', StudentIcons.settings),
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ColoredBox(
      color: scheme.surface,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (showBrand) ...[
              const _SidebarBrand(),
              const SizedBox(height: 38),
            ],
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                'ESTUDAR',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.8,
                ),
              ),
            ),
            const SizedBox(height: 10),
            for (final item in _primaryItems)
              _NavigationItem(
                item: item,
                selected: _isSelected(item.path),
                onTap: () => onNavigate(item.path),
              ),
            const Spacer(),
            Divider(color: scheme.outlineVariant),
            const SizedBox(height: 8),
            for (final item in _accountItems)
              _NavigationItem(
                item: item,
                selected: currentPath.startsWith(item.path),
                onTap: () => onNavigate(item.path),
              ),
          ],
        ),
      ),
    );
  }

  bool _isSelected(String path) {
    if (path == '/dashboard/courses') {
      return currentPath.startsWith(path) ||
          currentPath.startsWith('/dashboard/search') ||
          currentPath.startsWith('/dashboard/favorites');
    }
    return currentPath.startsWith(path);
  }
}

class _SidebarBrand extends StatelessWidget {
  const _SidebarBrand();

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurface;
    return Semantics(
      label: 'Lawrence Academy',
      image: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'LAWRENCE',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: color,
              letterSpacing: 1.4,
              height: 1,
            ),
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              Container(width: 34, height: 1, color: color),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 7),
                child: Text(
                  'ACADEMY',
                  style: TextStyle(
                    color: color,
                    fontSize: 8,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.6,
                  ),
                ),
              ),
              Expanded(child: Container(height: 1, color: color)),
            ],
          ),
        ],
      ),
    );
  }
}

class _NavigationItem extends StatelessWidget {
  const _NavigationItem({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final _SidebarItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      selected: selected,
      button: true,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: InkWell(
          onTap: onTap,
          child: AnimatedContainer(
            duration: MediaQuery.disableAnimationsOf(context)
                ? Duration.zero
                : const Duration(milliseconds: 180),
            constraints: const BoxConstraints(minHeight: 48),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: selected
                  ? scheme.primary.withValues(alpha: .11)
                  : Colors.transparent,
              border: Border(
                left: BorderSide(
                  color: selected ? scheme.primary : Colors.transparent,
                  width: 2,
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  item.icon,
                  size: 21,
                  color: selected ? scheme.primary : scheme.onSurfaceVariant,
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Text(
                    item.label,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: selected ? scheme.primary : scheme.onSurface,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
                if (selected)
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 16,
                    color: scheme.primary,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SidebarItem {
  const _SidebarItem(this.label, this.path, this.icon);
  final String label;
  final String path;
  final IconData icon;
}
