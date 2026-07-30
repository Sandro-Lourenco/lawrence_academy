import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/providers/learning_repositories.dart';
import '../../../../design_system/tokens/lawrence_theme.dart';
import '../../../../design_system/widgets/state_widgets.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../dashboard/domain/entities/learning_resume_target.dart';
import '../../../lesson_progress/domain/entities/lesson_progress_entity.dart';
import '../../../lesson_progress/presentation/controllers/lesson_progress_controller.dart';
import '../../../lessons/domain/entities/lesson_entity.dart';
import '../../../lessons/presentation/controllers/lessons_controller.dart';
import '../controllers/lesson_navigation_presentation.dart';
import '../controllers/player_controller.dart';
import '../widgets/player_fullscreen_host.dart';
import '../widgets/stateless_player_view.dart';
import '../widgets/learning_workspace.dart';

class SecurePlayerPage extends ConsumerStatefulWidget {
  final String courseId;
  final String lessonId;
  final LearningResumeView initialView;

  const SecurePlayerPage({
    super.key,
    required this.courseId,
    required this.lessonId,
    this.initialView = LearningResumeView.watch,
  });

  @override
  ConsumerState<SecurePlayerPage> createState() => _SecurePlayerPageState();
}

class _SecurePlayerPageState extends ConsumerState<SecurePlayerPage>
    with WidgetsBindingObserver {
  final FocusNode _keyboardFocusNode = FocusNode(debugLabel: 'lesson-player');
  Timer? _heartbeatTimer;
  Duration _lastSavedPosition = Duration.zero;
  bool _saveInProgress = false;

  ({String courseId, String lessonId}) get _playerKey =>
      (courseId: widget.courseId, lessonId: widget.lessonId);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_saveResumeTarget(widget.initialView));
    });
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      unawaited(_saveProgress());
    });
  }

  @override
  void didUpdateWidget(covariant SecurePlayerPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.lessonId != widget.lessonId ||
        oldWidget.courseId != widget.courseId) {
      _lastSavedPosition = Duration.zero;
      _saveInProgress = false;
      unawaited(_saveResumeTarget(widget.initialView));
    }
  }

  Future<void> _saveResumeTarget(LearningResumeView view) async {
    final studentId = ref.read(authNotifierProvider).user?.id;
    if (studentId == null) return;
    await ref
        .read(learningResumeRepositoryProvider)
        .save(
          LearningResumeTarget(
            studentId: studentId,
            courseId: widget.courseId,
            lessonId: widget.lessonId,
            view: view,
            updatedAt: DateTime.now().toUtc(),
          ),
        );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      unawaited(_saveProgress(force: true));
    }
  }

  Future<void> _saveProgress({bool force = false}) async {
    if (_saveInProgress) return;
    final player = ref.read(playerControllerProvider(_playerKey));
    final controller = player.controller;
    if (controller == null || !controller.value.isInitialized) return;
    final position = controller.value.position;
    final duration = controller.value.duration;
    if (duration <= Duration.zero) return;
    if (!force && position == _lastSavedPosition) return;

    _saveInProgress = true;
    try {
      final watchedSeconds = position.inSeconds
          .clamp(0, duration.inSeconds)
          .toInt();
      final percentage = (watchedSeconds / duration.inSeconds * 100)
          .clamp(0.0, 100.0)
          .toDouble();
      await ref
          .read(lessonProgressControllerProvider.notifier)
          .updateProgress(
            courseId: widget.courseId,
            lessonId: widget.lessonId,
            watchedSeconds: watchedSeconds,
            progressPercentage: percentage,
            completed: percentage >= 90,
          );
      _lastSavedPosition = position;
      if (mounted) {
        ref.invalidate(lessonProgressProvider(_playerKey));
        ref.invalidate(courseProgressListProvider(widget.courseId));
      }
    } finally {
      _saveInProgress = false;
    }
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) return;
    final notifier = ref.read(playerControllerProvider(_playerKey).notifier);
    final controller = ref
        .read(playerControllerProvider(_playerKey))
        .controller;
    if (controller == null || !controller.value.isInitialized) return;

    if (event.logicalKey == LogicalKeyboardKey.space) {
      if (controller.value.isPlaying) {
        notifier.pause();
        unawaited(_saveProgress(force: true));
      } else {
        notifier.play();
      }
    } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
      final target = controller.value.position + const Duration(seconds: 10);
      notifier.seekTo(
        target > controller.value.duration ? controller.value.duration : target,
      );
    } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      final target = controller.value.position - const Duration(seconds: 10);
      notifier.seekTo(target < Duration.zero ? Duration.zero : target);
    }
  }

  Future<void> _openLesson(String lessonId) async {
    await _saveProgress(force: true);
    final studentId = ref.read(authNotifierProvider).user?.id;
    if (studentId != null) {
      await ref
          .read(learningResumeRepositoryProvider)
          .save(
            LearningResumeTarget(
              studentId: studentId,
              courseId: widget.courseId,
              lessonId: lessonId,
              view: LearningResumeView.watch,
              updatedAt: DateTime.now().toUtc(),
            ),
          );
    }
    if (!mounted) return;
    context.go('/dashboard/courses/${widget.courseId}/lessons/$lessonId');
  }

  @override
  void dispose() {
    _heartbeatTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    _keyboardFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final player = ref.watch(playerControllerProvider(_playerKey));
    final lesson = ref.watch(lessonDetailProvider(_playerKey));
    final courseLessons = ref.watch(courseLessonsProvider(widget.courseId));
    final localProgress = ref.watch(lessonProgressProvider(_playerKey));

    return PlayerFullscreenHost(
      playerBuilder: (context, isFullscreen, toggleFullscreen) =>
          StatelessPlayerView(
            state: player,
            isFullscreen: isFullscreen,
            onPlayPause: () {
              final notifier = ref.read(
                playerControllerProvider(_playerKey).notifier,
              );
              if (player.controller?.value.isPlaying ?? false) {
                notifier.pause();
                unawaited(_saveProgress(force: true));
              } else {
                notifier.play();
              }
            },
            onReplay: () {
              final notifier = ref.read(
                playerControllerProvider(_playerKey).notifier,
              );
              notifier.seekTo(Duration.zero);
              notifier.play();
            },
            onRetry: () =>
                ref.read(playerControllerProvider(_playerKey).notifier).retry(),
            onManageAccess: () => context.go('/dashboard/subscriptions'),
            onFullscreen: toggleFullscreen,
          ),
      pageBuilder: (context, embeddedPlayer) => KeyboardListener(
        focusNode: _keyboardFocusNode,
        autofocus: true,
        onKeyEvent: _handleKeyEvent,
        child: LearningWorkspace(
          title: lesson.valueOrNull?.title ?? 'Aula',
          lesson: lesson.valueOrNull,
          lessons: courseLessons.valueOrNull ?? const [],
          navigation: resolveLessonNavigation(
            courseLessons.valueOrNull ?? const [],
            courseId: widget.courseId,
            lessonId: widget.lessonId,
          ),
          progressPercentage:
              (localProgress.valueOrNull?.progressPercentage ?? 0)
                  .clamp(0, 100)
                  .round(),
          onBack: () async {
            await _saveProgress(force: true);
            if (!context.mounted) return;
            context.go('/dashboard/courses/${widget.courseId}');
          },
          onOpenLesson: _openLesson,
          initialMode: switch (widget.initialView) {
            LearningResumeView.watch => LearningWorkspaceMode.watch,
            LearningResumeView.activities => LearningWorkspaceMode.activities,
            LearningResumeView.learnMore => LearningWorkspaceMode.learnMore,
          },
          onModeChanged: (mode) => unawaited(
            _saveResumeTarget(switch (mode) {
              LearningWorkspaceMode.watch => LearningResumeView.watch,
              LearningWorkspaceMode.activities => LearningResumeView.activities,
              LearningWorkspaceMode.learnMore => LearningResumeView.learnMore,
            }),
          ),
          onOpenActivities: () async {
            await _saveProgress(force: true);
            if (!context.mounted) return;
            context.go('/dashboard/activities');
          },
          player: embeddedPlayer,
        ),
      ),
    );
  }
}

// TODO(learning-workspace): remove after the legacy lesson layout is retired.
// ignore: unused_element
class _LessonDetails extends StatelessWidget {
  final AsyncValue<LessonEntity> lesson;
  final LessonProgressEntity? localProgress;
  final VoidCallback onRetry;

  const _LessonDetails({
    required this.lesson,
    required this.localProgress,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return lesson.when(
      loading: () => const SizedBox(
        height: 220,
        child: AppLoadingState(message: 'Carregando detalhes da aula'),
      ),
      error: (_, _) => SizedBox(
        height: 260,
        child: AppErrorState(
          title: 'Detalhes da aula indisponíveis',
          message:
              'O vídeo pode continuar disponível. Tente carregar novamente.',
          onRetry: onRetry,
        ),
      ),
      data: (value) {
        final progress = localProgress?.progressPercentage;
        final percentage = (progress ?? 0).clamp(0.0, 100.0).round();
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(LawrenceSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        value.title,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ),
                    Text(
                      '$percentage%',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
                const SizedBox(height: LawrenceSpacing.sm),
                LinearProgressIndicator(
                  value: percentage / 100,
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(LawrenceRadii.pill),
                  semanticsLabel: 'Progresso salvo da aula',
                  semanticsValue: '$percentage%',
                ),
                const SizedBox(height: LawrenceSpacing.lg),
                Text(
                  value.description?.trim().isNotEmpty ?? false
                      ? value.description!.trim()
                      : 'Nenhuma descrição foi publicada para esta aula.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// TODO(learning-workspace): remove after the legacy lesson layout is retired.
// ignore: unused_element
class _LessonNavigationBar extends StatelessWidget {
  final LessonNavigation navigation;
  final Future<void> Function(String lessonId) onOpenLesson;

  const _LessonNavigationBar({
    required this.navigation,
    required this.onOpenLesson,
  });

  @override
  Widget build(BuildContext context) {
    if (navigation.previous == null && navigation.next == null) {
      return const SizedBox.shrink();
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(LawrenceSpacing.md),
        child: Wrap(
          alignment: WrapAlignment.spaceBetween,
          runSpacing: LawrenceSpacing.sm,
          spacing: LawrenceSpacing.sm,
          children: [
            if (navigation.previous case final previous?)
              OutlinedButton.icon(
                onPressed: () => onOpenLesson(previous.id),
                icon: const Icon(Icons.arrow_back_rounded),
                label: const Text('Aula anterior'),
              ),
            if (navigation.next case final next?)
              FilledButton.icon(
                onPressed: () => onOpenLesson(next.id),
                iconAlignment: IconAlignment.end,
                icon: const Icon(Icons.arrow_forward_rounded),
                label: const Text('Próxima aula'),
              ),
          ],
        ),
      ),
    );
  }
}
