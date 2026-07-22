import '../../../../core/network/network_client.dart';
import 'package:dio/dio.dart';
import '../../domain/entities/subscription_status.dart';
import '../../domain/entities/checkout_eligibility_result.dart';

abstract class SubscriptionRemoteDataSource {
  Future<List<SubscriptionStatus>> getSubscriptions();
  Future<CheckoutEligibilityResult> checkCheckoutEligibility(String courseId);
  Future<String> createCheckoutSession({
    required String courseId,
    required String successUrl,
    required String cancelUrl,
    String? idempotencyKey,
  });
  Future<void> cancelSubscription(String subscriptionId);
  Future<String> getCheckoutStatus(String sessionId);
}

class SubscriptionRemoteDataSourceImpl implements SubscriptionRemoteDataSource {
  final NetworkClient _networkClient;

  SubscriptionRemoteDataSourceImpl(this._networkClient);

  @override
  Future<List<SubscriptionStatus>> getSubscriptions() async {
    final response = await _networkClient.get('/api/v1/subscriptions/me');
    final data = response.data as List;
    return data
        .map(
          (json) => SubscriptionStatus.fromJson(json as Map<String, dynamic>),
        )
        .toList();
  }

  @override
  Future<CheckoutEligibilityResult> checkCheckoutEligibility(
    String courseId,
  ) async {
    final response = await _networkClient.get(
      '/api/v1/payments/checkout/eligibility',
      queryParameters: {'course_id': courseId},
    );
    return CheckoutEligibilityResult.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  @override
  Future<String> createCheckoutSession({
    required String courseId,
    required String successUrl,
    required String cancelUrl,
    String? idempotencyKey,
  }) async {
    final response = await _networkClient.post(
      '/api/v1/payments/checkout',
      data: {
        'course_id': courseId,
        'success_url': successUrl,
        'cancel_url': cancelUrl,
      },
      options: Options(
        headers: idempotencyKey != null
            ? {'Idempotency-Key': idempotencyKey}
            : null,
      ),
    );
    return response.data['data']['checkout_url'] as String;
  }

  @override
  Future<void> cancelSubscription(String subscriptionId) async {
    await _networkClient.patch(
      '/api/v1/subscriptions/$subscriptionId/cancel',
    );
  }

  @override
  Future<String> getCheckoutStatus(String sessionId) async {
    final response = await _networkClient.get(
      '/api/v1/payments/checkout/status/$sessionId',
    );
    return response.data['status'] as String;
  }
}
