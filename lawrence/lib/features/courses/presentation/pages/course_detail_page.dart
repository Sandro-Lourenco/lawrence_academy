import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/error/app_error.dart';
import '../../../../core/errors/app_exceptions.dart';
import '../../../../design_system/tokens/lawrence_theme.dart';
import '../../../../design_system/widgets/couture_primary_button.dart';
import '../../../../design_system/widgets/couture_progress_bar.dart';
import '../../../../design_system/widgets/state_widgets.dart';
import '../../../../design_system/widgets/status_badge.dart';
import '../../../../design_system/widgets/student_page_header.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../subscriptions/domain/entities/checkout_eligibility_result.dart';
import '../../../subscriptions/presentation/controllers/checkout_eligibility_controller.dart';
import '../../domain/entities/course.dart';
import '../providers/course_detail_provider.dart';
import '../../../lesson_progress/presentation/controllers/lesson_progress_controller.dart';
import '../../../lesson_progress/domain/entities/lesson_progress_entity.dart';
import '../../../lessons/presentation/controllers/purchased_course_presentation.dart';

enum CourseAccessAction {
  login,
  subscribe,
  access,
  manageSubscription,
  unavailable,
}

enum CourseAccessErrorAction { retry, signInAgain }

class CourseAccessErrorPresentation {
  final String message;
  final String actionLabel;
  final CourseAccessErrorAction action;

  const CourseAccessErrorPresentation({
    required this.message,
    required this.actionLabel,
    required this.action,
  });
}

CourseAccessErrorPresentation resolveCourseAccessErrorPresentation(
  Object error,
) {
  if (error is AuthFailure) {
    return const CourseAccessErrorPresentation(
      message:
          'Sua sessão expirou ou não pôde ser validada. Entre novamente para continuar.',
      actionLabel: 'Entrar novamente',
      action: CourseAccessErrorAction.signInAgain,
    );
  }
  if (error is NetworkFailure) {
    return const CourseAccessErrorPresentation(
      message:
          'Não foi possível conectar ao serviço de acesso. Verifique sua conexão e tente novamente.',
      actionLabel: 'Tentar novamente',
      action: CourseAccessErrorAction.retry,
    );
  }
  return const CourseAccessErrorPresentation(
    message:
        'O serviço de acesso está temporariamente indisponível. Tente novamente em instantes.',
    actionLabel: 'Tentar novamente',
    action: CourseAccessErrorAction.retry,
  );
}

class CourseAccessPresentation {
  final CourseAccessAction action;
  final String label;
  final String? message;

  const CourseAccessPresentation(this.action, this.label, {this.message});
}

CourseAccessPresentation resolveCourseAccessPresentation({
  required bool authenticated,
  required bool isFree,
  required CheckoutEligibilityResult? eligibility,
}) {
  if (!authenticated) {
    return CourseAccessPresentation(
      CourseAccessAction.login,
      isFree ? 'Entrar para acessar' : 'Entrar para assinar',
    );
  }
  if (eligibility == null) {
    return const CourseAccessPresentation(
      CourseAccessAction.unavailable,
      'Acesso indisponível',
      message: 'Não foi possível verificar o acesso a este curso.',
    );
  }
  if (eligibility.hasAccess) {
    return const CourseAccessPresentation(
      CourseAccessAction.access,
      'Continuar curso',
    );
  }
  if (eligibility.reasonCode == 'PAST_DUE_EXPIRED') {
    return CourseAccessPresentation(
      CourseAccessAction.manageSubscription,
      'Regularizar assinatura',
      message: eligibility.message,
    );
  }
  if (eligibility.canPurchase) {
    return CourseAccessPresentation(
      CourseAccessAction.subscribe,
      isFree ? 'Começar curso' : 'Assinar este curso',
    );
  }
  return CourseAccessPresentation(
    CourseAccessAction.unavailable,
    'Acesso indisponível',
    message: eligibility.message,
  );
}

class CourseDetailPage extends ConsumerWidget {
  final String slug;

  const CourseDetailPage({super.key, required this.slug});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final course = ref.watch(courseDetailBySlugProvider(slug));
    return course.when(
      loading: () => const SizedBox(
        height: 560,
        child: AppLoadingState(message: 'Carregando detalhes do curso'),
      ),
      error: (error, _) {
        final appError = AppError.fromException(error);
        return SizedBox(
          height: 560,
          child: AppErrorState(
            title: appError.title,
            message: appError.message,
            onRetry: () => ref.invalidate(courseDetailBySlugProvider(slug)),
          ),
        );
      },
      data: (item) => item == null
          ? const SizedBox(
              height: 500,
              child: AppEmptyState(
                title: 'Curso não encontrado',
                description: 'Este curso não está disponível no momento.',
              ),
            )
          : _CourseDetailContent(course: item),
    );
  }
}

class _CourseDetailContent extends StatelessWidget {
  final Course course;

  const _CourseDetailContent({required this.course});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1180),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            StudentPageHeader(
              title: 'Detalhes do curso',
              leading: IconButton(
                tooltip: 'Voltar ao catálogo',
                onPressed: () =>
                    context.canPop() ? context.pop() : context.go('/courses'),
                icon: const Icon(Icons.arrow_back_rounded),
              ),
            ),
            const SizedBox(height: LawrenceSpacing.lg),
            LayoutBuilder(
              builder: (context, constraints) {
                final desktop = constraints.maxWidth >= 900;
                final main = Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _CourseHero(course: course),
                    if (!desktop) ...[
                      const SizedBox(height: LawrenceSpacing.lg),
                      _PurchasePanel(course: course),
                    ],
                    const SizedBox(height: LawrenceSpacing.xl),
                    _CourseOverview(course: course),
                    const SizedBox(height: LawrenceSpacing.xl),
                    _Curriculum(course: course),
                  ],
                );
                if (!desktop) return main;
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: main),
                    const SizedBox(width: LawrenceSpacing.lg),
                    SizedBox(width: 340, child: _PurchasePanel(course: course)),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _CourseHero extends ConsumerWidget {
  final Course course;

  const _CourseHero({required this.course});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authenticated = ref.watch(authNotifierProvider).user != null;
    final eligibility = authenticated
        ? ref.watch(checkoutEligibilityProvider(course.id)).valueOrNull
        : null;
    final hasAccess = eligibility?.hasAccess ?? false;

    PurchasedCourseSummary? summary;
    if (hasAccess) {
      final progressList =
          ref.watch(courseProgressListProvider(course.id)).valueOrNull ?? [];
      summary = summarizePurchasedCourse(course, progressList);
    }

    return Card(
      clipBehavior: Clip.antiAlias,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 680;
          final visual = Container(
            width: compact ? double.infinity : 280,
            height: compact ? 190 : 300,
            color: LawrenceColors.brandNavy,
            alignment: Alignment.center,
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.ondemand_video_outlined,
                  color: Colors.white,
                  size: 64,
                ),
                SizedBox(height: LawrenceSpacing.sm),
                Text(
                  'Prévia ainda não disponível',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          );
          final details = Padding(
            padding: const EdgeInsets.all(LawrenceSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Wrap(
                  spacing: LawrenceSpacing.xs,
                  runSpacing: LawrenceSpacing.xs,
                  children: [
                    AppStatusBadge(
                      label: course.category,
                      icon: Icons.category_outlined,
                      tone: AppStatusTone.info,
                    ),
                    AppStatusBadge(
                      label: course.level,
                      icon: Icons.signal_cellular_alt_rounded,
                    ),
                    if (course.estimatedDurationMinutes != null &&
                        course.estimatedDurationMinutes! > 0)
                      AppStatusBadge(
                        label: _formatDuration(
                          course.estimatedDurationMinutes!,
                        ),
                        icon: Icons.schedule_outlined,
                      ),
                  ],
                ),
                const SizedBox(height: LawrenceSpacing.md),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        course.title,
                        style: Theme.of(context).textTheme.headlineLarge
                            ?.copyWith(
                              color: LawrenceColors.brandNavy,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                    ),
                    if (hasAccess) ...[
                      const SizedBox(width: LawrenceSpacing.sm),
                      IconButton(
                        icon: const Icon(Icons.more_vert),
                        tooltip: 'Mais opções',
                        onPressed: () {
                          // TODO: Implement more options
                        },
                      ),
                    ],
                  ],
                ),
                if (course.summary.trim().isNotEmpty) ...[
                  const SizedBox(height: LawrenceSpacing.sm),
                  Text(
                    course.summary,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: LawrenceColors.textSecondary,
                    ),
                  ),
                ],
                if (hasAccess && summary != null) ...[
                  const SizedBox(height: LawrenceSpacing.lg),
                  Row(
                    children: [
                      Expanded(
                        child: CoutureProgressBar(
                          value: summary.progress,
                          semanticLabel: 'Progresso em ${course.title}',
                        ),
                      ),
                      const SizedBox(width: LawrenceSpacing.md),
                      Text(
                        '${(summary.progress * 100).toInt()}% concluído',
                        style: const TextStyle(
                          color: LawrenceColors.textSecondary,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          );
          return compact
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [visual, details],
                )
              : Row(
                  children: [
                    visual,
                    Expanded(child: details),
                  ],
                );
        },
      ),
    );
  }
}

class _CourseOverview extends StatelessWidget {
  final Course course;

  const _CourseOverview({required this.course});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const StudentSectionHeader(title: 'Sobre o curso'),
        const SizedBox(height: LawrenceSpacing.sm),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(LawrenceSpacing.lg),
            child: Wrap(
              spacing: LawrenceSpacing.xl,
              runSpacing: LawrenceSpacing.md,
              children: [
                _Fact(
                  icon: Icons.view_module_outlined,
                  label: '${course.modules.length} módulos',
                ),
                _Fact(
                  icon: Icons.play_lesson_outlined,
                  label: '${course.lessonCount} aulas',
                ),
                _Fact(
                  icon: Icons.signal_cellular_alt_rounded,
                  label: 'Nível ${course.level}',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Fact extends StatelessWidget {
  final IconData icon;
  final String label;

  const _Fact({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: LawrenceColors.actionPrimary),
        const SizedBox(width: LawrenceSpacing.xs),
        Text(label, style: const TextStyle(color: LawrenceColors.textPrimary)),
      ],
    );
  }
}

class _Curriculum extends ConsumerWidget {
  final Course course;

  const _Curriculum({required this.course});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authenticated = ref.watch(authNotifierProvider).user != null;
    final eligibility = authenticated
        ? ref.watch(checkoutEligibilityProvider(course.id)).valueOrNull
        : null;
    final hasAccess = eligibility?.hasAccess ?? false;

    Map<String, LessonProgressEntity>? progressByLesson;
    if (hasAccess) {
      final progressList =
          ref.watch(courseProgressListProvider(course.id)).valueOrNull ?? [];
      progressByLesson = {for (final item in progressList) item.lessonId: item};
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const StudentSectionHeader(title: 'Conteúdo do curso'),
        const SizedBox(height: LawrenceSpacing.sm),
        if (course.modules.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(LawrenceSpacing.lg),
              child: Text('O currículo deste curso ainda não foi publicado.'),
            ),
          )
        else
          hasAccess
              ? Column(
                  children: [
                    for (var index = 0; index < course.modules.length; index++)
                      _EnrolledModuleCard(
                        module: course.modules[index],
                        course: course,
                        progressByLesson: progressByLesson ?? {},
                      ),
                  ],
                )
              : Card(
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      for (
                        var index = 0;
                        index < course.modules.length;
                        index++
                      )
                        ExpansionTile(
                          title: Text(
                            'Módulo ${index + 1}: ${course.modules[index].title}',
                            style: const TextStyle(
                              color: LawrenceColors.textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          subtitle: Text(
                            '${course.modules[index].lessons.length} aulas',
                          ),
                          children: [
                            for (final lesson in course.modules[index].lessons)
                              ListTile(
                                leading: const Icon(Icons.lock_outline_rounded),
                                title: Text(lesson.title),
                                subtitle: const Text(
                                  'Disponível após liberar o acesso',
                                ),
                              ),
                          ],
                        ),
                    ],
                  ),
                ),
      ],
    );
  }
}

class _EnrolledModuleCard extends StatelessWidget {
  final Module module;
  final Course course;
  final Map<String, LessonProgressEntity> progressByLesson;

  const _EnrolledModuleCard({
    required this.module,
    required this.course,
    required this.progressByLesson,
  });

  @override
  Widget build(BuildContext context) {
    final completedLessons = module.lessons
        .where((l) => progressByLesson[l.id]?.completed == true)
        .length;
    final totalLessons = module.lessons.length;
    final totalDuration = module.lessons.fold(
      0,
      (sum, l) => sum + (l.estimatedDurationMinutes ?? 0),
    );

    final nextLessonIndex = module.lessons.indexWhere(
      (l) => progressByLesson[l.id]?.completed != true,
    );
    final isModuleCompleted = nextLessonIndex == -1;
    final isModuleStarted =
        completedLessons > 0 ||
        module.lessons.any(
          (l) => (progressByLesson[l.id]?.progressPercentage ?? 0) > 0,
        );

    final nextLesson = isModuleCompleted
        ? null
        : module.lessons[nextLessonIndex];

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: .24),
        ),
      ),
      margin: const EdgeInsets.only(bottom: LawrenceSpacing.md),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          collapsedBackgroundColor: LawrenceColors.canvasParchment,
          backgroundColor: LawrenceColors.canvas,
          tilePadding: const EdgeInsets.symmetric(
            horizontal: LawrenceSpacing.lg,
            vertical: LawrenceSpacing.sm,
          ),
          title: Row(
            children: [
              Expanded(
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: LawrenceSpacing.lg,
                  runSpacing: LawrenceSpacing.sm,
                  children: [
                    Text(
                      module.title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: LawrenceColors.textPrimary,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    if (!isModuleCompleted && nextLesson != null)
                      CouturePrimaryButton(
                        onPressed: () {
                          context.go(
                            '/dashboard/courses/${course.id}/lessons/${nextLesson.id}',
                          );
                        },
                        icon: Icons.play_circle_outline,
                        label: isModuleStarted
                            ? 'Continuar'
                            : 'Ver primeiro vídeo',
                      ),
                  ],
                ),
              ),
              const SizedBox(width: LawrenceSpacing.md),
              Text(
                '$completedLessons / $totalLessons',
                style: const TextStyle(color: LawrenceColors.textSecondary),
              ),
              if (totalDuration > 0) ...[
                const SizedBox(width: LawrenceSpacing.xs),
                Text(
                  _formatDuration(totalDuration),
                  style: const TextStyle(color: LawrenceColors.textSecondary),
                ),
              ],
            ],
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                LawrenceSpacing.xl,
                0,
                LawrenceSpacing.lg,
                LawrenceSpacing.lg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final lesson in module.lessons)
                    Padding(
                      padding: const EdgeInsets.only(
                        bottom: LawrenceSpacing.sm,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(
                              top: 6.0,
                              right: LawrenceSpacing.sm,
                            ),
                            child: Icon(
                              Icons.circle,
                              size: 6,
                              color: LawrenceColors.textSecondary,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              lesson.title,
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(
                                    color: LawrenceColors.textSecondary,
                                    height: 1.4,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PurchasePanel extends StatelessWidget {
  final Course course;

  const _PurchasePanel({required this.course});

  @override
  Widget build(BuildContext context) {
    final price = course.isFree
        ? 'Gratuito'
        : 'R\$ ${course.monthlyPrice.toStringAsFixed(2).replaceAll('.', ',')} por mês';
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(LawrenceSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              course.isFree ? 'Acesso ao curso' : 'Assinatura deste curso',
              style: const TextStyle(
                color: LawrenceColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: LawrenceSpacing.xs),
            Text(
              price,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: LawrenceColors.brandNavy,
                fontWeight: FontWeight.w800,
              ),
            ),
            if (!course.isFree) ...[
              const SizedBox(height: LawrenceSpacing.sm),
              const Text(
                'Cobrança mensal somente deste curso. Cancele quando quiser; seu acesso continua até o fim do período pago.',
                style: TextStyle(color: LawrenceColors.textSecondary),
              ),
            ],
            const SizedBox(height: LawrenceSpacing.lg),
            _CourseAccessButton(course: course),
            const SizedBox(height: LawrenceSpacing.md),
            const _PurchaseNote(
              icon: Icons.lock_outline_rounded,
              text: 'Pagamento processado com segurança pelo Stripe.',
            ),
            const SizedBox(height: LawrenceSpacing.sm),
            const _PurchaseNote(
              icon: Icons.workspace_premium_outlined,
              text:
                  'O certificado é liberado após a conclusão e aprovação exigidas pelo curso.',
            ),
          ],
        ),
      ),
    );
  }
}

class _PurchaseNote extends StatelessWidget {
  const _PurchaseNote({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: LawrenceColors.textSecondary),
        const SizedBox(width: LawrenceSpacing.xs),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: LawrenceColors.textSecondary,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}

class _CourseAccessButton extends ConsumerWidget {
  final Course course;

  const _CourseAccessButton({required this.course});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authenticated = ref.watch(authNotifierProvider).user != null;
    if (!authenticated) {
      return _ActionButton(
        presentation: resolveCourseAccessPresentation(
          authenticated: false,
          isFree: course.isFree,
          eligibility: null,
        ),
        course: course,
      );
    }

    return ref
        .watch(checkoutEligibilityProvider(course.id))
        .when(
          loading: () => Semantics(
            liveRegion: true,
            label: 'Confirmando sua assinatura',
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (error, _) {
            final presentation = resolveCourseAccessErrorPresentation(error);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  presentation.message,
                  style: const TextStyle(color: LawrenceColors.danger),
                ),
                const SizedBox(height: LawrenceSpacing.sm),
                OutlinedButton.icon(
                  onPressed: () async {
                    if (presentation.action ==
                        CourseAccessErrorAction.signInAgain) {
                      await ref.read(authNotifierProvider.notifier).signOut();
                      if (!context.mounted) return;
                      context.go(
                        Uri(
                          path: '/login',
                          queryParameters: {
                            'redirect': '/courses/${course.slug}',
                          },
                        ).toString(),
                      );
                      return;
                    }
                    await ref
                        .read(checkoutEligibilityProvider(course.id).notifier)
                        .checkEligibility();
                  },
                  icon: Icon(
                    presentation.action == CourseAccessErrorAction.signInAgain
                        ? Icons.login_rounded
                        : Icons.refresh_rounded,
                  ),
                  label: Text(presentation.actionLabel),
                ),
              ],
            );
          },
          data: (eligibility) => _ActionButton(
            presentation: resolveCourseAccessPresentation(
              authenticated: true,
              isFree: course.isFree,
              eligibility: eligibility,
            ),
            course: course,
          ),
        );
  }
}

class _ActionButton extends StatelessWidget {
  final CourseAccessPresentation presentation;
  final Course course;

  const _ActionButton({required this.presentation, required this.course});

  @override
  Widget build(BuildContext context) {
    final lessons = [for (final module in course.modules) ...module.lessons];
    final learningPath = lessons.isEmpty
        ? '/dashboard/courses/${course.id}'
        : '/dashboard/courses/${course.id}/lessons/${lessons.first.id}';
    final VoidCallback? action = switch (presentation.action) {
      CourseAccessAction.login => () => context.go(
        Uri(
          path: '/login',
          queryParameters: {'redirect': '/courses/${course.slug}'},
        ).toString(),
      ),
      CourseAccessAction.subscribe =>
        course.isFree
            ? () => context.go(learningPath)
            : () => context.push('/checkout/${course.id}'),
      CourseAccessAction.access => () => context.go(learningPath),
      CourseAccessAction.manageSubscription => () => context.go(
        '/dashboard/subscriptions',
      ),
      CourseAccessAction.unavailable => null,
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton(onPressed: action, child: Text(presentation.label)),
        if (presentation.message != null) ...[
          const SizedBox(height: LawrenceSpacing.xs),
          Text(
            presentation.message!,
            style: const TextStyle(color: LawrenceColors.textSecondary),
          ),
        ],
      ],
    );
  }
}

String _formatDuration(int minutes) {
  final hours = minutes ~/ 60;
  final remaining = minutes % 60;
  if (hours == 0) return '${remaining}min';
  if (remaining == 0) return '${hours}h';
  return '${hours}h ${remaining}min';
}
