import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/error/app_error.dart';
import '../../../../app/config/env_config.dart';
import '../../../../design_system/tokens/lawrence_theme.dart';
import '../../../../design_system/widgets/state_widgets.dart';
import '../../../courses/domain/entities/course.dart';
import '../../../courses/presentation/providers/course_detail_provider.dart';
import '../controllers/checkout_eligibility_controller.dart';
import '../controllers/subscriptions_controller.dart';

class CourseCheckoutPage extends ConsumerStatefulWidget {
  const CourseCheckoutPage({super.key, required this.courseId});

  final String courseId;

  @override
  ConsumerState<CourseCheckoutPage> createState() => _CourseCheckoutPageState();
}

class _CourseCheckoutPageState extends ConsumerState<CourseCheckoutPage>
    with WidgetsBindingObserver {
  bool _isOpeningPayment = false;
  String? _awaitingPaymentCourseId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _reconcilePaymentAfterBrowser();
    }
  }

  @override
  Widget build(BuildContext context) {
    final courseAsync = ref.watch(courseDetailByIdProvider(widget.courseId));

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          tooltip: 'Voltar',
          onPressed: context.pop,
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text('Sua assinatura'),
      ),
      body: courseAsync.when(
        loading: () => const AppLoadingState(
          message: 'Preparando seu pagamento seguro...',
        ),
        error: (error, stackTrace) {
          final appError = AppError.fromException(error);
          return AppErrorState(
            title: appError.title,
            message: appError.message,
            onRetry: () =>
                ref.invalidate(courseDetailByIdProvider(widget.courseId)),
          );
        },
        data: (course) => course == null
            ? const AppEmptyState(
                title: 'Curso indisponível',
                description: 'Este curso não pode ser assinado no momento.',
              )
            : _CheckoutContent(
                course: course,
                isOpeningPayment: _isOpeningPayment,
                onContinue: () => _continueToPayment(course),
              ),
      ),
    );
  }

  Future<void> _continueToPayment(Course course) async {
    if (course.isFree) {
      final lessons = [for (final module in course.modules) ...module.lessons];
      context.go(
        lessons.isEmpty
            ? '/dashboard/courses/${course.id}'
            : '/dashboard/courses/${course.id}/lessons/${lessons.first.id}',
      );
      return;
    }

    setState(() => _isOpeningPayment = true);
    try {
      final eligibilityProvider = checkoutEligibilityProvider(course.id);
      await ref.read(eligibilityProvider.notifier).checkEligibility();
      final eligibility = ref.read(eligibilityProvider).value;
      if (eligibility == null) {
        throw StateError('Não foi possível validar esta assinatura.');
      }
      if (eligibility.hasAccess) {
        if (mounted) context.go('/dashboard/courses/${course.id}');
        return;
      }
      if (!eligibility.canPurchase) {
        throw StateError(
          eligibility.message ?? 'Assinatura indisponível no momento.',
        );
      }

      final publicOrigin = ref
          .read(envConfigProvider)
          .publicWebUrl
          .replaceFirst(RegExp(r'/$'), '');

      final checkoutUrl = await ref
          .read(subscriptionsControllerProvider.notifier)
          .createCheckout(
            courseId: course.id,
            // Stripe Checkout returns to an HTTPS page. On Android this can
            // later be upgraded to a verified App Link without making the
            // payment depend on a custom URI scheme.
            successUrl: '$publicOrigin/payment/pending/{CHECKOUT_SESSION_ID}',
            cancelUrl: '$publicOrigin/cancel',
            idempotencyKey: const Uuid().v4(),
          );
      _awaitingPaymentCourseId = course.id;
      final opened = await launchUrl(
        Uri.parse(checkoutUrl),
        mode: LaunchMode.externalApplication,
      );
      if (!opened) {
        _awaitingPaymentCourseId = null;
        throw StateError('Não foi possível abrir a página segura do Stripe.');
      }
    } catch (error) {
      if (!mounted) return;
      final appError = AppError.fromException(error);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(appError.message)));
    } finally {
      if (mounted) setState(() => _isOpeningPayment = false);
    }
  }

  Future<void> _reconcilePaymentAfterBrowser() async {
    final courseId = _awaitingPaymentCourseId;
    if (courseId == null || !mounted) return;

    try {
      final eligibilityProvider = checkoutEligibilityProvider(courseId);
      await ref.read(eligibilityProvider.notifier).checkEligibility();
      if (!mounted) return;
      final eligibility = ref.read(eligibilityProvider).value;
      if (eligibility?.hasAccess == true) {
        _awaitingPaymentCourseId = null;
        ref.invalidate(subscriptionsControllerProvider);
        context.go('/dashboard/courses/$courseId');
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'O pagamento ainda está sendo confirmado. Tente novamente em instantes.',
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Ainda não foi possível confirmar o pagamento. Seu acesso será liberado pelo webhook.',
          ),
        ),
      );
    }
  }
}

class _CheckoutContent extends StatelessWidget {
  const _CheckoutContent({
    required this.course,
    required this.isOpeningPayment,
    required this.onContinue,
  });

  final Course course;
  final bool isOpeningPayment;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 900;
    final price = course.isFree
        ? 'Gratuito'
        : 'R\$ ${course.monthlyPrice.toStringAsFixed(2).replaceAll('.', ',')} / mês';

    final summary = _OrderSummary(course: course, price: price);
    final assurance = _PaymentAssurance(
      course: course,
      price: price,
      isOpeningPayment: isOpeningPayment,
      onContinue: onContinue,
    );

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(isWide ? 40 : 20, 24, isWide ? 40 : 20, 40),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                course.isFree ? 'Comece agora' : 'Revise sua assinatura',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: LawrenceColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                course.isFree
                    ? 'Este curso não exige cartão nem cobrança.'
                    : 'Uma assinatura mensal, somente para este curso. Confira os detalhes antes de continuar.',
                style: const TextStyle(
                  color: LawrenceColors.textSecondary,
                  fontSize: 16,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 28),
              if (isWide)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 6, child: summary),
                    const SizedBox(width: 24),
                    Expanded(flex: 4, child: assurance),
                  ],
                )
              else ...[
                summary,
                const SizedBox(height: 20),
                assurance,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _OrderSummary extends StatelessWidget {
  const _OrderSummary({required this.course, required this.price});

  final Course course;
  final String price;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: LawrenceColors.borderMist),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Semantics(
              header: true,
              child: const Text(
                'O QUE VOCÊ ESTÁ ASSINANDO',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: LawrenceColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              course.title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: LawrenceColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              course.summary,
              style: const TextStyle(
                color: LawrenceColors.textSecondary,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 24),
            const Divider(color: LawrenceColors.borderMist),
            const SizedBox(height: 16),
            _InfoRow(
              icon: Icons.play_lesson_outlined,
              text: '${course.lessonCount} aulas',
            ),
            const SizedBox(height: 12),
            _InfoRow(
              icon: Icons.workspace_premium_outlined,
              text: 'Certificado de conclusão',
            ),
            const SizedBox(height: 12),
            const _InfoRow(
              icon: Icons.phone_android_outlined,
              text: 'Acesso no celular e na web',
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Cobrança mensal',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                Text(
                  price,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: LawrenceColors.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentAssurance extends StatelessWidget {
  const _PaymentAssurance({
    required this.course,
    required this.price,
    required this.isOpeningPayment,
    required this.onContinue,
  });

  final Course course;
  final String price;
  final bool isOpeningPayment;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF102A43),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(
              course.isFree ? Icons.celebration_outlined : Icons.lock_outline,
              color: Colors.white,
              size: 32,
            ),
            const SizedBox(height: 18),
            Text(
              course.isFree ? 'Acesso gratuito' : 'Pronto para começar?',
              textAlign: TextAlign.left,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              course.isFree
                  ? 'Entre no curso e assista às aulas publicadas sem cobrança.'
                  : 'A assinatura é mensal por curso. Você poderá gerenciá-la separadamente em Minhas assinaturas.',
              textAlign: TextAlign.left,
              style: const TextStyle(color: Colors.white70, height: 1.45),
            ),
            if (!course.isFree) ...[
              const SizedBox(height: 20),
              const _AssurancePoint(
                icon: Icons.autorenew_rounded,
                text: 'Renovação mensal deste curso',
              ),
              const SizedBox(height: 12),
              const _AssurancePoint(
                icon: Icons.event_available_outlined,
                text:
                    'Cancele quando quiser; o acesso continua até o fim do período pago',
              ),
            ],
            const SizedBox(height: 24),
            Semantics(
              button: true,
              label: course.isFree
                  ? 'Acessar gratuitamente ${course.title}'
                  : 'Continuar para pagamento seguro de $price',
              child: FilledButton.icon(
                onPressed: isOpeningPayment ? null : onContinue,
                style: FilledButton.styleFrom(
                  backgroundColor: LawrenceColors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: isOpeningPayment
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Icon(
                        course.isFree ? Icons.play_arrow : Icons.arrow_forward,
                      ),
                label: Text(
                  course.isFree
                      ? 'Começar curso'
                      : 'Continuar para o pagamento',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
            if (!course.isFree) ...[
              const SizedBox(height: 14),
              const Text(
                'Pagamento processado com segurança pelo Stripe.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  height: 1.35,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _AssurancePoint extends StatelessWidget {
  const _AssurancePoint({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: LawrenceSpacing.sm),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: Colors.white, height: 1.4),
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: LawrenceColors.primary),
        const SizedBox(width: 10),
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
