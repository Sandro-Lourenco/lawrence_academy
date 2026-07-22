import '../../domain/entities/subscription_status.dart';
import '../../domain/entities/checkout_eligibility_result.dart';
import '../../domain/repositories/subscription_repository_interface.dart';
import '../datasources/subscription_remote_datasource.dart';

class SubscriptionRepositoryImpl implements SubscriptionRepository {
  final SubscriptionRemoteDataSource _remoteDataSource;

  SubscriptionRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<SubscriptionStatus>> getSubscriptions() async {
    return await _remoteDataSource.getSubscriptions();
  }

  @override
  Future<CheckoutEligibilityResult> checkCheckoutEligibility(
    String courseId,
  ) async {
    return await _remoteDataSource.checkCheckoutEligibility(courseId);
  }

  @override
  Future<String> createCheckoutSession({
    required String courseId,
    required String successUrl,
    required String cancelUrl,
    String? idempotencyKey,
  }) async {
    return _remoteDataSource.createCheckoutSession(
      courseId: courseId,
      successUrl: successUrl,
      cancelUrl: cancelUrl,
      idempotencyKey: idempotencyKey,
    );
  }

  @override
  Future<void> cancelSubscription(String subscriptionId) {
    return _remoteDataSource.cancelSubscription(subscriptionId);
  }

  @override
  Future<String> getCheckoutStatus(String sessionId) {
    return _remoteDataSource.getCheckoutStatus(sessionId);
  }
}
