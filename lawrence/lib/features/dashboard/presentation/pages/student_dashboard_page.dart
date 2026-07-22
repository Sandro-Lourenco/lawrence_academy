import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/error/app_error.dart';
import '../../../../design_system/tokens/lawrence_theme.dart';
import '../../../../design_system/widgets/state_widgets.dart';
import '../../../../design_system/widgets/student_page_scaffold.dart';
import '../controllers/dashboard_controller.dart';
import '../widgets/continue_watching_section.dart';
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
      data: (state) => StudentPageScaffold(
        title: _greeting(state.studentName),
        subtitle: 'Pronta para continuar aprendendo?',
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
            if (state.isUsingCachedAccess) ...[
              const _CachedAccessBanner(),
              const SizedBox(height: LawrenceSpacing.lg),
            ],
            if (state.resume != null) ...[
              ContinueWatchingSection(
                course: state.resume!.course,
                progress: state.resume!.progressPercentage,
                nextLessonId: state.resume!.nextLessonId,
              ),
              const SizedBox(height: LawrenceSpacing.xl),
            ],
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
