import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import '../../../../app/providers/learning_repositories.dart';

enum PlayerStatus {
  initializing,
  loading,
  ready,
  playing,
  paused,
  buffering,
  completed,
  streamExpired,
  accessDenied,
  offline,
  error,
}

class PlayerStateData {
  final PlayerStatus status;
  final VideoPlayerController? controller;
  final String? errorMessage;
  final int retryCount;
  final Duration lastPosition;

  PlayerStateData({
    required this.status,
    this.controller,
    this.errorMessage,
    this.retryCount = 0,
    this.lastPosition = Duration.zero,
  });

  PlayerStateData copyWith({
    PlayerStatus? status,
    VideoPlayerController? controller,
    String? errorMessage,
    int? retryCount,
    Duration? lastPosition,
  }) {
    return PlayerStateData(
      status: status ?? this.status,
      controller: controller ?? this.controller,
      errorMessage: errorMessage ?? this.errorMessage,
      retryCount: retryCount ?? this.retryCount,
      lastPosition: lastPosition ?? this.lastPosition,
    );
  }
}

class PlayerController extends StateNotifier<PlayerStateData> {
  final Ref _ref;
  final String courseId;
  final String lessonId;
  bool _recoveringPlayback = false;

  PlayerController(this._ref, {required this.courseId, required this.lessonId})
    : super(PlayerStateData(status: PlayerStatus.initializing)) {
    _initialize();
  }

  Future<void> _initialize() async {
    final previousPosition = state.lastPosition;
    await _disposeActiveController();
    state = PlayerStateData(
      status: PlayerStatus.loading,
      retryCount: state.retryCount,
      lastPosition: previousPosition,
    );
    try {
      final repo = _ref.read(lessonRepositoryProvider);
      final streamUrl = await repo.getLessonStreamUrl(courseId, lessonId);

      final controller = VideoPlayerController.networkUrl(Uri.parse(streamUrl));
      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }

      // Configurar escutas de eventos do player
      controller.addListener(_videoPlayerListener);

      state = state.copyWith(
        status: PlayerStatus.ready,
        controller: controller,
      );

      // Se havia uma posição salva (ex: pós-renovação de url expirada), busca-a
      if (state.lastPosition > Duration.zero) {
        await controller.seekTo(state.lastPosition);
        await controller.play();
      }
    } catch (e) {
      if (!mounted) return;
      _handleInitError(e);
    }
  }

  void _videoPlayerListener() {
    final controller = state.controller;
    if (controller == null) return;

    if (controller.value.hasError) {
      _handlePlaybackError(controller.value.errorDescription);
      return;
    }

    final value = controller.value;
    final position = value.position;
    final duration = value.duration;

    // Atualizar posição atual periodically
    if (value.isPlaying &&
        position > Duration.zero &&
        (position - state.lastPosition).abs() >= const Duration(seconds: 5)) {
      state = state.copyWith(lastPosition: position);
    }

    final PlayerStatus nextStatus;
    if (value.isBuffering) {
      nextStatus = PlayerStatus.buffering;
    } else if (position >= duration && duration > Duration.zero) {
      nextStatus = PlayerStatus.completed;
    } else if (value.isPlaying) {
      nextStatus = PlayerStatus.playing;
    } else {
      nextStatus = PlayerStatus.paused;
    }
    if (state.status != nextStatus) {
      state = state.copyWith(status: nextStatus);
    }
  }

  void _handleInitError(dynamic error) {
    if (error.toString().contains('403') ||
        error.toString().contains('Forbidden')) {
      state = state.copyWith(
        status: PlayerStatus.accessDenied,
        errorMessage:
            "Acesso negado. Sua assinatura para este curso expirou ou é inválida.",
      );
    } else if (error.toString().contains('SocketException') ||
        error.toString().contains('Network')) {
      state = state.copyWith(
        status: PlayerStatus.offline,
        errorMessage: "Você está offline. Verifique sua conexão.",
      );
    } else {
      state = state.copyWith(
        status: PlayerStatus.error,
        errorMessage: "Não foi possível iniciar o vídeo.",
      );
    }
  }

  Future<void> _handlePlaybackError(String? errorDescription) async {
    if (_recoveringPlayback) return;
    _recoveringPlayback = true;
    try {
      final currentPos = state.lastPosition;
      final currentRetries = state.retryCount;

      // Se o erro parecer com url assinada expirada
      if (errorDescription != null &&
          (errorDescription.contains('403') ||
              errorDescription.contains('expired') ||
              errorDescription.contains('Forbidden'))) {
        if (currentRetries < 3) {
          state = state.copyWith(
            status: PlayerStatus.loading,
            retryCount: currentRetries + 1,
            lastPosition: currentPos,
          );

          // Tentar re-inicializar com nova URL assinada
          await _initialize();
          return;
        }
        state = state.copyWith(
          status: PlayerStatus.streamExpired,
          errorMessage:
              "A sessão de reprodução expirou após várias tentativas. Recarregue a página.",
        );
      } else {
        state = state.copyWith(
          status: PlayerStatus.error,
          errorMessage: "A reprodução foi interrompida. Tente novamente.",
        );
      }
    } finally {
      _recoveringPlayback = false;
    }
  }

  void play() {
    state.controller?.play();
  }

  void pause() {
    state.controller?.pause();
  }

  void seekTo(Duration position) {
    state.controller?.seekTo(position);
  }

  Future<void> retry() async {
    state = PlayerStateData(
      status: PlayerStatus.initializing,
      retryCount: 0,
      lastPosition: state.lastPosition,
    );
    await _initialize();
  }

  Future<void> _disposeActiveController() async {
    final controller = state.controller;
    if (controller == null) return;
    controller.removeListener(_videoPlayerListener);
    await controller.dispose();
  }

  @override
  void dispose() {
    final controller = state.controller;
    if (controller != null) {
      controller.removeListener(_videoPlayerListener);
      controller.dispose();
    }
    super.dispose();
  }
}

// Provider de escopo para obter o controller ativo do player
final playerControllerProvider = StateNotifierProvider.autoDispose
    .family<
      PlayerController,
      PlayerStateData,
      ({String courseId, String lessonId})
    >((ref, arg) {
      return PlayerController(
        ref,
        courseId: arg.courseId,
        lessonId: arg.lessonId,
      );
    });
