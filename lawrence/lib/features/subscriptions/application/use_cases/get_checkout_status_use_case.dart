import '../../domain/repositories/subscription_repository_interface.dart';

class GetCheckoutStatusUseCase {
  final SubscriptionRepository _repository;

  GetCheckoutStatusUseCase(this._repository);

  Future<String> execute(String sessionId) {
    return _repository.getCheckoutStatus(sessionId);
  }
}
