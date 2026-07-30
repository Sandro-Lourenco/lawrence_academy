import 'package:flutter/material.dart';

import '../../../../design_system/tokens/lawrence_theme.dart';
import '../../../lessons/domain/entities/lesson_entity.dart';
import '../../../lessons/presentation/widgets/lesson_content_renderer.dart';
import '../controllers/lesson_navigation_presentation.dart';

const _ink = Color(0xFF0D2235);
const _navy = Color(0xFF081C2C);
const _paper = Color(0xFFFFE5A3);
const _gold = Color(0xFFE9A126);
const _brown = Color(0xFF543A2F);

enum LearningWorkspaceMode { watch, activities, learnMore }

class LearningWorkspace extends StatefulWidget {
  final String title;
  final LessonEntity? lesson;
  final List<LessonEntity> lessons;
  final LessonNavigation navigation;
  final int progressPercentage;
  final Widget player;
  final VoidCallback onBack;
  final Future<void> Function(String lessonId) onOpenLesson;
  final VoidCallback onOpenActivities;
  final LearningWorkspaceMode initialMode;
  final ValueChanged<LearningWorkspaceMode>? onModeChanged;

  const LearningWorkspace({
    super.key,
    required this.title,
    required this.lesson,
    required this.lessons,
    required this.navigation,
    required this.progressPercentage,
    required this.player,
    required this.onBack,
    required this.onOpenLesson,
    required this.onOpenActivities,
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

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final desktop = width >= LawrenceBreakpoints.desktop;
    return Scaffold(
      backgroundColor: const Color(0xFFF2EFE8),
      body: SafeArea(
        child: Column(
          children: [
            _LearningHeader(title: widget.title, onBack: widget.onBack),
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
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      32,
                                      16,
                                      32,
                                      0,
                                    ),
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: _ModeControl(
                                        mode: _mode,
                                        onChanged: _selectMode,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: _LearningBody(
                                      mode: _mode,
                                      lesson: widget.lesson,
                                      player: widget.player,
                                      navigation: widget.navigation,
                                      onOpenLesson: widget.onOpenLesson,
                                      onOpenActivities: widget.onOpenActivities,
                                      onShowTranscript: () => setState(() {
                                        _curriculumVisible = true;
                                        _curriculumTab = 1;
                                      }),
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
                                  lessons: widget.lessons,
                                  progressPercentage: widget.progressPercentage,
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
                              backgroundColor: const Color(0xFFE8EAFE),
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
                      lessons: widget.lessons,
                      progressPercentage: widget.progressPercentage,
                      navigation: widget.navigation,
                      onOpenLesson: widget.onOpenLesson,
                      onOpenActivities: widget.onOpenActivities,
                      onShowTranscript: _showTranscript,
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTranscript() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFFF0F2FF),
      builder: (context) => FractionallySizedBox(
        heightFactor: .84,
        child: _TranscriptPanel(lesson: widget.lesson),
      ),
    );
  }
}

class _LearningHeader extends StatelessWidget {
  final String title;
  final VoidCallback onBack;

  const _LearningHeader({required this.title, required this.onBack});

  @override
  Widget build(BuildContext context) {
    final compact =
        MediaQuery.sizeOf(context).width < LawrenceBreakpoints.tablet;
    return Container(
      height: compact ? 76 : 88,
      padding: EdgeInsets.symmetric(horizontal: compact ? 12 : 24),
      decoration: const BoxDecoration(
        color: Color(0xFFF0F2FF),
        border: Border(bottom: BorderSide(color: Color(0x180D2235))),
      ),
      child: Row(
        children: [
          IconButton(
            tooltip: 'Voltar ao curso',
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_rounded, color: _ink),
          ),
          const SizedBox(width: 8),
          if (!compact) const _LearningBrand(),
          if (!compact) const SizedBox(width: 28),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: compact ? TextAlign.start : TextAlign.center,
              style: TextStyle(
                color: _ink,
                fontFamily: 'Georgia',
                fontSize: compact ? 17 : 20,
              ),
            ),
          ),
          const SizedBox(width: 20),
          const CircleAvatar(
            radius: 22,
            backgroundColor: _paper,
            child: Icon(Icons.person_outline_rounded, color: _ink),
          ),
        ],
      ),
    );
  }
}

class _LearningBrand extends StatelessWidget {
  const _LearningBrand();

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'LAWRENCE',
          style: TextStyle(
            color: _ink,
            fontFamily: 'Georgia',
            fontSize: 15,
            letterSpacing: 1.8,
          ),
        ),
        SizedBox(height: 2),
        Text(
          'ACADEMY',
          style: TextStyle(
            color: _gold,
            fontSize: 7,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }
}

class _ModeControl extends StatelessWidget {
  final LearningWorkspaceMode mode;
  final ValueChanged<LearningWorkspaceMode> onChanged;

  const _ModeControl({required this.mode, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<LearningWorkspaceMode>(
      segments: const [
        ButtonSegment(
          value: LearningWorkspaceMode.watch,
          icon: Icon(Icons.play_circle_outline, size: 18),
          label: Text('Assistir'),
        ),
        ButtonSegment(
          value: LearningWorkspaceMode.activities,
          icon: Icon(Icons.draw_outlined, size: 18),
          label: Text('Atividades'),
        ),
        ButtonSegment(
          value: LearningWorkspaceMode.learnMore,
          icon: Icon(Icons.auto_stories_outlined, size: 18),
          label: Text('Saber mais'),
        ),
      ],
      selected: {mode},
      showSelectedIcon: false,
      onSelectionChanged: (selection) => onChanged(selection.first),
      style: ButtonStyle(
        minimumSize: const WidgetStatePropertyAll(Size(48, 44)),
        foregroundColor: WidgetStateProperty.resolveWith(
          (states) =>
              states.contains(WidgetState.selected) ? Colors.white : _navy,
        ),
        backgroundColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? LawrenceColors.actionPrimary
              : Colors.white,
        ),
        side: const WidgetStatePropertyAll(
          BorderSide(color: LawrenceColors.borderMist),
        ),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        textStyle: const WidgetStatePropertyAll(
          TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class _LearningBody extends StatelessWidget {
  final LearningWorkspaceMode mode;
  final LessonEntity? lesson;
  final Widget player;
  final LessonNavigation navigation;
  final Future<void> Function(String lessonId) onOpenLesson;
  final VoidCallback onOpenActivities;
  final VoidCallback onShowTranscript;

  const _LearningBody({
    required this.mode,
    required this.lesson,
    required this.player,
    required this.navigation,
    required this.onOpenLesson,
    required this.onOpenActivities,
    required this.onShowTranscript,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
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
          navigation: navigation,
          onOpenLesson: onOpenLesson,
          onShowTranscript: onShowTranscript,
        ),
        LearningWorkspaceMode.activities => _ActivitySurface(
          key: const ValueKey('activities'),
          lesson: lesson,
          onOpenActivities: onOpenActivities,
        ),
        LearningWorkspaceMode.learnMore => _LearnMoreSurface(
          key: const ValueKey('learn-more'),
          lesson: lesson,
        ),
      },
    );
  }
}

class _WatchSurface extends StatelessWidget {
  final LessonEntity? lesson;
  final Widget player;
  final LessonNavigation navigation;
  final Future<void> Function(String lessonId) onOpenLesson;
  final VoidCallback onShowTranscript;

  const _WatchSurface({
    super.key,
    required this.lesson,
    required this.player,
    required this.navigation,
    required this.onOpenLesson,
    required this.onShowTranscript,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(32, 32, 32, 48),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x26081C2C),
                        blurRadius: 40,
                        offset: Offset(0, 18),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: player,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'AULA ATUAL',
                          style: TextStyle(
                            color: _brown,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.6,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          lesson?.title ?? 'Carregando aula',
                          style: const TextStyle(
                            color: _ink,
                            fontFamily: 'Georgia',
                            fontSize: 36,
                            height: 1.08,
                          ),
                        ),
                        if (lesson?.description?.trim().isNotEmpty == true) ...[
                          const SizedBox(height: 14),
                          Text(
                            lesson!.description!.trim(),
                            style: const TextStyle(
                              color: LawrenceColors.textSecondary,
                              fontSize: 16,
                              height: 1.55,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(170, 56),
                      backgroundColor: const Color(0xFFE8EAFE),
                      foregroundColor: _ink,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: onShowTranscript,
                    icon: const Icon(Icons.description_outlined),
                    label: const Text('Transcrição'),
                  ),
                  const SizedBox(width: 12),
                  if (navigation.next case final next?)
                    FilledButton.icon(
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(170, 56),
                        backgroundColor: const Color(0xFF1437D9),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () => onOpenLesson(next.id),
                      iconAlignment: IconAlignment.end,
                      icon: const Icon(Icons.arrow_forward_rounded),
                      label: const Text('Avançar'),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActivitySurface extends StatelessWidget {
  final LessonEntity? lesson;
  final VoidCallback onOpenActivities;

  const _ActivitySurface({
    super.key,
    required this.lesson,
    required this.onOpenActivities,
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
          else
            LessonContentRenderer(blocks: blocks, isPreview: true),
          const SizedBox(height: 24),
          Align(
            alignment: Alignment.centerLeft,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                minimumSize: const Size(210, 54),
                backgroundColor: _ink,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              onPressed: onOpenActivities,
              iconAlignment: IconAlignment.end,
              icon: const Icon(Icons.arrow_outward),
              label: const Text('Abrir minhas atividades'),
            ),
          ),
        ],
      ),
    );
  }
}

class _LearnMoreSurface extends StatelessWidget {
  final LessonEntity? lesson;

  const _LearnMoreSurface({super.key, required this.lesson});

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
          : LessonContentRenderer(blocks: blocks),
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
    return SingleChildScrollView(
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
                  color: _brown,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.7,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  color: _ink,
                  fontFamily: 'Georgia',
                  fontSize: 44,
                  height: 1.05,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                intro,
                style: const TextStyle(
                  color: LawrenceColors.textSecondary,
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0x1F543A2F)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: const BoxDecoration(
              color: _paper,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: _ink),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: _ink,
                    fontFamily: 'Georgia',
                    fontSize: 22,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  style: const TextStyle(
                    color: LawrenceColors.textSecondary,
                    height: 1.5,
                  ),
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
  final List<LessonEntity> lessons;
  final int progressPercentage;
  final int selectedTab;
  final ValueChanged<int> onTabChanged;
  final Future<void> Function(String lessonId) onOpenLesson;
  final ValueChanged<LearningWorkspaceMode> onSelectMode;

  const _CurriculumPanel({
    required this.activeLesson,
    required this.lessons,
    required this.progressPercentage,
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
      decoration: const BoxDecoration(
        border: Border(left: BorderSide(color: Color(0x22543A2F))),
      ),
      child: Material(
        color: const Color(0xFFF0F2FF),
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
                              color: _ink,
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
                              color: _ink,
                              fontWeight: selectedTab == 1
                                  ? FontWeight.w800
                                  : FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Configurações',
                        onPressed: () {},
                        icon: const Icon(Icons.settings_outlined),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: LinearProgressIndicator(
                            value: progressPercentage / 100,
                            minHeight: 6,
                            color: const Color(0xFF1CAD6B),
                            backgroundColor: const Color(0xFFB8C3DE),
                          ),
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
            const Divider(height: 1),
            Expanded(
              child: selectedTab == 1
                  ? _TranscriptPanel(lesson: activeLesson)
                  : ListView(
                      children: [
                        for (final entry in modules.entries)
                          ExpansionTile(
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
                                  onTap: () {
                                    if (lesson.id == activeLesson?.id) {
                                      onSelectMode(LearningWorkspaceMode.watch);
                                    } else {
                                      onOpenLesson(lesson.id);
                                    }
                                  },
                                ),
                                for (final block in _sequenceBlocks(lesson))
                                  ListTile(
                                    contentPadding: const EdgeInsets.only(
                                      left: 44,
                                      right: 20,
                                    ),
                                    leading: Icon(
                                      block.type == 'activity'
                                          ? Icons.assignment_outlined
                                          : Icons.auto_stories_outlined,
                                    ),
                                    title: Text(_blockLabel(block)),
                                    subtitle: Text(
                                      block.type == 'activity'
                                          ? 'Atividade'
                                          : 'Saber mais',
                                    ),
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
  final VoidCallback onTap;

  const _LessonTile({
    required this.index,
    required this.lesson,
    required this.selected,
    required this.onTap,
  });

  @override
  State<_LessonTile> createState() => _LessonTileState();
}

class _LessonTileState extends State<_LessonTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: widget.selected
              ? const Border(left: BorderSide(color: _gold, width: 4))
              : null,
        ),
        child: Material(
          color: widget.selected
              ? Colors.white
              : _hovered
              ? const Color(0xFFF4F0E8)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
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
                shape: BoxShape.circle,
                color: widget.selected ? _ink : const Color(0xFFE9E4DA),
              ),
              child: Text(
                '${widget.index + 1}',
                style: TextStyle(
                  color: widget.selected ? Colors.white : _brown,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            title: Text(
              widget.lesson.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: _ink,
                fontWeight: widget.selected ? FontWeight.w800 : FontWeight.w600,
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
            trailing: widget.selected
                ? const Icon(Icons.play_arrow_rounded, color: _gold)
                : null,
          ),
        ),
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
  final List<LessonEntity> lessons;
  final int progressPercentage;
  final LessonNavigation navigation;
  final Future<void> Function(String lessonId) onOpenLesson;
  final VoidCallback onOpenActivities;
  final VoidCallback onShowTranscript;

  const _MobileLearningBody({
    required this.mode,
    required this.onModeChanged,
    required this.lesson,
    required this.player,
    required this.lessons,
    required this.progressPercentage,
    required this.navigation,
    required this.onOpenLesson,
    required this.onOpenActivities,
    required this.onShowTranscript,
  });

  @override
  State<_MobileLearningBody> createState() => _MobileLearningBodyState();
}

class _MobileLearningBodyState extends State<_MobileLearningBody> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: _ModeControl(
            mode: widget.mode,
            onChanged: widget.onModeChanged,
          ),
        ),
        Expanded(
          child: _LearningBody(
            mode: widget.mode,
            lesson: widget.lesson,
            player: widget.player,
            navigation: widget.navigation,
            onOpenLesson: widget.onOpenLesson,
            onOpenActivities: widget.onOpenActivities,
            onShowTranscript: widget.onShowTranscript,
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
            (block) => block.type == 'activity' || block.type == 'learn_more',
          )
          .toList()
        ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
  return blocks;
}

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
