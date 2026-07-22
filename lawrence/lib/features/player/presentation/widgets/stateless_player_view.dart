import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../../../design_system/tokens/lawrence_theme.dart';
import '../controllers/player_controller.dart';

class StatelessPlayerView extends StatelessWidget {
  final PlayerStateData state;
  final VoidCallback onPlayPause;
  final VoidCallback onReplay;
  final VoidCallback onRetry;
  final VoidCallback onManageAccess;

  const StatelessPlayerView({
    super.key,
    required this.state,
    required this.onPlayPause,
    required this.onReplay,
    required this.onRetry,
    required this.onManageAccess,
  });

  @override
  Widget build(BuildContext context) {
    switch (state.status) {
      case PlayerStatus.initializing:
      case PlayerStatus.loading:
        return const Center(
          child: CircularProgressIndicator(color: LawrenceColors.primary),
        );
      case PlayerStatus.buffering:
        final controller = state.controller;
        final hasSize =
            controller != null &&
            controller.value.isInitialized &&
            controller.value.size.width > 0 &&
            controller.value.size.height > 0;
        return Stack(
          children: [
            if (hasSize)
              VideoPlayer(controller)
            else
              const Center(
                child: CircularProgressIndicator(color: LawrenceColors.primary),
              ),
            const Center(child: CircularProgressIndicator(color: Colors.white)),
          ],
        );
      case PlayerStatus.ready:
      case PlayerStatus.playing:
      case PlayerStatus.paused:
        final controller = state.controller!;
        final hasSize =
            controller.value.isInitialized &&
            controller.value.size.width > 0 &&
            controller.value.size.height > 0;
        if (!hasSize) {
          return const Center(
            child: CircularProgressIndicator(color: LawrenceColors.primary),
          );
        }
        return Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Semantics(
              button: true,
              label: controller.value.isPlaying
                  ? 'Pausar vídeo'
                  : 'Reproduzir vídeo',
              child: GestureDetector(
                onTap: onPlayPause,
                child: VideoPlayer(controller),
              ),
            ),
            _PlayerControls(controller: controller, onPlayPause: onPlayPause),
          ],
        );
      case PlayerStatus.completed:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.check_circle_outline,
                color: LawrenceColors.success,
                size: 64,
              ),
              const SizedBox(height: 16),
              const Text(
                "Aula concluída!",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: onReplay,
                child: const Text("Reassistir"),
              ),
            ],
          ),
        );
      case PlayerStatus.streamExpired:
        return _PlayerMessage(
          icon: Icons.timer_off_outlined,
          title: 'A sessão de vídeo expirou',
          message: 'Solicite uma nova sessão para continuar do mesmo ponto.',
          actionLabel: 'Renovar sessão',
          onAction: onRetry,
          tone: LawrenceColors.warning,
        );
      case PlayerStatus.accessDenied:
        return _PlayerMessage(
          icon: Icons.lock_outline_rounded,
          title: 'Acesso não disponível',
          message: 'Esta aula requer uma assinatura ativa para o curso.',
          actionLabel: 'Gerenciar assinatura',
          onAction: onManageAccess,
          tone: LawrenceColors.danger,
        );
      case PlayerStatus.offline:
        return _PlayerMessage(
          icon: Icons.wifi_off_rounded,
          title: 'Você está offline',
          message: 'Reconecte-se para assistir ou acesse seus downloads.',
          actionLabel: 'Tentar novamente',
          onAction: onRetry,
          tone: LawrenceColors.warning,
        );
      case PlayerStatus.error:
        return _PlayerMessage(
          icon: Icons.error_outline_rounded,
          title: 'Não foi possível reproduzir',
          message: state.errorMessage ?? 'Tente novamente em instantes.',
          actionLabel: 'Tentar novamente',
          onAction: onRetry,
          tone: LawrenceColors.danger,
        );
    }
  }
}

class _PlayerControls extends StatelessWidget {
  final VideoPlayerController controller;
  final VoidCallback onPlayPause;

  const _PlayerControls({required this.controller, required this.onPlayPause});

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black45,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          VideoProgressIndicator(
            controller,
            allowScrubbing: true,
            colors: const VideoProgressColors(
              playedColor: LawrenceColors.primary,
              bufferedColor: Colors.white24,
              backgroundColor: Colors.white10,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                tooltip: controller.value.isPlaying ? 'Pausar' : 'Reproduzir',
                icon: Icon(
                  controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                ),
                onPressed: onPlayPause,
              ),
              Row(
                children: [
                  ValueListenableBuilder(
                    valueListenable: controller,
                    builder: (context, VideoPlayerValue value, child) {
                      return Text(
                        "${_formatDuration(value.position)} / ${_formatDuration(value.duration)}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PlayerMessage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;
  final Color tone;

  const _PlayerMessage({
    required this.icon,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
    required this.tone,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      liveRegion: true,
      label: '$title. $message',
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(LawrenceSpacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: tone, size: 48),
              const SizedBox(height: LawrenceSpacing.md),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: LawrenceSpacing.xs),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: LawrenceSpacing.md),
              FilledButton(onPressed: onAction, child: Text(actionLabel)),
            ],
          ),
        ),
      ),
    );
  }
}
