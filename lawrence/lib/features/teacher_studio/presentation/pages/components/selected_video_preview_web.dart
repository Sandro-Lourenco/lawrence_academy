// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter

import 'dart:html' as html;

import 'package:file_picker/file_picker.dart';
import 'package:video_player/video_player.dart';

class SelectedVideoPreview {
  const SelectedVideoPreview._(this.controller, this._objectUrl);

  final VideoPlayerController? controller;
  final String? _objectUrl;

  static Future<SelectedVideoPreview> create(
    PlatformFile file,
    String contentType,
  ) async {
    final bytes = file.bytes;
    if (bytes == null || bytes.isEmpty) {
      return const SelectedVideoPreview._(null, null);
    }
    final objectUrl = html.Url.createObjectUrlFromBlob(
      html.Blob(<Object>[bytes], contentType),
    );
    final controller = VideoPlayerController.networkUrl(Uri.parse(objectUrl));
    try {
      await controller.initialize();
      return SelectedVideoPreview._(controller, objectUrl);
    } catch (_) {
      await controller.dispose();
      html.Url.revokeObjectUrl(objectUrl);
      return const SelectedVideoPreview._(null, null);
    }
  }

  Future<void> dispose() async {
    await controller?.dispose();
    final objectUrl = _objectUrl;
    if (objectUrl != null) html.Url.revokeObjectUrl(objectUrl);
  }
}
