import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/errors/app_exceptions.dart';
import '../../../../../design_system/public/public_editorial_colors.dart';
import '../../../../../design_system/public/public_editorial_typography.dart';
import '../../../../../design_system/public/public_glass_button.dart';
import '../../../../auth/presentation/controllers/auth_controller.dart';
import '../../../../subscriptions/domain/entities/checkout_eligibility_result.dart';
import '../../../../subscriptions/presentation/controllers/checkout_eligibility_controller.dart';
import '../../../domain/entities/course.dart';

class PublicCourseClosingOffer extends StatelessWidget {
  const PublicCourseClosingOffer({super.key, required this.course});

  final Course course;

  @override
  Widget build(BuildContext context) {
    final mobile = MediaQuery.sizeOf(context).width < 800;
    final price = _price(course);
    return ColoredBox(
      color: PublicEditorialColors.wine,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1160),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 24,
              vertical: mobile ? 92 : 120,
            ),
            child: Column(
              children: [
                Text(
                  'SEU PRÓXIMO CAPÍTULO',
                  style: PublicEditorialTypography.eyebrow(
                    color: PublicEditorialColors.champagne,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'A técnica começa com uma decisão.',
                  textAlign: TextAlign.center,
                  style: PublicEditorialTypography.sectionDisplay(
                    color: PublicEditorialColors.ivory,
                    size: mobile ? 54 : 78,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  price,
                  textAlign: TextAlign.center,
                  style: PublicEditorialTypography.bodyLarge(
                    color: PublicEditorialColors.ivory,
                  ).copyWith(fontWeight: FontWeight.w700),
                ),
                if (!course.isFree) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Assinatura mensal exclusiva deste curso.',
                    style: PublicEditorialTypography.caption(
                      color: PublicEditorialColors.parchment,
                    ),
                  ),
                ],
                const SizedBox(height: 34),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 380),
                  child: PublicCourseAccessButton(
                    course: course,
                    expand: true,
                    light: true,
                    anonymousLabel: course.isFree
                        ? 'Acessar esta formação'
                        : 'Assinar esta formação',
                  ),
                ),
                const SizedBox(height: 24),
                Wrap(
                  spacing: 24,
                  runSpacing: 12,
                  alignment: WrapAlignment.center,
                  children: [
                    const _Assurance(
                      icon: Icons.verified_user_outlined,
                      text: 'Acesso validado com segurança',
                    ),
                    if (course.certificateEnabled)
                      const _Assurance(
                        icon: Icons.workspace_premium_outlined,
                        text: 'Certificado conforme conclusão',
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

class PublicCourseAccessButton extends ConsumerWidget {
  const PublicCourseAccessButton({
    super.key,
    required this.course,
    this.expand = false,
    this.light = false,
    this.anonymousLabel,
  });

  final Course course;
  final bool expand;
  final bool light;
  final String? anonymousLabel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tone = light
        ? PublicGlassButtonTone.ivory
        : PublicGlassButtonTone.wine;
    final authenticated = ref.watch(authNotifierProvider).user != null;
    if (!authenticated) {
      return PublicGlassButton(
        label:
            anonymousLabel ??
            (course.isFree ? 'Entrar para acessar' : 'Entrar para assinar'),
        expand: expand,
        tone: tone,
        onPressed: () => context.go(
          Uri(
            path: '/login',
            queryParameters: {'redirect': '/courses/${course.slug}'},
          ).toString(),
        ),
      );
    }
    return ref
        .watch(checkoutEligibilityProvider(course.id))
        .when(
          loading: () => const Center(
            child: CircularProgressIndicator(
              color: PublicEditorialColors.champagne,
            ),
          ),
          error: (error, _) => _AccessError(course: course, error: error),
          data: (eligibility) => _EligibilityAction(
            course: course,
            eligibility: eligibility,
            expand: expand,
            tone: tone,
          ),
        );
  }
}

class _EligibilityAction extends StatelessWidget {
  const _EligibilityAction({
    required this.course,
    required this.eligibility,
    required this.expand,
    required this.tone,
  });

  final Course course;
  final CheckoutEligibilityResult? eligibility;
  final bool expand;
  final PublicGlassButtonTone tone;

  @override
  Widget build(BuildContext context) {
    final result = eligibility;
    if (result == null) return _button('Acesso indisponível', null);
    if (result.hasAccess) {
      return _button(
        'Acessar curso',
        () => context.go('/dashboard/courses/${course.id}'),
      );
    }
    if (result.reasonCode == 'PAST_DUE_EXPIRED') {
      return _button(
        'Regularizar assinatura',
        () => context.go('/dashboard/subscriptions'),
      );
    }
    if (result.canPurchase) {
      return _button(
        course.isFree ? 'Liberar acesso gratuito' : 'Assinar curso',
        () => context.push('/checkout/${course.id}'),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _button('Acesso indisponível', null),
        if (result.message != null) ...[
          const SizedBox(height: 8),
          Text(
            result.message!,
            style: PublicEditorialTypography.caption(
              color: PublicEditorialColors.parchment,
            ),
          ),
        ],
      ],
    );
  }

  Widget _button(String label, VoidCallback? onPressed) => PublicGlassButton(
    label: label,
    expand: expand,
    tone: tone,
    onPressed: onPressed,
  );
}

class _AccessError extends ConsumerWidget {
  const _AccessError({required this.course, required this.error});

  final Course course;
  final Object error;

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
        Text(
          message,
          style: PublicEditorialTypography.caption(
            color: PublicEditorialColors.ivory,
          ),
        ),
        const SizedBox(height: 12),
        PublicGlassButton(
          label: authFailure ? 'Entrar novamente' : 'Tentar novamente',
          expand: true,
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
        ),
      ],
    );
  }
}

class _Assurance extends StatelessWidget {
  const _Assurance({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: BoxConstraints(
      maxWidth: (MediaQuery.sizeOf(context).width - 48).clamp(180, 420),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: PublicEditorialColors.champagne),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            text,
            style: PublicEditorialTypography.caption(
              color: PublicEditorialColors.ivory,
            ).copyWith(fontSize: 13),
          ),
        ),
      ],
    ),
  );
}

String _price(Course course) => course.isFree
    ? 'Acesso gratuito'
    : 'R\$ ${course.monthlyPrice.toStringAsFixed(2).replaceAll('.', ',')} por mês';
