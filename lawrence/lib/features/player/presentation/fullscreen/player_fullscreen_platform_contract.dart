typedef FullscreenChanged = void Function(bool isFullscreen);

abstract interface class PlayerFullscreenPlatform {
  Future<void> enter();

  Future<void> exit();

  void dispose();
}
