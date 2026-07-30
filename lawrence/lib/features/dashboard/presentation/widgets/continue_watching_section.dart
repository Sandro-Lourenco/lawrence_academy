import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../design_system/tokens/lawrence_theme.dart';
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
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    return Semantics(
      container: true,
      label:
          'Curso em andamento, ${course.title}, ${progress.round()} por cento concluído.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Row(
            children: [
              _StatusDot(),
              SizedBox(width: LawrenceSpacing.sm),
              Text(
                'CURSO EM ANDAMENTO',
                style: TextStyle(
                  color: LawrenceColors.textSecondary,
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
              color: LawrenceColors.canvas,
              border: Border.all(color: LawrenceColors.borderMist),
              borderRadius: BorderRadius.circular(LawrenceRadii.control),
            ),
            clipBehavior: Clip.antiAlias,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxWidth < 720;
                final details = Padding(
                  padding: const EdgeInsets.all(LawrenceSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        course.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.headlineLarge
                            ?.copyWith(
                              color: LawrenceColors.textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: LawrenceSpacing.sm),
                      Text(
                        hasStarted
                            ? 'Último conteúdo: ${view.label} · $lessonTitle'
                            : 'Próximo conteúdo: $lessonTitle',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: LawrenceColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: LawrenceSpacing.lg),
                      FilledButton.icon(
                        key: const Key('continue-from-last-position'),
                        onPressed: () => context.go(destination),
                        icon: const Icon(Icons.play_circle_outline_rounded),
                        label: Text(
                          hasStarted
                              ? 'Continuar de onde parou'
                              : 'Começar curso',
                        ),
                      ),
                    ],
                  ),
                );
                final progressVisual = Container(
                  width: compact ? double.infinity : 280,
                  padding: const EdgeInsets.all(LawrenceSpacing.lg),
                  color: const Color(0xFFEAF0FF),
                  alignment: Alignment.center,
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: normalizedProgress),
                    duration: reduceMotion
                        ? Duration.zero
                        : const Duration(milliseconds: 420),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, _) => SizedBox.square(
                      dimension: compact ? 132 : 158,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox.expand(
                            child: CircularProgressIndicator(
                              value: value,
                              strokeWidth: 7,
                              color: LawrenceColors.actionPrimary,
                              backgroundColor: const Color(0xFFB9C5DE),
                              semanticsLabel: 'Progresso do curso',
                              semanticsValue: '${progress.round()}%',
                            ),
                          ),
                          Text(
                            '${(value * 100).round()}%',
                            style: Theme.of(context).textTheme.headlineLarge
                                ?.copyWith(fontWeight: FontWeight.w400),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
                return compact
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [details, progressVisual],
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
  const _StatusDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: const BoxDecoration(
        color: LawrenceColors.success,
        shape: BoxShape.circle,
      ),
    );
  }
}
