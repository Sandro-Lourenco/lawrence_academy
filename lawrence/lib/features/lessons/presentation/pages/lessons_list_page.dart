import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../design_system/tokens/lawrence_theme.dart';
import '../../../../core/offline/local_cache.dart';
import '../../../../design_system/widgets/couture_progress_bar.dart';
import '../../../../design_system/widgets/state_widgets.dart';
import '../../../../design_system/widgets/student_page_scaffold.dart';
import '../../../courses/domain/entities/course.dart';
import '../../../courses/presentation/providers/course_detail_provider.dart';
import '../../../favorites/presentation/controllers/favorites_controller.dart';
import '../../../feedbacks/presentation/providers/feedback_providers.dart';
import '../../../certificates/presentation/providers/certificate_providers.dart';
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
                description:
                    result?.message ??
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
          data: (items) =>
              _PurchasedCourseContent(course: value, progressItems: items),
        );
      },
    );
  }
}

class _PurchasedCourseContent extends ConsumerWidget {
  final Course course;
  final List<LessonProgressEntity> progressItems;
  final bool progressUnavailable;

  const _PurchasedCourseContent({
    required this.course,
    required this.progressItems,
    this.progressUnavailable = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = summarizePurchasedCourse(course, progressItems);
    final learnMoreLessonIds = [
      for (final module in course.modules)
        for (final lesson in module.lessons)
          if (lesson.blocks.any(
            (block) => const {
              'heading',
              'text',
              'notice',
              'tip',
              'summary',
              'learn_more',
              'image',
              'gallery',
              'audio',
              'pdf',
              'download',
              'material',
            }.contains(block.blockType),
          ))
            lesson.id,
    ];
    final allLearnMoreViewed = learnMoreLessonIds.every(
      (lessonId) =>
          LocalCache.getBox(LocalCache.settingsBox).get(
            'learn_more_seen:${course.id}:$lessonId',
            defaultValue: false,
          ) ==
          true,
    );
    final favorites = ref.watch(favoritesNotifierProvider);
    final isFavorite =
        favorites.valueOrNull?.any((item) => item.id == course.id) ?? false;
    final progressByLesson = {
      for (final item in progressItems)
        if (item.courseId == course.id) item.lessonId: item,
    };
    final hasStarted = progressItems.any(
      (item) =>
          item.courseId == course.id &&
          (item.completed || item.progressPercentage > 0),
    );
    if (LawrenceBreakpoints.isMobile(MediaQuery.sizeOf(context).width)) {
      return _MobilePurchasedCoursePage(
        course: course,
        summary: summary,
        progressByLesson: progressByLesson,
        progressUnavailable: progressUnavailable,
        isFavorite: isFavorite,
        onFavorite: () => ref
            .read(favoritesNotifierProvider.notifier)
            .toggleFavorite(course.id),
      );
    }
    return StudentPageScaffold(
      title: course.title,
      showHeader: false,
      maxContentWidth: 1440,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _CourseProgressHero(
            course: course,
            summary: summary,
            hasStarted: hasStarted,
          ),
          const SizedBox(height: LawrenceSpacing.xl),
          LayoutBuilder(
            builder: (context, constraints) {
              final desktop = constraints.maxWidth >= 940;
              final main = Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _CourseActionsPanel(
                    courseId: course.id,
                    allLearnMoreViewed: allLearnMoreViewed,
                    isFavorite: isFavorite,
                    onFavorite: () => ref
                        .read(favoritesNotifierProvider.notifier)
                        .toggleFavorite(course.id),
                  ),
                  if (progressUnavailable) ...[
                    const SizedBox(height: LawrenceSpacing.md),
                    const _ProgressUnavailableBanner(),
                  ],
                  const SizedBox(height: LawrenceSpacing.xl),
                  _CourseObjectives(course: course),
                  const SizedBox(height: LawrenceSpacing.xl),
                  Text(
                    'Aulas',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: LawrenceSpacing.md),
                  if (course.modules.isEmpty)
                    const SizedBox(
                      height: 300,
                      child: AppEmptyState(
                        title: 'Nenhuma aula publicada',
                        description:
                            'O conteúdo deste curso ainda não está disponível.',
                        icon: Icons.video_library_outlined,
                      ),
                    )
                  else
                    ...course.modules.asMap().entries.map(
                      (entry) => Padding(
                        padding: const EdgeInsets.only(
                          bottom: LawrenceSpacing.md,
                        ),
                        child: _ModuleCard(
                          courseId: course.id,
                          number: entry.key + 1,
                          module: entry.value,
                          progressByLesson: progressByLesson,
                        ),
                      ),
                    ),
                ],
              );
              if (!desktop) {
                return Column(
                  children: [
                    main,
                    const SizedBox(height: LawrenceSpacing.xl),
                    _CourseInformationSidebar(course: course),
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 2, child: main),
                  const SizedBox(width: LawrenceSpacing.xl),
                  SizedBox(
                    width: 330,
                    child: _CourseInformationSidebar(course: course),
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

class _MobilePurchasedCoursePage extends StatelessWidget {
  const _MobilePurchasedCoursePage({
    required this.course,
    required this.summary,
    required this.progressByLesson,
    required this.progressUnavailable,
    required this.isFavorite,
    required this.onFavorite,
  });

  final Course course;
  final PurchasedCourseSummary summary;
  final Map<String, LessonProgressEntity> progressByLesson;
  final bool progressUnavailable;
  final bool isFavorite;
  final VoidCallback onFavorite;

  @override
  Widget build(BuildContext context) {
    final nextLesson = summary.nextLesson;
    final duration = course.estimatedDurationMinutes ?? 0;
    return DefaultTabController(
      length: 3,
      child: StudentPageScaffold(
        title: '',
        showHeader: false,
        maxContentWidth: 700,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                IconButton(
                  tooltip: 'Voltar',
                  onPressed: () => context.go('/dashboard/home'),
                  icon: const Icon(Icons.arrow_back_rounded),
                ),
                const Spacer(),
                IconButton(
                  tooltip: isFavorite
                      ? 'Remover dos favoritos'
                      : 'Favoritar curso',
                  onPressed: onFavorite,
                  icon: Icon(
                    isFavorite
                        ? Icons.bookmark_rounded
                        : Icons.bookmark_border_rounded,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 92,
                  height: 92,
                  color: LawrenceColors.surfaceSubtle,
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.architecture_outlined,
                    size: 48,
                    color: LawrenceColors.wine,
                  ),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        course.title,
                        style: Theme.of(
                          context,
                        ).textTheme.headlineLarge?.copyWith(height: 1.12),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 16,
                        runSpacing: 8,
                        children: [
                          _MobileCourseMetric(
                            icon: Icons.thumb_up_alt_outlined,
                            label: '9,2',
                          ),
                          _MobileCourseMetric(
                            icon: Icons.schedule_outlined,
                            label: duration > 0
                                ? '${(duration / 60).ceil()}h'
                                : '${course.lessonCount} aulas',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            _MobileCourseAction(
              icon: Icons.play_arrow_rounded,
              label: summary.progress > 0
                  ? 'Continuar onde parou'
                  : 'Iniciar curso',
              onTap: nextLesson == null
                  ? null
                  : () => context.go(
                      '/dashboard/courses/${course.id}/lessons/${nextLesson.id}',
                    ),
            ),
            const SizedBox(height: 10),
            _MobileCourseAction(
              icon: Icons.download_rounded,
              label: 'Baixar curso para estudar offline',
              outlined: true,
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('O download será preparado em segundo plano.'),
                ),
              ),
            ),
            const SizedBox(height: 10),
            _MobileCourseAction(
              icon: Icons.add_rounded,
              label: 'Adicionar a um plano',
              outlined: true,
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Curso adicionado ao seu plano de estudo.'),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _MobileIconAction(
                  icon: Icons.pause_rounded,
                  label: 'Pausar',
                  onTap: () {},
                ),
                _MobileIconAction(
                  icon: Icons.flag_outlined,
                  label: 'Concluir',
                  onTap: null,
                ),
                _MobileIconAction(
                  icon: Icons.forum_outlined,
                  label: 'Fórum',
                  onTap: () {},
                ),
                _MobileIconAction(
                  icon: Icons.delete_outline_rounded,
                  label: 'Apagar',
                  onTap: null,
                ),
              ],
            ),
            const SizedBox(height: 18),
            const TabBar(
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              tabs: [
                Tab(text: 'Aulas'),
                Tab(text: 'Pré-requisitos'),
                Tab(text: 'Instrutores'),
              ],
            ),
            if (progressUnavailable) ...[
              const SizedBox(height: 12),
              const _ProgressUnavailableBanner(),
            ],
            SizedBox(
              height: 430,
              child: TabBarView(
                children: [
                  _MobileLessonsTab(
                    course: course,
                    progressByLesson: progressByLesson,
                  ),
                  _MobilePrerequisitesTab(course: course),
                  const _MobileInstructorTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MobileCourseMetric extends StatelessWidget {
  const _MobileCourseMetric({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 19, color: LawrenceColors.wine),
      const SizedBox(width: 5),
      Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
    ],
  );
}

class _MobileCourseAction extends StatelessWidget {
  const _MobileCourseAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.outlined = false,
  });
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool outlined;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 58,
    child: outlined
        ? OutlinedButton.icon(
            onPressed: onTap,
            icon: Icon(icon),
            label: Text(label),
          )
        : FilledButton.icon(
            onPressed: onTap,
            icon: Icon(icon),
            label: Text(label),
          ),
  );
}

class _MobileIconAction extends StatelessWidget {
  const _MobileIconAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: onTap != null,
    label: label,
    child: InkWell(
      onTap: onTap,
      child: SizedBox(
        width: 70,
        height: 68,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: onTap == null
                  ? LawrenceColors.textDisabled
                  : LawrenceColors.wine,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: onTap == null
                    ? LawrenceColors.textDisabled
                    : LawrenceColors.textPrimary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _MobileLessonsTab extends StatelessWidget {
  const _MobileLessonsTab({
    required this.course,
    required this.progressByLesson,
  });
  final Course course;
  final Map<String, LessonProgressEntity> progressByLesson;

  @override
  Widget build(BuildContext context) {
    if (course.modules.isEmpty) {
      return const AppEmptyState(
        title: 'Nenhuma aula publicada',
        description: 'O conteúdo ainda não está disponível.',
        icon: Icons.video_library_outlined,
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.only(top: 16),
      itemCount: course.modules.length,
      itemBuilder: (context, index) {
        final module = course.modules[index];
        return ExpansionTile(
          initiallyExpanded: index == 0,
          tilePadding: EdgeInsets.zero,
          title: Text(
            module.title,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          children: [
            for (final lesson in module.lessons)
              _LessonTile(
                courseId: course.id,
                lesson: lesson,
                progress: progressByLesson[lesson.id],
              ),
          ],
        );
      },
    );
  }
}

class _MobilePrerequisitesTab extends StatelessWidget {
  const _MobilePrerequisitesTab({required this.course});
  final Course course;

  @override
  Widget build(BuildContext context) {
    final hasItems =
        course.requirements.isNotEmpty || course.prerequisiteCourses.isNotEmpty;
    if (!hasItems) {
      return const AppEmptyState(
        title: 'Sem pré-requisitos',
        description: 'Você pode começar este curso agora.',
        icon: Icons.lock_open_rounded,
      );
    }
    return ListView(
      padding: const EdgeInsets.only(top: 16),
      children: [
        for (final requirement in course.requirements)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(
              Icons.check_circle_outline_rounded,
              color: LawrenceColors.wine,
            ),
            title: Text(requirement),
          ),
        for (final prerequisite in course.prerequisiteCourses)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(
              Icons.workspace_premium_outlined,
              color: LawrenceColors.wine,
            ),
            title: Text(prerequisite.title),
            subtitle: Text(prerequisite.summary),
            trailing: const Icon(Icons.chevron_right_rounded),
          ),
      ],
    );
  }
}

class _MobileInstructorTab extends StatelessWidget {
  const _MobileInstructorTab();

  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.only(top: 20),
    child: ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: LawrenceColors.plum,
        foregroundColor: Colors.white,
        child: Icon(Icons.person_outline_rounded),
      ),
      title: Text('Instrutor responsável'),
      subtitle: Text('Especialista Lawrence Academy'),
      trailing: Icon(Icons.north_east_rounded, color: LawrenceColors.wine),
    ),
  );
}

class _CourseActionsPanel extends ConsumerStatefulWidget {
  final String courseId;
  final bool isFavorite;
  final bool allLearnMoreViewed;
  final VoidCallback onFavorite;

  const _CourseActionsPanel({
    required this.courseId,
    required this.isFavorite,
    required this.allLearnMoreViewed,
    required this.onFavorite,
  });

  @override
  ConsumerState<_CourseActionsPanel> createState() =>
      _CourseActionsPanelState();
}

class _CourseActionsPanelState extends ConsumerState<_CourseActionsPanel> {
  bool _submitting = false;

  Future<void> _completeCourse() async {
    if (_submitting) return;
    setState(() => _submitting = true);
    try {
      ref.invalidate(courseCompletionProvider(widget.courseId));
      final completion = await ref.read(
        courseCompletionProvider(widget.courseId).future,
      );
      if (!completion.certificateEligible) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'O servidor confirmou ${completion.progressPercentage}% do curso. Conclua as etapas pendentes antes de emitir o certificado.',
            ),
          ),
        );
        return;
      }

      ref.invalidate(generateCertificateProvider(widget.courseId));
      await ref.read(generateCertificateProvider(widget.courseId).future);
      ref.invalidate(certificatesListProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Conclusão confirmada. Seu certificado está disponível em Certificados.',
          ),
        ),
      );
      if (completion.reviewRequired && !completion.reviewSubmitted) {
        context.go('/dashboard/courses/${widget.courseId}/review');
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Não foi possível confirmar a conclusão agora. Tente novamente.',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final completion = ref.watch(courseCompletionProvider(widget.courseId));
    final canComplete = completion.valueOrNull?.certificateEligible == true;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(LawrenceSpacing.md),
        child: Wrap(
          spacing: LawrenceSpacing.sm,
          runSpacing: LawrenceSpacing.sm,
          children: [
            OutlinedButton.icon(
              onPressed: widget.onFavorite,
              icon: Icon(
                widget.isFavorite
                    ? Icons.star_rounded
                    : Icons.star_border_rounded,
              ),
              label: Text(widget.isFavorite ? 'Favoritado' : 'Favoritar'),
            ),
            OutlinedButton.icon(
              onPressed: canComplete && !_submitting ? _completeCourse : null,
              icon: const Icon(Icons.workspace_premium_outlined),
              label: Text(_submitting ? 'Confirmando...' : 'Concluir curso'),
            ),
            OutlinedButton.icon(
              onPressed: () => context.go('/dashboard/subscriptions'),
              icon: const Icon(Icons.remove_circle_outline_rounded),
              label: const Text('Sair do curso'),
            ),
            if (completion.isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text('Confirmando progresso com o servidor...'),
              )
            else if (!canComplete)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  !widget.allLearnMoreViewed
                      ? 'Conclua as aulas, atividades e confirme a leitura do Saber mais.'
                      : 'Complete as aulas e atividades pendentes para chegar a 100%.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CourseObjectives extends StatelessWidget {
  final Course course;

  const _CourseObjectives({required this.course});

  @override
  Widget build(BuildContext context) {
    final objectives = course.learningObjectives.isNotEmpty
        ? course.learningObjectives
        : course.description.trim().isNotEmpty
        ? [course.description.trim()]
        : const <String>[];
    if (objectives.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'O que você vai aprender',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: LawrenceSpacing.md),
        for (final objective in objectives)
          Padding(
            padding: const EdgeInsets.only(bottom: LawrenceSpacing.sm),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.check_rounded,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: LawrenceSpacing.sm),
                Expanded(child: Text(objective)),
              ],
            ),
          ),
      ],
    );
  }
}

class _CourseInformationSidebar extends StatelessWidget {
  final Course course;

  const _CourseInformationSidebar({required this.course});

  @override
  Widget build(BuildContext context) {
    final duration = course.estimatedDurationMinutes;
    final hours = duration == null ? null : (duration / 60).ceil();
    final requirements = course.requirements.isEmpty
        ? const ['Nenhum conhecimento prévio obrigatório.']
        : course.requirements;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(LawrenceSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sobre este curso',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: LawrenceSpacing.lg),
                _SidebarFact(
                  icon: Icons.schedule_outlined,
                  label: hours == null
                      ? 'Carga horária flexível'
                      : '${hours}h de conteúdo',
                ),
                _SidebarFact(
                  icon: Icons.play_lesson_outlined,
                  label: '${course.lessonCount} aulas',
                ),
                _SidebarFact(
                  icon: Icons.signal_cellular_alt_rounded,
                  label: 'Nível ${course.level}',
                ),
                _SidebarFact(
                  icon: Icons.closed_caption_outlined,
                  label: 'Transcrição disponível',
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: LawrenceSpacing.md),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(LawrenceSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pré-requisitos',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: LawrenceSpacing.md),
                for (final requirement in requirements)
                  Padding(
                    padding: const EdgeInsets.only(bottom: LawrenceSpacing.sm),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.check_circle_outline_rounded,
                          size: 19,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: LawrenceSpacing.sm),
                        Expanded(child: Text(requirement)),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SidebarFact extends StatelessWidget {
  final IconData icon;
  final String label;

  const _SidebarFact({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: LawrenceSpacing.md),
    child: Row(
      children: [
        Icon(icon, size: 21, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: LawrenceSpacing.sm),
        Expanded(child: Text(label)),
      ],
    ),
  );
}

class _CourseProgressHero extends StatelessWidget {
  final Course course;
  final PurchasedCourseSummary summary;
  final bool hasStarted;

  const _CourseProgressHero({
    required this.course,
    required this.summary,
    required this.hasStarted,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = (summary.progress * 100).round();
    final totalMinutes =
        course.estimatedDurationMinutes ??
        course.modules.fold<int>(
          0,
          (moduleTotal, module) =>
              moduleTotal +
              module.lessons.fold<int>(
                0,
                (lessonTotal, lesson) =>
                    lessonTotal + (lesson.durationSeconds / 60).ceil(),
              ),
        );
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      container: true,
      label: hasStarted
          ? '$percentage por cento concluído. ${summary.completedLessons} de ${summary.totalLessons} aulas concluídas.'
          : 'Curso ainda não iniciado.',
      child: Card(
        color: scheme.primaryContainer.withValues(alpha: .22),
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(LawrenceSpacing.xl),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 680;
              final details = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextButton.icon(
                    onPressed: () => context.go('/dashboard/courses'),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      foregroundColor: scheme.primary,
                    ),
                    icon: const Icon(Icons.arrow_back_rounded, size: 19),
                    label: const Text('Explorar catálogo'),
                  ),
                  const SizedBox(height: LawrenceSpacing.lg),
                  Text(
                    'CURSO ${course.category.toUpperCase()}',
                    style: TextStyle(
                      color: scheme.primary,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.3,
                    ),
                  ),
                  const SizedBox(height: LawrenceSpacing.md),
                  Text(
                    course.title,
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: scheme.onSurface,
                      fontWeight: FontWeight.w500,
                      height: 1.12,
                    ),
                  ),
                  if (course.summary.trim().isNotEmpty) ...[
                    const SizedBox(height: LawrenceSpacing.md),
                    Text(
                      course.summary,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: scheme.onSurfaceVariant,
                        height: 1.5,
                      ),
                    ),
                  ],
                  if (hasStarted) ...[
                    const SizedBox(height: LawrenceSpacing.xl),
                    Row(
                      children: [
                        Expanded(
                          child: CoutureProgressBar(
                            value: summary.progress,
                            height: 6,
                            semanticLabel: 'Progresso do curso',
                          ),
                        ),
                        const SizedBox(width: LawrenceSpacing.sm),
                        Text('$percentage%'),
                      ],
                    ),
                  ],
                  const SizedBox(height: LawrenceSpacing.xl),
                  Wrap(
                    spacing: LawrenceSpacing.lg,
                    runSpacing: LawrenceSpacing.sm,
                    children: [
                      _CoverFact(
                        icon: Icons.view_module_outlined,
                        label: '${course.modules.length} módulos',
                      ),
                      _CoverFact(
                        icon: Icons.play_lesson_outlined,
                        label: '${course.lessonCount} aulas',
                      ),
                      _CoverFact(
                        icon: Icons.schedule_outlined,
                        label: totalMinutes > 0
                            ? '${(totalMinutes / 60).ceil()}h de conteúdo'
                            : 'Carga horária flexível',
                      ),
                      _CoverFact(
                        icon: Icons.signal_cellular_alt_rounded,
                        label: 'Nível ${course.level}',
                      ),
                      if (course.certificateEnabled)
                        const _CoverFact(
                          icon: Icons.workspace_premium_outlined,
                          label: 'Certificado',
                        ),
                    ],
                  ),
                ],
              );
              final primaryAction = summary.nextLesson == null
                  ? null
                  : FilledButton.icon(
                      onPressed: () => context.go(
                        '/dashboard/courses/${course.id}/lessons/${summary.nextLesson!.id}',
                      ),
                      icon: const Icon(Icons.play_arrow_rounded),
                      label: Text(
                        hasStarted ? 'Continuar curso' : 'Iniciar curso',
                      ),
                    );
              final actions = Wrap(
                spacing: LawrenceSpacing.sm,
                runSpacing: LawrenceSpacing.sm,
                children: [
                  ...primaryAction == null
                      ? const <Widget>[]
                      : <Widget>[primaryAction],
                  OutlinedButton.icon(
                    onPressed: () => _showCourseOptions(context),
                    iconAlignment: IconAlignment.end,
                    icon: const Icon(Icons.keyboard_arrow_down_rounded),
                    label: const Text('Mais opções'),
                  ),
                ],
              );
              if (compact) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    details,
                    const SizedBox(height: LawrenceSpacing.lg),
                    actions,
                  ],
                );
              }
              return Row(
                children: [
                  Expanded(child: details),
                  const SizedBox(width: LawrenceSpacing.xl),
                  actions,
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _showCourseOptions(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: LawrenceSpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.list_alt_rounded),
                title: const Text('Ver meus cursos'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  context.go('/dashboard/courses');
                },
              ),
              ListTile(
                leading: const Icon(Icons.credit_card_outlined),
                title: const Text('Gerenciar assinatura'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  context.go('/dashboard/subscriptions');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CoverFact extends StatelessWidget {
  final IconData icon;
  final String label;

  const _CoverFact({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
      const SizedBox(width: LawrenceSpacing.xs),
      Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
    ],
  );
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
    final completedLessons = module.lessons
        .where((lesson) => progressByLesson[lesson.id]?.completed ?? false)
        .length;
    final durationMinutes = module.lessons.fold<int>(
      0,
      (total, lesson) => total + (lesson.durationSeconds / 60).ceil(),
    );
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        initiallyExpanded: number == 1,
        shape: const RoundedRectangleBorder(),
        collapsedShape: const RoundedRectangleBorder(),
        tilePadding: const EdgeInsets.symmetric(
          horizontal: LawrenceSpacing.lg,
          vertical: LawrenceSpacing.sm,
        ),
        childrenPadding: const EdgeInsets.fromLTRB(
          LawrenceSpacing.lg,
          0,
          LawrenceSpacing.lg,
          LawrenceSpacing.md,
        ),
        title: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 620;
            return Row(
              children: [
                Expanded(
                  child: Text(
                    'Módulo $number · ${module.title}',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                if (!compact && module.lessons.isNotEmpty) ...[
                  FilledButton.icon(
                    onPressed: () => context.go(
                      '/dashboard/courses/$courseId/lessons/${module.lessons.first.id}',
                    ),
                    icon: const Icon(Icons.play_circle_outline_rounded),
                    label: Text(
                      number == 1 ? 'Ver primeira aula' : 'Abrir módulo',
                    ),
                  ),
                  const SizedBox(width: LawrenceSpacing.lg),
                ],
                Text('$completedLessons/${module.lessons.length}'),
                if (durationMinutes > 0) ...[
                  const SizedBox(width: LawrenceSpacing.sm),
                  Text('${durationMinutes}min'),
                ],
              ],
            );
          },
        ),
        subtitle: module.lessons.isEmpty
            ? const Text('Nenhuma aula publicada neste módulo.')
            : null,
        children: [
          if (module.lessons.isNotEmpty)
            for (final lesson in module.lessons)
              _LessonTile(
                courseId: courseId,
                lesson: lesson,
                progress: progressByLesson[lesson.id],
              ),
        ],
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
        onTap: () =>
            context.go('/dashboard/courses/$courseId/lessons/${lesson.id}'),
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
