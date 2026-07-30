import 'package:flutter/material.dart';

import '../../../../../design_system/tokens/lawrence_theme.dart';
import '../../../../courses/domain/entities/course.dart';
import '../../../../lessons/presentation/widgets/lesson_content_renderer.dart';

class PublicationReview extends StatefulWidget {
  const PublicationReview({
    super.key,
    required this.course,
    required this.isPublishing,
    required this.loadChecklist,
    required this.loadVersions,
    required this.loadVersion,
    required this.restoreVersion,
    required this.onPublish,
    required this.onBack,
  });

  final Course course;
  final bool isPublishing;
  final Future<Map<String, dynamic>> Function() loadChecklist;
  final Future<List<Map<String, dynamic>>> Function() loadVersions;
  final Future<Map<String, dynamic>> Function(String versionId) loadVersion;
  final Future<bool> Function(
    String versionId,
    String expectedUpdatedAt,
    String? reason,
  )
  restoreVersion;
  final Future<bool> Function() onPublish;
  final VoidCallback onBack;

  @override
  State<PublicationReview> createState() => _PublicationReviewState();
}

class _PublicationReviewState extends State<PublicationReview> {
  late Future<Map<String, dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.loadChecklist();
  }

  void _reload() => setState(() => _future = widget.loadChecklist());

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(40),
              child: CircularProgressIndicator(
                semanticsLabel: 'Carregando revisão do curso',
              ),
            ),
          );
        }
        if (snapshot.hasError) {
          return Center(
            child: Column(
              children: [
                const Text('Não foi possível carregar a revisão.'),
                TextButton(
                  onPressed: _reload,
                  child: const Text('Tentar novamente'),
                ),
              ],
            ),
          );
        }
        final data = snapshot.data!;
        final issues = (data['issues'] as List? ?? const [])
            .map((item) => Map<String, dynamic>.from(item as Map))
            .toList();
        final ready = data['ready'] == true;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Revisão e publicação',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'A validação final será repetida pelo servidor.',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Wrap(
                  spacing: 24,
                  runSpacing: 12,
                  children: [
                    _Metric('Curso', widget.course.title),
                    _Metric(
                      'Preço',
                      widget.course.isFree
                          ? 'Gratuito'
                          : 'R\$ ${widget.course.monthlyPrice.toStringAsFixed(2)}',
                    ),
                    _Metric('Visibilidade', widget.course.visibility),
                    _Metric('Módulos', '${data['module_count']}'),
                    _Metric('Aulas', '${data['lesson_count']}'),
                    _Metric('Uploads pendentes', '${data['pending_uploads']}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            _VersionHistory(
              loadVersions: widget.loadVersions,
              loadVersion: widget.loadVersion,
              restoreVersion: widget.restoreVersion,
              onRestored: () {
                _reload();
                widget.onBack();
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Text(
                    ready
                        ? 'Pronto para publicar'
                        : '${data['blocking_count']} pendência(s) bloqueadora(s)',
                    style: TextStyle(
                      color: ready
                          ? LawrenceColors.success
                          : LawrenceColors.warning,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Atualizar checklist',
                  onPressed: _reload,
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),
            if (issues.isEmpty)
              const Card(
                child: ListTile(
                  leading: Icon(
                    Icons.check_circle,
                    color: LawrenceColors.success,
                  ),
                  title: Text('Nenhuma pendência encontrada.'),
                ),
              ),
            for (final issue in issues)
              Card(
                child: ListTile(
                  leading: Icon(
                    issue['severity'] == 'blocking'
                        ? Icons.error_outline
                        : Icons.info_outline,
                    color: issue['severity'] == 'blocking'
                        ? LawrenceColors.danger
                        : LawrenceColors.warning,
                  ),
                  title: Text(issue['label'].toString()),
                  subtitle: Text(
                    issue['severity'] == 'blocking'
                        ? 'Bloqueadora'
                        : 'Recomendada',
                  ),
                ),
              ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                OutlinedButton.icon(
                  onPressed: widget.onBack,
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Voltar e editar'),
                ),
                OutlinedButton.icon(
                  onPressed: () => _preview(context, data),
                  icon: const Icon(Icons.visibility_outlined),
                  label: const Text('Prévia como aluno'),
                ),
                FilledButton.icon(
                  onPressed: !ready || widget.isPublishing
                      ? null
                      : () async {
                          if (!await _confirm(context)) return;
                          if (await widget.onPublish() && mounted) {
                            await _success(context);
                          }
                        },
                  icon: widget.isPublishing
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.publish),
                  label: Text(
                    widget.isPublishing ? 'Publicando…' : 'Publicar agora',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Agendamento indisponível até existir um executor backend.',
              style: TextStyle(color: Colors.white60),
            ),
          ],
        );
      },
    );
  }

  Future<bool> _confirm(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Publicar curso agora?'),
            content: Text(
              '“${widget.course.title}” ficará disponível conforme preço e visibilidade.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: const Text('Confirmar'),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _success(BuildContext context) => showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => AlertDialog(
      icon: const Icon(
        Icons.check_circle,
        color: LawrenceColors.success,
        size: 52,
      ),
      title: const Text('Curso publicado com sucesso'),
      content: const Text(
        'A disponibilidade respeita a visibilidade e as regras de acesso.',
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('Continuar editando'),
        ),
      ],
    ),
  );

  void _preview(BuildContext context, Map<String, dynamic> data) {
    final modules = (data['structure'] as List? ?? const [])
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
    showDialog<void>(
      context: context,
      builder: (dialogContext) => Dialog.fullscreen(
        child: _StudentCoursePreview(
          title: widget.course.title,
          summary: widget.course.summary,
          modules: modules,
          onClose: () => Navigator.pop(dialogContext),
        ),
      ),
    );
  }
}

class _VersionHistory extends StatelessWidget {
  const _VersionHistory({
    required this.loadVersions,
    required this.loadVersion,
    required this.restoreVersion,
    required this.onRestored,
  });

  final Future<List<Map<String, dynamic>>> Function() loadVersions;
  final Future<Map<String, dynamic>> Function(String versionId) loadVersion;
  final Future<bool> Function(
    String versionId,
    String expectedUpdatedAt,
    String? reason,
  )
  restoreVersion;
  final VoidCallback onRestored;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: loadVersions(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Card(
            child: ListTile(
              leading: CircularProgressIndicator(),
              title: Text('Carregando histórico de versões'),
            ),
          );
        }
        if (snapshot.hasError) {
          return const Card(
            child: ListTile(
              leading: Icon(Icons.history_toggle_off),
              title: Text('Histórico temporariamente indisponível'),
            ),
          );
        }
        final versions = snapshot.data ?? const [];
        if (versions.isEmpty) {
          return const Card(
            child: ListTile(
              leading: Icon(Icons.history),
              title: Text('Nenhuma versão publicada'),
              subtitle: Text(
                'A primeira publicação criará uma versão imutável para os alunos.',
              ),
            ),
          );
        }
        return Card(
          child: ExpansionTile(
            leading: const Icon(Icons.history),
            title: Text('${versions.length} versão(ões) publicada(s)'),
            subtitle: const Text(
              'Edições atuais não alteram a versão vigente até republicar.',
            ),
            children: [
              for (final version in versions)
                ListTile(
                  leading: CircleAvatar(
                    child: Text('v${version['version_number']}'),
                  ),
                  title: Text(
                    version['change_summary']?.toString().trim().isNotEmpty ==
                            true
                        ? version['change_summary'].toString()
                        : 'Publicação sem resumo',
                  ),
                  subtitle: Text(
                    version['created_at']?.toString() ?? 'Data indisponível',
                  ),
                  trailing: version['is_current'] == true
                      ? const Chip(label: Text('Vigente'))
                      : const Icon(Icons.chevron_right),
                  onTap: () => _openVersion(context, version['id'].toString()),
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _openVersion(BuildContext context, String versionId) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => _VersionDetailDialog(
        load: () => loadVersion(versionId),
        restore: (expected, reason) =>
            restoreVersion(versionId, expected, reason),
        onRestored: onRestored,
      ),
    );
  }
}

class _VersionDetailDialog extends StatefulWidget {
  const _VersionDetailDialog({
    required this.load,
    required this.restore,
    required this.onRestored,
  });

  final Future<Map<String, dynamic>> Function() load;
  final Future<bool> Function(String expectedUpdatedAt, String? reason) restore;
  final VoidCallback onRestored;

  @override
  State<_VersionDetailDialog> createState() => _VersionDetailDialogState();
}

class _VersionDetailDialogState extends State<_VersionDetailDialog> {
  late final Future<Map<String, dynamic>> future = widget.load();
  bool restoring = false;

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Comparar versão publicada'),
    content: SizedBox(
      width: 720,
      child: FutureBuilder<Map<String, dynamic>>(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Text('Não foi possível carregar esta versão.');
          }
          final data = snapshot.data!;
          final comparison = Map<String, dynamic>.from(
            data['comparison'] as Map? ?? const {},
          );
          final oldCounts = Map<String, dynamic>.from(
            comparison['version'] as Map? ?? const {},
          );
          final currentCounts = Map<String, dynamic>.from(
            comparison['authoring'] as Map? ?? const {},
          );
          final fields = (comparison['changed_fields'] as List? ?? const []);
          final version = Map<String, dynamic>.from(data['snapshot'] as Map);
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'v${data['version_number']} • ${data['change_summary'] ?? 'Sem resumo'}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                Text(
                  fields.isEmpty
                      ? 'Os campos principais não mudaram.'
                      : 'Campos diferentes: ${fields.join(', ')}',
                ),
                const SizedBox(height: 12),
                Text(
                  'Estrutura da versão: ${oldCounts['modules'] ?? 0} módulos, '
                  '${oldCounts['lessons'] ?? 0} aulas e ${oldCounts['blocks'] ?? 0} blocos.',
                ),
                Text(
                  'Autoria atual: ${currentCounts['modules'] ?? 0} módulos, '
                  '${currentCounts['lessons'] ?? 0} aulas e ${currentCounts['blocks'] ?? 0} blocos.',
                ),
                const SizedBox(height: 16),
                FilledButton.tonalIcon(
                  onPressed: () => _previewSnapshot(context, version),
                  icon: const Icon(Icons.visibility_outlined),
                  label: const Text('Visualizar esta versão como aluno'),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Restaurar substitui a área de autoria. A versão pública vigente '
                  'continua inalterada até uma nova publicação.',
                ),
                if (data['is_current'] != true) ...[
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: restoring
                        ? null
                        : () => _restore(
                            context,
                            data['authoring_updated_at'].toString(),
                          ),
                    icon: const Icon(Icons.restore),
                    label: Text(
                      restoring ? 'Restaurando…' : 'Restaurar na autoria',
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    ),
    actions: [
      TextButton(
        onPressed: restoring ? null : () => Navigator.pop(context),
        child: const Text('Fechar'),
      ),
    ],
  );

  void _previewSnapshot(BuildContext context, Map<String, dynamic> snapshot) {
    final modules = (snapshot['modules'] as List? ?? const []).map((raw) {
      final module = Map<String, dynamic>.from(raw as Map);
      module['lessons'] = (module['lessons'] as List? ?? const []).map((
        rawLesson,
      ) {
        final lesson = Map<String, dynamic>.from(rawLesson as Map);
        lesson['blocks'] = lesson['lesson_blocks'] ?? const [];
        return lesson;
      }).toList();
      return module;
    }).toList();
    showDialog<void>(
      context: context,
      builder: (previewContext) => Dialog.fullscreen(
        child: _StudentCoursePreview(
          title: snapshot['title']?.toString() ?? 'Curso',
          summary: snapshot['summary']?.toString() ?? '',
          modules: modules,
          onClose: () => Navigator.pop(previewContext),
        ),
      ),
    );
  }

  Future<void> _restore(BuildContext context, String expected) async {
    final reason = await showDialog<String>(
      context: context,
      builder: (confirmContext) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text('Restaurar versão na autoria?'),
          content: TextField(
            controller: controller,
            maxLength: 500,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Motivo (opcional)',
              helperText: 'A ação será registrada no histórico.',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(confirmContext),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(confirmContext, controller.text),
              child: const Text('Confirmar restauração'),
            ),
          ],
        );
      },
    );
    if (reason == null || !mounted) return;
    setState(() => restoring = true);
    try {
      if (await widget.restore(expected, reason) && mounted) {
        Navigator.pop(context);
        widget.onRestored();
      }
    } finally {
      if (mounted) setState(() => restoring = false);
    }
  }
}

class _StudentCoursePreview extends StatefulWidget {
  const _StudentCoursePreview({
    required this.title,
    required this.summary,
    required this.modules,
    required this.onClose,
  });

  final String title;
  final String summary;
  final List<Map<String, dynamic>> modules;
  final VoidCallback onClose;

  @override
  State<_StudentCoursePreview> createState() => _StudentCoursePreviewState();
}

class _StudentCoursePreviewState extends State<_StudentCoursePreview> {
  Map<String, dynamic>? selectedLesson;

  @override
  void initState() {
    super.initState();
    for (final module in widget.modules) {
      final lessons = module['lessons'] as List? ?? const [];
      if (lessons.isNotEmpty) {
        selectedLesson = Map<String, dynamic>.from(lessons.first as Map);
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final navigation = _CourseTree(
      modules: widget.modules,
      selectedLessonId: selectedLesson?['id']?.toString(),
      onSelect: (lesson) => setState(() => selectedLesson = lesson),
    );
    final content = _LessonPreview(
      courseTitle: widget.title,
      courseSummary: widget.summary,
      lesson: selectedLesson,
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prévia como aluno'),
        leading: IconButton(
          tooltip: 'Fechar prévia',
          onPressed: widget.onClose,
          icon: const Icon(Icons.close),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Chip(
              avatar: Icon(Icons.visibility_outlined, size: 18),
              label: Text('Modo de prévia'),
            ),
          ),
        ],
      ),
      drawer: MediaQuery.sizeOf(context).width < 900
          ? Drawer(child: SafeArea(child: navigation))
          : null,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (MediaQuery.sizeOf(context).width >= 900)
            SizedBox(width: 320, child: navigation),
          Expanded(child: content),
        ],
      ),
    );
  }
}

class _CourseTree extends StatelessWidget {
  const _CourseTree({
    required this.modules,
    required this.selectedLessonId,
    required this.onSelect,
  });

  final List<Map<String, dynamic>> modules;
  final String? selectedLessonId;
  final ValueChanged<Map<String, dynamic>> onSelect;

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(LawrenceSpacing.md),
    children: [
      Text('Conteúdo do curso', style: Theme.of(context).textTheme.titleLarge),
      const SizedBox(height: LawrenceSpacing.md),
      for (final module in modules)
        ExpansionTile(
          initiallyExpanded: true,
          title: Text(module['title']?.toString() ?? 'Módulo'),
          children: [
            for (final rawLesson in module['lessons'] as List? ?? const [])
              Builder(
                builder: (context) {
                  final lesson = Map<String, dynamic>.from(rawLesson as Map);
                  return ListTile(
                    selected: lesson['id']?.toString() == selectedLessonId,
                    leading: const Icon(Icons.play_circle_outline),
                    title: Text(lesson['title']?.toString() ?? 'Aula'),
                    onTap: () {
                      onSelect(lesson);
                      if (Scaffold.maybeOf(context)?.hasDrawer ?? false) {
                        Navigator.pop(context);
                      }
                    },
                  );
                },
              ),
          ],
        ),
    ],
  );
}

class _LessonPreview extends StatelessWidget {
  const _LessonPreview({
    required this.courseTitle,
    required this.courseSummary,
    required this.lesson,
  });

  final String courseTitle;
  final String courseSummary;
  final Map<String, dynamic>? lesson;

  @override
  Widget build(BuildContext context) {
    if (lesson == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(LawrenceSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                courseTitle,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: LawrenceSpacing.sm),
              Text(courseSummary, textAlign: TextAlign.center),
              const SizedBox(height: LawrenceSpacing.lg),
              const Text('Adicione uma aula para visualizar o conteúdo.'),
            ],
          ),
        ),
      );
    }
    final blocks = (lesson!['blocks'] as List? ?? const [])
        .map(
          (item) => LessonContentBlock.fromJson(
            Map<String, dynamic>.from(item as Map),
          ),
        )
        .toList();
    return ListView(
      padding: const EdgeInsets.all(LawrenceSpacing.xl),
      children: [
        Text(
          lesson!['title']?.toString() ?? 'Aula',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: LawrenceSpacing.lg),
        const AspectRatio(
          aspectRatio: 16 / 9,
          child: ColoredBox(
            color: LawrenceColors.surfaceBlack,
            child: Center(
              child: Text(
                'Player seguro da aula',
                style: TextStyle(color: Colors.white70),
              ),
            ),
          ),
        ),
        const SizedBox(height: LawrenceSpacing.lg),
        LessonContentRenderer(blocks: blocks, isPreview: true),
      ],
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 150,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: LawrenceColors.textSecondary,
            fontSize: 12,
          ),
        ),
        Text(
          value,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ],
    ),
  );
}
