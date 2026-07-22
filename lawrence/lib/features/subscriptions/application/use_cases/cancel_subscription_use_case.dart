import '../../domain/repositories/subscription_repository_interface.dart';

class CancelSubscriptionUseCase {
  final SubscriptionRepository _repository;

  CancelSubscriptionUseCase(this._repository);

  Future<void> execute(String subscriptionId) async {
    return _repository.cancelSubscription(subscriptionId);
  }
}
