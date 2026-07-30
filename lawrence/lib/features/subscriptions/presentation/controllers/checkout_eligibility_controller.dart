import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../domain/entities/checkout_eligibility_result.dart';
import '../../domain/repositories/subscription_repository_interface.dart';
import '../../subscriptions_providers.dart';

final checkoutEligibilityProvider =
    StateNotifierProvider.autoDispose.family<
      CheckoutEligibilityController,
      AsyncValue<CheckoutEligibilityResult?>,
      String
    >((ref, courseId) {
      // Eligibility is user/session scoped. Recreate it when the authenticated
      // identity or JWT changes so a stale error/result is never reused after
      // logout, login as another role, or an automatic token refresh.
      ref.watch(
        authNotifierProvider.select(
          (state) => (state.user?.id, state.session?.accessToken),
        ),
      );
      final repository = ref.watch(subscriptionRepositoryProvider);
      return CheckoutEligibilityController(repository, courseId);
    });

class CheckoutEligibilityController
    extends StateNotifier<AsyncValue<CheckoutEligibilityResult?>> {
  final SubscriptionRepository _repository;
  final String _courseId;
  int _latestRequest = 0;

  CheckoutEligibilityController(this._repository, this._courseId)
    : super(const AsyncValue.loading()) {
    checkEligibility();
  }

  Future<void> checkEligibility() async {
    final request = ++_latestRequest;
    state = const AsyncValue.loading();
    try {
      final result = await _repository.checkCheckoutEligibility(_courseId);
      if (mounted && request == _latestRequest) {
        state = AsyncValue.data(result);
      }
    } catch (e, st) {
      if (mounted && request == _latestRequest) {
        state = AsyncValue.error(e, st);
      }
    }
  }
}
