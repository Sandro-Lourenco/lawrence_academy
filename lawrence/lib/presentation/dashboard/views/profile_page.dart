import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lawrence/core/theme.dart';
import 'package:lawrence/presentation/auth/controllers/auth_controller.dart';
import 'package:lawrence/shared/widgets/liquid_glass_card.dart';

class StudentProfilePage extends ConsumerWidget {
  const StudentProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final authState = ref.watch(authControllerProvider);
    final user = authState.user;
    
    final studentName = user?.userMetadata?['full_name'] as String? ?? 'Ariane Lawrence';
    final studentRole = 'Aluna de Modelagem & Design';

    return Scaffold(
      backgroundColor: Colors.transparent, // Permite visualizar o canvas claro do layout shell
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Cabeçalho Superior (Logo e Configurações) exatamente como na Imagem 2
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'LAWRENCE',
                        style: theme.textTheme.titleLarge?.copyWith(
                          letterSpacing: 2.0,
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: LawrenceTheme.surfaceTile1,
                          fontFamily: 'Outfit',
                        ),
                      ),
                      Text(
                        'ACADEMY',
                        style: theme.textTheme.labelSmall?.copyWith(
                          letterSpacing: 1.2,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: LawrenceTheme.accent,
                          fontFamily: 'Outfit',
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings, color: LawrenceTheme.surfaceTile1),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: const Text('Abrindo configurações gerais...')),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // 2. Perfil Central (Avatar e Nomes)
              Center(
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 54,
                      backgroundColor: LawrenceTheme.borderMist,
                      backgroundImage: NetworkImage('https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150'),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      studentName,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 22,
                        color: LawrenceTheme.surfaceTile1,
                        fontFamily: 'Outfit',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      studentRole,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: LawrenceTheme.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Outfit',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // 3. Seção "Minha Conta" (Cards com itens e chevrons)
              Text(
                'Minha Conta',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: LawrenceTheme.surfaceTile1,
                  fontFamily: 'Outfit',
                ),
              ),
              const SizedBox(height: 12),
              
              // Bloco integrado de itens em um Liquid Glass Container
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.72),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withOpacity(0.28)),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                    child: Column(
                      children: [
                        _buildAccountItem(
                          context,
                          icon: Icons.person_outline,
                          title: 'Editar Dados Pessoais',
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: const Text('Navegando para edição de perfil...')),
                            );
                          },
                        ),
                        _buildAccountItem(
                          context,
                          icon: Icons.lock_outline,
                          title: 'Segurança e Senha',
                          onTap: () {},
                        ),
                        _buildAccountItem(
                          context,
                          icon: Icons.notifications_none_outlined,
                          title: 'Notificações',
                          onTap: () {},
                        ),
                        _buildAccountItem(
                          context,
                          icon: Icons.security_outlined,
                          title: 'Privacidade',
                          onTap: () {},
                          showDivider: false,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // 4. Seção "Conquistas" (Cards menores horizontais)
              Text(
                'Conquistas',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: LawrenceTheme.surfaceTile1,
                  fontFamily: 'Outfit',
                ),
              ),
              const SizedBox(height: 12),
              
              Row(
                children: [
                  Expanded(
                    child: LiquidGlassCard(
                      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
                      child: Column(
                        children: [
                          const Text(
                            '4',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              color: LawrenceTheme.surfaceTile1,
                              fontFamily: 'Outfit',
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Cursos Concluídos',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: LawrenceTheme.textSecondary,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                              fontFamily: 'Outfit',
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: LiquidGlassCard(
                      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
                      child: Column(
                        children: [
                          const Text(
                            '12',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              color: LawrenceTheme.surfaceTile1,
                              fontFamily: 'Outfit',
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Certificados Disponíveis',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: LawrenceTheme.textSecondary,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                              fontFamily: 'Outfit',
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              
              // Botão Sair da Conta
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    ref.read(authControllerProvider.notifier).signOut();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: LawrenceTheme.danger.withOpacity(0.1),
                    foregroundColor: LawrenceTheme.danger,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Sair da Conta',
                    style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Outfit'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccountItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool showDivider = true,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Icon(icon, color: LawrenceTheme.surfaceTile1, size: 22),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: LawrenceTheme.surfaceTile1,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      fontFamily: 'Outfit',
                    ),
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, size: 14, color: LawrenceTheme.textSecondary),
              ],
            ),
          ),
          if (showDivider)
            const Divider(height: 1, color: LawrenceTheme.borderMist, indent: 56),
        ],
      ),
    );
  }
}
