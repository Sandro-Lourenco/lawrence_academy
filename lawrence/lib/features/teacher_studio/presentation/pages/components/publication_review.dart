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
        final blockers = issues
            .where((issue) => issue['severity'] == 'blocking')
            .toList();
        final recommendations = issues
            .where((issue) => issue['severity'] != 'blocking')
            .toList();
        final completedChecks = ready
            ? 100
            : (100 - blockers.length * 12).clamp(12, 88);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'FASE 5 DE 5',
              style: TextStyle(
                color: Color(0xFFA63B5E),
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.4,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Revise com confiança. Publique sem surpresa.',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                letterSpacing: -.8,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Confira a oferta, o conteúdo e a experiência do aluno antes do lançamento.',
              style: TextStyle(color: Color(0xFFB8C1DD), fontSize: 16),
            ),
            const SizedBox(height: 24),
            _ReadinessSummary(
              percent: completedChecks,
              ready: ready,
              title: widget.course.title,
              price: widget.course.isFree
                  ? 'Gratuito'
                  : 'R\$ ${widget.course.monthlyPrice.toStringAsFixed(2).replaceAll('.', ',')} / mês',
              visibility: widget.course.visibility,
              modules: '${data['module_count']}',
              lessons: '${data['lesson_count']}',
              pendingUploads: '${data['pending_uploads']}',
            ),
            const SizedBox(height: 24),
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
                color: Color(0xCC102A28),
                child: ListTile(
                  leading: Icon(
                    Icons.check_circle,
                    color: LawrenceColors.success,
                  ),
                  title: Text(
                    'Nenhuma pendência encontrada.',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            if (blockers.isNotEmpty) ...[
              const SizedBox(height: 8),
              const _ReviewGroupHeader(
                icon: Icons.error_outline,
                title: 'Corrija antes de publicar',
                description: 'Estes itens impedem o lançamento do curso.',
                color: LawrenceColors.danger,
              ),
              const SizedBox(height: 10),
              for (final issue in blockers)
                _IssueCard(issue: issue, blocking: true, onEdit: widget.onBack),
            ],
            if (recommendations.isNotEmpty) ...[
              const SizedBox(height: 18),
              ExpansionTile(
                tilePadding: EdgeInsets.zero,
                leading: const Icon(
                  Icons.lightbulb_outline,
                  color: LawrenceColors.warning,
                ),
                title: Text(
                  '${recommendations.length} recomendação(ões) para melhorar o lançamento',
                ),
                subtitle: const Text(
                  'O curso pode ser publicado sem estes ajustes.',
                ),
                children: [
                  for (final issue in recommendations)
                    _IssueCard(
                      issue: issue,
                      blocking: false,
                      onEdit: widget.onBack,
                    ),
                ],
              ),
            ],
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xE62C111B),
                border: Border.all(color: const Color(0x33A63B5E)),
                borderRadius: BorderRadius.circular(18),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x14071833),
                    blurRadius: 24,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.end,
                children: [
                  OutlinedButton.icon(
                    onPressed: widget.onBack,
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Voltar e editar'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFC8C2FF),
                      side: const BorderSide(color: Color(0xFF766AF2)),
                      minimumSize: const Size(180, 52),
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => _preview(context, data),
                    icon: const Icon(Icons.visibility_outlined),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFC8C2FF),
                      side: const BorderSide(color: Color(0xFF766AF2)),
                      minimumSize: const Size(200, 52),
                    ),
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
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF6B1328),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(190, 52),
                    ),
                    label: Text(
                      widget.isPublishing ? 'Publicando…' : 'Publicar agora',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Agendamento indisponível até existir um executor backend.',
              style: TextStyle(color: LawrenceColors.textSecondary),
            ),
            const SizedBox(height: 24),
            _VersionHistory(
              loadVersions: widget.loadVersions,
              loadVersion: widget.loadVersion,
              restoreVersion: widget.restoreVersion,
              onRestored: () {
                _reload();
                widget.onBack();
              },
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
          monthlyPrice: widget.course.monthlyPrice,
          isFree: widget.course.isFree,
          visibility: widget.course.visibility,
          certificateEnabled: widget.course.certificateEnabled,
          onClose: () => Navigator.pop(dialogContext),
        ),
      ),
    );
  }
}

class _ReadinessSummary extends StatelessWidget {
  const _ReadinessSummary({
    required this.percent,
    required this.ready,
    required this.title,
    required this.price,
    required this.visibility,
    required this.modules,
    required this.lessons,
    required this.pendingUploads,
  });

  final num percent;
  final bool ready;
  final String title;
  final String price;
  final String visibility;
  final String modules;
  final String lessons;
  final String pendingUploads;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xE62C111B), Color(0xD94B0C1B)],
      ),
      border: Border.all(color: const Color(0x55A63B5E)),
      borderRadius: BorderRadius.circular(22),
      boxShadow: const [
        BoxShadow(
          color: Color(0x0A071833),
          blurRadius: 26,
          offset: Offset(0, 10),
        ),
      ],
    ),
    child: LayoutBuilder(
      builder: (context, constraints) {
        final score = SizedBox(
          width: 118,
          child: Column(
            children: [
              SizedBox(
                width: 78,
                height: 78,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(
                      value: percent / 100,
                      strokeWidth: 7,
                      backgroundColor: const Color(0xFF29314D),
                      color: ready
                          ? LawrenceColors.success
                          : LawrenceColors.primary,
                    ),
                    Center(
                      child: Text(
                        '$percent%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                ready ? 'Pronto' : 'Em preparação',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        );
        final details = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 24,
              runSpacing: 14,
              children: [
                _Metric('Preço para o aluno', price),
                _Metric('Visibilidade', _visibilityLabel(visibility)),
                _Metric('Estrutura', '$modules módulos • $lessons aulas'),
                _Metric('Uploads pendentes', pendingUploads),
              ],
            ),
          ],
        );
        if (constraints.maxWidth < 620) {
          return Column(
            children: [
              score,
              const SizedBox(height: 20),
              Align(alignment: Alignment.centerLeft, child: details),
            ],
          );
        }
        return Row(
          children: [
            score,
            const SizedBox(width: 24),
            Expanded(child: details),
          ],
        );
      },
    ),
  );

  static String _visibilityLabel(String value) => switch (value) {
    'unlisted' => 'Somente por link',
    'private' => 'Privado',
    _ => 'Catálogo público',
  };
}

class _ReviewGroupHeader extends StatelessWidget {
  const _ReviewGroupHeader({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, color: color),
      const SizedBox(width: 10),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
            ),
            Text(
              description,
              style: const TextStyle(color: LawrenceColors.textSecondary),
            ),
          ],
        ),
      ),
    ],
  );
}

class _IssueCard extends StatelessWidget {
  const _IssueCard({
    required this.issue,
    required this.blocking,
    required this.onEdit,
  });
  final Map<String, dynamic> issue;
  final bool blocking;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: blocking
          ? LawrenceColors.danger.withValues(alpha: .05)
          : LawrenceColors.warning.withValues(alpha: .05),
      border: Border.all(
        color: (blocking ? LawrenceColors.danger : LawrenceColors.warning)
            .withValues(alpha: .22),
      ),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Row(
      children: [
        Icon(
          blocking ? Icons.error_outline : Icons.info_outline,
          color: blocking ? LawrenceColors.danger : LawrenceColors.warning,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                issue['label'].toString(),
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              Text(
                blocking ? 'Bloqueia a publicação' : 'Melhoria recomendada',
                style: const TextStyle(
                  color: LawrenceColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        TextButton.icon(
          onPressed: onEdit,
          icon: const Icon(Icons.edit_outlined, size: 17),
          label: const Text('Corrigir'),
        ),
      ],
    ),
  );
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
    this.monthlyPrice = 0,
    this.isFree = true,
    this.visibility = 'public',
    this.certificateEnabled = false,
  });

  final String title;
  final String summary;
  final List<Map<String, dynamic>> modules;
  final VoidCallback onClose;
  final double monthlyPrice;
  final bool isFree;
  final String visibility;
  final bool certificateEnabled;

  @override
  State<_StudentCoursePreview> createState() => _StudentCoursePreviewState();
}

class _StudentCoursePreviewState extends State<_StudentCoursePreview> {
  Map<String, dynamic>? selectedLesson;
  String mode = 'sales';
  String viewport = 'desktop';

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
    final lessonContent = _LessonPreview(
      courseTitle: widget.title,
      courseSummary: widget.summary,
      lesson: selectedLesson,
    );
    final salesContent = _SalesPreview(
      title: widget.title,
      summary: widget.summary,
      modules: widget.modules,
      monthlyPrice: widget.monthlyPrice,
      isFree: widget.isFree,
      visibility: widget.visibility,
      certificateEnabled: widget.certificateEnabled,
    );
    final content = mode == 'sales' ? salesContent : lessonContent;
    final width = switch (viewport) {
      'mobile' => 390.0,
      'tablet' => 768.0,
      _ => double.infinity,
    };
    return Scaffold(
      backgroundColor: const Color(0xFFEEF2F7),
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Prévia como aluno',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            Text(
              'Nenhuma compra ou publicação será realizada',
              style: TextStyle(
                fontSize: 12,
                color: LawrenceColors.textSecondary,
              ),
            ),
          ],
        ),
        leading: IconButton(
          tooltip: 'Fechar prévia',
          onPressed: widget.onClose,
          icon: const Icon(Icons.close),
        ),
        actions: [
          if (MediaQuery.sizeOf(context).width >= 760) ...[
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                  value: 'sales',
                  icon: Icon(Icons.storefront_outlined),
                  label: Text('Página do curso'),
                ),
                ButtonSegment(
                  value: 'lesson',
                  icon: Icon(Icons.play_circle_outline),
                  label: Text('Experiência da aula'),
                ),
              ],
              selected: {mode},
              onSelectionChanged: (value) => setState(() => mode = value.first),
            ),
            const SizedBox(width: 12),
            SegmentedButton<String>(
              showSelectedIcon: false,
              segments: const [
                ButtonSegment(
                  value: 'desktop',
                  icon: Icon(Icons.desktop_windows_outlined),
                  tooltip: 'Desktop',
                ),
                ButtonSegment(
                  value: 'tablet',
                  icon: Icon(Icons.tablet_mac_outlined),
                  tooltip: 'Tablet',
                ),
                ButtonSegment(
                  value: 'mobile',
                  icon: Icon(Icons.phone_iphone_outlined),
                  tooltip: 'Celular',
                ),
              ],
              selected: {viewport},
              onSelectionChanged: (value) =>
                  setState(() => viewport = value.first),
            ),
          ],
          const SizedBox(width: 16),
        ],
      ),
      drawer: mode == 'lesson' && MediaQuery.sizeOf(context).width < 900
          ? Drawer(child: SafeArea(child: navigation))
          : null,
      body: Column(
        children: [
          if (MediaQuery.sizeOf(context).width < 760)
            Padding(
              padding: const EdgeInsets.all(12),
              child: SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'sales', label: Text('Página do curso')),
                  ButtonSegment(value: 'lesson', label: Text('Aula')),
                ],
                selected: {mode},
                onSelectionChanged: (value) =>
                    setState(() => mode = value.first),
              ),
            ),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (mode == 'lesson' &&
                    MediaQuery.sizeOf(context).width >= 900 &&
                    viewport == 'desktop')
                  SizedBox(width: 300, child: navigation),
                Expanded(
                  child: Center(
                    child: AnimatedContainer(
                      duration: MediaQuery.disableAnimationsOf(context)
                          ? Duration.zero
                          : const Duration(milliseconds: 280),
                      width: width,
                      margin: EdgeInsets.all(viewport == 'desktop' ? 0 : 20),
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        color: LawrenceColors.canvas,
                        borderRadius: BorderRadius.circular(
                          viewport == 'desktop' ? 0 : 22,
                        ),
                        boxShadow: viewport == 'desktop'
                            ? null
                            : const [
                                BoxShadow(
                                  color: Color(0x26071833),
                                  blurRadius: 32,
                                  offset: Offset(0, 14),
                                ),
                              ],
                      ),
                      child: content,
                    ),
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

class _SalesPreview extends StatelessWidget {
  const _SalesPreview({
    required this.title,
    required this.summary,
    required this.modules,
    required this.monthlyPrice,
    required this.isFree,
    required this.visibility,
    required this.certificateEnabled,
  });

  final String title;
  final String summary;
  final List<Map<String, dynamic>> modules;
  final double monthlyPrice;
  final bool isFree;
  final String visibility;
  final bool certificateEnabled;

  @override
  Widget build(BuildContext context) => ListView(
    children: [
      Container(
        constraints: const BoxConstraints(minHeight: 340),
        padding: const EdgeInsets.all(36),
        decoration: const BoxDecoration(color: Color(0xFF071833)),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 720;
            final copy = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'CURSO LAWRENCE ACADEMY',
                  style: TextStyle(
                    color: Color(0xFF8DC8FF),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.3,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  title.isEmpty ? 'Título do seu curso' : title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: compact ? 32 : 44,
                    height: 1.05,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1.4,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  summary.isEmpty
                      ? 'O resumo do curso aparecerá aqui para apresentar sua transformação.'
                      : summary,
                  style: const TextStyle(
                    color: Color(0xFFBDC9D9),
                    fontSize: 16,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 24),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _PreviewPill(
                      icon: Icons.menu_book_outlined,
                      label: '${modules.length} módulos',
                    ),
                    if (certificateEnabled)
                      const _PreviewPill(
                        icon: Icons.workspace_premium_outlined,
                        label: 'Certificado',
                      ),
                    _PreviewPill(
                      icon: Icons.visibility_outlined,
                      label: _previewVisibility(visibility),
                    ),
                  ],
                ),
              ],
            );
            final offer = Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Acesso completo',
                    style: TextStyle(color: LawrenceColors.textSecondary),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isFree
                        ? 'Gratuito'
                        : 'R\$ ${monthlyPrice.toStringAsFixed(2).replaceAll('.', ',')} / mês',
                    style: const TextStyle(
                      color: LawrenceColors.textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 18),
                  FilledButton(
                    onPressed: null,
                    child: Text(isFree ? 'Começar agora' : 'Assinar curso'),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'CTA desabilitado no modo prévia',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: LawrenceColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            );
            if (compact) {
              return Column(
                children: [copy, const SizedBox(height: 28), offer],
              );
            }
            return Row(
              children: [
                Expanded(child: copy),
                const SizedBox(width: 36),
                SizedBox(width: 280, child: offer),
              ],
            );
          },
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'O que você vai aprender',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 18),
            for (final module in modules)
              Card(
                elevation: 0,
                child: ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.auto_awesome, size: 18),
                  ),
                  title: Text(module['title']?.toString() ?? 'Módulo'),
                  subtitle: Text(
                    '${(module['lessons'] as List? ?? const []).length} aulas',
                  ),
                  trailing: const Icon(Icons.expand_more),
                ),
              ),
          ],
        ),
      ),
    ],
  );

  static String _previewVisibility(String value) => switch (value) {
    'unlisted' => 'Somente por link',
    'private' => 'Privado',
    _ => 'Catálogo público',
  };
}

class _PreviewPill extends StatelessWidget {
  const _PreviewPill({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      color: const Color(0x1FFFFFFF),
      borderRadius: BorderRadius.circular(99),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white70, size: 16),
        const SizedBox(width: 7),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    ),
  );
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
          style: const TextStyle(color: Color(0xFFB8C1DD), fontSize: 12),
        ),
        Text(
          value,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
  );
}
