import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../design_system/tokens/lawrence_theme.dart';
import '../../../../design_system/widgets/semantic_progress_indicator.dart';
import '../../../../design_system/widgets/state_widgets.dart';
import '../../../../design_system/widgets/student_page_header.dart';
import '../../../courses/domain/entities/course.dart';
import '../../../lesson_progress/domain/entities/lesson_progress_entity.dart';

class MyCoursesSection extends StatelessWidget {
  final List<Course> courses;
  final List<LessonProgressEntity> progressList;

  const MyCoursesSection({
    super.key,
    required this.courses,
    required this.progressList,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        StudentSectionHeader(
          title: 'Meus cadernos de formação',
          actionLabel: courses.isEmpty ? null : 'Ver cursos',
          onAction: courses.isEmpty
              ? null
              : () => context.go('/dashboard/courses'),
        ),
        const SizedBox(height: LawrenceSpacing.sm),
        if (courses.isEmpty)
          AppEmptyState(
            title: 'Você ainda não possui cursos',
            description:
                'Explore o catálogo e escolha o próximo passo da sua formação.',
            icon: Icons.menu_book_outlined,
            actionLabel: 'Explorar cursos',
            onActionPressed: () => context.go('/dashboard/courses'),
          )
        else
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 980
                  ? 3
                  : constraints.maxWidth >= 620
                  ? 2
                  : 1;
              final cardWidth =
                  (constraints.maxWidth - (columns - 1) * LawrenceSpacing.md) /
                  columns;
              return Wrap(
                spacing: LawrenceSpacing.md,
                runSpacing: LawrenceSpacing.md,
                children: [
                  for (final entry in courses.indexed)
                    SizedBox(
                      width: cardWidth,
                      child: _CourseSummaryCard(
                        course: entry.$2,
                        progress: _courseProgress(entry.$2.id),
                        issueNumber: entry.$1 + 1,
                      ),
                    ),
                ],
              );
            },
          ),
      ],
    );
  }

  double _courseProgress(String courseId) {
    final items = progressList
        .where((item) => item.courseId == courseId)
        .toList(growable: false);
    if (items.isEmpty) return 0;
    return items.fold<double>(
          0,
          (total, item) => total + item.progressPercentage,
        ) /
        items.length;
  }
}

class _CourseSummaryCard extends StatelessWidget {
  final Course course;
  final double progress;
  final int issueNumber;

  const _CourseSummaryCard({
    required this.course,
    required this.progress,
    required this.issueNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () => context.go('/dashboard/courses/${course.id}'),
        borderRadius: BorderRadius.circular(LawrenceRadii.card),
        child: Padding(
          padding: const EdgeInsets.all(LawrenceSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'CADERNO ${issueNumber.toString().padLeft(2, '0')}',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: LawrenceColors.brandNavy,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: LawrenceSpacing.sm),
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      color: LawrenceColors.brandNavy,
                    ),
                    child: const Center(
                      child: Text(
                        'L',
                        style: TextStyle(
                          color: LawrenceColors.canvas,
                          fontFamily: 'Georgia',
                          fontSize: 24,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: LawrenceSpacing.sm),
                  Expanded(
                    child: Text(
                      course.title,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontFamily: 'Georgia',
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
              const SizedBox(height: LawrenceSpacing.md),
              Text(
                '${course.modules.length} MÓDULOS · ${course.lessonCount} AULAS',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: LawrenceColors.brandNavy,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: LawrenceSpacing.sm),
              SemanticProgressIndicator(
                label: 'Progresso',
                value: progress.clamp(0.0, 100.0).toDouble() / 100,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
