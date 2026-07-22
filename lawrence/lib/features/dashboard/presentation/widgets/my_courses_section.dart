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
          title: 'Meus cursos',
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
                  (constraints.maxWidth -
                      (columns - 1) * LawrenceSpacing.md) /
                  columns;
              return Wrap(
                spacing: LawrenceSpacing.md,
                runSpacing: LawrenceSpacing.md,
                children: [
                  for (final course in courses)
                    SizedBox(
                      width: cardWidth,
                      child: _CourseSummaryCard(
                        course: course,
                        progress: _courseProgress(course.id),
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

  const _CourseSummaryCard({required this.course, required this.progress});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () => context.go('/dashboard/courses/${course.id}'),
        borderRadius: BorderRadius.circular(LawrenceRadii.card),
        child: Padding(
          padding: const EdgeInsets.all(LawrenceSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: LawrenceColors.surfaceSubtle,
                      borderRadius: BorderRadius.circular(
                        LawrenceRadii.control,
                      ),
                    ),
                    child: const Icon(
                      Icons.menu_book_rounded,
                      color: LawrenceColors.actionPrimary,
                    ),
                  ),
                  const SizedBox(width: LawrenceSpacing.sm),
                  Expanded(
                    child: Text(
                      course.title,
                      style: const TextStyle(
                        color: LawrenceColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: LawrenceColors.textSecondary,
                  ),
                ],
              ),
              const SizedBox(height: LawrenceSpacing.md),
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
