import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../design_system/tokens/lawrence_theme.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../courses/domain/entities/course.dart';
import '../controllers/teacher_courses_controller.dart';

class TeacherDashboardPage extends ConsumerStatefulWidget {
  const TeacherDashboardPage({super.key});

  @override
  ConsumerState<TeacherDashboardPage> createState() =>
      _TeacherDashboardPageState();
}

class _TeacherDashboardPageState extends ConsumerState<TeacherDashboardPage> {
  final _searchController = TextEditingController();
  String _filter = 'all';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(teacherCoursesControllerProvider);
    final compact =
        MediaQuery.sizeOf(context).width < LawrenceBreakpoints.tablet;
    return Scaffold(
      backgroundColor: LawrenceColors.canvas,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.menu_book_outlined,
              color: LawrenceColors.wine,
              size: 20,
            ),
            const SizedBox(width: 10),
            Text(
              compact ? 'LAWRENCE' : 'LAWRENCE  /  ESTÚDIO DO PROFESSOR',
              style: const TextStyle(
                color: LawrenceColors.textPrimary,
                fontSize: 14,
                letterSpacing: 1.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        backgroundColor: LawrenceColors.canvas,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: LawrenceColors.borderMist, height: 1),
        ),
        actions: [
          IconButton(
            tooltip: 'Meu perfil profissional',
            onPressed: () => context.push('/teacher/profile'),
            icon: const Icon(
              Icons.account_circle_outlined,
              color: LawrenceColors.textPrimary,
            ),
          ),
          if (!compact) ...[
            IconButton(
              tooltip: 'Gerenciar eventos e lives',
              onPressed: () => context.push('/teacher/live-events'),
              icon: const Icon(
                Icons.live_tv_outlined,
                color: LawrenceColors.textPrimary,
              ),
            ),
            IconButton(
              tooltip: 'Atualizar cursos',
              onPressed: () =>
                  ref.read(teacherCoursesControllerProvider.notifier).reload(),
              icon: const Icon(
                Icons.refresh,
                color: LawrenceColors.textPrimary,
              ),
            ),
          ],
          IconButton(
            tooltip: 'Sair da conta',
            icon: const Icon(
              Icons.logout_rounded,
              color: LawrenceColors.danger,
            ),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (dialogContext) => AlertDialog(
                  title: const Text('Sair da conta?'),
                  content: const Text(
                    'Tem certeza que deseja sair do Lawrence Academy? Seus rascunhos de cursos salvos não serão perdidos.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext, false),
                      child: const Text('Cancelar'),
                    ),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: LawrenceColors.danger,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () => Navigator.pop(dialogContext, true),
                      child: const Text('Sair'),
                    ),
                  ],
                ),
              );
              if (confirm == true && mounted) {
                await ref.read(authNotifierProvider.notifier).signOut();
              }
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: state.when(
        loading: () => const _TeacherDashboardSkeleton(),
        error: (_, _) => _ErrorState(
          onRetry: () =>
              ref.read(teacherCoursesControllerProvider.notifier).reload(),
        ),
        data: (courses) => _content(context, courses),
      ),
      floatingActionButton: compact
          ? FloatingActionButton.extended(
              onPressed: () => context.push('/teacher/courses/new'),
              icon: const Icon(Icons.add, color: Colors.white),
              backgroundColor: LawrenceColors.primary,
              label: const Text(
                'Novo curso',
                style: TextStyle(color: Colors.white),
              ),
            )
          : null,
    );
  }

  Widget _content(BuildContext context, List<Course> courses) {
    final query = _searchController.text.trim().toLowerCase();
    final visible = courses.where((course) {
      final matchesFilter = _filter == 'all' || course.status == _filter;
      final matchesSearch =
          query.isEmpty ||
          course.title.toLowerCase().contains(query) ||
          course.category.toLowerCase().contains(query);
      return matchesFilter && matchesSearch;
    }).toList();
    final published = courses
        .where((course) => course.status == 'published')
        .length;
    final drafts = courses.where((course) => course.status == 'draft').length;
    final attention = courses
        .where(
          (course) =>
              course.status == 'reviewing' || course.status == 'unpublished',
        )
        .length;
    final archived = courses
        .where((course) => course.status == 'archived')
        .length;

    final horizontalPadding = MediaQuery.sizeOf(context).width >= 1180
        ? (MediaQuery.sizeOf(context).width - 1180) / 2
        : 20.0;
    return RefreshIndicator(
      onRefresh: () =>
          ref.read(teacherCoursesControllerProvider.notifier).reload(),
      child: ListView(
        padding: EdgeInsets.fromLTRB(
          horizontalPadding,
          28,
          horizontalPadding,
          96,
        ),
        children: [
          _StudioHero(
            draftCount: drafts,
            attentionCount: attention,
            onCreate: () => context.push('/teacher/courses/new'),
          ),
          const SizedBox(height: 36),
          const _SectionHeader(
            eyebrow: 'VISÃO GERAL',
            title: 'O pulso do seu estúdio',
            description: 'Acompanhe o que está publicado e onde agir agora.',
          ),
          const SizedBox(height: LawrenceSpacing.md),
          GridView.count(
            crossAxisCount: _metricColumns(MediaQuery.sizeOf(context).width),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: LawrenceSpacing.md,
            crossAxisSpacing: LawrenceSpacing.md,
            childAspectRatio: 2.4,
            children: [
              _MetricCard(
                'Publicados',
                published,
                Icons.public,
                LawrenceColors.success,
              ),
              _MetricCard(
                'Rascunhos',
                drafts,
                Icons.edit_note,
                LawrenceColors.primary,
              ),
              _MetricCard(
                'Precisam de atenção',
                attention,
                Icons.warning_amber,
                LawrenceColors.warning,
              ),
              _MetricCard(
                'Arquivados',
                archived,
                Icons.archive_outlined,
                Colors.grey,
              ),
            ],
          ),
          const SizedBox(height: 36),
          const _SectionHeader(
            eyebrow: 'BIBLIOTECA',
            title: 'Seus cursos',
            description:
                'Continue um rascunho ou gerencie o que já está no ar.',
          ),
          const SizedBox(height: LawrenceSpacing.md),
          LayoutBuilder(
            builder: (context, constraints) {
              final search = TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                style: const TextStyle(color: LawrenceColors.textPrimary),
                cursorColor: LawrenceColors.wine,
                decoration: InputDecoration(
                  labelText: 'Buscar cursos',
                  labelStyle: const TextStyle(
                    color: LawrenceColors.textSecondary,
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: LawrenceColors.textSecondary,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(2),
                    borderSide: const BorderSide(
                      color: LawrenceColors.borderMist,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(2),
                    borderSide: const BorderSide(
                      color: LawrenceColors.focusRing,
                      width: 2,
                    ),
                  ),
                ),
              );
              final filters = SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (final entry in _filters.entries)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          selected: _filter == entry.key,
                          label: Text(entry.value),
                          labelStyle: TextStyle(
                            color: _filter == entry.key
                                ? Colors.white
                                : LawrenceColors.textSecondary,
                            fontWeight: FontWeight.w700,
                          ),
                          color: WidgetStateProperty.resolveWith((states) {
                            if (states.contains(WidgetState.selected)) {
                              return LawrenceColors.wine;
                            }
                            if (states.contains(WidgetState.hovered)) {
                              return LawrenceColors.surfaceSubtle;
                            }
                            return Colors.white;
                          }),
                          checkmarkColor: Colors.white,
                          side: BorderSide(
                            color: _filter == entry.key
                                ? LawrenceColors.wine
                                : LawrenceColors.borderMist,
                          ),
                          onSelected: (_) =>
                              setState(() => _filter = entry.key),
                        ),
                      ),
                  ],
                ),
              );
              if (constraints.maxWidth < 720) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    search,
                    const SizedBox(height: LawrenceSpacing.md),
                    filters,
                  ],
                );
              }
              return Row(
                children: [
                  SizedBox(width: 320, child: search),
                  const SizedBox(width: LawrenceSpacing.lg),
                  Expanded(child: filters),
                ],
              );
            },
          ),
          const SizedBox(height: LawrenceSpacing.lg),
          if (courses.isEmpty)
            _EmptyState(onCreate: () => context.push('/teacher/courses/new'))
          else if (visible.isEmpty)
            const _NoResults()
          else
            for (final course in visible)
              Padding(
                padding: const EdgeInsets.only(bottom: LawrenceSpacing.md),
                child: _CourseManagementCard(
                  course: course,
                  onStudents: () =>
                      context.push('/teacher/courses/${course.id}/students'),
                  onEdit: () =>
                      context.push('/teacher/courses/${course.id}/edit'),
                  onUnpublish: () => _unpublish(course),
                  onArchive: () => _archive(course),
                  onRestore: () => _restore(course),
                ),
              ),
        ],
      ),
    );
  }

  int _metricColumns(double width) {
    if (width >= 1000) return 4;
    if (width >= 600) return 2;
    return 1;
  }

  Future<void> _unpublish(Course course) async {
    final reason = await _reasonDialog(
      title: 'Despublicar curso?',
      message:
          'Novas matrículas e acesso pelo catálogo serão interrompidos. '
          'Esta ação não apaga o conteúdo.',
      actionLabel: 'Despublicar',
    );
    if (reason == null || !mounted) return;
    await ref
        .read(teacherCoursesControllerProvider.notifier)
        .unpublishCourse(course.id, reason: reason);
  }

  Future<void> _archive(Course course) async {
    final reason = await _reasonDialog(
      title: 'Arquivar curso?',
      message:
          'O curso ficará oculto da área ativa. Ele poderá ser restaurado posteriormente.',
      actionLabel: 'Arquivar',
      destructive: true,
    );
    if (reason == null || !mounted) return;
    await ref
        .read(teacherCoursesControllerProvider.notifier)
        .archiveCourse(course.id, reason: reason);
  }

  Future<void> _restore(Course course) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Restaurar curso?'),
        content: const Text(
          'O curso voltará como despublicado para que você possa revisar antes de republicar.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Restaurar'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await ref
        .read(teacherCoursesControllerProvider.notifier)
        .restoreCourse(course.id, reason: 'Restaurado pelo professor');
  }

  Future<String?> _reasonDialog({
    required String title,
    required String message,
    required String actionLabel,
    bool destructive = false,
  }) async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(message),
            const SizedBox(height: LawrenceSpacing.lg),
            TextField(
              controller: controller,
              maxLength: 500,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Motivo (opcional)',
                hintText: 'Ex.: atualização importante de conteúdo',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: destructive
                ? FilledButton.styleFrom(backgroundColor: LawrenceColors.danger)
                : null,
            onPressed: () =>
                Navigator.pop(dialogContext, controller.text.trim()),
            child: Text(actionLabel),
          ),
        ],
      ),
    );
    controller.dispose();
    return result;
  }
}

class _StudioHero extends StatelessWidget {
  const _StudioHero({
    required this.draftCount,
    required this.attentionCount,
    required this.onCreate,
  });

  final int draftCount;
  final int attentionCount;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(32),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: LawrenceColors.borderMist),
      boxShadow: const [
        BoxShadow(
          color: Color(0x126B1328),
          blurRadius: 28,
          offset: Offset(0, 12),
        ),
      ],
    ),
    child: LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 720;
        final copy = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'SEU ESTÚDIO DE ENSINO',
              style: TextStyle(
                color: LawrenceColors.wine,
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Transforme conhecimento\nem uma experiência memorável.',
              style: TextStyle(
                color: LawrenceColors.textPrimary,
                fontSize: compact ? 30 : 40,
                height: 1.08,
                fontWeight: FontWeight.w400,
                fontFamily: 'Georgia',
                letterSpacing: -1.4,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              _insight,
              style: const TextStyle(
                color: LawrenceColors.textSecondary,
                fontSize: 16,
                height: 1.45,
              ),
            ),
          ],
        );
        final action = FilledButton.icon(
          onPressed: onCreate,
          icon: const Icon(Icons.add),
          label: const Text('Criar novo curso'),
          style: FilledButton.styleFrom(
            backgroundColor: LawrenceColors.wine,
            foregroundColor: Colors.white,
            minimumSize: const Size(190, 54),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          ),
        );
        if (compact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [copy, const SizedBox(height: 24), action],
          );
        }
        return Row(
          children: [
            Expanded(child: copy),
            const SizedBox(width: 32),
            action,
          ],
        );
      },
    ),
  );

  String get _insight {
    if (attentionCount > 0) {
      return '$attentionCount curso${attentionCount == 1 ? '' : 's'} precisa${attentionCount == 1 ? '' : 'm'} de atenção antes do próximo lançamento.';
    }
    if (draftCount > 0) {
      return 'Você tem $draftCount rascunho${draftCount == 1 ? '' : 's'} pronto${draftCount == 1 ? '' : 's'} para continuar.';
    }
    return 'Planeje, publique e evolua seus cursos em um só lugar.';
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.eyebrow,
    required this.title,
    required this.description,
  });
  final String eyebrow;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        eyebrow,
        style: const TextStyle(
          color: LawrenceColors.wine,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.4,
        ),
      ),
      const SizedBox(height: 6),
      Text(
        title,
        style: Theme.of(context).textTheme.displaySmall?.copyWith(
          color: LawrenceColors.textPrimary,
          fontWeight: FontWeight.w400,
          letterSpacing: -.6,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        description,
        style: const TextStyle(color: LawrenceColors.textSecondary),
      ),
    ],
  );
}

class _CourseArtwork extends StatelessWidget {
  const _CourseArtwork({required this.course});
  final Course course;

  @override
  Widget build(BuildContext context) {
    final cover = course.coverImagePath?.trim();
    final hasRemoteCover =
        cover != null &&
        (cover.startsWith('https://') || cover.startsWith('http://'));
    return Container(
      width: 104,
      height: 82,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: LawrenceColors.surfaceSubtle,
        borderRadius: BorderRadius.zero,
        border: Border.all(color: LawrenceColors.borderMist),
      ),
      child: hasRemoteCover
          ? Image.network(
              cover,
              fit: BoxFit.cover,
              alignment: Alignment(
                (course.coverFocalX * 2) - 1,
                (course.coverFocalY * 2) - 1,
              ),
              semanticLabel: course.coverAltText ?? 'Capa de ${course.title}',
              errorBuilder: (_, _, _) => _fallbackArtwork(),
            )
          : _fallbackArtwork(),
    );
  }

  Widget _fallbackArtwork() => Stack(
    children: [
      const Positioned(
        right: -10,
        bottom: -16,
        child: Icon(
          Icons.content_cut_rounded,
          color: Color(0x246B1328),
          size: 86,
        ),
      ),
      Center(
        child: Icon(
          course.status == 'published'
              ? Icons.play_circle_fill_rounded
              : Icons.design_services_outlined,
          color: LawrenceColors.wine,
          size: 30,
        ),
      ),
    ],
  );
}

class _CourseFact extends StatelessWidget {
  const _CourseFact({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
    decoration: BoxDecoration(
      color: LawrenceColors.surfaceSubtle,
      border: Border.all(color: LawrenceColors.borderMist),
      borderRadius: BorderRadius.circular(2),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: LawrenceColors.wine),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            color: LawrenceColors.textPrimary,
            fontSize: 12,
          ),
        ),
      ],
    ),
  );
}

String _visibilityLabel(String value) => switch (value) {
  'unlisted' => 'Somente por link',
  'private' => 'Privado',
  _ => 'No catálogo',
};

class _CourseManagementCard extends StatelessWidget {
  const _CourseManagementCard({
    required this.course,
    required this.onEdit,
    required this.onStudents,
    required this.onUnpublish,
    required this.onArchive,
    required this.onRestore,
  });

  final Course course;
  final VoidCallback onEdit;
  final VoidCallback onStudents;
  final VoidCallback onUnpublish;
  final VoidCallback onArchive;
  final VoidCallback onRestore;

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 680;
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: LawrenceSpacing.sm,
          runSpacing: LawrenceSpacing.xs,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              course.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: LawrenceColors.textPrimary,
                fontWeight: FontWeight.w700,
                letterSpacing: -.3,
              ),
            ),
            _StatusBadge(status: course.status),
          ],
        ),
        const SizedBox(height: 7),
        Text(
          '${course.courseType == 'quick' ? 'Curso rápido' : '${course.modules.where((module) => !module.isSystem).length} módulos'}  •  ${course.lessonCount} aulas  •  ${course.category}',
          style: const TextStyle(color: LawrenceColors.textSecondary),
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _CourseFact(
              icon: course.isFree ? Icons.redeem_outlined : Icons.autorenew,
              label: course.isFree
                  ? 'Gratuito'
                  : 'R\$ ${course.monthlyPrice.toStringAsFixed(2).replaceAll('.', ',')} / mês',
            ),
            _CourseFact(
              icon: Icons.visibility_outlined,
              label: _visibilityLabel(course.visibility),
            ),
          ],
        ),
      ],
    );
    final actions = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (course.status != 'archived')
          OutlinedButton.icon(
            onPressed: onStudents,
            icon: const Icon(Icons.group_outlined, size: 18),
            label: const Text('Alunos'),
            style: OutlinedButton.styleFrom(
              foregroundColor: LawrenceColors.wine,
              side: const BorderSide(color: LawrenceColors.wine),
            ),
          ),
        const SizedBox(width: 8),
        if (course.status != 'archived')
          FilledButton.tonalIcon(
            onPressed: onEdit,
            icon: const Icon(Icons.edit_outlined, size: 18),
            label: Text(course.status == 'draft' ? 'Continuar' : 'Editar'),
            style: FilledButton.styleFrom(
              backgroundColor: LawrenceColors.wine,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
          ),
        PopupMenuButton<String>(
          tooltip: 'Ações do curso ${course.title}',
          onSelected: (action) {
            if (action == 'edit') onEdit();
            if (action == 'unpublish') onUnpublish();
            if (action == 'archive') onArchive();
            if (action == 'restore') onRestore();
          },
          itemBuilder: (_) => [
            if (course.status != 'archived')
              const PopupMenuItem(
                value: 'edit',
                child: Text('Editar e revisar'),
              ),
            if (course.status == 'published')
              const PopupMenuItem(
                value: 'unpublish',
                child: Text('Despublicar'),
              ),
            if (course.status != 'archived')
              const PopupMenuItem(value: 'archive', child: Text('Arquivar')),
            if (course.status == 'archived')
              const PopupMenuItem(value: 'restore', child: Text('Restaurar')),
          ],
        ),
      ],
    );
    return Container(
      padding: const EdgeInsets.all(LawrenceSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: LawrenceColors.borderMist),
        borderRadius: BorderRadius.zero,
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: compact
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [content, const SizedBox(height: 18), actions],
            )
          : Row(
              children: [
                _CourseArtwork(course: course),
                const SizedBox(width: LawrenceSpacing.lg),
                Expanded(child: content),
                const SizedBox(width: LawrenceSpacing.lg),
                actions,
              ],
            ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard(this.label, this.value, this.icon, this.color);

  final String label;
  final int value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(LawrenceSpacing.lg),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: LawrenceColors.borderMist),
      borderRadius: BorderRadius.zero,
    ),
    child: Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: color.withValues(alpha: .09),
            borderRadius: BorderRadius.zero,
          ),
          child: Icon(icon, color: color, size: 21),
        ),
        const SizedBox(width: LawrenceSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$value',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: LawrenceColors.textPrimary,
                  fontWeight: FontWeight.w400,
                  fontFamily: 'Georgia',
                  letterSpacing: -.5,
                ),
              ),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: LawrenceColors.textSecondary),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      'published' => LawrenceColors.success,
      'reviewing' => LawrenceColors.warning,
      'archived' => Colors.grey,
      'unpublished' => LawrenceColors.danger,
      _ => LawrenceColors.primary,
    };
    return Semantics(
      label: 'Status: ${_statusLabels[status] ?? status}',
      child: Chip(
        visualDensity: VisualDensity.compact,
        side: BorderSide(color: color.withValues(alpha: .4)),
        backgroundColor: color.withValues(alpha: .1),
        label: Text(_statusLabels[status] ?? status),
      ),
    );
  }
}

class _TeacherDashboardSkeleton extends StatelessWidget {
  const _TeacherDashboardSkeleton();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final horizontalPadding = width >= 1180 ? (width - 1180) / 2 : 20.0;
    return Semantics(
      label: 'Carregando o estúdio do professor',
      liveRegion: true,
      child: ListView(
        padding: EdgeInsets.fromLTRB(
          horizontalPadding,
          28,
          horizontalPadding,
          48,
        ),
        children: [
          const _SkeletonBlock(height: 214),
          const SizedBox(height: 36),
          const _SkeletonLine(width: 112, height: 12),
          const SizedBox(height: 10),
          const _SkeletonLine(width: 280, height: 34),
          const SizedBox(height: 20),
          GridView.count(
            crossAxisCount: width >= 1000 ? 4 : (width >= 600 ? 2 : 1),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: LawrenceSpacing.md,
            crossAxisSpacing: LawrenceSpacing.md,
            childAspectRatio: 2.4,
            children: const [
              _SkeletonBlock(height: 96),
              _SkeletonBlock(height: 96),
              _SkeletonBlock(height: 96),
              _SkeletonBlock(height: 96),
            ],
          ),
          const SizedBox(height: 36),
          const _SkeletonLine(width: 210, height: 34),
          const SizedBox(height: 20),
          const _SkeletonBlock(height: 130),
          const SizedBox(height: 16),
          const _SkeletonBlock(height: 130),
        ],
      ),
    );
  }
}

class _SkeletonBlock extends StatelessWidget {
  const _SkeletonBlock({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: Container(
      height: height,
      decoration: BoxDecoration(
        color: LawrenceColors.surfaceSubtle,
        border: Border.all(color: LawrenceColors.borderMist),
      ),
    ),
  );
}

class _SkeletonLine extends StatelessWidget {
  const _SkeletonLine({required this.width, required this.height});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.centerLeft,
    child: SizedBox(
      width: width,
      child: _SkeletonBlock(height: height),
    ),
  );
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Container(
      constraints: const BoxConstraints(maxWidth: 440),
      margin: const EdgeInsets.all(LawrenceSpacing.lg),
      padding: const EdgeInsets.all(LawrenceSpacing.xl),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: LawrenceColors.borderMist),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.cloud_off_outlined,
            size: 52,
            color: LawrenceColors.wine,
          ),
          const SizedBox(height: LawrenceSpacing.md),
          Text(
            'Não foi possível carregar seus cursos',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: LawrenceSpacing.sm),
          const Text(
            'Verifique sua conexão e tente novamente. Seus rascunhos permanecem salvos.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: LawrenceSpacing.md),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Tentar novamente'),
          ),
        ],
      ),
    ),
  );
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(LawrenceSpacing.xl),
      child: Column(
        children: [
          const Icon(Icons.school_outlined, size: 52),
          const SizedBox(height: LawrenceSpacing.md),
          Text(
            'Seu primeiro curso começa aqui',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: LawrenceSpacing.sm),
          const Text('Crie um rascunho e continue no seu ritmo.'),
          const SizedBox(height: LawrenceSpacing.lg),
          FilledButton(onPressed: onCreate, child: const Text('Criar curso')),
        ],
      ),
    ),
  );
}

class _NoResults extends StatelessWidget {
  const _NoResults();

  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.all(LawrenceSpacing.xl),
    child: Center(child: Text('Nenhum curso corresponde aos filtros.')),
  );
}

const _filters = {
  'all': 'Todos',
  'published': 'Publicados',
  'draft': 'Rascunhos',
  'reviewing': 'Em revisão',
  'unpublished': 'Despublicados',
  'archived': 'Arquivados',
};

const _statusLabels = {
  'published': 'Publicado',
  'draft': 'Rascunho',
  'reviewing': 'Em revisão',
  'unpublished': 'Despublicado',
  'archived': 'Arquivado',
};
