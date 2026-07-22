import '../../domain/entities/subscription_status.dart';
import '../../domain/repositories/subscription_repository_interface.dart';

class GetSubscriptionsUseCase {
  final SubscriptionRepository _repository;

  GetSubscriptionsUseCase(this._repository);

  Future<List<SubscriptionStatus>> execute() async {
    return _repository.getSubscriptions();
  }
}
