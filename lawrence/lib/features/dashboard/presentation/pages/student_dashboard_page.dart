import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/error/app_error.dart';
import '../../../../design_system/motion/public_motion.dart';
import '../../../../design_system/tokens/lawrence_theme.dart';
import '../../../../design_system/widgets/state_widgets.dart';
import '../../../../design_system/widgets/couture_primary_button.dart';
import '../../../../design_system/widgets/student_page_scaffold.dart';
import '../../../courses/domain/entities/course.dart';
import '../controllers/dashboard_controller.dart';
import '../widgets/continue_watching_section.dart';
import '../widgets/events_banner.dart';
import '../widgets/learning_overview_section.dart';
import '../widgets/my_courses_section.dart';

class StudentDashboardPage extends ConsumerWidget {
  const StudentDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboard = ref.watch(dashboardNotifierProvider);
    Future<void> refresh() =>
        ref.read(dashboardNotifierProvider.notifier).refresh();

    return dashboard.when(
      loading: () => const StudentPageScaffold(
        title: 'Início',
        subtitle: 'Preparando sua experiência de aprendizagem.',
        body: _DashboardSkeleton(),
      ),
      error: (error, _) {
        final appError = AppError.fromException(error);
        return StudentPageScaffold(
          title: 'Início',
          subtitle: 'Continue sua jornada na Lawrence Academy.',
          body: SizedBox(
            height: 460,
            child: AppErrorState(
              title: appError.title,
              message: appError.message,
              onRetry: refresh,
            ),
          ),
        );
      },
      data: (state) =>
          LawrenceBreakpoints.isMobile(MediaQuery.sizeOf(context).width)
          ? _MobileDashboard(state: state, onRefresh: refresh)
          : StudentPageScaffold(
              title: '',
              showHeader: false,
              maxContentWidth: 1280,
              onRefresh: refresh,
              actions: [
                IconButton(
                  tooltip: 'Pesquisar',
                  onPressed: () => context.go('/dashboard/search'),
                  icon: const Icon(Icons.search_rounded),
                ),
                IconButton(
                  tooltip: 'Notificações',
                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Nenhuma notificação nova no momento.'),
                    ),
                  ),
                  icon: const Icon(Icons.notifications_none_rounded),
                ),
              ],
              body: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  PublicReveal(
                    child: _EditorialMasthead(
                      greeting: _greeting(state.studentName),
                      courseCount: state.courses.length,
                      onSearch: () => context.go('/dashboard/search'),
                      onCatalog: () => context.go('/dashboard/courses'),
                    ),
                  ),
                  const SizedBox(height: LawrenceSpacing.xxl),
                  if (state.isUsingCachedAccess) ...[
                    const _CachedAccessBanner(),
                    const SizedBox(height: LawrenceSpacing.lg),
                  ],
                  if (state.resume != null) ...[
                    ContinueWatchingSection(
                      course: state.resume!.course,
                      progress: state.resume!.progressPercentage,
                      lessonTitle: state.resume!.lessonTitle,
                      view: state.resume!.view,
                      destination: state.resume!.destination,
                    ),
                    const SizedBox(height: LawrenceSpacing.xxl),
                  ],
                  const PublicReveal(
                    delay: Duration(milliseconds: 60),
                    child: EventsBanner(),
                  ),
                  const SizedBox(height: LawrenceSpacing.xxxl),
                  MyCoursesSection(
                    courses: state.courses,
                    progressList: state.progressList,
                  ),
                  if (state.courses.isNotEmpty) ...[
                    const SizedBox(height: LawrenceSpacing.xl),
                    LearningOverviewSection(
                      courses: state.courses,
                      progress: state.progressList,
                    ),
                  ],
                ],
              ),
            ),
    );
  }

  String _greeting(String name) {
    final normalizedName = name.trim();
    final firstName = normalizedName.isEmpty
        ? 'Estudante'
        : normalizedName.split(RegExp(r'\s+')).first;
    return 'Olá, $firstName!';
  }
}

class _MobileDashboard extends StatelessWidget {
  const _MobileDashboard({required this.state, required this.onRefresh});

  final DashboardState state;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return StudentPageScaffold(
      title: '',
      showHeader: false,
      maxContentWidth: 700,
      onRefresh: onRefresh,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              IconButton(
                tooltip: 'Abrir menu',
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Use a navegação na parte inferior.'),
                  ),
                ),
                icon: const Icon(Icons.menu_rounded),
              ),
              const Spacer(),
              IconButton(
                tooltip: 'Pesquisar',
                onPressed: () => context.go('/dashboard/search'),
                icon: const Icon(Icons.search_rounded),
              ),
              IconButton(
                tooltip: 'Notificações',
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Nenhuma notificação nova.')),
                ),
                icon: const Icon(Icons.notifications_none_rounded),
              ),
            ],
          ),
          const SizedBox(height: LawrenceSpacing.md),
          Text(
            'Meus cursos',
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              color: LawrenceColors.plum,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: LawrenceSpacing.md),
          if (state.courses.isEmpty)
            AppEmptyState(
              title: 'Sua formação começa aqui',
              description: 'Explore os cursos e escolha sua próxima técnica.',
              icon: Icons.menu_book_outlined,
              actionLabel: 'Explorar cursos',
              onActionPressed: () => context.go('/dashboard/courses'),
            )
          else
            SizedBox(
              height: 220,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: state.courses.length,
                separatorBuilder: (_, _) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final course = state.courses[index];
                  final items = state.progressList
                      .where((item) => item.courseId == course.id)
                      .toList(growable: false);
                  final progress = items.isEmpty
                      ? 0.0
                      : items.fold<double>(
                              0,
                              (sum, item) => sum + item.progressPercentage,
                            ) /
                            items.length;
                  return _MobileCourseCard(course: course, progress: progress);
                },
              ),
            ),
          const SizedBox(height: LawrenceSpacing.xl),
          _MobileSectionTitle(
            title: 'Formações e planos de estudo',
            onMore: () => context.go('/dashboard/courses'),
          ),
          const SizedBox(height: LawrenceSpacing.sm),
          _MobilePathCard(courseCount: state.courses.length),
          const SizedBox(height: LawrenceSpacing.xl),
          _MobileSectionTitle(
            title: 'Atividades',
            onMore: () => context.go('/dashboard/activities'),
          ),
          const SizedBox(height: LawrenceSpacing.sm),
          ListTile(
            minTileHeight: 76,
            tileColor: LawrenceColors.surfaceSubtle,
            leading: const Icon(
              Icons.fact_check_outlined,
              color: LawrenceColors.wine,
            ),
            title: const Text('Continue praticando'),
            subtitle: const Text('Questionários, projetos e entregas do curso'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => context.go('/dashboard/activities'),
          ),
        ],
      ),
    );
  }
}

class _MobileCourseCard extends StatelessWidget {
  const _MobileCourseCard({required this.course, required this.progress});

  final Course course;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '${course.title}, ${progress.round()} por cento concluído',
      child: SizedBox(
        width: 278,
        child: Material(
          color: Colors.white,
          shape: const RoundedRectangleBorder(
            side: BorderSide(color: LawrenceColors.borderMist),
          ),
          child: InkWell(
            onTap: () => context.go('/dashboard/courses/${course.id}'),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LinearProgressIndicator(
                    value: (progress / 100).clamp(0.0, 1.0),
                    minHeight: 5,
                    backgroundColor: LawrenceColors.surfaceSubtle,
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.school_outlined,
                    size: 38,
                    color: LawrenceColors.wine,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    course.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(
                      context,
                    ).textTheme.titleLarge?.copyWith(height: 1.25),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${progress.round()}% concluído',
                    style: const TextStyle(color: LawrenceColors.textSecondary),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MobileSectionTitle extends StatelessWidget {
  const _MobileSectionTitle({required this.title, required this.onMore});
  final String title;
  final VoidCallback onMore;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Text(title, style: Theme.of(context).textTheme.headlineMedium),
      ),
      TextButton(onPressed: onMore, child: const Text('MAIS')),
    ],
  );
}

class _MobilePathCard extends StatelessWidget {
  const _MobilePathCard({required this.courseCount});
  final int courseCount;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: const BoxDecoration(
      color: LawrenceColors.plum,
      border: Border(left: BorderSide(color: LawrenceColors.wine, width: 5)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'FORMAÇÃO',
          style: TextStyle(
            color: LawrenceColors.goldHighlight,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Sua jornada Lawrence',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        const SizedBox(height: 16),
        LinearProgressIndicator(
          value: courseCount == 0 ? 0 : .18,
          backgroundColor: Colors.white24,
        ),
        const SizedBox(height: 10),
        Text(
          '$courseCount cursos em andamento',
          style: const TextStyle(color: LawrenceColors.goldHighlight),
        ),
      ],
    ),
  );
}

class _CachedAccessBanner extends StatelessWidget {
  const _CachedAccessBanner();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      label:
          'Conteúdo salvo. Não foi possível atualizar seus acessos. Exibindo cursos com progresso disponível neste dispositivo.',
      child: Container(
        padding: const EdgeInsets.all(LawrenceSpacing.md),
        decoration: BoxDecoration(
          color: LawrenceColors.warningSurface,
          borderRadius: BorderRadius.circular(LawrenceRadii.card),
          border: Border.all(color: LawrenceColors.warning),
        ),
        child: const Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.cloud_off_outlined, color: LawrenceColors.warning),
            SizedBox(width: LawrenceSpacing.sm),
            Expanded(
              child: Text(
                'Não foi possível atualizar seus acessos. Exibindo o conteúdo salvo neste dispositivo.',
                style: TextStyle(color: LawrenceColors.textPrimary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EditorialMasthead extends StatelessWidget {
  const _EditorialMasthead({
    required this.greeting,
    required this.courseCount,
    required this.onSearch,
    required this.onCatalog,
  });

  final String greeting;
  final int courseCount;
  final VoidCallback onSearch;
  final VoidCallback onCatalog;

  @override
  Widget build(BuildContext context) {
    final mobile = MediaQuery.sizeOf(context).width < 700;
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.symmetric(vertical: mobile ? 12 : 24),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: scheme.outlineVariant)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ATELIÊ DIGITAL · SUA FORMAÇÃO',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: scheme.primary,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.8,
            ),
          ),
          SizedBox(height: mobile ? 12 : 16),
          Text(
            greeting,
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
              fontSize: mobile ? 44 : 58,
              height: 1,
              letterSpacing: -1.2,
            ),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final copy = Text(
                courseCount == 0
                    ? 'Escolha uma formação e comece a construir sua assinatura.'
                    : 'Retome sua prática com clareza. O próximo passo está logo abaixo.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  height: 1.55,
                  color: scheme.onSurfaceVariant,
                ),
              );
              final actions = Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  StudentActionButton(
                    onPressed: onCatalog,
                    icon: Icons.book_outlined,
                    label: courseCount == 0 ? 'Explorar cursos' : 'Meus cursos',
                  ),
                  StudentActionButton(
                    onPressed: onSearch,
                    icon: Icons.search_rounded,
                    label: 'Pesquisar',
                    variant: StudentActionButtonVariant.secondary,
                  ),
                ],
              );
              if (constraints.maxWidth < 760) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [copy, const SizedBox(height: 20), actions],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(child: copy),
                  const SizedBox(width: 48),
                  actions,
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _DashboardSkeleton extends StatelessWidget {
  const _DashboardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        AppSkeletonState(width: 220, height: 28),
        SizedBox(height: LawrenceSpacing.sm),
        AppSkeletonState(width: double.infinity, height: 220),
        SizedBox(height: LawrenceSpacing.xl),
        AppSkeletonState(width: 160, height: 28),
        SizedBox(height: LawrenceSpacing.sm),
        AppSkeletonState(width: double.infinity, height: 150),
        SizedBox(height: LawrenceSpacing.md),
        AppSkeletonState(width: double.infinity, height: 150),
      ],
    );
  }
}
