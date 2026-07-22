import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

enum DownloadStatus { pending, downloading, paused, completed, failed }

class DownloadTask {
  final String lessonId;
  final String url;
  final int totalSegments;
  final int downloadedSegments;
  final DownloadStatus status;
  final String? errorMessage;

  DownloadTask({
    required this.lessonId,
    required this.url,
    this.totalSegments = 0,
    this.downloadedSegments = 0,
    this.status = DownloadStatus.pending,
    this.errorMessage,
  });

  DownloadTask copyWith({
    String? lessonId,
    String? url,
    int? totalSegments,
    int? downloadedSegments,
    DownloadStatus? status,
    String? errorMessage,
  }) {
    return DownloadTask(
      lessonId: lessonId ?? this.lessonId,
      url: url ?? this.url,
      totalSegments: totalSegments ?? this.totalSegments,
      downloadedSegments: downloadedSegments ?? this.downloadedSegments,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class DownloadNotifier extends StateNotifier<Map<String, DownloadTask>> {
  final Ref ref;
  final Dio _dio = Dio();
  final Map<String, CancelToken> _cancelTokens = {};
  final _secureStorage = const FlutterSecureStorage();

  DownloadNotifier(this.ref) : super({});

  /// Adiciona e inicia uma nova tarefa de download
  Future<void> startDownload(String lessonId, String manifestUrl) async {
    final task = DownloadTask(
      lessonId: lessonId,
      url: manifestUrl,
      status: DownloadStatus.downloading,
    );
    state = {...state, lessonId: task};

    final cancelToken = CancelToken();
    _cancelTokens[lessonId] = cancelToken;

    try {
      final appDir = await getApplicationDocumentsDirectory();
      final downloadDir = Directory('${appDir.path}/downloads/$lessonId');
      if (!await downloadDir.exists()) {
        await downloadDir.create(recursive: true);
      }

      // 1. Baixar o arquivo manifest .m3u8 usando Range Request se parcial
      final manifestFile = File('${downloadDir.path}/index.m3u8');
      await _downloadFileWithRange(manifestUrl, manifestFile, cancelToken);

      // Ler o arquivo manifest e parsear os caminhos dos segmentos
      final lines = await manifestFile.readAsLines();
      final List<String> segmentUrls = [];
      final String baseUrl = manifestUrl.substring(
        0,
        manifestUrl.lastIndexOf('/') + 1,
      );

      for (var line in lines) {
        if (line.isNotEmpty && !line.startsWith('#')) {
          segmentUrls.add(line.startsWith('http') ? line : '$baseUrl$line');
        }
      }

      final total = segmentUrls.length;
      state = {
        ...state,
        lessonId: task.copyWith(totalSegments: total, downloadedSegments: 0),
      };

      int downloaded = 0;

      // 2. Baixar e criptografar cada segmento de vídeo em AES-256
      for (int i = 0; i < total; i++) {
        if (cancelToken.isCancelled) return;

        final segmentUrl = segmentUrls[i];
        final segmentFile = File('${downloadDir.path}/segment_$i.enc');

        // Download com Range Request se o arquivo de segmento já existir parcialmente
        await _downloadFileWithRange(segmentUrl, segmentFile, cancelToken);

        // Criptografar o arquivo se ele acabou de ser completamente baixado
        await _encryptFile(segmentFile);

        downloaded++;
        state = {
          ...state,
          lessonId: state[lessonId]!.copyWith(downloadedSegments: downloaded),
        };
      }

      state = {
        ...state,
        lessonId: state[lessonId]!.copyWith(status: DownloadStatus.completed),
      };
    } catch (e) {
      if (CancelToken.isCancel(e as DioException)) {
        state = {
          ...state,
          lessonId: state[lessonId]!.copyWith(status: DownloadStatus.paused),
        };
      } else {
        state = {
          ...state,
          lessonId: state[lessonId]!.copyWith(
            status: DownloadStatus.failed,
            errorMessage: e.toString(),
          ),
        };
      }
    } finally {
      _cancelTokens.remove(lessonId);
    }
  }

  /// Cancela ou pausa um download ativo
  void pauseDownload(String lessonId) {
    if (_cancelTokens.containsKey(lessonId)) {
      _cancelTokens[lessonId]!.cancel();
    }
  }

  /// Faz o download de um arquivo individual usando HTTP Range Requests se existir arquivo parcial
  Future<void> _downloadFileWithRange(
    String url,
    File file,
    CancelToken cancelToken,
  ) async {
    int startBytes = 0;
    if (await file.exists()) {
      startBytes = await file.length();
    }

    // Se o arquivo já existe e é parcial, solicitar a partir do offset
    final options = Options(
      headers: startBytes > 0 ? {'Range': 'bytes=$startBytes-'} : {},
      responseType: ResponseType.stream,
    );

    final response = await _dio.get(
      url,
      options: options,
      cancelToken: cancelToken,
    );

    // Se startBytes > 0, abrimos o arquivo no modo Append, caso contrário em Write
    final fileMode = startBytes > 0 ? FileMode.append : FileMode.write;
    final sink = file.openWrite(mode: fileMode);

    final responseStream = response.data.stream as Stream<List<int>>;
    await for (var chunk in responseStream) {
      sink.add(chunk);
    }
    await sink.flush();
    await sink.close();
  }

  /// Obtém ou gera uma chave mestre segura para uma aula armazenada na Keychain/Keystore
  Future<Uint8List> _getOrGenerateLessonKey(String lessonId) async {
    final storageKey = 'lesson_key_$lessonId';
    final existingKey = await _secureStorage.read(key: storageKey);
    if (existingKey != null) {
      return base64Decode(existingKey);
    }

    // Gera chave com SecureRandom
    final newKeyBytes = encrypt.Key.fromSecureRandom(32).bytes;
    await _secureStorage.write(
      key: storageKey,
      value: base64Encode(newKeyBytes),
    );
    return newKeyBytes;
  }

  /// Criptografa o arquivo baixado em AES-256 GCM usando chave do Secure Storage
  Future<void> _encryptFile(File file) async {
    // Apenas criptografamos se o arquivo não estiver criptografado
    if (file.path.endsWith('.enc') && await file.length() > 0) {
      final bytes = await file.readAsBytes();

      // Se já começar com o cabeçalho personalizado "LAWRENCE_ENC", assumimos que já está criptografado
      final header = utf8.encode("LAWRENCE_ENC");
      if (bytes.length > header.length) {
        bool isAlreadyEncrypted = true;
        for (int i = 0; i < header.length; i++) {
          if (bytes[i] != header[i]) {
            isAlreadyEncrypted = false;
            break;
          }
        }
        if (isAlreadyEncrypted) return; // Já está seguro
      }

      // Extrair o lessonId a partir do path (../downloads/<lessonId>/segment_X.enc)
      final parts = file.path.split('/');
      final lessonId = parts[parts.length - 2];

      final keyBytes = await _getOrGenerateLessonKey(lessonId);

      final key = encrypt.Key(Uint8List.fromList(keyBytes));
      final iv = encrypt.IV.fromSecureRandom(16);

      // Usa AESMode.gcm para autencidade e confidencialidade
      final encrypter = encrypt.Encrypter(
        encrypt.AES(key, mode: encrypt.AESMode.gcm),
      );

      final encrypted = encrypter.encryptBytes(bytes, iv: iv);

      // Escrever o arquivo final com cabeçalho identificador + iv + bytes criptografados
      final outputFile = await file.open(mode: FileMode.write);
      await outputFile.writeFrom(header);
      await outputFile.writeFrom(iv.bytes);
      await outputFile.writeFrom(encrypted.bytes);
      await outputFile.close();
    }
  }

  /// Descriptografa localmente na memória para streaming privado no Player
  Future<Uint8List> decryptSegment(String lessonId, int segmentIndex) async {
    final appDir = await getApplicationDocumentsDirectory();
    final file = File(
      '${appDir.path}/downloads/$lessonId/segment_$segmentIndex.enc',
    );

    if (!await file.exists()) {
      throw FileNotFoundException("Segment file not found.");
    }

    final bytes = await file.readAsBytes();
    final header = utf8.encode("LAWRENCE_ENC");

    // Verificar cabeçalho de integridade
    for (int i = 0; i < header.length; i++) {
      if (bytes[i] != header[i]) {
        throw SecurityException("Criptografia violada ou inválida.");
      }
    }

    final ivOffset = header.length;
    final payloadOffset = ivOffset + 16;

    final ivBytes = bytes.sublist(ivOffset, payloadOffset);
    final encryptedPayload = bytes.sublist(payloadOffset);

    // Obter chave da Keystore
    final keyBytes = await _getOrGenerateLessonKey(lessonId);

    final key = encrypt.Key(Uint8List.fromList(keyBytes));
    final iv = encrypt.IV(Uint8List.fromList(ivBytes));
    final encrypter = encrypt.Encrypter(
      encrypt.AES(key, mode: encrypt.AESMode.gcm),
    );

    final decrypted = encrypter.decryptBytes(
      encrypt.Encrypted(encryptedPayload),
      iv: iv,
    );
    return Uint8List.fromList(decrypted);
  }
}

class SecurityException implements Exception {
  final String message;
  SecurityException(this.message);
  @override
  String toString() => "SecurityException: $message";
}

class FileNotFoundException implements Exception {
  final String message;
  FileNotFoundException(this.message);
  @override
  String toString() => "FileNotFoundException: $message";
}

final downloadProvider =
    StateNotifierProvider<DownloadNotifier, Map<String, DownloadTask>>((ref) {
      return DownloadNotifier(ref);
    });
