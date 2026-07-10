import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme.dart';

class PublicLayout extends StatelessWidget {
  final Widget child;

  const PublicLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 600;

    return Scaffold(
      backgroundColor: LiquidTheme.background,
      body: Column(
        children: [
          // 1. Header: GlobalNavBar preta absoluta (44px)
          Container(
            height: 44,
            color: Colors.black,
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Minimalist Logo & Brand
                GestureDetector(
                  onTap: () => context.go('/'),
                  child: Row(
                    children: [
                      Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          gradient: LiquidTheme.auraGradient,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Icon(Icons.auto_awesome, color: Colors.white, size: 10),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        "LAWRENCE ACADEMY",
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Navigation Links
                if (!isMobile)
                  Row(
                    children: [
                      _buildNavLink(context, "Início", '/'),
                      const SizedBox(width: 24),
                      _buildNavLink(context, "Catálogo", '/courses'),
                      const SizedBox(width: 24),
                      _buildNavLink(context, "Depoimentos", '/'),
                    ],
                  ),

                // Auth CTAs
                Row(
                  children: [
                    TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white70,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                      onPressed: () => context.go('/login'),
                      child: const Text("Entrar", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: LiquidTheme.primary,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        minimumSize: const Size(0, 26),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => context.go('/register'),
                      child: const Text("Matricular", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 2. Flexible Body Canvas
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Center(
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 1440),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                      child: child,
                    ),
                  ),

                  // 3. Footer: InstitutionalFooter em pergaminho (#F8F9FB)
                  Container(
                    width: double.infinity,
                    color: const Color(0xFFF8F9FB),
                    padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
                    child: Center(
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 1440),
                        child: Column(
                          children: [
                            if (isMobile) ...[
                              const Column(
                                children: [
                                  Text(
                                    "Lawrence Academy • Alta Costura & Modelagem",
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text("Termos de Uso", style: TextStyle(fontSize: 11, color: Colors.black54)),
                                      SizedBox(width: 16),
                                      Text("Privacidade", style: TextStyle(fontSize: 11, color: Colors.black54)),
                                    ],
                                  ),
                                ],
                              ),
                              const Divider(color: Colors.black12, height: 32),
                              const Column(
                                children: [
                                  Text(
                                    "© 2026 Lawrence Academy. Todos os direitos reservados.",
                                    style: TextStyle(fontSize: 11, color: Colors.black38),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    "Desenvolvido sob diretrizes Apple Design System",
                                    style: TextStyle(fontSize: 11, color: Colors.black38),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ] else ...[
                              const Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Lawrence Academy • Alta Costura & Modelagem",
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Text("Termos de Uso", style: TextStyle(fontSize: 11, color: Colors.black54)),
                                      SizedBox(width: 16),
                                      Text("Privacidade", style: TextStyle(fontSize: 11, color: Colors.black54)),
                                    ],
                                  ),
                                ],
                              ),
                              const Divider(color: Colors.black12, height: 40),
                              const Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "© 2026 Lawrence Academy. Todos os direitos reservados.",
                                    style: TextStyle(fontSize: 11, color: Colors.black38),
                                  ),
                                  Text(
                                    "Desenvolvido sob diretrizes Apple Design System",
                                    style: TextStyle(fontSize: 11, color: Colors.black38),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavLink(BuildContext context, String title, String route) {
    return InkWell(
      onTap: () => context.go(route),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white70,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
