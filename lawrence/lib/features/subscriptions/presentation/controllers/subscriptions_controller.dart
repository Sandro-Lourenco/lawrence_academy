import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/subscription_status.dart';
import '../../subscriptions_providers.dart';

class SubscriptionsState {
  final List<SubscriptionStatus> subscriptions;
  final bool isLoading;
  final String? error;

  SubscriptionsState({
    this.subscriptions = const [],
    this.isLoading = false,
    this.error,
  });

  SubscriptionsState copyWith({
    List<SubscriptionStatus>? subscriptions,
    bool? isLoading,
    String? error,
  }) {
    return SubscriptionsState(
      subscriptions: subscriptions ?? this.subscriptions,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class SubscriptionsController
    extends AutoDisposeAsyncNotifier<List<SubscriptionStatus>> {
  @override
  Future<List<SubscriptionStatus>> build() async {
    final getSubscriptionsUseCase = ref.watch(getSubscriptionsUseCaseProvider);
    return await getSubscriptionsUseCase.execute();
  }

  Future<void> cancelSubscription(String subscriptionId) async {
    final cancelUseCase = ref.read(cancelSubscriptionUseCaseProvider);

    try {
      await cancelUseCase.execute(subscriptionId);
      // Refresh the list after cancellation
      ref.invalidateSelf();
    } catch (e) {
      // Typically we might throw or show a snackbar via a presentation hook,
      // for now we rethrow so the UI can catch it.
      rethrow;
    }
  }

  Future<String> createCheckout({
    required String courseId,
    required String successUrl,
    required String cancelUrl,
    String? idempotencyKey,
  }) async {
    final checkoutUseCase = ref.read(createCheckoutUseCaseProvider);
    return await checkoutUseCase.execute(
      courseId: courseId,
      successUrl: successUrl,
      cancelUrl: cancelUrl,
      idempotencyKey: idempotencyKey,
    );
  }

  Future<String> getCheckoutStatus(String sessionId) async {
    final statusUseCase = ref.read(getCheckoutStatusUseCaseProvider);
    return await statusUseCase.execute(sessionId);
  }
}

final subscriptionsControllerProvider =
    AutoDisposeAsyncNotifierProvider<
      SubscriptionsController,
      List<SubscriptionStatus>
    >(SubscriptionsController.new);
