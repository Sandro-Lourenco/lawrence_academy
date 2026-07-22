import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';

class GetMyProfileUseCase {
  const GetMyProfileUseCase(this._repository);

  final ProfileRepository _repository;

  Future<UserProfile> execute() {
    return _repository.getMyProfile();
  }
}
