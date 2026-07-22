import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/error/app_error.dart';
import '../../../../design_system/tokens/lawrence_theme.dart';
import '../../../../design_system/widgets/state_widgets.dart';
import '../../../../design_system/widgets/status_badge.dart';
import '../../../../design_system/widgets/student_page_header.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../subscriptions/domain/entities/checkout_eligibility_result.dart';
import '../../../subscriptions/presentation/controllers/checkout_eligibility_controller.dart';
import '../../domain/entities/course.dart';
import '../providers/course_detail_provider.dart';

enum CourseAccessAction { login, subscribe, access, manageSubscription, unavailable }

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
      'Acessar curso',
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
      isFree ? 'Liberar acesso gratuito' : 'Assinar curso',
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
                onPressed: () => context.canPop()
                    ? context.pop()
                    : context.go('/courses'),
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

class _CourseHero extends StatelessWidget {
  final Course course;

  const _CourseHero({required this.course});

  @override
  Widget build(BuildContext context) {
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
                Icon(Icons.ondemand_video_outlined, color: Colors.white, size: 64),
                SizedBox(height: LawrenceSpacing.sm),
                Text(
                  'Prévia ainda não disponível',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
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
                  ],
                ),
                const SizedBox(height: LawrenceSpacing.md),
                Text(
                  course.title,
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: LawrenceColors.brandNavy,
                    fontWeight: FontWeight.w800,
                  ),
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
              ],
            ),
          );
          return compact
              ? Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [visual, details])
              : Row(children: [visual, Expanded(child: details)]);
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
                _Fact(icon: Icons.view_module_outlined, label: '${course.modules.length} módulos'),
                _Fact(icon: Icons.play_lesson_outlined, label: '${course.lessonCount} aulas'),
                _Fact(icon: Icons.signal_cellular_alt_rounded, label: 'Nível ${course.level}'),
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

class _Curriculum extends StatelessWidget {
  final Course course;

  const _Curriculum({required this.course});

  @override
  Widget build(BuildContext context) {
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
          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                for (var index = 0; index < course.modules.length; index++)
                  ExpansionTile(
                    title: Text(
                      'Módulo ${index + 1}: ${course.modules[index].title}',
                      style: const TextStyle(
                        color: LawrenceColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    subtitle: Text('${course.modules[index].lessons.length} aulas'),
                    children: [
                      for (final lesson in course.modules[index].lessons)
                        ListTile(
                          leading: const Icon(Icons.lock_outline_rounded),
                          title: Text(lesson.title),
                          subtitle: const Text('Disponível após liberar o acesso'),
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
                'Cobrança recorrente por curso. Você pode gerenciar ou cancelar esta assinatura separadamente.',
                style: TextStyle(color: LawrenceColors.textSecondary),
              ),
            ],
            const SizedBox(height: LawrenceSpacing.lg),
            _CourseAccessButton(course: course),
            const SizedBox(height: LawrenceSpacing.md),
            const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.verified_user_outlined, size: 20, color: LawrenceColors.success),
                SizedBox(width: LawrenceSpacing.xs),
                Expanded(
                  child: Text(
                    'Pagamento e autorização são validados com segurança antes da liberação.',
                    style: TextStyle(color: LawrenceColors.textSecondary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: LawrenceSpacing.sm),
            const Text(
              'Certificados seguem os critérios de conclusão e aprovação definidos para a plataforma.',
              style: TextStyle(color: LawrenceColors.textSecondary),
            ),
          ],
        ),
      ),
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

    return ref.watch(checkoutEligibilityProvider(course.id)).when(
      loading: () => Semantics(
        liveRegion: true,
        label: 'Verificando acesso ao curso',
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Não foi possível verificar seu acesso.',
            style: TextStyle(color: LawrenceColors.danger),
          ),
          const SizedBox(height: LawrenceSpacing.sm),
          OutlinedButton.icon(
            onPressed: () => ref
                .read(checkoutEligibilityProvider(course.id).notifier)
                .checkEligibility(),
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Tentar novamente'),
          ),
        ],
      ),
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
    final VoidCallback? action = switch (presentation.action) {
      CourseAccessAction.login => () => context.go('/login'),
      CourseAccessAction.subscribe => () => context.push('/checkout/${course.id}'),
      CourseAccessAction.access => () => context.go('/dashboard/courses/${course.id}'),
      CourseAccessAction.manageSubscription => () => context.go('/dashboard/subscriptions'),
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
