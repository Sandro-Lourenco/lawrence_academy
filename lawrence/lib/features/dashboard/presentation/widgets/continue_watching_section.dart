import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../design_system/tokens/lawrence_theme.dart';
import '../../../../design_system/widgets/couture_primary_button.dart';
import '../../../../design_system/widgets/couture_progress_bar.dart';
import '../../../courses/domain/entities/course.dart';
import '../../domain/entities/learning_resume_target.dart';

class ContinueWatchingSection extends StatelessWidget {
  final Course course;
  final double progress;
  final String lessonTitle;
  final LearningResumeView view;
  final String destination;

  const ContinueWatchingSection({
    super.key,
    required this.course,
    required this.progress,
    required this.lessonTitle,
    required this.view,
    required this.destination,
  });

  @override
  Widget build(BuildContext context) {
    final normalizedProgress = progress.clamp(0.0, 100.0).toDouble() / 100;
    final hasStarted = progress > 0;
    final isComplete = normalizedProgress >= .999;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    return Semantics(
      container: true,
      label:
          'Curso em andamento, ${course.title}, ${progress.round()} por cento concluído.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              _StatusDot(complete: isComplete),
              const SizedBox(width: LawrenceSpacing.sm),
              Text(
                isComplete ? 'CURSO CONCLUÍDO' : 'CONTINUE DE ONDE PAROU',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 12,
                  letterSpacing: .9,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: LawrenceSpacing.md),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? LawrenceColors.darkSurface
                  : LawrenceColors.surfaceBlack,
              border: Border(
                top: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                  width: 3,
                ),
                bottom: BorderSide(
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxWidth < 720;
                final details = Padding(
                  padding: EdgeInsets.all(compact ? 28 : 44),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        course.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.displayMedium
                            ?.copyWith(
                              color: LawrenceColors.canvas,
                              fontWeight: FontWeight.w400,
                              height: .98,
                            ),
                      ),
                      const SizedBox(height: LawrenceSpacing.sm),
                      Text(
                        hasStarted
                            ? 'Último conteúdo: ${view.label} · $lessonTitle'
                            : 'Próximo conteúdo: $lessonTitle',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: LawrenceColors.canvasParchment,
                        ),
                      ),
                      const SizedBox(height: LawrenceSpacing.lg),
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: normalizedProgress),
                        duration: reduceMotion
                            ? Duration.zero
                            : const Duration(milliseconds: 420),
                        curve: Curves.easeOutCubic,
                        builder: (context, value, _) => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${(value * 100).round()}% concluído',
                              style: Theme.of(context).textTheme.labelLarge
                                  ?.copyWith(
                                    color: LawrenceColors.darkTextPrimary,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: .6,
                                  ),
                            ),
                            const SizedBox(height: LawrenceSpacing.xs),
                            CoutureProgressBar(
                              value: value,
                              height: 7,
                              semanticLabel: 'Progresso em ${course.title}',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: LawrenceSpacing.lg),
                      CouturePrimaryButton(
                        key: const Key('continue-from-last-position'),
                        onPressed: () => context.go(destination),
                        icon: Icons.play_circle_outline_rounded,
                        label: isComplete
                            ? 'Rever curso'
                            : hasStarted
                            ? 'Continuar de onde parou'
                            : 'Começar curso',
                      ),
                    ],
                  ),
                );
                final progressVisual = SizedBox(
                  width: compact ? double.infinity : 360,
                  height: compact ? 220 : null,
                  child: Image.asset(
                    'assets/images/couture_draping_portrait.webp',
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                  ),
                );
                return compact
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [progressVisual, details],
                      )
                    : IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(child: details),
                            progressVisual,
                          ],
                        ),
                      );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusDot extends StatelessWidget {
  const _StatusDot({required this.complete});

  final bool complete;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: complete
            ? Theme.of(context).colorScheme.primary
            : LawrenceColors.success,
        shape: BoxShape.circle,
      ),
    );
  }
}
