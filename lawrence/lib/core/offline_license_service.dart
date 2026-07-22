import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'package:uuid/uuid.dart';

/// Serviço responsável por gerenciar o ciclo de vida e a validação das licenças offline
class OfflineLicenseService {
  final _secureStorage = const FlutterSecureStorage();

  /// Persiste a licença offline retornada pelo endpoint de token
  Future<void> saveLicense({
    required String downloadId,
    required String userId,
    required String deviceId,
    required String courseId,
    required String lessonId,
    required int licenseExpiresAt,
  }) async {
    final licenseData = {
      'user_id': userId,
      'device_id': deviceId,
      'course_id': courseId,
      'lesson_id': lessonId,
      'license_expires_at': licenseExpiresAt,
      'status': 'active',
    };

    await _secureStorage.write(
      key: 'license_$downloadId',
      value: jsonEncode(licenseData),
    );
  }

  /// Valida as regras temporais e de ownership antes de reproduzir
  Future<bool> isLicenseValid({
    required String downloadId,
    required String currentUserId,
    required String currentDeviceId,
  }) async {
    final dataString = await _secureStorage.read(key: 'license_$downloadId');
    if (dataString == null) return false;

    try {
      final licenseData = jsonDecode(dataString);

      // Validações restritas (Zero Trust local)
      if (licenseData['status'] != 'active') return false;
      if (licenseData['user_id'] != currentUserId) return false;
      if (licenseData['device_id'] != currentDeviceId) return false;

      final expiresAt = licenseData['license_expires_at'] as int;
      final nowSeconds = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      // Device clock can be spoofed, so in production we also sync with the server
      // if internet is available, but this is the offline check.
      if (nowSeconds > expiresAt) return false;

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> revokeLicense(String downloadId) async {
    await _secureStorage.delete(key: 'license_$downloadId');
  }

  /// Recupera o installation_id do dispositivo (gerado na primeira inicialização)
  Future<String> getInstallationId() async {
    final existingId = await _secureStorage.read(key: 'installation_id');
    if (existingId != null) return existingId;

    // Gerar UUID de instalação se não existir
    final newId = const Uuid().v4();
    await _secureStorage.write(key: 'installation_id', value: newId);
    return newId;
  }
}
