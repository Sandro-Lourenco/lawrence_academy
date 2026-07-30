import 'package:flutter/services.dart';

import 'player_fullscreen_platform_contract.dart';

PlayerFullscreenPlatform createPlayerFullscreenPlatform({
  required FullscreenChanged onFullscreenChanged,
}) {
  return _SystemFullscreenPlatform(onFullscreenChanged);
}

class _SystemFullscreenPlatform implements PlayerFullscreenPlatform {
  _SystemFullscreenPlatform(this._onFullscreenChanged);

  final FullscreenChanged _onFullscreenChanged;
  bool _disposed = false;

  @override
  Future<void> enter() async {
    await SystemChrome.setPreferredOrientations(const [
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    if (!_disposed) _onFullscreenChanged(true);
  }

  @override
  Future<void> exit() async {
    await SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    if (!_disposed) _onFullscreenChanged(false);
  }

  @override
  void dispose() {
    _disposed = true;
    // A restauração não deve atrasar a desmontagem da rota.
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }
}
