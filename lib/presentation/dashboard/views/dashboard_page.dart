import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lawrence/core/theme.dart';
import 'package:lawrence/presentation/auth/controllers/auth_controller.dart';
import 'package:lawrence/presentation/dashboard/controllers/dashboard_controller.dart';
import 'package:lawrence/shared/widgets/liquid_glass_card.dart';

class StudentDashboardPage extends ConsumerWidget {
  const StudentDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final authState = ref.watch(authControllerProvider);
    final dashboardAsync = ref.watch(dashboardControllerProvider);

    // BOLA safe name extraction
    final studentName = authState.user?.userMetadata?['full_name'] as String? ?? 'Prof. Marlene';

    return Scaffold(
      backgroundColor: Colors.transparent, // Permite visualizar o gradiente/vidro do layout shell
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Navegando para catálogo de novas turmas...'),
              behavior: SnackBarBehavior.floating,
            ),
          );
          context.go('/courses');
        },
        backgroundColor: LawrenceTheme.primary,
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, size: 28),
      ),
      body: dashboardAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: LawrenceTheme.primary),
        ),
        error: (err, stack) => Center(
          child: Text(
            'Erro ao carregar o painel: $err',
            style: const TextStyle(color: LawrenceTheme.danger),
          ),
        ),
        data: (state) {
          // Regra 1: Responsividade Total com SingleChildScrollView
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Regra 2: Liquid Glass no Cabeçalho (Top App Bar) usando o padrão estrito
                  Container(
                    width: double.infinity, // Sem largura fixa
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.72),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withOpacity(0.28)),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 24,
                                          height: 24,
                                          decoration: BoxDecoration(
                                            color: LawrenceTheme.accent,
                                            shape: BoxShape.circle,
                                            border: Border.all(color: Colors.white, width: 1),
                                          ),
                                          child: const Center(
                                            child: Text(
                                              'L',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            'LAWRENCE ACADEMY',
                                            style: theme.textTheme.titleLarge?.copyWith(
                                              letterSpacing: 1.5,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w900,
                                              color: LawrenceTheme.surfaceTile1,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  // Ícone de Notificações com Badge
                                  Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.notifications_none_outlined, size: 24),
                                        onPressed: () {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Você tem 3 novas atividades hoje!')),
                                          );
                                        },
                                      ),
                                      Positioned(
                                        top: 6,
                                        right: 6,
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: const BoxDecoration(
                                            color: LawrenceTheme.primary,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Text(
                                            '3',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 8,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 4),
                                  const CircleAvatar(
                                    radius: 16,
                                    backgroundColor: LawrenceTheme.borderMist,
                                    backgroundImage: NetworkImage('https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Boas-vindas
                  Text(
                    'Olá, $studentName! 👋',
                    style: theme.textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 26,
                      color: LawrenceTheme.surfaceTile1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Aqui está o resumo das suas turmas e atividades.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: LawrenceTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 3. Bloco "Visão geral" Estilo Vidro Profissional
                  LiquidGlassCard(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: LawrenceTheme.primary,
                                    borderRadius: BorderRadius.circular(LawrenceTheme.radiusSm),
                                  ),
                                  child: const Icon(
                                    Icons.school_outlined,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Visão geral',
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            DropdownButton<String>(
                              value: 'Este mês',
                              underline: const SizedBox(),
                              icon: const Icon(Icons.keyboard_arrow_down, size: 18),
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: LawrenceTheme.textSecondary,
                              ),
                              items: const [
                                DropdownMenuItem(value: 'Este mês', child: Text('Este mês')),
                                DropdownMenuItem(value: 'Este ano', child: Text('Este ano')),
                              ],
                              onChanged: (_) {},
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildStatItem(context, value: '1.248', label: 'Alunos ativos', delta: '↑ 12%'),
                            _buildStatItem(context, value: '32', label: 'Turmas ativas', delta: '↑ 8%'),
                            _buildStatItem(context, value: '78%', label: 'Taxa de conclusão', delta: '↑ 15%'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Seção Minhas turmas
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Minhas turmas',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: LawrenceTheme.surfaceTile1,
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.go('/courses'),
                        child: Text(
                          'Ver todas',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: LawrenceTheme.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Lista de Cursos/Turmas
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: state.courses.length,
                    itemBuilder: (context, index) {
                      final course = state.courses[index];
                      final progress = (index == 0) ? 0.76 : (index == 1 ? 0.64 : 0.58);
                      
                      // Regra 3: LiquidGlassCard com interatividade e animação de escala de 0.97
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: LiquidGlassCard(
                          padding: const EdgeInsets.all(12.0),
                          onTap: () {
                            if (course.modules.isNotEmpty && course.modules.first.lessons.isNotEmpty) {
                              final lessonId = course.modules.first.lessons.first.id;
                              context.go('/dashboard/courses/${course.id}/lesson/$lessonId');
                            } else {
                              context.go('/courses');
                            }
                          },
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Miniatura
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        LawrenceTheme.primary.withOpacity(0.4),
                                        LawrenceTheme.accent.withOpacity(0.4),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.design_services_outlined,
                                      color: LawrenceTheme.surfaceTile1,
                                      size: 32,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              
                              // Detalhes responsivos (Expanded)
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      course.title,
                                      style: theme.textTheme.titleLarge?.copyWith(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800,
                                        color: LawrenceTheme.surfaceTile1,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Turma 0${index + 1} • 2${8 - index * 2} alunos',
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(LawrenceTheme.radiusXs),
                                            child: LinearProgressIndicator(
                                              value: progress,
                                              backgroundColor: LawrenceTheme.borderMist,
                                              valueColor: const AlwaysStoppedAnimation<Color>(LawrenceTheme.primary),
                                              minHeight: 5,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          '${(progress * 100).round()}%',
                                          style: theme.textTheme.bodySmall?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: LawrenceTheme.surfaceTile1,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.more_horiz, color: LawrenceTheme.textSecondary),
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Configurações da turma ${course.title}...')),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required String value,
    required String label,
    required String delta,
  }) {
    final theme = Theme.of(context);
    
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: LawrenceTheme.surfaceTile1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: LawrenceTheme.textSecondary,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Text(
            delta,
            style: theme.textTheme.labelSmall?.copyWith(
              color: LawrenceTheme.primary,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
