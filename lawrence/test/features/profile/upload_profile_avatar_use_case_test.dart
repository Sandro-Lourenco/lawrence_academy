import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:lawrence/features/profile/application/use_cases/upload_profile_avatar_use_case.dart';
import 'package:lawrence/features/profile/domain/entities/user_profile.dart';
import 'package:lawrence/features/profile/domain/repositories/profile_repository.dart';

class _Repository implements ProfileRepository {
  String? contentType;

  @override
  Future<String> uploadAvatar({
    required String userId,
    required String fileName,
    required Uint8List bytes,
    required String contentType,
  }) async {
    this.contentType = contentType;
    return 'https://example.com/$fileName';
  }

  @override
  Future<UserProfile> getMyProfile() => throw UnimplementedError();

  @override
  Future<UserProfile> updateProfile(UserProfile profile) =>
      throw UnimplementedError();
}

void main() {
  test('aceita PNG real e envia MIME canônico', () async {
    final repository = _Repository();
    final useCase = UploadProfileAvatarUseCase(repository);
    final bytes = Uint8List.fromList([
      0x89,
      0x50,
      0x4E,
      0x47,
      0x0D,
      0x0A,
      0x1A,
      0x0A,
    ]);

    await useCase.execute(
      userId: 'user-1',
      fileName: 'avatar.png',
      bytes: bytes,
    );

    expect(repository.contentType, 'image/png');
  });

  test('rejeita extensão disfarçada e arquivo acima de 5 MB', () async {
    final useCase = UploadProfileAvatarUseCase(_Repository());

    expect(
      () => useCase.execute(
        userId: 'user-1',
        fileName: 'avatar.png',
        bytes: Uint8List.fromList([1, 2, 3]),
      ),
      throwsFormatException,
    );
    expect(
      () => useCase.execute(
        userId: 'user-1',
        fileName: 'avatar.jpg',
        bytes: Uint8List(UploadProfileAvatarUseCase.maxBytes + 1),
      ),
      throwsFormatException,
    );
  });
}
