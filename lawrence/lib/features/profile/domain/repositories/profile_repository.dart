import 'dart:typed_data';

import '../entities/user_profile.dart';

abstract interface class ProfileRepository {
  Future<UserProfile> getMyProfile();
  Future<UserProfile> updateProfile(UserProfile profile);
  Future<String> uploadAvatar({
    required String userId,
    required String fileName,
    required Uint8List bytes,
    required String contentType,
  });
}
