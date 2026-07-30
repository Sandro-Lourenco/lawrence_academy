import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/upload_file_payload.dart';

Future<void> uploadWithSignedToken({
  required SupabaseClient client,
  required String bucket,
  required String storagePath,
  required String token,
  required UploadFilePayload file,
}) async {
  final path = file.path;
  if (path != null) {
    await client.storage
        .from(bucket)
        .uploadToSignedUrl(
          storagePath,
          token,
          File(path),
          FileOptions(contentType: file.contentType, upsert: false),
        );
    return;
  }

  final bytes = file.bytes;
  if (bytes == null) {
    throw StateError('Não foi possível acessar o arquivo selecionado.');
  }
  await client.storage
      .from(bucket)
      .uploadBinaryToSignedUrl(
        storagePath,
        token,
        bytes,
        FileOptions(contentType: file.contentType, upsert: false),
      );
}
