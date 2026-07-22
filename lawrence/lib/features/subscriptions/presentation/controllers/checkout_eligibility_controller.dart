import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/checkout_eligibility_result.dart';
import '../../domain/repositories/subscription_repository_interface.dart';
import '../../subscriptions_providers.dart';

final checkoutEligibilityProvider =
    StateNotifierProvider.family<
      CheckoutEligibilityController,
      AsyncValue<CheckoutEligibilityResult?>,
      String
    >((ref, courseId) {
      final repository = ref.watch(subscriptionRepositoryProvider);
      return CheckoutEligibilityController(repository, courseId);
    });

class CheckoutEligibilityController
    extends StateNotifier<AsyncValue<CheckoutEligibilityResult?>> {
  final SubscriptionRepository _repository;
  final String _courseId;

  CheckoutEligibilityController(this._repository, this._courseId)
    : super(const AsyncValue.loading()) {
    checkEligibility();
  }

  Future<void> checkEligibility() async {
    state = const AsyncValue.loading();
    try {
      final result = await _repository.checkCheckoutEligibility(_courseId);
      state = AsyncValue.data(result);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
