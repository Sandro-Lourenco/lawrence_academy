import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'encryption_service.dart';
import 'offline_license_service.dart';
import 'network/network_client.dart';

class DownloadManager {
  final NetworkClient _networkClient;
  final EncryptionService _encryptionService = EncryptionService();
  final OfflineLicenseService _licenseService = OfflineLicenseService();

  DownloadManager(this._networkClient);

  Future<void> startDownload({
    required String courseId,
    required String lessonId,
    required String userId,
    required String backendTokenEndpoint,
    required String bearerToken,
  }) async {
    try {
      final installationId = await _licenseService.getInstallationId();

      // 1. Obter Token e Licença do Backend
      final response = await _networkClient.post(
        backendTokenEndpoint,
        options: Options(headers: {'Authorization': 'Bearer $bearerToken'}),
        data: {
          'course_id': courseId,
          'lesson_id': lessonId,
          'installation_id': installationId,
        },
      );

      final downloadId = response.data['download_id'];
      final signedUrl = response.data['signed_url'];
      final licenseExpiresAt = response.data['license_expires_at'];

      // 2. Persistir Licença Offline
      await _licenseService.saveLicense(
        downloadId: downloadId,
        userId: userId,
        deviceId: installationId,
        courseId: courseId,
        lessonId: lessonId,
        licenseExpiresAt: licenseExpiresAt,
      );

      // 3. Preparar diretório de download
      final appDir = await getApplicationDocumentsDirectory();
      final downloadDir = Directory('${appDir.path}/downloads/$downloadId');
      if (!await downloadDir.exists()) {
        await downloadDir.create(recursive: true);
      }

      // 4. Baixar manifesto HLS e protegê-lo localmente (reescrever e criptografar)
      final manifestFile = File('${downloadDir.path}/index.m3u8');
      await _downloadFile(signedUrl, manifestFile);

      // (Na prática, aqui também realizaríamos parsing do manifesto, baixando os segmentos .ts/.m4s)
      // Simulando download e criptografia de segmentos...
      final List<String> simulatedSegmentUrls = ["segment0.ts", "segment1.ts"];

      for (int i = 0; i < simulatedSegmentUrls.length; i++) {
        final segmentUrl =
            "${signedUrl.split('?')[0].replaceAll('index.m3u8', '')}${simulatedSegmentUrls[i]}?${signedUrl.split('?')[1]}";
        final segmentFile = File('${downloadDir.path}/segment_$i.ts.enc');

        await _downloadFile(segmentUrl, segmentFile);

        // 5. Criptografar o segmento individualmente
        await _encryptionService.encryptSegment(segmentFile, downloadId);
      }

      // 6. Proteger o manifesto (pode ser criptografado via EncryptionService tbm)
      await _encryptionService.encryptSegment(manifestFile, downloadId);
    } catch (e) {
      // Falha parcial / rollback cleanup log
      print("Error during download: $e");
      rethrow;
    }
  }

  Future<void> _downloadFile(String url, File file) async {
    final response = await _networkClient.get(
      url,
      options: Options(responseType: ResponseType.stream),
    );
    final sink = file.openWrite(mode: FileMode.write);
    final stream = response.data.stream as Stream<List<int>>;
    await for (var chunk in stream) {
      sink.add(chunk);
    }
    await sink.close();
  }
}
