import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../design_system/tokens/lawrence_theme.dart';
import '../../../../design_system/widgets/state_widgets.dart';
import '../../../../design_system/widgets/student_page_scaffold.dart';
import '../../../lesson_progress/domain/entities/lesson_progress_entity.dart';
import '../../../lesson_progress/presentation/controllers/lesson_progress_controller.dart';
import '../../../lessons/domain/entities/lesson_entity.dart';
import '../../../lessons/presentation/controllers/lessons_controller.dart';
import '../controllers/lesson_navigation_presentation.dart';
import '../controllers/player_controller.dart';
import '../widgets/stateless_player_view.dart';

class SecurePlayerPage extends ConsumerStatefulWidget {
  final String courseId;
  final String lessonId;

  const SecurePlayerPage({
    super.key,
    required this.courseId,
    required this.lessonId,
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

  ({String courseId, String lessonId}) get _playerKey => (
    courseId: widget.courseId,
    lessonId: widget.lessonId,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
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
    }
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
    final controller = ref.read(playerControllerProvider(_playerKey)).controller;
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

    return KeyboardListener(
      focusNode: _keyboardFocusNode,
      autofocus: true,
      onKeyEvent: _handleKeyEvent,
      child: StudentPageScaffold(
        title: lesson.valueOrNull?.title ?? 'Aula',
        subtitle: 'Ambiente seguro de aprendizagem',
        leading: IconButton(
          tooltip: 'Voltar ao curso',
          onPressed: () async {
            await _saveProgress(force: true);
            if (!context.mounted) return;
            context.go('/dashboard/courses/${widget.courseId}');
          },
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: LawrenceColors.surfaceBlack,
                  borderRadius: BorderRadius.circular(LawrenceRadii.featured),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(LawrenceRadii.featured),
                  child: StatelessPlayerView(
                    state: player,
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
                    onRetry: () => ref
                        .read(playerControllerProvider(_playerKey).notifier)
                        .retry(),
                    onManageAccess: () =>
                        context.go('/dashboard/subscriptions'),
                  ),
                ),
              ),
            ),
            const SizedBox(height: LawrenceSpacing.lg),
            _LessonDetails(
              lesson: lesson,
              localProgress: localProgress.valueOrNull,
              onRetry: () => ref.invalidate(lessonDetailProvider(_playerKey)),
            ),
            const SizedBox(height: LawrenceSpacing.lg),
            courseLessons.when(
              loading: () => const SizedBox.shrink(),
              error: (_, _) => const SizedBox.shrink(),
              data: (items) {
                final navigation = resolveLessonNavigation(
                  items,
                  courseId: widget.courseId,
                  lessonId: widget.lessonId,
                );
                return _LessonNavigationBar(
                  navigation: navigation,
                  onOpenLesson: _openLesson,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

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
          message: 'O vídeo pode continuar disponível. Tente carregar novamente.',
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
