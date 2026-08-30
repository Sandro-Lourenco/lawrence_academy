import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../../../design_system/tokens/lawrence_theme.dart';
import '../../../../design_system/widgets/couture_primary_button.dart';
import '../controllers/player_controller.dart';

class StatelessPlayerView extends StatelessWidget {
  final PlayerStateData state;
  final VoidCallback onPlayPause;
  final VoidCallback onReplay;
  final VoidCallback onRetry;
  final VoidCallback onManageAccess;
  final VoidCallback onFullscreen;
  final bool isFullscreen;

  const StatelessPlayerView({
    super.key,
    required this.state,
    required this.onPlayPause,
    required this.onReplay,
    required this.onRetry,
    required this.onManageAccess,
    required this.onFullscreen,
    this.isFullscreen = false,
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
            _PlayerControls(
              controller: controller,
              onPlayPause: onPlayPause,
              onFullscreen: onFullscreen,
              isFullscreen: isFullscreen,
            ),
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
  final VoidCallback onFullscreen;
  final bool isFullscreen;

  const _PlayerControls({
    required this.controller,
    required this.onPlayPause,
    required this.onFullscreen,
    required this.isFullscreen,
  });

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(LawrenceRadii.control),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: const Color(0xB8141A22),
                borderRadius: BorderRadius.circular(LawrenceRadii.control),
                border: Border.all(color: Colors.white.withValues(alpha: .24)),
                boxShadow: const [
                  BoxShadow(color: Color(0x55000000), blurRadius: 24),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 8, 6),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    VideoProgressIndicator(
                      controller,
                      allowScrubbing: true,
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      colors: const VideoProgressColors(
                        playedColor: LawrenceColors.actionOnDark,
                        bufferedColor: Colors.white38,
                        backgroundColor: Colors.white24,
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          tooltip: controller.value.isPlaying
                              ? 'Pausar (Espaço)'
                              : 'Reproduzir (Espaço)',
                          icon: Icon(
                            controller.value.isPlaying
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                          ),
                          color: Colors.white,
                          onPressed: onPlayPause,
                        ),
                        IconButton(
                          tooltip: controller.value.volume == 0
                              ? 'Ativar som'
                              : 'Silenciar',
                          onPressed: () => controller.setVolume(
                            controller.value.volume == 0 ? 1 : 0,
                          ),
                          icon: Icon(
                            controller.value.volume == 0
                                ? Icons.volume_off_rounded
                                : Icons.volume_up_rounded,
                          ),
                          color: Colors.white,
                        ),
                        ValueListenableBuilder(
                          valueListenable: controller,
                          builder: (context, VideoPlayerValue value, child) {
                            return Text(
                              '${_formatDuration(value.position)} / ${_formatDuration(value.duration)}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            );
                          },
                        ),
                        const Spacer(),
                        PopupMenuButton<double>(
                          tooltip: 'Velocidade de reprodução',
                          initialValue: controller.value.playbackSpeed,
                          onSelected: controller.setPlaybackSpeed,
                          color: const Color(0xEE18202A),
                          iconColor: Colors.white,
                          itemBuilder: (context) => [
                            for (final speed in const <double>[
                              .5,
                              .75,
                              1,
                              1.25,
                              1.5,
                              1.75,
                              2,
                            ])
                              PopupMenuItem(
                                value: speed,
                                child: Text(
                                  '$speed×',
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                          ],
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(
                              minWidth: 48,
                              minHeight: 48,
                            ),
                            child: Center(
                              child: Text(
                                '${controller.value.playbackSpeed}×',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: isFullscreen
                              ? 'Sair da tela cheia'
                              : 'Entrar em tela cheia',
                          onPressed: onFullscreen,
                          icon: Icon(
                            isFullscreen
                                ? Icons.fullscreen_exit_rounded
                                : Icons.fullscreen_rounded,
                          ),
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
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
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 430),
          child: Container(
            margin: const EdgeInsets.all(LawrenceSpacing.lg),
            padding: const EdgeInsets.all(LawrenceSpacing.xl),
            decoration: BoxDecoration(
              color: LawrenceColors.brandNavy.withValues(alpha: .72),
              border: Border.all(color: Colors.white.withValues(alpha: .14)),
              boxShadow: const [
                BoxShadow(color: Color(0x66000000), blurRadius: 32),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: tone.withValues(alpha: .14),
                    border: Border.all(color: tone.withValues(alpha: .7)),
                  ),
                  child: Icon(icon, color: tone, size: 28),
                ),
                const SizedBox(height: LawrenceSpacing.md),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'Georgia',
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: LawrenceSpacing.xs),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70, height: 1.45),
                ),
                const SizedBox(height: LawrenceSpacing.xs),
                const Text(
                  'Seu progresso foi preservado.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: LawrenceColors.darkTextPrimary),
                ),
                const SizedBox(height: LawrenceSpacing.lg),
                CouturePrimaryButton(
                  label: actionLabel,
                  icon: Icons.refresh_rounded,
                  onPressed: onAction,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
