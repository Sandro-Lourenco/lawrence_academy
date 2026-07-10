import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../tokens/lawrence_theme.dart';
import '../widgets/liquid_glass_sidebar.dart';

class StudentLayout extends StatelessWidget {
  final Widget body;

  const StudentLayout({super.key, required this.body});

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final isDesktop = media.size.width >= 768.0;
    final currentPath = GoRouterState.of(context).uri.path;

    return Scaffold(
      backgroundColor:
          LawrenceColors.canvasParchment, // Fundo principal claro #F8F9FB
      body: SafeArea(
        child: isDesktop
            ? Row(
                children: [
                  // Sidebar fixa de 260px na esquerda
                  Container(
                    width: 260,
                    height: double.infinity,
                    padding: const EdgeInsets.all(16.0),
                    child: LiquidGlassSidebar(
                      currentPath: currentPath,
                      onNavigate: (path) => context.go(path),
                    ),
                  ),

                  // Conteúdo Principal dinâmico responsivo (Expanded)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24.0,
                        vertical: 16.0,
                      ),
                      child: body,
                    ),
                  ),
                ],
              )
            : Column(
                children: [
                  // Cabeçalho para mobile
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        bottom: BorderSide(
                          color: LawrenceColors.borderMist.withOpacity(0.5),
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          backgroundColor: LawrenceColors.primary,
                          radius: 16,
                          child: Text(
                            'L',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Lawrence Academy',
                            style: Theme.of(
                              context,
                            ).textTheme.titleLarge?.copyWith(fontSize: 16),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Conteúdo do body responsivo
                  Expanded(child: body),
                ],
              ),
      ),
      // BottomNav flutuante, arredondado de 24 e de vidro (Liquid Glass) para Mobile
      bottomNavigationBar: !isDesktop
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  16.0,
                  0,
                  16.0,
                  16.0,
                ), // Floating
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.72),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white.withOpacity(0.28)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                      child: BottomNavigationBar(
                        currentIndex: _getSelectedIndex(currentPath),
                        selectedItemColor: LawrenceColors.primary,
                        unselectedItemColor: LawrenceColors.textSecondary,
                        backgroundColor: Colors
                            .transparent, // Transparência para o BackdropFilter
                        elevation: 0,
                        type: BottomNavigationBarType.fixed,
                        onTap: (index) => _onBottomNavTapped(context, index),
                        items: const [
                          BottomNavigationBarItem(
                            icon: Icon(Icons.dashboard_outlined),
                            activeIcon: Icon(Icons.dashboard),
                            label: 'Início',
                          ),
                          BottomNavigationBarItem(
                            icon: Icon(Icons.school_outlined),
                            activeIcon: Icon(Icons.school),
                            label: 'Cursos',
                          ),
                          BottomNavigationBarItem(
                            icon: Icon(Icons.sensors_outlined),
                            activeIcon: Icon(Icons.sensors),
                            label: 'Lives',
                          ),
                          BottomNavigationBarItem(
                            icon: Icon(Icons.person_outline),
                            activeIcon: Icon(Icons.person),
                            label: 'Perfil',
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            )
          : null,
    );
  }

  int _getSelectedIndex(String path) {
    if (path.startsWith('/dashboard/home')) return 0;
    if (path.startsWith('/courses')) return 1;
    if (path.startsWith('/dashboard/lives')) return 2;
    if (path.startsWith('/dashboard/profile')) return 3;
    return 0;
  }

  void _onBottomNavTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/dashboard/home');
        break;
      case 1:
        context.go('/courses');
        break;
      case 2:
        context.go('/dashboard/lives');
        break;
      case 3:
        context.go('/dashboard/profile');
        break;
    }
  }
}
