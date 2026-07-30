import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;
import 'package:flutter_test/flutter_test.dart';
import 'package:lawrence/core/errors/app_exceptions.dart';
import 'package:lawrence/features/subscriptions/domain/entities/checkout_eligibility_result.dart';
import 'package:lawrence/features/subscriptions/domain/entities/subscription_status.dart';
import 'package:lawrence/features/subscriptions/domain/repositories/subscription_repository_interface.dart';
import 'package:lawrence/features/subscriptions/presentation/controllers/checkout_eligibility_controller.dart';

class _SequencedSubscriptionRepository implements SubscriptionRepository {
  final List<Future<CheckoutEligibilityResult> Function()> eligibilityCalls;
  int callCount = 0;

  _SequencedSubscriptionRepository(this.eligibilityCalls);

  @override
  Future<CheckoutEligibilityResult> checkCheckoutEligibility(String courseId) {
    final call = eligibilityCalls[callCount++];
    return call();
  }

  @override
  Future<void> cancelSubscription(String subscriptionId) =>
      throw UnimplementedError();

  @override
  Future<String> createCheckoutSession({
    required String courseId,
    required String successUrl,
    required String cancelUrl,
    String? idempotencyKey,
  }) => throw UnimplementedError();

  @override
  Future<String> getCheckoutStatus(String sessionId) =>
      throw UnimplementedError();

  @override
  Future<List<SubscriptionStatus>> getSubscriptions() =>
      throw UnimplementedError();
}

CheckoutEligibilityResult _accessGranted() => const CheckoutEligibilityResult(
  canPurchase: false,
  hasAccess: true,
  reasonCode: 'ALREADY_ACTIVE',
  message: null,
  subscriptionStatus: 'active',
  courseId: 'course-1',
);

void main() {
  test('retry recovers from an authentication failure', () async {
    final repository = _SequencedSubscriptionRepository([
      () => Future.error(const AuthFailure(code: 'HTTP_401')),
      () async => _accessGranted(),
    ]);
    final controller = CheckoutEligibilityController(repository, 'course-1');
    addTearDown(controller.dispose);

    await Future<void>.delayed(Duration.zero);
    expect(
      controller.state,
      isA<riverpod.AsyncError<CheckoutEligibilityResult?>>(),
    );

    await controller.checkEligibility();

    expect(controller.state.value?.hasAccess, isTrue);
    expect(repository.callCount, 2);
  });

  test('an older failed request cannot overwrite a newer success', () async {
    final first = Completer<CheckoutEligibilityResult>();
    final second = Completer<CheckoutEligibilityResult>();
    final repository = _SequencedSubscriptionRepository([
      () => first.future,
      () => second.future,
    ]);
    final controller = CheckoutEligibilityController(repository, 'course-1');
    addTearDown(controller.dispose);

    final retry = controller.checkEligibility();
    second.complete(_accessGranted());
    await retry;
    first.completeError(const NetworkFailure(code: 'CONNECTION_ERROR'));
    await Future<void>.delayed(Duration.zero);

    expect(
      controller.state,
      isA<riverpod.AsyncData<CheckoutEligibilityResult?>>(),
    );
    expect(controller.state.value?.hasAccess, isTrue);
  });
}
