import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import 'package:dio/dio.dart';
import 'package:lawrence/data/models/course_dto.dart';
import 'package:lawrence/data/repositories/course_repository.dart';
import '../core/auth_provider.dart';

class PlayerState {
  final bool isPlaying;
  final Duration position;
  final Duration duration;
  final bool isBuffering;
  final bool isWatermarkVisible;
  final bool isTampered;
  final String? errorMessage;

  PlayerState({
    this.isPlaying = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.isBuffering = false,
    this.isWatermarkVisible = true,
    this.isTampered = false,
    this.errorMessage,
  });

  PlayerState copyWith({
    bool? isPlaying,
    Duration? position,
    Duration? duration,
    bool? isBuffering,
    bool? isWatermarkVisible,
    bool? isTampered,
    String? errorMessage,
  }) {
    return PlayerState(
      isPlaying: isPlaying ?? this.isPlaying,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      isBuffering: isBuffering ?? this.isBuffering,
      isWatermarkVisible: isWatermarkVisible ?? this.isWatermarkVisible,
      isTampered: isTampered ?? this.isTampered,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class PlayerController extends StateNotifier<PlayerState> {
  final Ref ref;
  final Lesson lesson;
  VideoPlayerController? _videoController;
  Timer? _heartbeatTimer;
  int _accumulatedSeconds = 0;
  Duration _lastSyncedPosition = Duration.zero;

  VideoPlayerController? get videoController => _videoController;

  PlayerController(this.ref, this.lesson) : super(PlayerState()) {
    _initializePlayer();
  }

  @override
  void dispose() {
    _syncProgress(force: true);
    _heartbeatTimer?.cancel();
    _videoController?.removeListener(_onPlayerUpdate);
    _videoController?.dispose();
    super.dispose();
  }

  Future<void> _initializePlayer() async {
    if (lesson.hlsStoragePath == null) {
      state = state.copyWith(errorMessage: "Esta lição ainda não possui vídeo disponível.");
      return;
    }

    state = state.copyWith(isBuffering: true);

    final supabase = ref.read(supabaseClientProvider);
    final session = supabase.auth.currentSession;
    final token = session?.accessToken;

    if (token == null) {
      state = state.copyWith(
        isBuffering: false,
        errorMessage: "Usuário não autenticado no portal.",
      );
      return;
    }

    final String videoUrl;
    try {
      final dio = Dio();
      final url = "http://127.0.0.1:8000/api/courses/${lesson.courseId}/lessons/${lesson.id}/stream";
      final response = await dio.get(
        url,
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
          },
        ),
      );

      final responseData = response.data;
      if (responseData != null && responseData["status"] == "success") {
        videoUrl = responseData["data"]["hls_manifest_url"] as String;
      } else {
        throw Exception("Estrutura de resposta inválida do servidor.");
      }
    } catch (e) {
      String msg = "Erro ao autorizar a sessão de vídeo.";
      if (e is DioException && e.response?.statusCode == 403) {
        msg = e.response?.data?["detail"] ?? "Assinatura inativa ou inválida.";
      }
      state = state.copyWith(
        isBuffering: false,
        errorMessage: msg,
      );
      return;
    }

    _videoController = VideoPlayerController.networkUrl(Uri.parse(videoUrl));

    try {
      await _videoController!.initialize();
      
      final repo = ref.read(courseRepositoryProvider);
      final progress = await repo.fetchLessonProgress(lesson.id);
      
      if (progress != null && progress['last_position_seconds'] != null) {
        final startSecs = progress['last_position_seconds'] as int;
        _lastSyncedPosition = Duration(seconds: startSecs);
        await _videoController!.seekTo(_lastSyncedPosition);
      }

      state = PlayerState(
        isPlaying: _videoController!.value.isPlaying,
        position: _videoController!.value.position,
        duration: _videoController!.value.duration,
        isBuffering: false,
      );

      _videoController!.addListener(_onPlayerUpdate);
      _startHeartbeat();

    } catch (e) {
      state = state.copyWith(
        isBuffering: false,
        errorMessage: "Erro ao carregar o vídeo. Tente novamente mais tarde.",
      );
    }
  }

  void _onPlayerUpdate() {
    if (_videoController == null) return;
    
    final value = _videoController!.value;
    final currentPos = value.position;
    
    final diff = currentPos.inSeconds - state.position.inSeconds;
    if (value.isPlaying && diff > 0 && diff < 5) {
      _accumulatedSeconds += diff;
    }

    state = state.copyWith(
      isPlaying: value.isPlaying,
      position: currentPos,
      isBuffering: value.isBuffering,
    );
  }

  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_accumulatedSeconds >= 60) {
        _syncProgress();
      }
    });
  }

  Future<void> _syncProgress({bool force = false}) async {
    if (_videoController == null) return;
    
    if (_accumulatedSeconds > 0 || force) {
      final repo = ref.read(courseRepositoryProvider);
      final currentPosSec = _videoController!.value.position.inSeconds;
      final isCompleted = currentPosSec >= (_videoController!.value.duration.inSeconds * 0.9);
      
      try {
        await repo.updateLessonProgress(
          courseId: lesson.courseId,
          lessonId: lesson.id,
          watchedSeconds: currentPosSec,
          completed: isCompleted,
        );
        
        _accumulatedSeconds = 0;
        _lastSyncedPosition = Duration(seconds: currentPosSec);
      } catch (e) {
        debugPrint("Erro ao sincronizar progresso: $e");
      }
    }
  }

  void togglePlay() {
    if (_videoController == null) return;
    
    if (_videoController!.value.isPlaying) {
      _videoController!.pause();
      _syncProgress(force: true);
    } else {
      _videoController!.play();
    }
  }

  void triggerWatermarkTamperingDetected() {
    if (state.isTampered) return;
    
    state = state.copyWith(isTampered: true, isWatermarkVisible: false);
    _videoController?.pause();
    _syncProgress(force: true);
    
    ref.read(authNotifierProvider.notifier).signOut();
  }
}

// Provedor parametrizado por Lição
final playerControllerProvider = StateNotifierProvider.family<PlayerController, PlayerState, Lesson>((ref, lesson) {
  return PlayerController(ref, lesson);
});
