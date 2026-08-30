import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/providers/learning_repositories.dart';
import '../../../../app/providers/service_repositories.dart';
import '../../../../design_system/tokens/lawrence_theme.dart';
import '../../../../design_system/widgets/couture_progress_bar.dart';
import '../../../../design_system/widgets/state_widgets.dart';
import '../../../../core/offline/local_cache.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../dashboard/domain/entities/learning_resume_target.dart';
import '../../../feedbacks/presentation/providers/feedback_providers.dart';
import '../../../certificates/presentation/providers/certificate_providers.dart';
import '../../../courses/presentation/providers/course_detail_provider.dart';
import '../../../lesson_progress/domain/entities/lesson_progress_entity.dart';
import '../../../lesson_progress/presentation/controllers/lesson_progress_controller.dart';
import '../../../lessons/domain/entities/lesson_entity.dart';
import '../../../lessons/presentation/controllers/lessons_controller.dart';
import '../../../lessons/presentation/widgets/lesson_content_renderer.dart';
import '../controllers/lesson_navigation_presentation.dart';
import '../controllers/player_controller.dart';
import '../widgets/player_fullscreen_host.dart';
import '../widgets/stateless_player_view.dart';
import '../widgets/learning_workspace.dart';
import '../widgets/external_lesson_player.dart';

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
  bool _reviewRedirected = false;
  bool _certificateIssuing = false;
  bool _learnMoreMarkedRead = false;
  DateTime? _externalPlaybackStartedAt;

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
      _reviewRedirected = false;
      _certificateIssuing = false;
      _learnMoreMarkedRead = false;
      _externalPlaybackStartedAt = null;
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
      final watchedSeconds = player.watchedDuration.inSeconds
          .clamp(0, duration.inSeconds)
          .toInt();
      final reachedEnd =
          player.watchedDuration >= duration - const Duration(seconds: 1);
      final confirmedWatchedSeconds = reachedEnd
          ? duration.inSeconds
          : watchedSeconds;
      final percentage = (confirmedWatchedSeconds / duration.inSeconds * 100)
          .clamp(0.0, 100.0)
          .toDouble();
      await ref
          .read(lessonProgressControllerProvider.notifier)
          .updateProgress(
            courseId: widget.courseId,
            lessonId: widget.lessonId,
            watchedSeconds: confirmedWatchedSeconds,
            progressPercentage: percentage,
            completed: reachedEnd,
          );
      _lastSavedPosition = position;
      if (mounted) {
        ref.invalidate(lessonProgressProvider(_playerKey));
        ref.invalidate(courseProgressListProvider(widget.courseId));
        if (reachedEnd) await _checkCourseCompletion();
      }
    } finally {
      _saveInProgress = false;
    }
  }

  Future<void> _markLearnMoreRead(LessonEntity? lesson) async {
    if (lesson == null) return;
    final blocks = lesson.blocks.where((block) {
      final type = block['block_type'] ?? block['type'];
      return type == 'learn_more';
    });
    for (final block in blocks) {
      final blockId = block['id']?.toString();
      if (blockId == null || blockId.isEmpty) continue;
      await ref
          .read(courseCompletionRepositoryProvider)
          .completeLearnMore(
            courseId: widget.courseId,
            lessonId: widget.lessonId,
            blockId: blockId,
          );
    }
    await LocalCache.getBox(
      LocalCache.settingsBox,
    ).put('learn_more_seen:${widget.courseId}:${widget.lessonId}', true);
    if (mounted) {
      setState(() => _learnMoreMarkedRead = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Leitura complementar concluída.')),
      );
    }
    await _checkCourseCompletion();
  }

  Future<void> _checkCourseCompletion() async {
    if (!mounted || _reviewRedirected || _certificateIssuing) return;
    final completion = await ref
        .read(courseCompletionRepositoryProvider)
        .getCompletion(widget.courseId);
    ref.invalidate(courseCompletionProvider(widget.courseId));
    if (!completion.certificateEligible) return;
    _certificateIssuing = true;
    try {
      await ref
          .read(certificateRepositoryProvider)
          .generateCertificate(widget.courseId);
      ref.invalidate(certificatesListProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Curso concluído em 100%. Seu certificado já está disponível!',
          ),
        ),
      );
      if (completion.reviewRequired) {
        _reviewRedirected = true;
        context.go('/dashboard/courses/${widget.courseId}/review');
      }
    } finally {
      _certificateIssuing = false;
    }
  }

  Future<void> _openExternalVideo(Uri url) async {
    final opened = await launchUrl(url, mode: LaunchMode.externalApplication);
    if (opened) {
      _externalPlaybackStartedAt ??= DateTime.now();
    }
    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível abrir o vídeo.')),
      );
    }
  }

  Future<void> _completeExternalLesson(LessonEntity? lesson) async {
    final durationSeconds = lesson?.durationSeconds ?? 0;
    if (durationSeconds <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('A duração desta aula ainda não foi configurada.'),
        ),
      );
      return;
    }
    final startedAt = _externalPlaybackStartedAt;
    final requiredSeconds = (durationSeconds * .8).ceil();
    final elapsedSeconds = startedAt == null
        ? 0
        : DateTime.now().difference(startedAt).inSeconds;
    if (elapsedSeconds < requiredSeconds) {
      final remainingMinutes = ((requiredSeconds - elapsedSeconds) / 60)
          .ceil()
          .clamp(1, 9999);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            startedAt == null
                ? 'Abra o vídeo antes de registrar a conclusão.'
                : 'Continue assistindo. Faltam cerca de $remainingMinutes min para liberar a conclusão.',
          ),
        ),
      );
      return;
    }
    await ref
        .read(lessonProgressControllerProvider.notifier)
        .updateProgress(
          courseId: widget.courseId,
          lessonId: widget.lessonId,
          watchedSeconds: durationSeconds,
          progressPercentage: 100.0,
          completed: true,
        );
    if (!mounted) return;
    ref.invalidate(lessonProgressProvider(_playerKey));
    ref.invalidate(courseProgressListProvider(widget.courseId));
    await _checkCourseCompletion();
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
    ref.listen<PlayerStateData>(playerControllerProvider(_playerKey), (
      previous,
      next,
    ) {
      if (previous?.status != PlayerStatus.completed &&
          next.status == PlayerStatus.completed) {
        unawaited(_saveProgress(force: true));
      }
    });
    final lesson = ref.watch(lessonDetailProvider(_playerKey));
    final courseLessons = ref.watch(courseLessonsProvider(widget.courseId));
    final course = ref.watch(courseDetailByIdProvider(widget.courseId));
    final localProgress = ref.watch(lessonProgressProvider(_playerKey));
    final courseProgress = ref.watch(
      courseProgressListProvider(widget.courseId),
    );
    final completedLessonIds = {
      for (final item
          in courseProgress.valueOrNull ?? const <LessonProgressEntity>[])
        if (item.completed) item.lessonId,
      if (localProgress.valueOrNull?.completed == true) widget.lessonId,
    };
    final visibleLessons = courseLessons.valueOrNull ?? const <LessonEntity>[];
    final settings = LocalCache.getBox(LocalCache.settingsBox);
    final seenLearnMoreLessonIds = {
      for (final item in visibleLessons)
        if (settings.get(
              'learn_more_seen:${widget.courseId}:${item.id}',
              defaultValue: false,
            ) ==
            true)
          item.id,
    };
    final completedActivityBlockIds = {
      for (final item in visibleLessons)
        for (final block in item.blocks.map(LessonContentBlock.fromJson))
          if (block.type == 'activity' && _activityBlockIsCompleted(block))
            block.id,
    };

    return PlayerFullscreenHost(
      playerBuilder: (context, isFullscreen, toggleFullscreen) =>
          player.externalUrl != null
          ? ExternalLessonPlayer(
              provider: player.externalProvider ?? 'plataforma de vídeo',
              url: player.externalUrl!,
              completed: localProgress.valueOrNull?.completed == true,
              onOpenExternal: () => _openExternalVideo(player.externalUrl!),
              onComplete: () => _completeExternalLesson(lesson.valueOrNull),
              onPlaybackStarted: () {
                _externalPlaybackStartedAt ??= DateTime.now();
              },
            )
          : StatelessPlayerView(
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
              onRetry: () => ref
                  .read(playerControllerProvider(_playerKey).notifier)
                  .retry(),
              onManageAccess: () => context.go('/dashboard/subscriptions'),
              onFullscreen: toggleFullscreen,
            ),
      pageBuilder: (context, embeddedPlayer) => KeyboardListener(
        focusNode: _keyboardFocusNode,
        autofocus: true,
        onKeyEvent: _handleKeyEvent,
        child: LearningWorkspace(
          courseTitle: course.valueOrNull?.title ?? 'Curso',
          title: lesson.valueOrNull?.title ?? 'Aula',
          lesson: lesson.valueOrNull,
          lessons: visibleLessons,
          navigation: resolveLessonNavigation(
            courseLessons.valueOrNull ?? const [],
            courseId: widget.courseId,
            lessonId: widget.lessonId,
          ),
          progressPercentage:
              (localProgress.valueOrNull?.progressPercentage ?? 0)
                  .clamp(0, 100)
                  .round(),
          completedLessonIds: completedLessonIds,
          completedActivityBlockIds: completedActivityBlockIds,
          seenLearnMoreLessonIds: seenLearnMoreLessonIds,
          learnMoreCompleted:
              _learnMoreMarkedRead ||
              seenLearnMoreLessonIds.contains(widget.lessonId),
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
          onCompleteLearnMore: () =>
              unawaited(_markLearnMoreRead(lesson.valueOrNull)),
          onOpenActivities: () async {
            await _saveProgress(force: true);
            if (!context.mounted) return;
            context.go('/dashboard/activities');
          },
          onOpenActivity: (taskId) async {
            await _saveProgress(force: true);
            if (!context.mounted) return;
            context.go('/dashboard/activities/$taskId');
          },
          player: embeddedPlayer,
        ),
      ),
    );
  }
}

bool _activityBlockIsCompleted(LessonContentBlock block) {
  final completed = block.content['completed'];
  if (completed == true) return true;
  final status = block.content['status']?.toString().toLowerCase().trim();
  return const {
    'completed',
    'submitted',
    'graded',
    'approved',
  }.contains(status);
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
                CoutureProgressBar(
                  value: percentage / 100,
                  height: 8,
                  semanticLabel: 'Progresso salvo da aula',
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
