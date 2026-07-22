import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../../../design_system/tokens/lawrence_theme.dart';
import '../../../../courses/domain/entities/course.dart';

class LessonEditorResult {
  const LessonEditorResult({
    required this.title,
    required this.description,
    required this.orderIndex,
    required this.status,
    this.video,
  });

  final String title;
  final String description;
  final int orderIndex;
  final String status;
  final PlatformFile? video;
}

class LessonEditorDialog extends StatefulWidget {
  const LessonEditorDialog({
    super.key,
    required this.defaultOrder,
    this.lesson,
  });

  final int defaultOrder;
  final Lesson? lesson;

  static Future<LessonEditorResult?> show(
    BuildContext context, {
    required int defaultOrder,
    Lesson? lesson,
  }) {
    return showDialog<LessonEditorResult>(
      context: context,
      barrierDismissible: false,
      builder: (_) =>
          LessonEditorDialog(defaultOrder: defaultOrder, lesson: lesson),
    );
  }

  @override
  State<LessonEditorDialog> createState() => _LessonEditorDialogState();
}

class _LessonEditorDialogState extends State<LessonEditorDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _description;
  late final TextEditingController _order;
  late String _status;
  PlatformFile? _video;

  bool get _isEditing => widget.lesson != null;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: widget.lesson?.title ?? '');
    _description = TextEditingController(
      text: widget.lesson?.description ?? '',
    );
    _order = TextEditingController(
      text: (widget.lesson?.orderIndex ?? widget.defaultOrder).toString(),
    );
    _status = widget.lesson?.status == 'published' ? 'published' : 'draft';
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _order.dispose();
    super.dispose();
  }

  Future<void> _pickVideo() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.video,
      allowMultiple: false,
      allowCompression: false,
    );
    if (result != null && mounted) {
      setState(() => _video = result.files.single);
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_video != null && _video!.path == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível acessar o arquivo.')),
      );
      return;
    }
    Navigator.pop(
      context,
      LessonEditorResult(
        title: _title.text.trim(),
        description: _description.text.trim(),
        orderIndex: int.parse(_order.text),
        status: _status,
        video: _video,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.viewInsetsOf(context);
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      backgroundColor: LawrenceColors.canvas,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(LawrenceTheme.radiusLg),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620),
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + viewInsets.bottom),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: LawrenceColors.primary.withValues(alpha: .10),
                        borderRadius: BorderRadius.circular(
                          LawrenceTheme.radiusMd,
                        ),
                      ),
                      child: const Icon(
                        Icons.play_lesson_outlined,
                        color: LawrenceColors.primary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isEditing ? 'Editar aula' : 'Nova aula',
                            style: const TextStyle(
                              color: LawrenceColors.textPrimary,
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _isEditing
                                ? 'Atualize esta aula sem alterar o módulo.'
                                : 'Crie uma unidade de aprendizado independente.',
                            style: const TextStyle(
                              color: LawrenceColors.textSecondary,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Fechar',
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _title,
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: 'Título da aula',
                    hintText: 'Ex.: Aula 01 — Introdução à modelagem',
                    prefixIcon: Icon(Icons.title),
                  ),
                  validator: (value) => value == null || value.trim().length < 3
                      ? 'Informe pelo menos 3 caracteres'
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _description,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Descrição',
                    hintText: 'Explique brevemente o que será aprendido.',
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _order,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Ordem',
                          prefixIcon: Icon(Icons.format_list_numbered),
                        ),
                        validator: (value) {
                          final order = int.tryParse(value ?? '');
                          return order == null || order < 0
                              ? 'Ordem inválida'
                              : null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _status,
                        decoration: const InputDecoration(
                          labelText: 'Status',
                          prefixIcon: Icon(Icons.visibility_outlined),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'draft',
                            child: Text('Rascunho'),
                          ),
                          DropdownMenuItem(
                            value: 'published',
                            child: Text('Publicada'),
                          ),
                        ],
                        onChanged: (value) => _status = value ?? 'draft',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Semantics(
                  button: true,
                  label: _isEditing
                      ? 'Selecionar novo vídeo para esta aula'
                      : 'Selecionar vídeo da aula',
                  child: InkWell(
                    onTap: _pickVideo,
                    borderRadius: BorderRadius.circular(LawrenceTheme.radiusMd),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: LawrenceColors.canvasParchment,
                        borderRadius: BorderRadius.circular(
                          LawrenceTheme.radiusMd,
                        ),
                        border: Border.all(color: LawrenceColors.borderMist),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.video_file_outlined,
                            color: LawrenceColors.primary,
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _video?.name ??
                                      (_isEditing
                                          ? 'Manter vídeo atual'
                                          : 'Selecionar vídeo'),
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: LawrenceColors.textPrimary,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'MP4, MOV ou M4V • até 2 GB',
                                  style: TextStyle(
                                    color: LawrenceColors.textSecondary,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancelar'),
                    ),
                    const SizedBox(width: 8),
                    FilledButton.icon(
                      onPressed: _submit,
                      icon: const Icon(Icons.check, size: 20),
                      label: Text(
                        _isEditing ? 'Salvar alterações' : 'Criar aula',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
