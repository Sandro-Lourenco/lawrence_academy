import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';

class UpdateMyProfileUseCase {
  const UpdateMyProfileUseCase(this._repository);

  final ProfileRepository _repository;

  Future<UserProfile> execute(UserProfile profile) {
    return _repository.updateProfile(profile);
  }
}
