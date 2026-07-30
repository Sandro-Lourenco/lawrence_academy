import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:video_player/video_player.dart';

class SelectedVideoPreview {
  const SelectedVideoPreview._(this.controller);

  final VideoPlayerController? controller;

  static Future<SelectedVideoPreview> create(
    PlatformFile file,
    String contentType,
  ) async {
    final path = file.path;
    if (path == null || path.isEmpty) return const SelectedVideoPreview._(null);
    final controller = VideoPlayerController.file(File(path));
    try {
      await controller.initialize();
      return SelectedVideoPreview._(controller);
    } catch (_) {
      await controller.dispose();
      return const SelectedVideoPreview._(null);
    }
  }

  Future<void> dispose() async {
    await controller?.dispose();
  }
}
