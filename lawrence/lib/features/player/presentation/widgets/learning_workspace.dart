import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme_controller.dart';
import '../../../../design_system/tokens/lawrence_theme.dart';
import '../../../../design_system/widgets/couture_progress_bar.dart';
import '../../../../design_system/widgets/couture_primary_button.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../profile/presentation/widgets/student_avatar.dart';
import '../../../lessons/domain/entities/lesson_entity.dart';
import '../../../lessons/presentation/widgets/lesson_content_renderer.dart';
import '../controllers/lesson_navigation_presentation.dart';

const _ink = LawrenceColors.plum;
const _accent = LawrenceColors.actionPrimary;
Color _learningCanvas(BuildContext context) =>
    Theme.of(context).scaffoldBackgroundColor;
Color _learningSurface(BuildContext context) =>
    Theme.of(context).colorScheme.surface;
Color _learningSurfaceRaised(BuildContext context) =>
    Theme.of(context).colorScheme.surfaceContainerHigh;
Color _learningText(BuildContext context) =>
    Theme.of(context).colorScheme.onSurface;
Color _learningMuted(BuildContext context) =>
    Theme.of(context).colorScheme.onSurfaceVariant;

enum LearningWorkspaceMode { watch, activities, learnMore }

class LearningWorkspace extends StatefulWidget {
  final String courseTitle;
  final String title;
  final LessonEntity? lesson;
  final List<LessonEntity> lessons;
  final LessonNavigation navigation;
  final int progressPercentage;
  final Set<String> completedLessonIds;
  final Set<String> completedActivityBlockIds;
  final Set<String> seenLearnMoreLessonIds;
  final Widget player;
  final VoidCallback onBack;
  final Future<void> Function(String lessonId) onOpenLesson;
  final VoidCallback onOpenActivities;
  final ValueChanged<String>? onOpenActivity;
  final VoidCallback? onCompleteLearnMore;
  final bool learnMoreCompleted;
  final LearningWorkspaceMode initialMode;
  final ValueChanged<LearningWorkspaceMode>? onModeChanged;

  const LearningWorkspace({
    super.key,
    this.courseTitle = 'Curso',
    required this.title,
    required this.lesson,
    required this.lessons,
    required this.navigation,
    required this.progressPercentage,
    this.completedLessonIds = const {},
    this.completedActivityBlockIds = const {},
    this.seenLearnMoreLessonIds = const {},
    required this.player,
    required this.onBack,
    required this.onOpenLesson,
    required this.onOpenActivities,
    this.onOpenActivity,
    this.onCompleteLearnMore,
    this.learnMoreCompleted = false,
    this.initialMode = LearningWorkspaceMode.watch,
    this.onModeChanged,
  });

  @override
  State<LearningWorkspace> createState() => _LearningWorkspaceState();
}

class _LearningWorkspaceState extends State<LearningWorkspace> {
  late LearningWorkspaceMode _mode;
  bool _curriculumVisible = true;
  int _curriculumTab = 0;

  @override
  void initState() {
    super.initState();
    _mode = widget.initialMode;
  }

  @override
  void didUpdateWidget(covariant LearningWorkspace oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialMode != widget.initialMode) {
      _mode = widget.initialMode;
    }
  }

  void _selectMode(LearningWorkspaceMode mode) {
    if (_mode == mode) return;
    setState(() => _mode = mode);
    widget.onModeChanged?.call(mode);
  }

  List<LearningWorkspaceMode> get _lessonSequence {
    final modes = <LearningWorkspaceMode>[LearningWorkspaceMode.watch];
    if (_blocksOfType(widget.lesson, const {'activity'}).isNotEmpty) {
      modes.add(LearningWorkspaceMode.activities);
    }
    if (_blocksOfType(widget.lesson, _learnMoreTypes).isNotEmpty) {
      modes.add(LearningWorkspaceMode.learnMore);
    }
    return modes;
  }

  bool get _canGoBack =>
      _lessonSequence.indexOf(_mode) > 0 || widget.navigation.previous != null;

  bool get _canAdvance =>
      _lessonSequence.indexOf(_mode) < _lessonSequence.length - 1 ||
      widget.navigation.next != null;

  Future<void> _goBack() async {
    final index = _lessonSequence.indexOf(_mode);
    if (index > 0) {
      _selectMode(_lessonSequence[index - 1]);
    } else if (widget.navigation.previous case final previous?) {
      await widget.onOpenLesson(previous.id);
    }
  }

  Future<void> _advance() async {
    final index = _lessonSequence.indexOf(_mode);
    if (index < _lessonSequence.length - 1) {
      _selectMode(_lessonSequence[index + 1]);
    } else if (widget.navigation.next case final next?) {
      await widget.onOpenLesson(next.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final desktop = width >= LawrenceBreakpoints.desktop;
    return Scaffold(
      backgroundColor: _learningCanvas(context),
      body: SafeArea(
        child: Column(
          children: [
            _LearningHeader(
              courseTitle: widget.courseTitle,
              onBack: widget.onBack,
            ),
            Expanded(
              child: desktop
                  ? Stack(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: Column(
                                children: [
                                  Expanded(
                                    child: _LearningBody(
                                      mode: _mode,
                                      lesson: widget.lesson,
                                      player: widget.player,
                                      onOpenActivities: widget.onOpenActivities,
                                      onOpenActivity: widget.onOpenActivity,
                                      onCompleteLearnMore:
                                          widget.onCompleteLearnMore,
                                      learnMoreCompleted:
                                          widget.learnMoreCompleted,
                                      onShowTranscript: () => setState(() {
                                        _curriculumVisible = true;
                                        _curriculumTab = 1;
                                      }),
                                      onPrevious: _canGoBack ? _goBack : null,
                                      onNext: _canAdvance ? _advance : null,
                                      nextLabel: _nextLabel,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (_curriculumVisible)
                              SizedBox(
                                width: 410,
                                child: _CurriculumPanel(
                                  activeLesson: widget.lesson,
                                  activeMode: _mode,
                                  lessons: widget.lessons,
                                  progressPercentage: widget.progressPercentage,
                                  completedLessonIds: widget.completedLessonIds,
                                  completedActivityBlockIds:
                                      widget.completedActivityBlockIds,
                                  seenLearnMoreLessonIds:
                                      widget.seenLearnMoreLessonIds,
                                  selectedTab: _curriculumTab,
                                  onTabChanged: (tab) =>
                                      setState(() => _curriculumTab = tab),
                                  onOpenLesson: widget.onOpenLesson,
                                  onSelectMode: _selectMode,
                                ),
                              ),
                          ],
                        ),
                        Positioned(
                          right: _curriculumVisible ? 386 : 12,
                          top: 42,
                          child: IconButton.filled(
                            tooltip: _curriculumVisible
                                ? 'Ocultar conteúdo do curso'
                                : 'Mostrar conteúdo do curso',
                            style: IconButton.styleFrom(
                              minimumSize: const Size(52, 52),
                              backgroundColor: LawrenceColors.surfaceSubtle,
                              foregroundColor: _ink,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () => setState(
                              () => _curriculumVisible = !_curriculumVisible,
                            ),
                            icon: Icon(
                              _curriculumVisible
                                  ? Icons.keyboard_tab_rounded
                                  : Icons.menu_open_rounded,
                            ),
                          ),
                        ),
                      ],
                    )
                  : _MobileLearningBody(
                      mode: _mode,
                      onModeChanged: _selectMode,
                      lesson: widget.lesson,
                      player: widget.player,
                      onOpenActivities: widget.onOpenActivities,
                      onOpenActivity: widget.onOpenActivity,
                      onCompleteLearnMore: widget.onCompleteLearnMore,
                      learnMoreCompleted: widget.learnMoreCompleted,
                      onShowTranscript: _showTranscript,
                      onPrevious: _canGoBack ? _goBack : null,
                      onNext: _canAdvance ? _advance : null,
                      nextLabel: _nextLabel,
                    ),
            ),
          ],
        ),
      ),
    );
  }

  String get _nextLabel {
    final index = _lessonSequence.indexOf(_mode);
    if (index < _lessonSequence.length - 1) {
      return switch (_lessonSequence[index + 1]) {
        LearningWorkspaceMode.activities => 'Ir para atividade',
        LearningWorkspaceMode.learnMore => 'Ir para Saber mais',
        LearningWorkspaceMode.watch => 'Avançar',
      };
    }
    return widget.navigation.next == null ? 'Fim da aula' : 'Próxima aula';
  }

  void _showTranscript() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (context) => FractionallySizedBox(
        heightFactor: .84,
        child: _TranscriptPanel(lesson: widget.lesson),
      ),
    );
  }
}

class _LearningHeader extends ConsumerWidget {
  final String courseTitle;
  final VoidCallback onBack;

  const _LearningHeader({required this.courseTitle, required this.onBack});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final compact =
        MediaQuery.sizeOf(context).width < LawrenceBreakpoints.tablet;
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          constraints: BoxConstraints(minHeight: compact ? 72 : 88),
          padding: EdgeInsets.symmetric(horizontal: compact ? 12 : 24),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface.withValues(alpha: .82),
            border: Border(
              bottom: BorderSide(
                color: Theme.of(
                  context,
                ).colorScheme.outlineVariant.withValues(alpha: .24),
              ),
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x12000000),
                blurRadius: 12,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              IconButton(
                tooltip: 'Voltar ao curso',
                onPressed: onBack,
                icon: Icon(
                  Icons.arrow_back_rounded,
                  color: _learningText(context),
                ),
              ),
              const SizedBox(width: 8),
              if (!compact) const _LearningBrand(),
              if (!compact) const SizedBox(width: 28),
              Expanded(
                child: Text(
                  courseTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _learningText(context),
                    fontFamily: 'Georgia',
                    fontSize: compact ? 17 : 20,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              PopupMenuButton<String>(
                tooltip: 'Abrir menu do perfil',
                offset: const Offset(0, 54),
                onSelected: (value) async {
                  if (value == 'profile') {
                    context.go('/dashboard/profile');
                  }
                  if (value == 'light') {
                    ref
                        .read(themeModeProvider.notifier)
                        .setMode(ThemeMode.light);
                  }
                  if (value == 'dark') {
                    ref
                        .read(themeModeProvider.notifier)
                        .setMode(ThemeMode.dark);
                  }
                  if (value == 'logout') {
                    await ref.read(authNotifierProvider.notifier).signOut();
                    if (context.mounted) context.go('/login');
                  }
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(
                    value: 'profile',
                    child: ListTile(
                      leading: StudentAvatar(radius: 18),
                      title: Text('Minha conta'),
                    ),
                  ),
                  PopupMenuItem(
                    value: 'light',
                    child: ListTile(
                      leading: Icon(Icons.light_mode_outlined),
                      title: Text('Tema claro'),
                    ),
                  ),
                  PopupMenuItem(
                    value: 'dark',
                    child: ListTile(
                      leading: Icon(Icons.dark_mode_outlined),
                      title: Text('Tema escuro'),
                    ),
                  ),
                  PopupMenuDivider(),
                  PopupMenuItem(
                    value: 'logout',
                    child: ListTile(
                      leading: Icon(Icons.logout_rounded),
                      title: Text('Sair'),
                    ),
                  ),
                ],
                child: const StudentAvatar(radius: 22),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LearningBrand extends StatelessWidget {
  const _LearningBrand();

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final logoColor = _learningText(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'LAWRENCE',
          style: TextStyle(
            color: logoColor,
            fontFamily: 'Georgia',
            fontSize: 15,
            letterSpacing: 1.8,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'ACADEMY',
          style: TextStyle(
            color: logoColor,
            fontSize: 7,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }
}

class _LearningBody extends StatelessWidget {
  final LearningWorkspaceMode mode;
  final LessonEntity? lesson;
  final Widget player;
  final VoidCallback onOpenActivities;
  final ValueChanged<String>? onOpenActivity;
  final VoidCallback? onCompleteLearnMore;
  final bool learnMoreCompleted;
  final VoidCallback onShowTranscript;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final String nextLabel;

  const _LearningBody({
    required this.mode,
    required this.lesson,
    required this.player,
    required this.onOpenActivities,
    required this.onOpenActivity,
    required this.onCompleteLearnMore,
    required this.learnMoreCompleted,
    required this.onShowTranscript,
    required this.onPrevious,
    required this.onNext,
    required this.nextLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: AnimatedSwitcher(
            duration: MediaQuery.disableAnimationsOf(context)
                ? Duration.zero
                : const Duration(milliseconds: 280),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            child: switch (mode) {
              LearningWorkspaceMode.watch => _WatchSurface(
                key: const ValueKey('watch'),
                lesson: lesson,
                player: player,
              ),
              LearningWorkspaceMode.activities => _ActivitySurface(
                key: const ValueKey('activities'),
                lesson: lesson,
                onOpenActivities: onOpenActivities,
                onOpenActivity: onOpenActivity,
              ),
              LearningWorkspaceMode.learnMore => _LearnMoreSurface(
                key: const ValueKey('learn-more'),
                lesson: lesson,
                onComplete: onCompleteLearnMore,
                completed: learnMoreCompleted,
              ),
            },
          ),
        ),
        _LearningBottomActions(
          onPrevious: onPrevious,
          onTranscript: onShowTranscript,
          onNext: onNext,
          nextLabel: nextLabel,
        ),
      ],
    );
  }
}

class _LearningBottomActions extends StatelessWidget {
  final VoidCallback? onPrevious;
  final VoidCallback onTranscript;
  final VoidCallback? onNext;
  final String nextLabel;

  const _LearningBottomActions({
    required this.onPrevious,
    required this.onTranscript,
    required this.onNext,
    required this.nextLabel,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface.withValues(alpha: .88),
          border: Border(
            top: BorderSide(
              color: Theme.of(
                context,
              ).colorScheme.outlineVariant.withValues(alpha: .28),
            ),
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x10000000),
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: Wrap(
          alignment: WrapAlignment.center,
          spacing: 12,
          runSpacing: 8,
          children: [
            OutlinedButton.icon(
              onPressed: onPrevious,
              style: OutlinedButton.styleFrom(
                foregroundColor: _learningText(context),
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.surfaceContainerLow.withValues(alpha: .72),
                side: BorderSide(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: .24),
                ),
              ),
              icon: const Icon(Icons.arrow_back_rounded),
              label: const Text('Anterior'),
            ),
            OutlinedButton.icon(
              onPressed: onTranscript,
              style: OutlinedButton.styleFrom(
                foregroundColor: _learningText(context),
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.surfaceContainerLow.withValues(alpha: .72),
                side: BorderSide(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: .24),
                ),
              ),
              icon: const Icon(Icons.description_outlined),
              label: const Text('Transcrição'),
            ),
            CouturePrimaryButton(
              label: nextLabel,
              icon: Icons.arrow_forward_rounded,
              onPressed: onNext,
            ),
          ],
        ),
      ),
    );
  }
}

class _WatchSurface extends StatelessWidget {
  final LessonEntity? lesson;
  final Widget player;

  const _WatchSurface({super.key, required this.lesson, required this.player});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final naturalHeight = constraints.maxWidth * 9 / 16;
        final maximumVideoHeight = naturalHeight < 160 ? 160.0 : naturalHeight;
        final availableForVideo = (constraints.maxHeight - 138).clamp(
          160.0,
          maximumVideoHeight,
        );
        return SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: availableForVideo,
                child: DecoratedBox(
                  decoration: const BoxDecoration(color: Colors.black),
                  child: player,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(32, 22, 32, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'AULA ATUAL',
                            style: TextStyle(
                              color: LawrenceColors.actionOnDark,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.6,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            lesson?.title ?? 'Carregando aula',
                            style: TextStyle(
                              color: _learningText(context),
                              fontFamily: 'Georgia',
                              fontSize: 36,
                              height: 1.08,
                            ),
                          ),
                          if (lesson?.description?.trim().isNotEmpty ==
                              true) ...[
                            const SizedBox(height: 14),
                            Text(
                              lesson!.description!.trim(),
                              style: TextStyle(
                                color: _learningMuted(context),
                                fontSize: 16,
                                height: 1.55,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ActivitySurface extends StatelessWidget {
  final LessonEntity? lesson;
  final VoidCallback onOpenActivities;
  final ValueChanged<String>? onOpenActivity;

  const _ActivitySurface({
    super.key,
    required this.lesson,
    required this.onOpenActivities,
    required this.onOpenActivity,
  });

  @override
  Widget build(BuildContext context) {
    final blocks = _blocksOfType(lesson, const {'activity'});
    return _ReadingSurface(
      eyebrow: 'PRÁTICA GUIADA',
      title: 'Transforme compreensão em gesto.',
      intro:
          'Resolver uma atividade logo após aprender melhora a recuperação da memória e revela o que precisa ser revisto.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (blocks.isEmpty)
            const _EmptyLearningCard(
              icon: Icons.draw_outlined,
              title: 'Nenhuma atividade vinculada a esta aula',
              message:
                  'Você ainda pode acessar projetos, exercícios e entregas do curso na central de atividades.',
            )
          else ...[
            for (final block in blocks)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(LawrenceSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        block.content['question']
                                    ?.toString()
                                    .trim()
                                    .isNotEmpty ==
                                true
                            ? block.content['question'].toString().trim()
                            : 'Atividade vinculada à aula',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: LawrenceSpacing.sm),
                      const Text(
                        'Abra a atividade para responder. A tentativa, a correção e o limite de envios são validados com segurança no servidor.',
                      ),
                      if (block.content['task_id']?.toString().isNotEmpty ==
                          true) ...[
                        const SizedBox(height: LawrenceSpacing.md),
                        FilledButton.icon(
                          onPressed: onOpenActivity == null
                              ? null
                              : () => onOpenActivity!(
                                  block.content['task_id'].toString(),
                                ),
                          icon: const Icon(Icons.assignment_turned_in_outlined),
                          label: const Text('Responder atividade'),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
          ],
          const SizedBox(height: 24),
          Align(
            alignment: Alignment.centerLeft,
            child: CouturePrimaryButton(
              label: 'ABRIR MINHAS ATIVIDADES',
              icon: Icons.arrow_outward,
              onPressed: onOpenActivities,
            ),
          ),
        ],
      ),
    );
  }
}

class _LearnMoreSurface extends StatelessWidget {
  final LessonEntity? lesson;
  final VoidCallback? onComplete;
  final bool completed;

  const _LearnMoreSurface({
    super.key,
    required this.lesson,
    required this.onComplete,
    required this.completed,
  });

  @override
  Widget build(BuildContext context) {
    final blocks = _blocksOfType(lesson, const {
      'heading',
      'text',
      'notice',
      'tip',
      'summary',
      'learn_more',
      'image',
      'gallery',
      'audio',
      'pdf',
      'download',
      'material',
    });
    return _ReadingSurface(
      eyebrow: 'APROFUNDE O OLHAR',
      title: 'Saber mais, sem perder o fio.',
      intro:
          'Referências, resumos e materiais complementares organizados em uma superfície de leitura calma e focada.',
      child: blocks.isEmpty
          ? const _EmptyLearningCard(
              icon: Icons.auto_stories_outlined,
              title: 'Conteúdo complementar em preparação',
              message:
                  'Quando a autora publicar referências ou materiais para esta aula, eles aparecerão aqui.',
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                LessonContentRenderer(blocks: blocks),
                const SizedBox(height: LawrenceSpacing.md),
                Align(
                  alignment: Alignment.centerLeft,
                  child: FilledButton.icon(
                    onPressed: completed ? null : onComplete,
                    icon: Icon(
                      completed
                          ? Icons.check_circle_rounded
                          : Icons.menu_book_rounded,
                    ),
                    label: Text(
                      completed ? 'Leitura concluída' : 'Concluir leitura',
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _ReadingSurface extends StatelessWidget {
  final String eyebrow;
  final String title;
  final String intro;
  final Widget child;

  const _ReadingSurface({
    required this.eyebrow,
    required this.title,
    required this.intro,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: _learningCanvas(context),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(40, 44, 40, 64),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 860),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  eyebrow,
                  style: const TextStyle(
                    color: LawrenceColors.actionOnDark,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.7,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: TextStyle(
                    color: _learningText(context),
                    fontFamily: 'Georgia',
                    fontSize: 44,
                    height: 1.05,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  intro,
                  style: TextStyle(
                    color: _learningMuted(context),
                    fontSize: 17,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 38),
                child,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyLearningCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  const _EmptyLearningCard({
    required this.icon,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: _learningSurfaceRaised(context),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Theme.of(
            context,
          ).colorScheme.outlineVariant.withValues(alpha: .22),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 14,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: const BoxDecoration(
              color: LawrenceColors.plum,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: LawrenceColors.actionOnDark),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: _learningText(context),
                    fontFamily: 'Georgia',
                    fontSize: 22,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  style: TextStyle(color: _learningMuted(context), height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CurriculumPanel extends StatelessWidget {
  final LessonEntity? activeLesson;
  final LearningWorkspaceMode activeMode;
  final List<LessonEntity> lessons;
  final int progressPercentage;
  final Set<String> completedLessonIds;
  final Set<String> completedActivityBlockIds;
  final Set<String> seenLearnMoreLessonIds;
  final int selectedTab;
  final ValueChanged<int> onTabChanged;
  final Future<void> Function(String lessonId) onOpenLesson;
  final ValueChanged<LearningWorkspaceMode> onSelectMode;

  const _CurriculumPanel({
    required this.activeLesson,
    required this.activeMode,
    required this.lessons,
    required this.progressPercentage,
    required this.completedLessonIds,
    required this.completedActivityBlockIds,
    required this.seenLearnMoreLessonIds,
    required this.selectedTab,
    required this.onTabChanged,
    required this.onOpenLesson,
    required this.onSelectMode,
  });

  @override
  Widget build(BuildContext context) {
    final modules = <String, List<LessonEntity>>{};
    for (final lesson in lessons) {
      modules.putIfAbsent(lesson.moduleId, () => []).add(lesson);
    }
    return Container(
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: Theme.of(
              context,
            ).colorScheme.outlineVariant.withValues(alpha: .25),
          ),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 12,
            offset: Offset(-2, 0),
          ),
        ],
      ),
      child: Material(
        color: _learningSurface(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(26, 26, 26, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => onTabChanged(0),
                          child: Text(
                            'Conteúdo',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontWeight: selectedTab == 0
                                  ? FontWeight.w800
                                  : FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: TextButton(
                          onPressed: () => onTabChanged(1),
                          child: Text(
                            'Transcrição',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontWeight: selectedTab == 1
                                  ? FontWeight.w800
                                  : FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: CoutureProgressBar(
                          value: progressPercentage / 100,
                          height: 6,
                          semanticLabel: 'Progresso do curso',
                        ),
                      ),
                      const SizedBox(width: 14),
                      Text(
                        '$progressPercentage%',
                        style: const TextStyle(
                          color: _ink,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Divider(
              height: 1,
              color: Theme.of(
                context,
              ).colorScheme.outlineVariant.withValues(alpha: .14),
            ),
            Expanded(
              child: selectedTab == 1
                  ? _TranscriptPanel(lesson: activeLesson)
                  : ListView(
                      children: [
                        for (final entry in modules.entries)
                          ExpansionTile(
                            shape: const RoundedRectangleBorder(),
                            collapsedShape: const RoundedRectangleBorder(),
                            backgroundColor: Colors.transparent,
                            collapsedBackgroundColor: Colors.transparent,
                            initiallyExpanded: entry.value.any(
                              (lesson) => lesson.id == activeLesson?.id,
                            ),
                            title: Text(
                              'Módulo ${(modules.keys.toList().indexOf(entry.key) + 1).toString().padLeft(2, '0')}',
                              style: const TextStyle(
                                color: _ink,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            subtitle: Text('${entry.value.length} aulas'),
                            children: [
                              for (final lesson in entry.value) ...[
                                _LessonTile(
                                  index: lessons.indexOf(lesson),
                                  lesson: lesson,
                                  selected: lesson.id == activeLesson?.id,
                                  completed: completedLessonIds.contains(
                                    lesson.id,
                                  ),
                                  onTap: () {
                                    if (lesson.id == activeLesson?.id) {
                                      onSelectMode(LearningWorkspaceMode.watch);
                                    } else {
                                      onOpenLesson(lesson.id);
                                    }
                                  },
                                ),
                                for (final block in _sequenceBlocks(lesson))
                                  _SequenceBlockTile(
                                    block: block,
                                    completed: block.type == 'activity'
                                        ? completedActivityBlockIds.contains(
                                            block.id,
                                          )
                                        : seenLearnMoreLessonIds.contains(
                                            lesson.id,
                                          ),
                                    selected:
                                        lesson.id == activeLesson?.id &&
                                        activeMode ==
                                            (block.type == 'activity'
                                                ? LearningWorkspaceMode
                                                      .activities
                                                : LearningWorkspaceMode
                                                      .learnMore),
                                    onTap: () {
                                      if (lesson.id != activeLesson?.id) {
                                        onOpenLesson(lesson.id);
                                      } else {
                                        onSelectMode(
                                          block.type == 'activity'
                                              ? LearningWorkspaceMode.activities
                                              : LearningWorkspaceMode.learnMore,
                                        );
                                      }
                                    },
                                  ),
                              ],
                            ],
                          ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LessonTile extends StatefulWidget {
  final int index;
  final LessonEntity lesson;
  final bool selected;
  final bool completed;
  final VoidCallback onTap;

  const _LessonTile({
    required this.index,
    required this.lesson,
    required this.selected,
    required this.completed,
    required this.onTap,
  });

  @override
  State<_LessonTile> createState() => _LessonTileState();
}

class _LessonTileState extends State<_LessonTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Semantics(
        button: true,
        selected: widget.selected,
        label:
            '${widget.lesson.title}. ${widget.completed
                ? 'Concluída'
                : widget.selected
                ? 'Aula atual'
                : 'Não concluída'}',
        child: AnimatedContainer(
          duration: reduceMotion
              ? Duration.zero
              : const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: widget.selected
                ? scheme.surface.withValues(alpha: .82)
                : _hovered
                ? scheme.surfaceContainerHighest.withValues(alpha: .48)
                : scheme.surface.withValues(alpha: .22),
            boxShadow: _hovered || widget.selected
                ? [
                    BoxShadow(
                      color: scheme.primary.withValues(
                        alpha: widget.selected ? .10 : .05,
                      ),
                      blurRadius: widget.selected ? 16 : 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Stack(
            children: [
              Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                clipBehavior: Clip.antiAlias,
                child: ListTile(
                  minTileHeight: 72,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  onTap: widget.onTap,
                  leading: Container(
                    width: 34,
                    height: 34,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(9),
                      color: widget.completed
                          ? LawrenceColors.success
                          : widget.selected
                          ? LawrenceColors.actionPrimary
                          : LawrenceColors.surfaceSubtle,
                      border: null,
                      boxShadow: widget.selected
                          ? [
                              BoxShadow(
                                color: LawrenceColors.focusRing.withValues(
                                  alpha: .34,
                                ),
                                blurRadius: 12,
                              ),
                            ]
                          : null,
                    ),
                    child: Icon(
                      widget.completed
                          ? Icons.check_rounded
                          : Icons.play_arrow_rounded,
                      color: widget.completed || widget.selected
                          ? Colors.white
                          : _ink,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    widget.lesson.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: scheme.onSurface,
                      fontWeight: widget.selected
                          ? FontWeight.w800
                          : FontWeight.w600,
                      height: 1.25,
                    ),
                  ),
                  subtitle: widget.lesson.durationSeconds > 0
                      ? Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: Text(
                            '${(widget.lesson.durationSeconds / 60).ceil()} min',
                            style: const TextStyle(fontSize: 12),
                          ),
                        )
                      : null,
                  trailing: widget.completed
                      ? const Icon(
                          Icons.check_circle_rounded,
                          color: LawrenceColors.success,
                          semanticLabel: 'Concluída',
                        )
                      : widget.selected
                      ? const Icon(Icons.play_arrow_rounded, color: _accent)
                      : null,
                ),
              ),
              if (widget.selected) ...[
                Positioned(
                  left: 0,
                  top: 14,
                  bottom: 14,
                  child: Container(
                    width: 3,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          scheme.primary.withValues(alpha: .35),
                          scheme.primary,
                          scheme.primary.withValues(alpha: .35),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: scheme.primary.withValues(alpha: .45),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  bottom: 0,
                  child: Container(
                    width: 52,
                    height: 2,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerRight,
                        end: Alignment.centerLeft,
                        colors: [
                          scheme.primary.withValues(alpha: 0),
                          scheme.primary,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: scheme.primary.withValues(alpha: .40),
                          blurRadius: 7,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SequenceBlockTile extends StatelessWidget {
  final LessonContentBlock block;
  final bool completed;
  final bool selected;
  final VoidCallback onTap;

  const _SequenceBlockTile({
    required this.block,
    required this.completed,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final activity = block.type == 'activity';
    final typeLabel = activity ? 'Atividade' : 'Saber mais';
    return Semantics(
      button: true,
      selected: selected,
      label:
          '$typeLabel. ${_blockLabel(block)}. ${completed
              ? 'Concluído'
              : selected
              ? 'Atual'
              : 'Não concluído'}',
      child: ListTile(
        minTileHeight: 64,
        contentPadding: const EdgeInsets.only(left: 44, right: 20),
        leading: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: completed
                ? LawrenceColors.success
                : selected
                ? LawrenceColors.actionPrimary
                : LawrenceColors.surfaceSubtle,
            borderRadius: BorderRadius.circular(9),
            border: Border.all(
              color: completed
                  ? LawrenceColors.success
                  : LawrenceColors.actionPrimary,
            ),
          ),
          child: Icon(
            completed
                ? Icons.check_rounded
                : activity
                ? Icons.assignment_outlined
                : Icons.auto_stories_outlined,
            size: 19,
            color: completed || selected
                ? Colors.white
                : LawrenceColors.actionPrimary,
          ),
        ),
        title: Text(_blockLabel(block)),
        subtitle: Text(completed ? '$typeLabel · Concluído' : typeLabel),
        trailing: completed
            ? const Icon(
                Icons.check_circle_rounded,
                color: LawrenceColors.success,
                semanticLabel: 'Concluído',
              )
            : null,
        selected: selected,
        selectedTileColor: LawrenceColors.surfaceSubtle,
        selectedColor: completed
            ? LawrenceColors.success
            : LawrenceColors.actionPrimary,
        onTap: onTap,
      ),
    );
  }
}

class _TranscriptPanel extends StatelessWidget {
  final LessonEntity? lesson;

  const _TranscriptPanel({required this.lesson});

  @override
  Widget build(BuildContext context) {
    final parts = <String>[
      if (lesson?.description?.trim().isNotEmpty == true)
        lesson!.description!.trim(),
      for (final block in _blocksOfType(lesson, const {
        'heading',
        'text',
        'summary',
      }))
        [block.content['title'], block.content['text']]
            .whereType<Object>()
            .map((value) => value.toString().trim())
            .where((value) => value.isNotEmpty)
            .join('\n'),
    ].where((value) => value.isNotEmpty).toList();
    return ListView(
      padding: const EdgeInsets.fromLTRB(28, 28, 28, 48),
      children: [
        Text(
          lesson?.title ?? 'Transcrição da aula',
          style: const TextStyle(
            color: _ink,
            fontFamily: 'Georgia',
            fontSize: 26,
          ),
        ),
        const SizedBox(height: 22),
        if (parts.isEmpty)
          const _EmptyLearningCard(
            icon: Icons.description_outlined,
            title: 'Transcrição em preparação',
            message: 'O texto desta aula aparecerá aqui quando for publicado.',
          )
        else
          SelectableText(
            parts.join('\n\n'),
            style: const TextStyle(color: _ink, fontSize: 16, height: 1.7),
          ),
      ],
    );
  }
}

class _MobileLearningBody extends StatefulWidget {
  final LearningWorkspaceMode mode;
  final ValueChanged<LearningWorkspaceMode> onModeChanged;
  final LessonEntity? lesson;
  final Widget player;
  final VoidCallback onOpenActivities;
  final ValueChanged<String>? onOpenActivity;
  final VoidCallback? onCompleteLearnMore;
  final bool learnMoreCompleted;
  final VoidCallback onShowTranscript;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final String nextLabel;

  const _MobileLearningBody({
    required this.mode,
    required this.onModeChanged,
    required this.lesson,
    required this.player,
    required this.onOpenActivities,
    required this.onOpenActivity,
    required this.onCompleteLearnMore,
    required this.learnMoreCompleted,
    required this.onShowTranscript,
    required this.onPrevious,
    required this.onNext,
    required this.nextLabel,
  });

  @override
  State<_MobileLearningBody> createState() => _MobileLearningBodyState();
}

class _MobileLearningBodyState extends State<_MobileLearningBody> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: _LearningBody(
            mode: widget.mode,
            lesson: widget.lesson,
            player: widget.player,
            onOpenActivities: widget.onOpenActivities,
            onOpenActivity: widget.onOpenActivity,
            onCompleteLearnMore: widget.onCompleteLearnMore,
            learnMoreCompleted: widget.learnMoreCompleted,
            onShowTranscript: widget.onShowTranscript,
            onPrevious: widget.onPrevious,
            onNext: widget.onNext,
            nextLabel: widget.nextLabel,
          ),
        ),
      ],
    );
  }
}

List<LessonContentBlock> _sequenceBlocks(LessonEntity lesson) {
  final blocks =
      lesson.blocks
          .map(LessonContentBlock.fromJson)
          .where(
            (block) =>
                block.type == 'activity' ||
                _learnMoreTypes.contains(block.type),
          )
          .toList()
        ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
  return blocks;
}

const _learnMoreTypes = <String>{
  'heading',
  'text',
  'notice',
  'tip',
  'summary',
  'learn_more',
  'image',
  'gallery',
  'audio',
  'pdf',
  'download',
  'material',
};

String _blockLabel(LessonContentBlock block) {
  for (final key in const ['title', 'question', 'text']) {
    final value = block.content[key]?.toString().trim() ?? '';
    if (value.isNotEmpty) return value;
  }
  return block.type == 'activity' ? 'Atividade' : 'Saber mais';
}

List<LessonContentBlock> _blocksOfType(
  LessonEntity? lesson,
  Set<String> types,
) {
  if (lesson == null) return const [];
  return lesson.blocks
      .map(LessonContentBlock.fromJson)
      .where((block) => types.contains(block.type))
      .toList();
}
