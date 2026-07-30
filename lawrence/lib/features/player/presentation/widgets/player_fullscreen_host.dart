import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../fullscreen/player_fullscreen_platform.dart';

typedef FullscreenPlayerBuilder =
    Widget Function(
      BuildContext context,
      bool isFullscreen,
      VoidCallback toggleFullscreen,
    );

typedef PlayerPageBuilder =
    Widget Function(BuildContext context, Widget embeddedPlayer);

/// Moves one player view between the learning page and a fullscreen overlay.
///
/// A [VideoPlayerController] must never be attached to two `VideoPlayer`
/// widgets simultaneously, particularly on web where both widgets would
/// compete for the same HTML media element.
class PlayerFullscreenHost extends StatefulWidget {
  const PlayerFullscreenHost({
    super.key,
    required this.playerBuilder,
    required this.pageBuilder,
  });

  final FullscreenPlayerBuilder playerBuilder;
  final PlayerPageBuilder pageBuilder;

  @override
  State<PlayerFullscreenHost> createState() => _PlayerFullscreenHostState();
}

class _PlayerFullscreenHostState extends State<PlayerFullscreenHost> {
  late final PlayerFullscreenPlatform _platform;
  final FocusNode _fullscreenFocus = FocusNode(
    debugLabel: 'fullscreen-video-player',
  );
  bool _isFullscreen = false;

  @override
  void initState() {
    super.initState();
    _platform = createPlayerFullscreenPlatform(
      onFullscreenChanged: _handlePlatformFullscreenChanged,
    );
  }

  void _handlePlatformFullscreenChanged(bool active) {
    if (!mounted || active == _isFullscreen) return;
    setState(() => _isFullscreen = active);
  }

  void _toggleFullscreen() {
    if (_isFullscreen) {
      _exitFullscreen();
    } else {
      _enterFullscreen();
    }
  }

  void _enterFullscreen() {
    if (_isFullscreen) return;
    setState(() => _isFullscreen = true);
    _fullscreenFocus.requestFocus();
    unawaited(_platform.enter());
  }

  void _exitFullscreen() {
    if (!_isFullscreen) return;
    setState(() => _isFullscreen = false);
    unawaited(_platform.exit());
  }

  void _handleFullscreenKey(KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.escape) {
      _exitFullscreen();
    }
  }

  @override
  void dispose() {
    _fullscreenFocus.dispose();
    _platform.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final player = widget.playerBuilder(
      context,
      _isFullscreen,
      _toggleFullscreen,
    );

    return Stack(
      fit: StackFit.expand,
      children: [
        widget.pageBuilder(
          context,
          _isFullscreen
              ? const ColoredBox(
                  key: ValueKey('fullscreen-player-placeholder'),
                  color: Colors.black,
                )
              : player,
        ),
        if (_isFullscreen)
          Positioned.fill(
            child: Material(
              key: const ValueKey('fullscreen-player-surface'),
              color: Colors.black,
              child: SafeArea(
                top: false,
                bottom: false,
                child: KeyboardListener(
                  focusNode: _fullscreenFocus,
                  autofocus: true,
                  onKeyEvent: _handleFullscreenKey,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Center(child: SizedBox.expand(child: player)),
                      Positioned(
                        top: MediaQuery.paddingOf(context).top + 12,
                        right: MediaQuery.paddingOf(context).right + 12,
                        child: IconButton.filled(
                          key: const ValueKey('fullscreen-exit-button'),
                          tooltip: 'Sair da tela cheia',
                          onPressed: _exitFullscreen,
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.black54,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          icon: const Icon(Icons.fullscreen_exit_rounded),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
