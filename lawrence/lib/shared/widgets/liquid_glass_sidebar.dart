import 'package:flutter/material.dart';
import 'package:lawrence/core/theme.dart';
import 'liquid_glass_container.dart';

class LiquidGlassSidebar extends StatelessWidget {
  final String currentPath;
  final Function(String path) onNavigate;

  const LiquidGlassSidebar({
    super.key,
    required this.currentPath,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LiquidGlassContainer(
      borderRadius: 24.0,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
      backgroundColor: Colors.white.withValues(alpha: 0.72),
      borderColor: Colors.white.withValues(alpha: 0.28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header / Logo minimalista
          Padding(
            padding: const EdgeInsets.only(left: 8.0, bottom: 32.0),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: LawrenceTheme.primary,
                    borderRadius: BorderRadius.circular(LawrenceTheme.radiusXs),
                  ),
                  child: const Center(
                    child: Text(
                      'L',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'LAWRENCE',
                  style: theme.textTheme.titleLarge?.copyWith(
                    letterSpacing: 1.5,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),

          // Itens de Navegação
          _buildNavItem(
            context,
            icon: Icons.dashboard_outlined,
            activeIcon: Icons.dashboard,
            label: 'Dashboard',
            path: '/dashboard/home',
          ),
          _buildNavItem(
            context,
            icon: Icons.school_outlined,
            activeIcon: Icons.school,
            label: 'Meus Cursos',
            path: '/dashboard/courses',
          ),
          _buildNavItem(
            context,
            icon: Icons.card_membership_outlined,
            activeIcon: Icons.card_membership,
            label: 'Certificados',
            path: '/admin/analytics', // Rota temporária ou placeholder
          ),
          _buildNavItem(
            context,
            icon: Icons.payment_outlined,
            activeIcon: Icons.payment,
            label: 'Pagamentos',
            path: '/payments', // Rota temporária ou placeholder
          ),

          const Spacer(),

          // Perfil do Aluno (Fundo do Sidebar)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(LawrenceTheme.radiusMd),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  backgroundColor: LawrenceTheme.borderMist,
                  child: Icon(Icons.person, color: LawrenceTheme.surfaceTile1),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ariane L.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Assinante Ativa',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: LawrenceTheme.accent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required String path,
  }) {
    final theme = Theme.of(context);
    final isActive = currentPath == path;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: InkWell(
        onTap: () => onNavigate(path),
        borderRadius: BorderRadius.circular(LawrenceTheme.radiusSm),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          decoration: BoxDecoration(
            color: isActive
                ? LawrenceTheme.primary.withValues(alpha: 0.08)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(LawrenceTheme.radiusSm),
          ),
          child: Row(
            children: [
              Icon(
                isActive ? activeIcon : icon,
                color: isActive
                    ? LawrenceTheme.primary
                    : LawrenceTheme.surfaceTile1,
                size: 22,
              ),
              const SizedBox(width: 16),
              Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                  color: isActive
                      ? LawrenceTheme.primary
                      : LawrenceTheme.surfaceTile1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
