import '../../../../core/network/network_client.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  const ProfileRepositoryImpl(this._networkClient);

  final NetworkClient _networkClient;

  @override
  Future<UserProfile> getMyProfile() async {
    final response = await _networkClient.get<Map<String, dynamic>>(
      '/api/v1/profiles/me',
    );
    final data = response.data ?? const <String, dynamic>{};

    return UserProfile(
      id: data['id'] as String,
      email: data['email'] as String,
      role: data['role'] as String,
      fullName: data['full_name'] as String?,
      referredBy: data['referred_by'] as String?,
    );
  }
}
