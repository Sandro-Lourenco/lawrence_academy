import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/upload_file_payload.dart';

Future<void> uploadWithSignedToken({
  required SupabaseClient client,
  required String bucket,
  required String storagePath,
  required String token,
  required UploadFilePayload file,
}) async {
  final bytes = file.bytes;
  if (bytes == null) {
    throw StateError('O navegador não conseguiu ler o arquivo selecionado.');
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
