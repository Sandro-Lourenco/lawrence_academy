import '../entities/subscription_status.dart';
import '../entities/checkout_eligibility_result.dart';

abstract class SubscriptionRepository {
  Future<List<SubscriptionStatus>> getSubscriptions();
  Future<CheckoutEligibilityResult> checkCheckoutEligibility(String courseId);
  Future<String> createCheckoutSession({
    required String courseId,
    required String successUrl,
    required String cancelUrl,
    String? idempotencyKey,
  });

  Future<String> getCheckoutStatus(String sessionId);
  Future<void> cancelSubscription(String subscriptionId);
}
