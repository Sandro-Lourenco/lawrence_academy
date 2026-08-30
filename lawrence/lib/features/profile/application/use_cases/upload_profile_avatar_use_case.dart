import 'dart:typed_data';

import '../../domain/repositories/profile_repository.dart';

class UploadProfileAvatarUseCase {
  const UploadProfileAvatarUseCase(this._repository);

  final ProfileRepository _repository;
  static const maxBytes = 5 * 1024 * 1024;

  Future<String> execute({
    required String userId,
    required String fileName,
    required Uint8List bytes,
  }) {
    if (bytes.isEmpty || bytes.length > maxBytes) {
      throw const FormatException('A imagem deve ter no máximo 5 MB.');
    }
    final extension = fileName.split('.').last.toLowerCase();
    final contentType = switch (extension) {
      'jpg' || 'jpeg' => 'image/jpeg',
      'png' => 'image/png',
      'webp' => 'image/webp',
      _ => throw const FormatException('Use uma imagem JPG, PNG ou WebP.'),
    };
    if (!_matchesSignature(bytes, extension)) {
      throw const FormatException(
        'O conteúdo do arquivo não é uma imagem válida.',
      );
    }
    return _repository.uploadAvatar(
      userId: userId,
      fileName: fileName,
      bytes: bytes,
      contentType: contentType,
    );
  }

  bool _matchesSignature(Uint8List bytes, String extension) {
    if (extension == 'jpg' || extension == 'jpeg') {
      return bytes.length >= 3 &&
          bytes[0] == 0xFF &&
          bytes[1] == 0xD8 &&
          bytes[2] == 0xFF;
    }
    if (extension == 'png') {
      const signature = <int>[0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A];
      if (bytes.length < signature.length) return false;
      for (var index = 0; index < signature.length; index++) {
        if (bytes[index] != signature[index]) return false;
      }
      return true;
    }
    return bytes.length >= 12 &&
        String.fromCharCodes(bytes.sublist(0, 4)) == 'RIFF' &&
        String.fromCharCodes(bytes.sublist(8, 12)) == 'WEBP';
  }
}
