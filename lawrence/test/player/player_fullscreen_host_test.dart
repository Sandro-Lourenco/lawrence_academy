import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lawrence/features/player/presentation/widgets/player_fullscreen_host.dart';

void main() {
  testWidgets('moves one player instance into and out of fullscreen', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: PlayerFullscreenHost(
          playerBuilder: (context, isFullscreen, toggleFullscreen) {
            return ColoredBox(
              key: const ValueKey('single-video-player'),
              color: Colors.black,
              child: IconButton(
                tooltip: isFullscreen
                    ? 'Sair da tela cheia'
                    : 'Entrar em tela cheia',
                onPressed: toggleFullscreen,
                icon: Icon(
                  isFullscreen ? Icons.fullscreen_exit : Icons.fullscreen,
                ),
              ),
            );
          },
          pageBuilder: (context, embeddedPlayer) {
            return Scaffold(body: embeddedPlayer);
          },
        ),
      ),
    );

    expect(find.byKey(const ValueKey('single-video-player')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('fullscreen-player-surface')),
      findsNothing,
    );

    await tester.tap(find.byTooltip('Entrar em tela cheia'));
    await tester.pump();

    expect(find.byKey(const ValueKey('single-video-player')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('fullscreen-player-placeholder')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('fullscreen-player-surface')),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const ValueKey('fullscreen-exit-button')));
    await tester.pump();

    expect(find.byKey(const ValueKey('single-video-player')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('fullscreen-player-surface')),
      findsNothing,
    );
  });

  testWidgets('escape restores the embedded player', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: PlayerFullscreenHost(
          playerBuilder: (context, isFullscreen, toggleFullscreen) {
            return IconButton(
              key: const ValueKey('single-video-player'),
              tooltip: isFullscreen
                  ? 'Sair da tela cheia'
                  : 'Entrar em tela cheia',
              onPressed: toggleFullscreen,
              icon: const Icon(Icons.fullscreen),
            );
          },
          pageBuilder: (context, embeddedPlayer) => embeddedPlayer,
        ),
      ),
    );

    await tester.tap(find.byTooltip('Entrar em tela cheia'));
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pump();

    expect(
      find.byKey(const ValueKey('fullscreen-player-surface')),
      findsNothing,
    );
    expect(find.byKey(const ValueKey('single-video-player')), findsOneWidget);
  });
}
