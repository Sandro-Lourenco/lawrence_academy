import 'package:flutter_test/flutter_test.dart';
import 'package:lawrence/features/courses/presentation/pages/course_detail_page.dart';
import 'package:lawrence/features/subscriptions/domain/entities/checkout_eligibility_result.dart';

void main() {
  CheckoutEligibilityResult eligibility({
    bool canPurchase = false,
    bool hasAccess = false,
    String? reasonCode,
    String? message,
  }) {
    return CheckoutEligibilityResult(
      canPurchase: canPurchase,
      hasAccess: hasAccess,
      reasonCode: reasonCode,
      message: message,
      courseId: 'course-1',
    );
  }

  test('usuário anônimo precisa entrar antes de assinar', () {
    final result = resolveCourseAccessPresentation(
      authenticated: false,
      isFree: false,
      eligibility: null,
    );

    expect(result.action, CourseAccessAction.login);
    expect(result.label, 'Entrar para assinar');
  });

  test('assinante com acesso abre o curso', () {
    final result = resolveCourseAccessPresentation(
      authenticated: true,
      isFree: false,
      eligibility: eligibility(hasAccess: true),
    );

    expect(result.action, CourseAccessAction.access);
  });

  test('curso elegível usa CTA de assinatura', () {
    final result = resolveCourseAccessPresentation(
      authenticated: true,
      isFree: false,
      eligibility: eligibility(canPurchase: true),
    );

    expect(result.action, CourseAccessAction.subscribe);
    expect(result.label, 'Assinar curso');
  });

  test('pagamento vencido direciona ao gerenciamento', () {
    final result = resolveCourseAccessPresentation(
      authenticated: true,
      isFree: false,
      eligibility: eligibility(
        reasonCode: 'PAST_DUE_EXPIRED',
        message: 'Regularize sua assinatura.',
      ),
    );

    expect(result.action, CourseAccessAction.manageSubscription);
    expect(result.label, 'Regularizar assinatura');
    expect(result.message, 'Regularize sua assinatura.');
  });

  test('resposta ausente não libera compra nem acesso', () {
    final result = resolveCourseAccessPresentation(
      authenticated: true,
      isFree: false,
      eligibility: null,
    );

    expect(result.action, CourseAccessAction.unavailable);
  });
}

