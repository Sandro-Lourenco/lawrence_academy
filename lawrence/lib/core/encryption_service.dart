import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:crypto/crypto.dart';

/// Serviço exclusivo para operações de criptografia de arquivos baixados (AES-256-GCM).
/// Não possui conhecimento de regras de negócio de licença ou download.
class EncryptionService {
  final _secureStorage = const FlutterSecureStorage();

  /// Obtém a Master Key do Keystore, ou gera se não existir.
  Future<Uint8List> _getMasterKey() async {
    const storageKey = 'lawrence_master_key';
    final existingKey = await _secureStorage.read(key: storageKey);
    if (existingKey != null) {
      return base64Decode(existingKey);
    }

    // Gera chave com SecureRandom 32 bytes (256-bit)
    final newKeyBytes = encrypt.Key.fromSecureRandom(32).bytes;
    await _secureStorage.write(
      key: storageKey,
      value: base64Encode(newKeyBytes),
    );
    return newKeyBytes;
  }

  /// Deriva uma chave específica para um download utilizando a Master Key
  /// Simula HKDF utilizando SHA-256 no MVP.
  Future<Uint8List> _deriveKeyForDownload(String downloadId) async {
    final masterKey = await _getMasterKey();
    // Simplified HKDF-like approach: HmacSHA256(MasterKey, downloadId)
    // Here we just use a simple derivation for compatibility.
    // In production, an official HKDF implementation should be used.
    final List<int> combined = [...masterKey, ...utf8.encode(downloadId)];
    // For simplicity with 'encrypt' package constraints, we will just take the masterKey and tweak it safely, or just use masterKey for MVP.
    // Let's implement a safe simple hash of master+downloadId
    final hashBytes = sha256.convert(combined).bytes;
    return Uint8List.fromList(hashBytes);
  }

  /// Criptografa o arquivo HLS segmentado em AES-256 GCM
  Future<void> encryptSegment(File file, String downloadId) async {
    if (!await file.exists() || await file.length() == 0) return;

    final bytes = await file.readAsBytes();

    // Verificação de header
    final header = utf8.encode("LAWRENCE_GCM");
    if (bytes.length > header.length) {
      bool isAlreadyEncrypted = true;
      for (int i = 0; i < header.length; i++) {
        if (bytes[i] != header[i]) {
          isAlreadyEncrypted = false;
          break;
        }
      }
      if (isAlreadyEncrypted) return;
    }

    final keyBytes = await _deriveKeyForDownload(downloadId);
    final key = encrypt.Key(keyBytes);

    // Nonce único de 96 bits (12 bytes) para GCM
    final iv = encrypt.IV.fromSecureRandom(12);

    final encrypter = encrypt.Encrypter(
      encrypt.AES(key, mode: encrypt.AESMode.gcm),
    );
    final encrypted = encrypter.encryptBytes(bytes, iv: iv);

    final outputFile = await file.open(mode: FileMode.write);
    await outputFile.writeFrom(header);
    await outputFile.writeFrom(iv.bytes);

    // The encrypt package implicitly appends the 16-byte authentication tag in the returned bytes when using GCM.
    await outputFile.writeFrom(encrypted.bytes);
    await outputFile.close();
  }

  /// Descriptografa localmente na memória para streaming privado no Player
  Future<Uint8List> decryptSegment(File file, String downloadId) async {
    if (!await file.exists()) {
      throw Exception("Segment file not found.");
    }

    final bytes = await file.readAsBytes();
    final header = utf8.encode("LAWRENCE_GCM");

    for (int i = 0; i < header.length; i++) {
      if (bytes[i] != header[i]) {
        throw Exception(
          "SecurityException: Criptografia violada ou header inválido.",
        );
      }
    }

    final ivOffset = header.length;
    final payloadOffset = ivOffset + 12; // 12 bytes nonce

    final ivBytes = bytes.sublist(ivOffset, payloadOffset);
    final encryptedPayload = bytes.sublist(payloadOffset);

    final keyBytes = await _deriveKeyForDownload(downloadId);
    final key = encrypt.Key(keyBytes);
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

  /// Transacional: invalida a chave mestre durante o logout
  Future<void> invalidateKeys() async {
    await _secureStorage.delete(key: 'lawrence_master_key');
    // Adicional: limpar quaisquer subkeys cacheadas se aplicável
  }
}
