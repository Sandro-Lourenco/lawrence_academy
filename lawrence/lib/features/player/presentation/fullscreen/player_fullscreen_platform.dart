import 'player_fullscreen_platform_contract.dart';
import 'player_fullscreen_platform_stub.dart'
    if (dart.library.js_interop) 'player_fullscreen_platform_web.dart'
    as implementation;

export 'player_fullscreen_platform_contract.dart';

PlayerFullscreenPlatform createPlayerFullscreenPlatform({
  required FullscreenChanged onFullscreenChanged,
}) {
  return implementation.createPlayerFullscreenPlatform(
    onFullscreenChanged: onFullscreenChanged,
  );
}
