import 'package:file_picker/file_picker.dart';
import 'package:video_player/video_player.dart';

class SelectedVideoPreview {
  const SelectedVideoPreview._(this.controller);

  final VideoPlayerController? controller;

  static Future<SelectedVideoPreview> create(
    PlatformFile file,
    String contentType,
  ) async => const SelectedVideoPreview._(null);

  Future<void> dispose() async {
    await controller?.dispose();
  }
}
