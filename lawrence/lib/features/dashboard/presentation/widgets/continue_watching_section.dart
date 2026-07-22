import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../design_system/tokens/lawrence_theme.dart';
import '../../../../design_system/widgets/semantic_progress_indicator.dart';
import '../../../../design_system/widgets/student_page_header.dart';
import '../../../courses/domain/entities/course.dart';

class ContinueWatchingSection extends StatelessWidget {
  final Course course;
  final double progress;
  final String? nextLessonId;

  const ContinueWatchingSection({
    super.key,
    required this.course,
    required this.progress,
    required this.nextLessonId,
  });

  @override
  Widget build(BuildContext context) {
    final normalizedProgress = progress.clamp(0.0, 100.0).toDouble() / 100;
    final hasStarted = progress > 0;
    final destination = nextLessonId == null
        ? '/dashboard/courses/${course.id}'
        : '/dashboard/courses/${course.id}/lessons/$nextLessonId';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const StudentSectionHeader(title: 'Continue aprendendo'),
        const SizedBox(height: LawrenceSpacing.sm),
        Card(
          clipBehavior: Clip.antiAlias,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 680;
              final visual = Container(
                width: compact ? double.infinity : 260,
                height: compact ? 156 : null,
                constraints: compact
                    ? null
                    : const BoxConstraints(minHeight: 220),
                color: LawrenceColors.brandNavy,
                alignment: Alignment.center,
                child: const ExcludeSemantics(
                  child: Icon(
                    Icons.play_circle_fill_rounded,
                    color: Colors.white,
                    size: 64,
                  ),
                ),
              );
              final details = Padding(
                padding: const EdgeInsets.all(LawrenceSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      hasStarted ? 'RETOME DE ONDE PAROU' : 'COMECE AGORA',
                      style: const TextStyle(
                        color: LawrenceColors.actionPrimary,
                        fontSize: 12,
                        letterSpacing: 1,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: LawrenceSpacing.xs),
                    Text(
                      course.title,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            color: LawrenceColors.brandNavy,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: LawrenceSpacing.md),
                    SemanticProgressIndicator(
                      label: 'Progresso do curso',
                      value: normalizedProgress,
                      supportingText: hasStarted
                          ? 'Seu progresso será sincronizado automaticamente.'
                          : 'Este curso ainda não foi iniciado.',
                    ),
                    const SizedBox(height: LawrenceSpacing.lg),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: FilledButton.icon(
                        onPressed: () => context.go(destination),
                        icon: const Icon(Icons.play_arrow_rounded),
                        label: Text(
                          hasStarted ? 'Continuar aula' : 'Começar curso',
                        ),
                      ),
                    ),
                  ],
                ),
              );

              return compact
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [visual, details],
                    )
                  : IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [visual, Expanded(child: details)],
                      ),
                    );
            },
          ),
        ),
      ],
    );
  }
}
