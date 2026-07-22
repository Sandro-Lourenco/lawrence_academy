import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../design_system/tokens/lawrence_theme.dart';
import '../../../../design_system/widgets/state_widgets.dart';
import '../../../../design_system/widgets/status_badge.dart';
import '../../../../design_system/widgets/student_page_scaffold.dart';
import '../../../courses/domain/entities/course.dart';
import '../../../courses/presentation/providers/course_detail_provider.dart';
import '../../../lesson_progress/domain/entities/lesson_progress_entity.dart';
import '../../../lesson_progress/presentation/controllers/lesson_progress_controller.dart';
import '../../../subscriptions/presentation/controllers/checkout_eligibility_controller.dart';
import '../controllers/purchased_course_presentation.dart';

class LessonsListPage extends ConsumerWidget {
  final String courseId;

  const LessonsListPage({super.key, required this.courseId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eligibility = ref.watch(checkoutEligibilityProvider(courseId));
    return eligibility.when(
      loading: () => const StudentPageScaffold(
        title: 'Curso',
        subtitle: 'Validando seu acesso.',
        body: SizedBox(
          height: 420,
          child: AppLoadingState(message: 'Validando acesso ao curso'),
        ),
      ),
      error: (_, _) => StudentPageScaffold(
        title: 'Curso',
        subtitle: 'Não foi possível validar seu acesso.',
        body: SizedBox(
          height: 420,
          child: AppErrorState(
            title: 'Falha ao validar o acesso',
            message: 'Verifique sua conexão e tente novamente.',
            onRetry: () => ref
                .read(checkoutEligibilityProvider(courseId).notifier)
                .checkEligibility(),
          ),
        ),
      ),
      data: (result) {
        if (result == null || !result.hasAccess) {
          return StudentPageScaffold(
            title: 'Curso indisponível',
            subtitle: 'É necessária uma assinatura ativa para estudar.',
            body: SizedBox(
              height: 420,
              child: AppEmptyState(
                title: 'Acesso ao curso não disponível',
                description: result?.message ??
                    'Gerencie sua assinatura para recuperar o acesso às aulas.',
                icon: Icons.lock_outline_rounded,
                actionLabel: 'Gerenciar assinaturas',
                onActionPressed: () => context.go('/dashboard/subscriptions'),
              ),
            ),
          );
        }
        return _PurchasedCoursePage(courseId: courseId);
      },
    );
  }
}

class _PurchasedCoursePage extends ConsumerWidget {
  final String courseId;

  const _PurchasedCoursePage({required this.courseId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final course = ref.watch(courseDetailByIdProvider(courseId));
    final progress = ref.watch(courseProgressListProvider(courseId));
    return course.when(
      loading: () => const StudentPageScaffold(
        title: 'Meu curso',
        body: SizedBox(
          height: 420,
          child: AppLoadingState(message: 'Carregando conteúdo do curso'),
        ),
      ),
      error: (_, _) => StudentPageScaffold(
        title: 'Meu curso',
        body: SizedBox(
          height: 420,
          child: AppErrorState(
            title: 'Não foi possível carregar o curso',
            message: 'Verifique sua conexão e tente novamente.',
            onRetry: () => ref.invalidate(courseDetailByIdProvider(courseId)),
          ),
        ),
      ),
      data: (value) {
        if (value == null) {
          return const StudentPageScaffold(
            title: 'Curso indisponível',
            body: SizedBox(
              height: 420,
              child: AppEmptyState(
                title: 'Curso não encontrado',
                description: 'Este conteúdo deixou de estar disponível.',
                icon: Icons.video_library_outlined,
              ),
            ),
          );
        }
        return progress.when(
          loading: () => StudentPageScaffold(
            title: value.title,
            subtitle: 'Carregando seu progresso.',
            body: const SizedBox(
              height: 420,
              child: AppLoadingState(message: 'Carregando progresso'),
            ),
          ),
          error: (_, _) => _PurchasedCourseContent(
            course: value,
            progressItems: const [],
            progressUnavailable: true,
          ),
          data: (items) => _PurchasedCourseContent(
            course: value,
            progressItems: items,
          ),
        );
      },
    );
  }
}

class _PurchasedCourseContent extends StatelessWidget {
  final Course course;
  final List<LessonProgressEntity> progressItems;
  final bool progressUnavailable;

  const _PurchasedCourseContent({
    required this.course,
    required this.progressItems,
    this.progressUnavailable = false,
  });

  @override
  Widget build(BuildContext context) {
    final summary = summarizePurchasedCourse(course, progressItems);
    final progressByLesson = {
      for (final item in progressItems)
        if (item.courseId == course.id) item.lessonId: item,
    };
    return StudentPageScaffold(
      title: course.title,
      subtitle: course.summary.isEmpty ? 'Conteúdo do curso' : course.summary,
      leading: IconButton(
        tooltip: 'Voltar aos cursos',
        onPressed: () => context.go('/dashboard/courses'),
        icon: const Icon(Icons.arrow_back_rounded),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _CourseProgressHero(course: course, summary: summary),
          if (progressUnavailable) ...[
            const SizedBox(height: LawrenceSpacing.md),
            const _ProgressUnavailableBanner(),
          ],
          const SizedBox(height: LawrenceSpacing.xl),
          Text(
            'Conteúdo do curso',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: LawrenceSpacing.md),
          if (course.modules.isEmpty)
            const SizedBox(
              height: 300,
              child: AppEmptyState(
                title: 'Nenhuma aula publicada',
                description: 'O conteúdo deste curso ainda não está disponível.',
                icon: Icons.video_library_outlined,
              ),
            )
          else
            ...course.modules.asMap().entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: LawrenceSpacing.md),
                child: _ModuleCard(
                  courseId: course.id,
                  number: entry.key + 1,
                  module: entry.value,
                  progressByLesson: progressByLesson,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CourseProgressHero extends StatelessWidget {
  final Course course;
  final PurchasedCourseSummary summary;

  const _CourseProgressHero({required this.course, required this.summary});

  @override
  Widget build(BuildContext context) {
    final percentage = (summary.progress * 100).round();
    return Semantics(
      container: true,
      label:
          '$percentage por cento concluído. ${summary.completedLessons} de ${summary.totalLessons} aulas concluídas.',
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(LawrenceSpacing.lg),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 680;
              final details = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppStatusBadge(
                    label: percentage == 100 ? 'Concluído' : 'Em andamento',
                    icon: percentage == 100
                        ? Icons.check_circle_outline_rounded
                        : Icons.play_circle_outline_rounded,
                    tone: percentage == 100
                        ? AppStatusTone.success
                        : AppStatusTone.info,
                  ),
                  const SizedBox(height: LawrenceSpacing.md),
                  Text(
                    '$percentage% concluído',
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  const SizedBox(height: LawrenceSpacing.sm),
                  LinearProgressIndicator(
                    value: summary.progress,
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(LawrenceRadii.pill),
                    semanticsLabel: 'Progresso do curso',
                    semanticsValue: '$percentage%',
                  ),
                  const SizedBox(height: LawrenceSpacing.sm),
                  Text(
                    '${summary.completedLessons} de ${summary.totalLessons} aulas concluídas',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              );
              final action = summary.nextLesson == null
                  ? null
                  : FilledButton.icon(
                      onPressed: () => context.go(
                        '/dashboard/courses/${course.id}/lessons/${summary.nextLesson!.id}',
                      ),
                      icon: const Icon(Icons.play_arrow_rounded),
                      label: Text(
                        summary.progress > 0 ? 'Continuar curso' : 'Iniciar curso',
                      ),
                    );
              if (compact) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    details,
                    if (action != null) ...[
                      const SizedBox(height: LawrenceSpacing.lg),
                      action,
                    ],
                  ],
                );
              }
              return Row(
                children: [
                  Expanded(child: details),
                  if (action != null) ...[
                    const SizedBox(width: LawrenceSpacing.xl),
                    action,
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ModuleCard extends StatelessWidget {
  final String courseId;
  final int number;
  final Module module;
  final Map<String, LessonProgressEntity> progressByLesson;

  const _ModuleCard({
    required this.courseId,
    required this.number,
    required this.module,
    required this.progressByLesson,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(LawrenceSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Módulo $number · ${module.title}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: LawrenceSpacing.sm),
            if (module.lessons.isEmpty)
              Text(
                'Nenhuma aula publicada neste módulo.',
                style: Theme.of(context).textTheme.bodyMedium,
              )
            else
              ...module.lessons.map((lesson) {
                final progress = progressByLesson[lesson.id];
                return _LessonTile(
                  courseId: courseId,
                  lesson: lesson,
                  progress: progress,
                );
              }),
          ],
        ),
      ),
    );
  }
}

class _LessonTile extends StatelessWidget {
  final String courseId;
  final Lesson lesson;
  final LessonProgressEntity? progress;

  const _LessonTile({
    required this.courseId,
    required this.lesson,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final completed = progress?.completed ?? false;
    final percentage = completed
        ? 100
        : (progress?.progressPercentage ?? 0).clamp(0, 100).round();
    final minutes = (lesson.durationSeconds / 60).ceil();
    return Semantics(
      button: true,
      label:
          '${lesson.title}. ${completed ? 'Concluída' : '$percentage por cento concluída'}. ${minutes > 0 ? '$minutes minutos' : 'Duração não informada'}.',
      child: ListTile(
        minTileHeight: 72,
        contentPadding: EdgeInsets.zero,
        leading: Icon(
          completed
              ? Icons.check_circle_rounded
              : percentage > 0
              ? Icons.play_circle_fill_rounded
              : Icons.play_circle_outline_rounded,
          color: completed
              ? LawrenceColors.success
              : LawrenceColors.actionPrimary,
        ),
        title: Text(lesson.title),
        subtitle: Text(
          [
            if (minutes > 0) '$minutes min',
            if (completed) 'Concluída' else if (percentage > 0) '$percentage%',
          ].join(' · '),
        ),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: () => context.go(
          '/dashboard/courses/$courseId/lessons/${lesson.id}',
        ),
      ),
    );
  }
}

class _ProgressUnavailableBanner extends StatelessWidget {
  const _ProgressUnavailableBanner();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      liveRegion: true,
      label: 'Progresso indisponível. As aulas continuam acessíveis.',
      child: Container(
        padding: const EdgeInsets.all(LawrenceSpacing.md),
        decoration: BoxDecoration(
          color: LawrenceColors.warningSurface,
          borderRadius: BorderRadius.circular(LawrenceRadii.control),
        ),
        child: const Row(
          children: [
            Icon(Icons.sync_problem_rounded, color: LawrenceColors.warning),
            SizedBox(width: LawrenceSpacing.sm),
            Expanded(
              child: Text(
                'Seu progresso não pôde ser carregado. As aulas continuam acessíveis.',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
