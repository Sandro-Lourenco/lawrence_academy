import 'dart:typed_data';

/// Platform-neutral file selected for a teacher Studio upload.
///
/// Android/desktop keep [path] so large videos can be streamed from disk.
/// Flutter Web provides [bytes], because browser files do not expose a usable
/// local filesystem path.
class UploadFilePayload {
  const UploadFilePayload({
    required this.filename,
    required this.sizeBytes,
    required this.contentType,
    this.path,
    this.bytes,
  }) : assert(path != null || bytes != null);

  final String filename;
  final int sizeBytes;
  final String contentType;
  final String? path;
  final Uint8List? bytes;
}
