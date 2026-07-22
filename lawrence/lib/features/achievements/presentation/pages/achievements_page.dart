import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../design_system/tokens/lawrence_theme.dart';
import '../../../../design_system/widgets/state_widgets.dart';
import '../../../../design_system/widgets/status_badge.dart';
import '../../../../design_system/widgets/student_page_scaffold.dart';
import '../../domain/entities/achievement.dart';
import '../../domain/entities/student_level.dart';
import '../controllers/achievements_controller.dart';

class AchievementsPage extends ConsumerWidget {
  const AchievementsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final achievements = ref.watch(achievementsNotifierProvider);
    return achievements.when(
      loading: () => const StudentPageScaffold(
        title: 'Conquistas',
        subtitle: 'Acompanhe marcos confirmados da sua aprendizagem.',
        body: SizedBox(
          height: 420,
          child: AppLoadingState(message: 'Carregando conquistas'),
        ),
      ),
      error: (_, _) => StudentPageScaffold(
        title: 'Conquistas',
        subtitle: 'Acompanhe marcos confirmados da sua aprendizagem.',
        body: SizedBox(
          height: 420,
          child: AppErrorState(
            title: 'Não foi possível carregar suas conquistas',
            message: 'Verifique sua conexão e tente novamente.',
            onRetry: () => ref
                .read(achievementsNotifierProvider.notifier)
                .loadData(),
          ),
        ),
      ),
      data: (state) => StudentPageScaffold(
        title: 'Conquistas',
        subtitle: state.achievements.isEmpty
            ? 'Seus marcos aparecerão aqui quando forem confirmados.'
            : '${state.unlockedCount} de ${state.achievements.length} conquistas desbloqueadas.',
        onRefresh: () => ref
            .read(achievementsNotifierProvider.notifier)
            .loadData(),
        body: state.achievements.isEmpty && state.level == null
            ? AppEmptyState(
                title: 'Nenhuma conquista disponível ainda',
                description:
                    'Continue avançando nos seus cursos. Exibiremos aqui apenas conquistas vinculadas ao seu progresso real.',
                icon: Icons.emoji_events_outlined,
                actionLabel: 'Ver meus cursos',
                onActionPressed: () => context.go('/dashboard/courses'),
              )
            : _AchievementsContent(state: state),
      ),
    );
  }
}

class _AchievementsContent extends StatelessWidget {
  final AchievementsState state;

  const _AchievementsContent({required this.state});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (state.level case final level?) ...[
          _LevelSummary(level: level),
          const SizedBox(height: LawrenceSpacing.xl),
        ],
        Text(
          'Minhas conquistas',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: LawrenceSpacing.md),
        if (state.achievements.isEmpty)
          const SizedBox(
            height: 280,
            child: AppEmptyState(
              title: 'Nenhuma medalha confirmada',
              description:
                  'Novas conquistas aparecerão quando o progresso for processado.',
              icon: Icons.military_tech_outlined,
            ),
          )
        else
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 1040
                  ? 3
                  : (constraints.maxWidth >= 620 ? 2 : 1);
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  mainAxisSpacing: LawrenceSpacing.md,
                  crossAxisSpacing: LawrenceSpacing.md,
                  mainAxisExtent: 238,
                ),
                itemCount: state.achievements.length,
                itemBuilder: (context, index) => _AchievementCard(
                  achievement: state.achievements[index],
                ),
              );
            },
          ),
      ],
    );
  }
}

class _LevelSummary extends StatelessWidget {
  final StudentLevel level;

  const _LevelSummary({required this.level});

  @override
  Widget build(BuildContext context) {
    final percentage = (level.progressPercentage * 100).round();
    return Semantics(
      container: true,
      label:
          '${level.title}. Nível ${level.currentLevel}. $percentage por cento para o próximo nível.',
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(LawrenceSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppStatusBadge(
                label: 'Nível ${level.currentLevel}',
                icon: Icons.workspace_premium_outlined,
                tone: AppStatusTone.info,
              ),
              const SizedBox(height: LawrenceSpacing.md),
              Text(
                level.title,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: LawrenceSpacing.lg),
              LinearProgressIndicator(
                value: level.progressPercentage,
                minHeight: 8,
                borderRadius: BorderRadius.circular(LawrenceRadii.pill),
                backgroundColor: LawrenceColors.surfaceSubtle,
                color: LawrenceColors.actionPrimary,
                semanticsLabel: 'Progresso para o próximo nível',
                semanticsValue: '$percentage%',
              ),
              const SizedBox(height: LawrenceSpacing.sm),
              Text(
                '${level.currentXP} de ${level.xpForNextLevel} pontos confirmados',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AchievementCard extends StatelessWidget {
  final Achievement achievement;

  const _AchievementCard({required this.achievement});

  @override
  Widget build(BuildContext context) {
    final unlocked = achievement.isUnlocked;
    return Semantics(
      container: true,
      label:
          '${achievement.title}. ${achievement.description}. ${unlocked ? 'Desbloqueada' : 'Bloqueada'}.',
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(LawrenceSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: unlocked
                          ? LawrenceColors.successSurface
                          : LawrenceColors.surfaceSubtle,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      unlocked
                          ? _achievementIcon(achievement.iconName)
                          : Icons.lock_outline_rounded,
                      color: unlocked
                          ? LawrenceColors.success
                          : LawrenceColors.textSecondary,
                    ),
                  ),
                  const Spacer(),
                  AppStatusBadge(
                    label: unlocked ? 'Desbloqueada' : 'Bloqueada',
                    icon: unlocked
                        ? Icons.check_circle_outline_rounded
                        : Icons.lock_outline_rounded,
                    tone: unlocked
                        ? AppStatusTone.success
                        : AppStatusTone.neutral,
                  ),
                ],
              ),
              const SizedBox(height: LawrenceSpacing.md),
              Text(
                achievement.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: LawrenceSpacing.xs),
              Text(
                achievement.description,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const Spacer(),
              Text(
                '${achievement.xpValue} pontos',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

IconData _achievementIcon(String name) {
  return switch (name) {
    'school' => Icons.school_outlined,
    'star' => Icons.star_outline_rounded,
    'emoji_events' => Icons.emoji_events_outlined,
    'timer' => Icons.timer_outlined,
    'groups' => Icons.groups_outlined,
    _ => Icons.military_tech_outlined,
  };
}
