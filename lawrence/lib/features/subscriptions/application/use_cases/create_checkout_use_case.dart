import '../../domain/repositories/subscription_repository_interface.dart';

class CreateCheckoutUseCase {
  final SubscriptionRepository _repository;

  CreateCheckoutUseCase(this._repository);

  Future<String> execute({
    required String courseId,
    required String successUrl,
    required String cancelUrl,
    String? idempotencyKey,
  }) async {
    return _repository.createCheckoutSession(
      courseId: courseId,
      successUrl: successUrl,
      cancelUrl: cancelUrl,
      idempotencyKey: idempotencyKey,
    );
  }
}
