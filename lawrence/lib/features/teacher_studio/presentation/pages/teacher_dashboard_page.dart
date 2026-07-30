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
    return Scaffold(
      backgroundColor: LawrenceColors.canvasParchment,
      appBar: AppBar(
        title: const Text(
          'Área do professor',
          style: TextStyle(
            color: LawrenceColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: LawrenceColors.canvas,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: LawrenceColors.borderMist,
            height: 1,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Atualizar cursos',
            onPressed: () =>
                ref.read(teacherCoursesControllerProvider.notifier).reload(),
            icon: const Icon(Icons.refresh, color: LawrenceColors.textPrimary),
          ),
          IconButton(
            tooltip: 'Sair da conta',
            icon: const Icon(Icons.logout_rounded, color: LawrenceColors.danger),
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
        loading: () => const Center(
          child: CircularProgressIndicator(
            semanticsLabel: 'Carregando cursos do professor',
          ),
        ),
        error: (_, _) => _ErrorState(
          onRetry: () =>
              ref.read(teacherCoursesControllerProvider.notifier).reload(),
        ),
        data: (courses) => _content(context, courses),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/teacher/courses/new'),
        icon: const Icon(Icons.add, color: Colors.white),
        backgroundColor: LawrenceColors.primary,
        label: const Text('Criar novo curso', style: TextStyle(color: Colors.white)),
      ),
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

    return RefreshIndicator(
      onRefresh: () =>
          ref.read(teacherCoursesControllerProvider.notifier).reload(),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 96),
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: LawrenceSpacing.lg,
            runSpacing: LawrenceSpacing.md,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Seus cursos',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Crie, acompanhe e mantenha seu conteúdo publicado.',
                    style: TextStyle(color: LawrenceColors.textSecondary),
                  ),
                ],
              ),
              FilledButton.icon(
                onPressed: () => context.push('/teacher/courses/new'),
                icon: const Icon(Icons.add),
                label: const Text('Criar novo curso'),
              ),
            ],
          ),
          const SizedBox(height: LawrenceSpacing.xl),
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
          const SizedBox(height: LawrenceSpacing.xl),
          LayoutBuilder(
            builder: (context, constraints) {
              final search = TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  labelText: 'Buscar cursos',
                  prefixIcon: Icon(Icons.search),
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

class _CourseManagementCard extends StatelessWidget {
  const _CourseManagementCard({
    required this.course,
    required this.onEdit,
    required this.onUnpublish,
    required this.onArchive,
    required this.onRestore,
  });

  final Course course;
  final VoidCallback onEdit;
  final VoidCallback onUnpublish;
  final VoidCallback onArchive;
  final VoidCallback onRestore;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(LawrenceSpacing.lg),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: LawrenceColors.primary.withValues(alpha: .1),
              borderRadius: BorderRadius.circular(LawrenceRadii.card),
            ),
            child: const Icon(
              Icons.school_outlined,
              color: LawrenceColors.primary,
            ),
          ),
          const SizedBox(width: LawrenceSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: LawrenceSpacing.sm,
                  runSpacing: LawrenceSpacing.xs,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      course.title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    _StatusBadge(status: course.status),
                  ],
                ),
                const SizedBox(height: LawrenceSpacing.xs),
                Text(
                  '${course.modules.length} módulo(s) • ${course.category} • ${course.level}',
                  style: const TextStyle(color: LawrenceColors.textSecondary),
                ),
              ],
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
      ),
    ),
  );
}

class _MetricCard extends StatelessWidget {
  const _MetricCard(this.label, this.value, this.icon, this.color);

  final String label;
  final int value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(LawrenceSpacing.md),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: LawrenceSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$value',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
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

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(LawrenceSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off_outlined, size: 52),
          const SizedBox(height: LawrenceSpacing.md),
          const Text('Não foi possível carregar seus cursos.'),
          const SizedBox(height: LawrenceSpacing.md),
          FilledButton(
            onPressed: onRetry,
            child: const Text('Tentar novamente'),
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
