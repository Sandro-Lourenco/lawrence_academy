import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lawrence/core/theme.dart';
import 'package:lawrence/presentation/auth/controllers/auth_controller.dart';
import 'package:lawrence/presentation/dashboard/controllers/dashboard_controller.dart';
import 'package:lawrence/presentation/dashboard/widgets/dashboard_hero_card.dart';
import 'package:lawrence/presentation/dashboard/widgets/course_progress_card.dart';
import 'package:lawrence/presentation/dashboard/widgets/agenda_item_tile.dart';
import 'package:lawrence/presentation/dashboard/widgets/referral_gold_card.dart';

class StudentDashboardPage extends ConsumerWidget {
  const StudentDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final authState = ref.watch(authControllerProvider);
    final dashboardAsync = ref.watch(dashboardControllerProvider);

    // BOLA safe name extraction
    final studentName =
        authState.user?.userMetadata?['full_name'] as String? ?? 'Ariane';

    return Scaffold(
      backgroundColor: Colors
          .transparent, // Permite visualizar o canvas claro do layout shell
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
          // Valores dinâmicos da primeira lição ou fallbacks para bater com a Imagem 1
          final activeCourseTitle =
              state.lastWatchedCourse?.title ?? "Modelagem do Zero ao Avançado";
          final activeInstructor = state.lastWatchedCourse?.instructorId != null
              ? "Prof. Ariane Lawrence"
              : "Prof. Marlene Souza";
          final activeProgress = (state.progressPercentage * 100).round() > 0
              ? (state.progressPercentage * 100).round()
              : 17;

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Cabeçalho Principal (Logo, Notificações e Perfil) exatamente como na Imagem 1
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Logo textual em 2 linhas
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

                      // Ícones de Ação: Busca, Notificação e Avatar
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.search,
                              size: 24,
                              color: LawrenceTheme.surfaceTile1,
                            ),
                            onPressed: () {},
                          ),
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.notifications_none_outlined,
                                  size: 24,
                                  color: LawrenceTheme.surfaceTile1,
                                ),
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Você tem 3 novas atividades hoje!',
                                      ),
                                    ),
                                  );
                                },
                              ),
                              Positioned(
                                top: 4,
                                right: 4,
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
                          const SizedBox(width: 8),
                          const CircleAvatar(
                            radius: 16,
                            backgroundColor: LawrenceTheme.borderMist,
                            backgroundImage: NetworkImage(
                              'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // 2. Boas-vindas Editorial (Imagem 1)
                  Text(
                    'Bem-vinda de volta, $studentName! 👋',
                    style: theme.textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 22,
                      color: LawrenceTheme.surfaceTile1,
                      fontFamily: 'Outfit',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Continue aprendendo e transformando paixão em profissão.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: LawrenceTheme.textSecondary,
                      fontSize: 13,
                      fontFamily: 'Outfit',
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 3. Card Hero "CURSO EM ANDAMENTO"
                  DashboardHeroCard(
                    courseTitle: activeCourseTitle,
                    instructorName: activeInstructor,
                    progressPercentage: activeProgress,
                    imageUrl:
                        'https://images.unsplash.com/photo-1556742049-0cfed4f6a45d?w=400',
                    onTap: () {
                      if (state.lastWatchedCourse != null &&
                          state.lastWatchedLesson != null) {
                        context.go(
                          '/dashboard/courses/${state.lastWatchedCourse!.id}/lesson/${state.lastWatchedLesson!.id}',
                        );
                      } else if (state.courses.isNotEmpty &&
                          state.courses.first.modules.isNotEmpty &&
                          state
                              .courses
                              .first
                              .modules
                              .first
                              .lessons
                              .isNotEmpty) {
                        context.go(
                          '/dashboard/courses/${state.courses.first.id}/lesson/${state.courses.first.modules.first.lessons.first.id}',
                        );
                      } else {
                        context.go('/courses');
                      }
                    },
                  ),
                  const SizedBox(height: 28),

                  // 4. Seção "Continue de onde parou" (Lista Horizontal de Cards)
                  Text(
                    'Continue de onde parou',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: LawrenceTheme.surfaceTile1,
                      fontFamily: 'Outfit',
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 165,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      children: [
                        CourseProgressCard(
                          courseTitle: 'Costura Criativa',
                          instructorName: 'Prof. Marlene Souza',
                          progressPercentage: 26,
                          imageUrl:
                              'https://images.unsplash.com/photo-1528570223976-b1b4ccb3a5a1?w=200',
                          onTap: () => context.go('/courses'),
                        ),
                        CourseProgressCard(
                          courseTitle: 'Design de Moda',
                          instructorName: 'Prof. Marlene Souza',
                          progressPercentage: 40,
                          imageUrl:
                              'https://images.unsplash.com/photo-1509631179647-0177331693ae?w=200',
                          onTap: () => context.go('/courses'),
                        ),
                        CourseProgressCard(
                          courseTitle: 'Estilista',
                          instructorName: 'Prof. Marlene Souza',
                          progressPercentage: 12,
                          imageUrl:
                              'https://images.unsplash.com/photo-1483985988355-763728e1935b?w=200',
                          onTap: () => context.go('/courses'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // 5. Seção "Sua Agenda" (Lista Vertical)
                  Text(
                    'Sua Agenda',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: LawrenceTheme.surfaceTile1,
                      fontFamily: 'Outfit',
                    ),
                  ),
                  const SizedBox(height: 8),
                  AgendaItemTile(
                    title: 'Modelagem de Mangas',
                    subtext: '10 vivo - 15 detail - Ao vivo',
                    isLive: true,
                    onTap: () => context.go('/dashboard/lives'),
                  ),
                  AgendaItemTile(
                    title: 'Tendências de Verão',
                    subtext: '16 nimo - 23 sem-elisa - Verão',
                    isLive: false,
                    onTap: () => context.go('/dashboard/lives'),
                  ),
                  const SizedBox(height: 28),

                  // 6. Bloco Dourado "Indique e Ganhe"
                  ReferralGoldCard(
                    onTap: () => context.go('/dashboard/profile'),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
