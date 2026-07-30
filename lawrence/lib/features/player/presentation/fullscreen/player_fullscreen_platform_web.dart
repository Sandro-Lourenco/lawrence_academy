import 'dart:async';
import 'dart:js_interop';

import 'package:web/web.dart' as web;

import 'player_fullscreen_platform_contract.dart';

PlayerFullscreenPlatform createPlayerFullscreenPlatform({
  required FullscreenChanged onFullscreenChanged,
}) {
  return _WebFullscreenPlatform(onFullscreenChanged);
}

class _WebFullscreenPlatform implements PlayerFullscreenPlatform {
  _WebFullscreenPlatform(this._onFullscreenChanged) {
    _subscription = web.document.documentElement?.onFullscreenChange.listen(
      (_) => _notifyCurrentState(),
    );
  }

  final FullscreenChanged _onFullscreenChanged;
  StreamSubscription<web.Event>? _subscription;
  bool _disposed = false;

  void _notifyCurrentState() {
    if (!_disposed) {
      _onFullscreenChanged(web.document.fullscreenElement != null);
    }
  }

  @override
  Future<void> enter() async {
    final element = web.document.documentElement;
    if (element == null || !web.document.fullscreenEnabled) return;
    try {
      await element.requestFullscreen().toDart;
    } catch (_) {
      // O host ainda oferece fullscreen dentro do viewport quando o navegador
      // nega a API (iframe, política corporativa ou ausência de gesto).
    }
  }

  @override
  Future<void> exit() async {
    if (web.document.fullscreenElement == null) return;
    try {
      await web.document.exitFullscreen().toDart;
    } catch (_) {
      // O estado visual local já foi restaurado pelo host.
    }
  }

  @override
  void dispose() {
    _disposed = true;
    unawaited(_subscription?.cancel());
    _subscription = null;
    if (web.document.fullscreenElement != null) {
      unawaited(web.document.exitFullscreen().toDart);
    }
  }
}
