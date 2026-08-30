import 'package:flutter/material.dart';

import '../../../../design_system/tokens/lawrence_theme.dart';
import '../../../../design_system/widgets/student_page_header.dart';
import '../../../courses/domain/entities/course.dart';
import '../../../lesson_progress/domain/entities/lesson_progress_entity.dart';

class LearningOverviewSection extends StatelessWidget {
  final List<Course> courses;
  final List<LessonProgressEntity> progress;

  const LearningOverviewSection({
    super.key,
    required this.courses,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final completedLessons = progress.where((item) => item.completed).length;
    final totalLessons = courses.fold<int>(
      0,
      (total, course) =>
          total +
          course.modules.fold<int>(
            0,
            (moduleTotal, module) => moduleTotal + module.lessons.length,
          ),
    );
    final overallProgress = progress.isEmpty
        ? 0.0
        : progress
                  .map((item) => item.progressPercentage)
                  .fold<double>(0, (sum, value) => sum + value) /
              progress.length;
    final studiedMinutes = progress.fold<int>(
      0,
      (total, item) => total + (item.watchedSeconds ~/ 60),
    );
    final pendingLessons = (totalLessons - completedLessons).clamp(
      0,
      totalLessons,
    );

    return Semantics(
      container: true,
      label:
          'Resumo do aprendizado. Progresso geral ${overallProgress.round()} por cento. '
          '$completedLessons aulas concluídas. $pendingLessons aulas pendentes. '
          '$studiedMinutes minutos estudados.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const StudentSectionHeader(title: 'Balanço desta edição'),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 900
                  ? 4
                  : constraints.maxWidth >= 520
                  ? 2
                  : 1;
              final width =
                  (constraints.maxWidth - (columns - 1) * 12) / columns;
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _MetricCard(
                    width: width,
                    icon: Icons.trending_up_rounded,
                    label: 'Progresso geral',
                    value: '${overallProgress.round()}%',
                    helper: 'Em todos os cursos',
                  ),
                  _MetricCard(
                    width: width,
                    icon: Icons.task_alt_rounded,
                    label: 'Aulas concluídas',
                    value: '$completedLessons',
                    helper: totalLessons == 0
                        ? 'Nenhuma aula disponível'
                        : 'de $totalLessons aulas',
                  ),
                  _MetricCard(
                    width: width,
                    icon: Icons.schedule_rounded,
                    label: 'Tempo estudado',
                    value: studiedMinutes >= 60
                        ? '${studiedMinutes ~/ 60}h ${studiedMinutes % 60}min'
                        : '${studiedMinutes}min',
                    helper: 'Progresso sincronizado',
                  ),
                  _MetricCard(
                    width: width,
                    icon: Icons.assignment_outlined,
                    label: 'Próximos passos',
                    value: '$pendingLessons',
                    helper: pendingLessons == 1
                        ? 'aula pendente'
                        : 'aulas pendentes',
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final double width;
  final IconData icon;
  final String label;
  final String value;
  final String helper;

  const _MetricCard({
    required this.width,
    required this.icon,
    required this.label,
    required this.value,
    required this.helper,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface.withValues(alpha: .86),
          border: const Border(
            top: BorderSide(color: LawrenceColors.brandNavy, width: 2),
          ),
          boxShadow: [
            BoxShadow(
              color: LawrenceColors.brandNavy.withValues(alpha: .07),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              ExcludeSemantics(
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: LawrenceColors.surfaceSubtle,
                  ),
                  child: Icon(icon, color: LawrenceColors.actionPrimary),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: Theme.of(context).textTheme.labelLarge),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.w400,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      helper,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
