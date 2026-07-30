import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/error/app_error.dart';
import '../../../../core/errors/app_exceptions.dart';
import '../../../../design_system/tokens/lawrence_theme.dart';
import '../../../../design_system/widgets/state_widgets.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../subscriptions/domain/entities/checkout_eligibility_result.dart';
import '../../../subscriptions/presentation/controllers/checkout_eligibility_controller.dart';
import '../../domain/entities/course.dart';
import '../providers/course_detail_provider.dart';

class PublicCourseDetailPage extends ConsumerWidget {
  final String slug;

  const PublicCourseDetailPage({super.key, required this.slug});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(courseDetailBySlugProvider(slug)).when(
      loading: () => const SizedBox(
        height: 620,
        child: AppLoadingState(message: 'Carregando detalhes do curso'),
      ),
      error: (error, _) {
        final appError = AppError.fromException(error);
        return SizedBox(
          height: 620,
          child: AppErrorState(
            title: appError.title,
            message: appError.message,
            onRetry: () => ref.invalidate(courseDetailBySlugProvider(slug)),
          ),
        );
      },
      data: (course) => course == null
          ? const SizedBox(
              height: 520,
              child: AppEmptyState(
                title: 'Curso não encontrado',
                description: 'Este curso não está disponível no momento.',
              ),
            )
          : _PublicCourseContent(course: course),
    );
  }
}

class _PublicCourseContent extends StatelessWidget {
  final Course course;

  const _PublicCourseContent({required this.course});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, viewport) {
        final mobile = viewport.maxWidth < LawrenceBreakpoints.tablet;
        final horizontal = mobile ? LawrenceSpacing.md : LawrenceSpacing.xxl;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _CourseHero(course: course, mobile: mobile),
            Padding(
              padding: EdgeInsets.fromLTRB(
                horizontal,
                LawrenceSpacing.xxl,
                horizontal,
                LawrenceSpacing.xxxl,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1180),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final desktop = constraints.maxWidth >= 900;
                      final details = Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _CourseOverview(course: course),
                          const SizedBox(height: LawrenceSpacing.xxl),
                          _Curriculum(course: course),
                        ],
                      );
                      if (!desktop) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _PurchasePanel(course: course),
                            const SizedBox(height: LawrenceSpacing.xxl),
                            details,
                          ],
                        );
                      }
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: details),
                          const SizedBox(width: LawrenceSpacing.xxl),
                          SizedBox(
                            width: 350,
                            child: _PurchasePanel(course: course),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _CourseHero extends StatelessWidget {
  final Course course;
  final bool mobile;

  const _CourseHero({required this.course, required this.mobile});

  @override
  Widget build(BuildContext context) {
    final subtitle = course.subtitle.trim().isNotEmpty
        ? course.subtitle
        : course.summary;
    return ColoredBox(
      color: const Color(0xFFE9EEFF),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: mobile ? LawrenceSpacing.md : LawrenceSpacing.xxl,
          vertical: mobile ? LawrenceSpacing.xl : LawrenceSpacing.xxxl,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1180),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextButton.icon(
                  onPressed: () => context.go('/courses'),
                  icon: const Icon(Icons.arrow_back_rounded, size: 18),
                  label: const Text('Explorar catálogo'),
                ),
                const SizedBox(height: LawrenceSpacing.lg),
                Text(
                  course.category.toUpperCase(),
                  style: const TextStyle(
                    color: LawrenceColors.actionPrimary,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: LawrenceSpacing.sm),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 900),
                  child: Text(
                    course.title,
                    style: (mobile
                            ? Theme.of(context).textTheme.displaySmall
                            : Theme.of(context).textTheme.displayMedium)
                        ?.copyWith(
                          color: LawrenceColors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
                if (subtitle.trim().isNotEmpty) ...[
                  const SizedBox(height: LawrenceSpacing.md),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 780),
                    child: Text(
                      subtitle,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: LawrenceColors.textSecondary,
                        fontWeight: FontWeight.w400,
                        height: 1.45,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: LawrenceSpacing.xl),
                Wrap(
                  spacing: LawrenceSpacing.xl,
                  runSpacing: LawrenceSpacing.md,
                  children: [
                    if (course.estimatedDurationMinutes case final value?
                        when value > 0)
                      _Fact(
                        icon: Icons.schedule_outlined,
                        label: _formatDuration(value),
                      ),
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
                    if (course.certificateEnabled)
                      const _Fact(
                        icon: Icons.workspace_premium_outlined,
                        label: 'Certificado',
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CourseOverview extends StatelessWidget {
  final Course course;

  const _CourseOverview({required this.course});

  @override
  Widget build(BuildContext context) {
    final learningItems = <String>[
      ...course.learningObjectives,
      ...course.competencies,
      ...course.expectedOutcomes,
    ].where((item) => item.trim().isNotEmpty).toSet().toList();
    final description = course.description.trim().isNotEmpty
        ? course.description
        : course.summary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (learningItems.isNotEmpty)
          _InformationSection(
            title: 'O que você vai aprender',
            child: _BulletList(items: learningItems),
          ),
        if (learningItems.isNotEmpty)
          const SizedBox(height: LawrenceSpacing.xxl),
        _InformationSection(
          title: 'Sobre o curso',
          child: Text(
            description,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              height: 1.65,
              color: LawrenceColors.textSecondary,
            ),
          ),
        ),
        if (course.targetAudience.isNotEmpty) ...[
          const SizedBox(height: LawrenceSpacing.xxl),
          _InformationSection(
            title: 'Para quem é este curso',
            child: _BulletList(items: course.targetAudience),
          ),
        ],
        if (course.requirements.isNotEmpty ||
            course.requiredMaterials.isNotEmpty) ...[
          const SizedBox(height: LawrenceSpacing.xxl),
          _InformationSection(
            title: 'O que você precisa',
            child: _BulletList(
              items: [...course.requirements, ...course.requiredMaterials],
            ),
          ),
        ],
      ],
    );
  }
}

class _InformationSection extends StatelessWidget {
  final String title;
  final Widget child;

  const _InformationSection({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: LawrenceSpacing.lg),
        child,
      ],
    );
  }
}

class _BulletList extends StatelessWidget {
  final List<String> items;

  const _BulletList({required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final item in items) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 2),
                child: Icon(
                  Icons.check_circle_outline_rounded,
                  color: LawrenceColors.success,
                  size: 22,
                ),
              ),
              const SizedBox(width: LawrenceSpacing.sm),
              Expanded(
                child: Text(
                  item,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: LawrenceColors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: LawrenceSpacing.md),
        ],
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
        Icon(icon, color: LawrenceColors.actionPrimary, size: 21),
        const SizedBox(width: LawrenceSpacing.xs),
        Text(
          label,
          style: const TextStyle(
            color: LawrenceColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
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
        Text(
          'Conteúdo do curso',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: LawrenceSpacing.sm),
        Text(
          '${course.modules.length} módulos · ${course.lessonCount} aulas',
          style: const TextStyle(color: LawrenceColors.textSecondary),
        ),
        const SizedBox(height: LawrenceSpacing.lg),
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
                'Cobrança recorrente por curso, gerenciada separadamente.',
                style: TextStyle(color: LawrenceColors.textSecondary),
              ),
            ],
            const SizedBox(height: LawrenceSpacing.lg),
            _CourseAccessButton(course: course),
            const SizedBox(height: LawrenceSpacing.md),
            const _Assurance(
              icon: Icons.verified_user_outlined,
              text:
                  'Pagamento e autorização são validados antes da liberação.',
            ),
            if (course.certificateEnabled) ...[
              const SizedBox(height: LawrenceSpacing.sm),
              const _Assurance(
                icon: Icons.workspace_premium_outlined,
                text: 'Certificado conforme os critérios de conclusão.',
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Assurance extends StatelessWidget {
  final IconData icon;
  final String text;

  const _Assurance({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: LawrenceColors.success),
        const SizedBox(width: LawrenceSpacing.xs),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: LawrenceColors.textSecondary),
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
      return FilledButton(
        onPressed: () => context.go(
          Uri(
            path: '/login',
            queryParameters: {'redirect': '/courses/${course.slug}'},
          ).toString(),
        ),
        child: Text(course.isFree ? 'Entrar para acessar' : 'Entrar para assinar'),
      );
    }
    return ref.watch(checkoutEligibilityProvider(course.id)).when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => _AccessError(course: course, error: error),
      data: (eligibility) =>
          _EligibilityAction(course: course, eligibility: eligibility),
    );
  }
}

class _AccessError extends ConsumerWidget {
  final Course course;
  final Object error;

  const _AccessError({required this.course, required this.error});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authFailure = error is AuthFailure;
    final message = authFailure
        ? 'Sua sessão expirou. Entre novamente para continuar.'
        : error is NetworkFailure
        ? 'Não foi possível verificar seu acesso. Confira a conexão.'
        : 'O serviço de acesso está temporariamente indisponível.';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(message, style: const TextStyle(color: LawrenceColors.danger)),
        const SizedBox(height: LawrenceSpacing.sm),
        OutlinedButton.icon(
          onPressed: () async {
            if (authFailure) {
              await ref.read(authNotifierProvider.notifier).signOut();
              if (!context.mounted) return;
              context.go(
                '/login?redirect=${Uri.encodeQueryComponent('/courses/${course.slug}')}',
              );
              return;
            }
            await ref
                .read(checkoutEligibilityProvider(course.id).notifier)
                .checkEligibility();
          },
          icon: Icon(
            authFailure ? Icons.login_rounded : Icons.refresh_rounded,
          ),
          label: Text(authFailure ? 'Entrar novamente' : 'Tentar novamente'),
        ),
      ],
    );
  }
}

class _EligibilityAction extends StatelessWidget {
  final Course course;
  final CheckoutEligibilityResult? eligibility;

  const _EligibilityAction({
    required this.course,
    required this.eligibility,
  });

  @override
  Widget build(BuildContext context) {
    final result = eligibility;
    if (result == null) {
      return const FilledButton(
        onPressed: null,
        child: Text('Acesso indisponível'),
      );
    }
    if (result.hasAccess) {
      return FilledButton(
        onPressed: () => context.go('/dashboard/courses/${course.id}'),
        child: const Text('Acessar curso'),
      );
    }
    if (result.reasonCode == 'PAST_DUE_EXPIRED') {
      return FilledButton(
        onPressed: () => context.go('/dashboard/subscriptions'),
        child: const Text('Regularizar assinatura'),
      );
    }
    if (result.canPurchase) {
      return FilledButton(
        onPressed: () => context.push('/checkout/${course.id}'),
        child: Text(course.isFree ? 'Liberar acesso gratuito' : 'Assinar curso'),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const FilledButton(
          onPressed: null,
          child: Text('Acesso indisponível'),
        ),
        if (result.message != null) ...[
          const SizedBox(height: LawrenceSpacing.xs),
          Text(
            result.message!,
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
  if (hours == 0) return '$remaining min';
  if (remaining == 0) return '${hours}h';
  return '${hours}h ${remaining}min';
}
