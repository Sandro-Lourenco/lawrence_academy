import 'package:flutter/material.dart';
import '../tokens/lawrence_theme.dart';
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
      backgroundColor: Colors.white.withOpacity(0.72),
      borderColor: Colors.white.withOpacity(0.28),
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
                    color: LawrenceColors.primary,
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
            path: '/courses',
          ),
          _buildNavItem(
            context,
            icon: Icons.card_membership_outlined,
            activeIcon: Icons.card_membership,
            label: 'Certificados',
            path: '/admin/analytics', // Rota temporária ou placeholder
          ),

          const Spacer(),

          // Perfil do Aluno (Fundo do Sidebar)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(LawrenceTheme.radiusMd),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  backgroundColor: LawrenceColors.borderMist,
                  child: Icon(Icons.person, color: LawrenceColors.textPrimary),
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
                          color: LawrenceColors.accentGold,
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
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isActive
                ? LawrenceColors.primary.withOpacity(0.08)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                isActive ? activeIcon : icon,
                color: isActive
                    ? LawrenceColors.primary
                    : LawrenceColors.textSecondary,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  color: isActive
                      ? LawrenceColors.primary
                      : LawrenceColors.textPrimary,
                  fontFamily: 'Inter',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
