import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';

import '../../../../../design_system/tokens/lawrence_theme.dart';
import '../../../../courses/domain/entities/course.dart';
import '../../../domain/entities/upload_file_payload.dart';
import '../../controllers/course_wizard_controller.dart';
import '../../widgets/studio_cinematic_background.dart';

final _lessonBlocksProvider = FutureProvider.autoDispose
    .family<List<LessonBlock>, String>(
      (ref, lessonId) => ref
          .read(courseWizardControllerProvider.notifier)
          .listLessonBlocks(lessonId),
    );

class LessonBlocksEditorDialog extends ConsumerWidget {
  const LessonBlocksEditorDialog({super.key, required this.lessonId});
  final String lessonId;

  static Future<void> show(BuildContext context, String lessonId) =>
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) => LessonBlocksEditorDialog(lessonId: lessonId),
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(courseWizardControllerProvider).valueOrNull;
    Lesson? lesson;
    for (final module in state?.course?.modules ?? const <Module>[]) {
      for (final item in module.lessons) {
        if (item.id == lessonId) lesson = item;
      }
    }
    final blocksState = ref.watch(_lessonBlocksProvider(lessonId));
    final blocks = [...?blocksState.valueOrNull]
      ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
    return Dialog.fullscreen(
      child: Scaffold(
        backgroundColor: const Color(0xFF070B18),
        appBar: AppBar(
          backgroundColor: const Color(0xF20A1022),
          foregroundColor: Colors.white,
          title: Text(
            lesson == null ? 'Conteúdo da aula' : 'Conteúdo • ${lesson.title}',
          ),
          leading: IconButton(
            tooltip: 'Fechar editor',
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: Text(
                  state?.isSaving == true ? 'Salvando…' : 'Alterações salvas',
                  semanticsLabel: state?.isSaving == true
                      ? 'Salvando alterações'
                      : 'Alterações salvas',
                ),
              ),
            ),
          ],
        ),
        body: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF071022), Color(0xFF172153), Color(0xFF120D2D)],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    const Text(
                      'Construa a sequência com blocos seguros e consistentes. HTML livre não é permitido.',
                      style: TextStyle(color: Color(0xFFB8C1DD)),
                    ),
                    const SizedBox(height: 20),
                    if (blocksState.isLoading)
                      const Center(child: CircularProgressIndicator()),
                    if (blocksState.hasError)
                      _BlocksError(
                        onRetry: () =>
                            ref.invalidate(_lessonBlocksProvider(lessonId)),
                      ),
                    if (!blocksState.isLoading &&
                        !blocksState.hasError &&
                        blocks.isEmpty)
                      const _EmptyBlocks(),
                    for (var index = 0; index < blocks.length; index++)
                      _BlockCard(
                        block: blocks[index],
                        index: index,
                        onEdit: () => _openEditor(
                          context,
                          ref,
                          blocks[index],
                          blocks.length,
                        ),
                        onDuplicate: () async {
                          if (blocks[index].blockType == 'activity') {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Crie uma nova atividade para gerar uma validação e tentativas independentes.',
                                ),
                              ),
                            );
                            return;
                          }
                          await ref
                              .read(courseWizardControllerProvider.notifier)
                              .duplicateLessonBlock(lessonId, blocks[index].id);
                          ref.invalidate(_lessonBlocksProvider(lessonId));
                        },
                        onDelete: () => _delete(context, ref, blocks[index]),
                        onMoveUp: index == 0
                            ? null
                            : () =>
                                  _swap(ref, blocks[index], blocks[index - 1]),
                        onMoveDown: index == blocks.length - 1
                            ? null
                            : () =>
                                  _swap(ref, blocks[index], blocks[index + 1]),
                      ),
                    const SizedBox(height: 20),
                    FilledButton.icon(
                      onPressed: lesson == null
                          ? null
                          : () =>
                                _openEditor(context, ref, null, blocks.length),
                      icon: const Icon(Icons.add),
                      label: const Text('Adicionar bloco'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openEditor(
    BuildContext context,
    WidgetRef ref,
    LessonBlock? block,
    int order,
  ) async {
    final saved = await _BlockEditorDialog.show(
      context,
      block: block,
      order: order,
      onSave: (data) => ref
          .read(courseWizardControllerProvider.notifier)
          .saveLessonBlock(lessonId, data, blockId: block?.id),
      onUpload: (file) => ref
          .read(courseWizardControllerProvider.notifier)
          .uploadLessonAsset(lessonId: lessonId, file: file),
    );
    if (saved == true) {
      ref.invalidate(_lessonBlocksProvider(lessonId));
    }
  }

  Future<void> _swap(WidgetRef ref, LessonBlock a, LessonBlock b) async {
    final controller = ref.read(courseWizardControllerProvider.notifier);
    if (await controller.saveLessonBlock(lessonId, {
      'order_index': b.orderIndex,
    }, blockId: a.id)) {
      await controller.saveLessonBlock(lessonId, {
        'order_index': a.orderIndex,
      }, blockId: b.id);
      ref.invalidate(_lessonBlocksProvider(lessonId));
    }
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    LessonBlock block,
  ) async {
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (c) => AlertDialog(
            title: const Text('Arquivar bloco?'),
            content: const Text(
              'O bloco será removido da sequência sem apagar silenciosamente outros conteúdos.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(c, false),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(c, true),
                child: const Text('Arquivar'),
              ),
            ],
          ),
        ) ??
        false;
    if (confirmed) {
      await ref
          .read(courseWizardControllerProvider.notifier)
          .deleteLessonBlock(lessonId, block.id);
      ref.invalidate(_lessonBlocksProvider(lessonId));
    }
  }
}

class _BlockEditorDialog extends StatefulWidget {
  const _BlockEditorDialog({
    this.block,
    required this.order,
    required this.onSave,
    required this.onUpload,
  });
  final LessonBlock? block;
  final int order;
  final Future<bool> Function(Map<String, dynamic> data) onSave;
  final Future<Map<String, String>> Function(UploadFilePayload file) onUpload;
  static Future<bool?> show(
    BuildContext context, {
    LessonBlock? block,
    required int order,
    required Future<bool> Function(Map<String, dynamic> data) onSave,
    required Future<Map<String, String>> Function(UploadFilePayload file)
    onUpload,
  }) => showDialog<bool>(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.transparent,
    builder: (_) => StudioModalBackdrop(
      child: _BlockEditorDialog(
        block: block,
        order: order,
        onSave: onSave,
        onUpload: onUpload,
      ),
    ),
  );
  @override
  State<_BlockEditorDialog> createState() => _BlockEditorDialogState();
}

class _BlockEditorDialogState extends State<_BlockEditorDialog> {
  final _form = GlobalKey<FormState>();
  late String _type;
  late String _activityType;
  late final TextEditingController _title;
  late final TextEditingController _text;
  late final TextEditingController _url;
  late final TextEditingController _alt;
  late final TextEditingController _items;
  late final TextEditingController _maxAttempts;
  late final TextEditingController _passingScore;
  int? _correctItemIndex;
  String? _storagePath, _filename, _contentType;
  bool _uploading = false;
  bool _saving = false;
  String? _saveError;
  @override
  void initState() {
    super.initState();
    final c = widget.block?.content ?? const {};
    _type = widget.block?.blockType ?? 'text';
    final storedActivityType =
        c['activity_type']?.toString() ?? 'single_choice';
    _activityType = switch (storedActivityType) {
      'short_answer' => 'essay',
      'multiple_choice' => 'single_choice',
      'single_choice' || 'true_false' || 'essay' => storedActivityType,
      _ => 'single_choice',
    };
    _title = TextEditingController(text: c['title']?.toString() ?? '');
    _text = TextEditingController(
      text: c['text']?.toString() ?? c['question']?.toString() ?? '',
    );
    _url = TextEditingController(text: c['url']?.toString() ?? '');
    _alt = TextEditingController(text: c['alt_text']?.toString() ?? '');
    _items = TextEditingController(
      text: (c['items'] as List? ?? const []).join('\n'),
    );
    _correctItemIndex = (c['correct_index'] as num?)?.toInt();
    _maxAttempts = TextEditingController(
      text: (c['max_attempts'] as num?)?.toInt().toString() ?? '3',
    );
    _passingScore = TextEditingController(
      text: (c['passing_score'] as num?)?.toString() ?? '7',
    );
    _storagePath = c['storage_path']?.toString();
    _filename = c['filename']?.toString();
    _contentType = c['content_type']?.toString();
  }

  @override
  void dispose() {
    _title.dispose();
    _text.dispose();
    _url.dispose();
    _alt.dispose();
    _items.dispose();
    _maxAttempts.dispose();
    _passingScore.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Theme(
    data: studioTheme(context),
    child: AlertDialog(
      backgroundColor: const Color(0xE62C111B),
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
        side: BorderSide(color: Colors.white.withValues(alpha: .22)),
      ),
      title: Text(widget.block == null ? 'Adicionar bloco' : 'Editar bloco'),
      content: SizedBox(
        width: 620,
        child: Form(
          key: _form,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: _type,
                  decoration: const InputDecoration(labelText: 'Tipo de bloco'),
                  items: _types.entries
                      .map(
                        (e) => DropdownMenuItem(
                          value: e.key,
                          child: Text(e.value),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => _type = v ?? 'text'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _title,
                  maxLength: 200,
                  decoration: const InputDecoration(labelText: 'Título'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _text,
                  maxLines: 6,
                  maxLength: 20000,
                  decoration: InputDecoration(
                    labelText: _type == 'activity' ? 'Enunciado' : 'Texto',
                    helperText: _type == 'learn_more'
                        ? 'Use texto, referência e link; a apresentação do aluno será padronizada.'
                        : null,
                  ),
                  validator: (v) =>
                      [
                            'text',
                            'heading',
                            'notice',
                            'tip',
                            'summary',
                            'learn_more',
                            'activity',
                          ].contains(_type) &&
                          (v ?? '').trim().isEmpty
                      ? 'Informe o conteúdo'
                      : null,
                ),
                if ([
                  'image',
                  'pdf',
                  'download',
                  'audio',
                  'video',
                  'learn_more',
                ].contains(_type)) ...[
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _url,
                    maxLength: 2000,
                    decoration: const InputDecoration(
                      labelText: 'URL segura do arquivo ou referência',
                    ),
                    validator: (v) {
                      if ((v ?? '').isEmpty) return null;
                      final uri = Uri.tryParse(v!);
                      return uri == null || !['https'].contains(uri.scheme)
                          ? 'Use uma URL HTTPS válida'
                          : null;
                    },
                  ),
                ],
                if (['image', 'gallery', 'learn_more'].contains(_type)) ...[
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _alt,
                    maxLength: 240,
                    decoration: const InputDecoration(
                      labelText: 'Texto alternativo',
                    ),
                  ),
                ],
                if ([
                  'image',
                  'gallery',
                  'pdf',
                  'download',
                  'audio',
                  'material',
                ].contains(_type)) ...[
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _uploading ? null : _pickAsset,
                    icon: _uploading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.upload_file),
                    label: Text(
                      _filename == null
                          ? 'Enviar arquivo privado'
                          : 'Substituir $_filename',
                    ),
                  ),
                  const Text(
                    'JPG, PNG, WebP, PDF, MP3, M4A, WAV, OGG, ZIP ou DOCX • até 100 MB',
                    style: TextStyle(color: LawrenceColors.textSecondary),
                  ),
                ],
                if (_type == 'activity') ...[
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _activityType,
                    decoration: const InputDecoration(
                      labelText: 'Tipo de atividade',
                    ),
                    items: _activityTypes.entries
                        .map(
                          (e) => DropdownMenuItem(
                            value: e.key,
                            child: Text(e.value),
                          ),
                        )
                        .toList(),
                    onChanged: (v) =>
                        setState(() => _activityType = v ?? 'single_choice'),
                  ),
                  if (_activityType == 'single_choice') ...[
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _items,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        labelText: 'Alternativas',
                        helperText: 'Uma alternativa por linha',
                      ),
                      validator: (v) =>
                          (v ?? '')
                                  .trim()
                                  .split('\n')
                                  .where((e) => e.trim().isNotEmpty)
                                  .length <
                              2
                          ? 'Informe pelo menos duas alternativas'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    ValueListenableBuilder<TextEditingValue>(
                      valueListenable: _items,
                      builder: (context, value, _) => _AlternativesPreview(
                        items: value.text
                            .split('\n')
                            .map((item) => item.trim())
                            .where((item) => item.isNotEmpty)
                            .toList(),
                        multiple: false,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ValueListenableBuilder<TextEditingValue>(
                      valueListenable: _items,
                      builder: (context, value, _) {
                        final alternatives = value.text
                            .split('\n')
                            .map((item) => item.trim())
                            .where((item) => item.isNotEmpty)
                            .toList();
                        return DropdownButtonFormField<int>(
                          value:
                              _correctItemIndex != null &&
                                  _correctItemIndex! < alternatives.length
                              ? _correctItemIndex
                              : null,
                          decoration: const InputDecoration(
                            labelText: 'Alternativa correta',
                            helperText:
                                'Obrigatória para validar a resposta do aluno',
                          ),
                          items: [
                            for (
                              var index = 0;
                              index < alternatives.length;
                              index++
                            )
                              DropdownMenuItem(
                                value: index,
                                child: Text(
                                  '${String.fromCharCode(65 + index)} — ${alternatives[index]}',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                          ],
                          validator: (_) =>
                              alternatives.isNotEmpty &&
                                  _correctItemIndex == null
                              ? 'Selecione a alternativa correta'
                              : null,
                          onChanged: (value) =>
                              setState(() => _correctItemIndex = value),
                        );
                      },
                    ),
                  ],
                  if (_activityType == 'true_false') ...[
                    const SizedBox(height: 12),
                    DropdownButtonFormField<int>(
                      initialValue: _correctItemIndex,
                      decoration: const InputDecoration(
                        labelText: 'Resposta correta',
                      ),
                      items: const [
                        DropdownMenuItem(value: 0, child: Text('Verdadeiro')),
                        DropdownMenuItem(value: 1, child: Text('Falso')),
                      ],
                      validator: (value) =>
                          value == null ? 'Selecione a resposta correta' : null,
                      onChanged: (value) =>
                          setState(() => _correctItemIndex = value),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _maxAttempts,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Máximo de tentativas',
                          ),
                          validator: (value) {
                            final parsed = int.tryParse(value ?? '');
                            return parsed == null || parsed < 1 || parsed > 20
                                ? 'Use um valor de 1 a 20'
                                : null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _passingScore,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: const InputDecoration(
                            labelText: 'Nota mínima',
                            suffixText: '/ 10',
                          ),
                          validator: (value) {
                            final parsed = double.tryParse(
                              (value ?? '').replaceAll(',', '.'),
                            );
                            return parsed == null || parsed < 0 || parsed > 10
                                ? 'Use uma nota de 0 a 10'
                                : null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'As respostas serão registradas e validadas no servidor. A nota mínima participa da conclusão do curso.',
                    style: TextStyle(color: LawrenceColors.textSecondary),
                  ),
                ],
                if (_saveError != null) ...[
                  const SizedBox(height: 16),
                  Semantics(
                    liveRegion: true,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: LawrenceColors.danger.withValues(alpha: .16),
                        border: Border.all(color: LawrenceColors.danger),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _saveError!,
                        style: const TextStyle(color: Color(0xFFFFC2C7)),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _uploading || _saving
              ? null
              : () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _uploading || _saving ? null : _save,
          child: _saving
              ? const SizedBox.square(
                  dimension: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Salvar bloco'),
        ),
      ],
    ),
  );

  Map<String, dynamic> _payload() => {
    'block_type': _type,
    'order_index': widget.block?.orderIndex ?? widget.order,
    'status': 'draft',
    'content': {
      'title': _title.text.trim(),
      'text': _type == 'activity' ? '' : _text.text.trim(),
      'question': _type == 'activity' ? _text.text.trim() : null,
      'url': _url.text.trim(),
      'storage_path': _storagePath,
      'filename': _filename,
      'content_type': _contentType,
      'alt_text': _alt.text.trim(),
      'activity_type': _type == 'activity' ? _activityType : null,
      'items': _items.text
          .split('\n')
          .map((item) => item.trim())
          .where((item) => item.isNotEmpty)
          .toList(),
      'correct_index': _type == 'activity' ? _correctItemIndex : null,
      'max_attempts': _type == 'activity'
          ? int.tryParse(_maxAttempts.text)
          : null,
      'passing_score': _type == 'activity'
          ? double.tryParse(_passingScore.text.replaceAll(',', '.'))
          : null,
      'task_id': widget.block?.content['task_id'],
    },
  };

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _saveError = null;
    });
    final saved = await widget.onSave(_payload());
    if (!mounted) return;
    if (saved) {
      Navigator.pop(context, true);
      return;
    }
    setState(() {
      _saving = false;
      _saveError =
          'Não foi possível confirmar a gravação. Nada foi descartado: revise a conexão e tente salvar novamente.';
    });
  }

  Future<void> _pickAsset() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const [
        'jpg',
        'jpeg',
        'png',
        'webp',
        'pdf',
        'mp3',
        'm4a',
        'wav',
        'ogg',
        'zip',
        'docx',
      ],
      withData: kIsWeb,
    );
    final file = result?.files.single;
    if (file == null || (file.path == null && file.bytes == null)) return;
    final ext = (file.extension ?? '').toLowerCase();
    final mime = {
      'jpg': 'image/jpeg',
      'jpeg': 'image/jpeg',
      'png': 'image/png',
      'webp': 'image/webp',
      'pdf': 'application/pdf',
      'mp3': 'audio/mpeg',
      'm4a': 'audio/mp4',
      'wav': 'audio/wav',
      'ogg': 'audio/ogg',
      'zip': 'application/zip',
      'docx':
          'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    }[ext];
    if (mime == null) return;
    setState(() => _uploading = true);
    try {
      final uploaded = await widget.onUpload(
        UploadFilePayload(
          filename: file.name,
          sizeBytes: file.size,
          contentType: mime,
          path: file.path,
          bytes: file.bytes,
        ),
      );
      if (mounted) {
        setState(() {
          _storagePath = uploaded['storage_path'];
          _filename = uploaded['filename'];
          _contentType = uploaded['content_type'];
        });
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }
}

const _types = {
  'text': 'Texto',
  'heading': 'Título ou subtítulo',
  'video': 'Vídeo',
  'image': 'Imagem',
  'gallery': 'Galeria',
  'pdf': 'PDF',
  'download': 'Download',
  'audio': 'Áudio',
  'material': 'Material complementar',
  'notice': 'Aviso',
  'tip': 'Dica',
  'summary': 'Resumo',
  'learn_more': 'Saiba mais',
  'activity': 'Atividade',
};

class _AlternativesPreview extends StatelessWidget {
  const _AlternativesPreview({required this.items, required this.multiple});

  final List<String> items;
  final bool multiple;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Align(
        alignment: Alignment.centerLeft,
        child: Text(
          'Digite as alternativas para visualizar A, B, C e D.',
          style: TextStyle(color: LawrenceColors.textSecondary, fontSize: 12),
        ),
      );
    }
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF181315),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0x406B4A55)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            multiple
                ? 'PRÉVIA · O ALUNO PODERÁ MARCAR MAIS DE UMA'
                : 'PRÉVIA · O ALUNO MARCARÁ UMA ALTERNATIVA',
            style: const TextStyle(
              color: Color(0xFFA63B5E),
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: .8,
            ),
          ),
          const SizedBox(height: 10),
          for (var index = 0; index < items.length; index++)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(
                    multiple
                        ? Icons.check_box_outline_blank
                        : Icons.radio_button_unchecked,
                    color: const Color(0xFFA63B5E),
                    size: 20,
                  ),
                  const SizedBox(width: 9),
                  Container(
                    width: 24,
                    height: 24,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xFF6B1328).withValues(alpha: .2),
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Text(
                      String.fromCharCode(65 + index),
                      style: const TextStyle(
                        color: Color(0xFFC8C2FF),
                        fontWeight: FontWeight.w800,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  const SizedBox(width: 9),
                  Expanded(child: Text(items[index])),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

const _activityTypes = {
  'single_choice': 'Marcar uma alternativa',
  'true_false': 'Verdadeiro ou falso',
  'essay': 'Dissertativa',
};

class _BlockCard extends StatelessWidget {
  const _BlockCard({
    required this.block,
    required this.index,
    required this.onEdit,
    required this.onDuplicate,
    required this.onDelete,
    this.onMoveUp,
    this.onMoveDown,
  });
  final LessonBlock block;
  final int index;
  final VoidCallback onEdit, onDuplicate, onDelete;
  final VoidCallback? onMoveUp, onMoveDown;
  @override
  Widget build(BuildContext context) => Card(
    color: const Color(0xCC2C111B),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: const BorderSide(color: Color(0x33A63B5E)),
    ),
    child: ListTile(
      leading: CircleAvatar(
        backgroundColor: const Color(0xFF6B1328),
        foregroundColor: Colors.white,
        child: Text('${index + 1}'),
      ),
      title: Text(
        _types[block.blockType] ?? block.blockType,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
      subtitle: Text(
        block.content['title']?.toString().isNotEmpty == true
            ? block.content['title'].toString()
            : (block.content['text']?.toString() ?? 'Bloco sem resumo'),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(color: Color(0xFFB8C1DD)),
      ),
      trailing: PopupMenuButton<String>(
        onSelected: (v) {
          if (v == 'edit') onEdit();
          if (v == 'copy') onDuplicate();
          if (v == 'up') onMoveUp?.call();
          if (v == 'down') onMoveDown?.call();
          if (v == 'delete') onDelete();
        },
        itemBuilder: (_) => [
          const PopupMenuItem(value: 'edit', child: Text('Editar')),
          const PopupMenuItem(value: 'copy', child: Text('Duplicar')),
          PopupMenuItem(
            value: 'up',
            enabled: onMoveUp != null,
            child: const Text('Mover para cima'),
          ),
          PopupMenuItem(
            value: 'down',
            enabled: onMoveDown != null,
            child: const Text('Mover para baixo'),
          ),
          const PopupMenuItem(value: 'delete', child: Text('Arquivar')),
        ],
      ),
    ),
  );
}

class _EmptyBlocks extends StatelessWidget {
  const _EmptyBlocks();
  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.all(32),
    child: Column(
      children: [
        Icon(
          Icons.view_agenda_outlined,
          size: 48,
          color: LawrenceColors.primary,
        ),
        SizedBox(height: 12),
        Text(
          'Nenhum bloco criado',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        Text(
          'Adicione texto, mídia, “Saiba mais” ou uma atividade na ordem em que o aluno verá.',
        ),
      ],
    ),
  );
}

class _BlocksError extends StatelessWidget {
  const _BlocksError({required this.onRetry});
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      children: [
        const Text('Não foi possível carregar os blocos.'),
        TextButton(onPressed: onRetry, child: const Text('Tentar novamente')),
      ],
    ),
  );
}
