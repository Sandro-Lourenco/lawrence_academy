import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../../../../design_system/tokens/lawrence_theme.dart';
import '../../../../courses/domain/entities/course.dart';
import 'selected_video_preview.dart';
import '../../widgets/studio_cinematic_background.dart';

const _maxVideoUploadBytes = 50 * 1024 * 1024;

class LessonEditorResult {
  const LessonEditorResult({
    required this.title,
    required this.description,
    required this.orderIndex,
    required this.status,
    required this.estimatedDurationMinutes,
    required this.isRequired,
    this.video,
    this.videoUrl,
    this.removeExternalVideo = false,
  });

  final String title;
  final String description;
  final int orderIndex;
  final String status;
  final int? estimatedDurationMinutes;
  final bool isRequired;
  final PlatformFile? video;
  final String? videoUrl;
  final bool removeExternalVideo;
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
      barrierColor: Colors.transparent,
      builder: (_) => StudioModalBackdrop(
        child: LessonEditorDialog(defaultOrder: defaultOrder, lesson: lesson),
      ),
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
  late final TextEditingController _estimatedDuration;
  late final TextEditingController _videoUrl;
  late bool _isRequired;
  late String _videoSource;
  PlatformFile? _video;
  SelectedVideoPreview? _videoMetadata;

  bool get _isEditing => widget.lesson != null;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: widget.lesson?.title ?? '');
    _description = TextEditingController(
      text: widget.lesson?.description ?? '',
    );
    _order = TextEditingController(
      text: ((widget.lesson?.orderIndex ?? widget.defaultOrder) + 1).toString(),
    );
    _status = widget.lesson?.status == 'published' ? 'published' : 'draft';
    _estimatedDuration = TextEditingController(
      text: widget.lesson?.estimatedDurationMinutes?.toString() ?? '',
    );
    _videoUrl = TextEditingController();
    _isRequired = widget.lesson?.isRequired ?? true;
    _videoSource =
        widget.lesson?.videoSourceType == 'youtube' ||
            widget.lesson?.videoSourceType == 'vimeo'
        ? 'link'
        : 'upload';
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _order.dispose();
    _estimatedDuration.dispose();
    _videoUrl.dispose();
    _videoMetadata?.dispose();
    super.dispose();
  }

  Future<void> _pickVideo() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['mp4', 'mov', 'm4v'],
      allowMultiple: false,
      allowCompression: false,
      withData: kIsWeb,
    );
    if (result == null || !mounted) return;
    final file = result.files.single;
    if (file.size > _maxVideoUploadBytes) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'O vídeo excede 50 MB. Comprima o arquivo ou escolha um vídeo menor.',
          ),
        ),
      );
      return;
    }
    final previous = _videoMetadata;
    final preview = await SelectedVideoPreview.create(
      file,
      _contentType(file.extension),
    );
    await previous?.dispose();
    if (!mounted) {
      await preview.dispose();
      return;
    }
    final duration = preview.controller?.value.duration;
    setState(() {
      _video = file;
      _videoMetadata = preview;
      if (_title.text.trim().isEmpty) {
        _title.text = _titleFromFilename(file.name);
      }
      if (duration != null && duration.inSeconds > 0) {
        _estimatedDuration.text = (duration.inSeconds / 60).ceil().toString();
      }
    });
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final hadExternalVideo =
        widget.lesson?.videoSourceType == 'youtube' ||
        widget.lesson?.videoSourceType == 'vimeo';
    if (_videoSource == 'upload' && hadExternalVideo && _video == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione um arquivo para substituir o link atual.'),
        ),
      );
      return;
    }
    if (_video != null && _video!.path == null && _video!.bytes == null) {
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
        orderIndex: int.parse(_order.text) - 1,
        status: _status,
        estimatedDurationMinutes: int.tryParse(_estimatedDuration.text),
        isRequired: _isRequired,
        video: _videoSource == 'upload' ? _video : null,
        videoUrl: _videoSource == 'link' && _videoUrl.text.trim().isNotEmpty
            ? _videoUrl.text.trim()
            : null,
        removeExternalVideo: _videoSource == 'upload' && hadExternalVideo,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.viewInsetsOf(context);
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(LawrenceTheme.radiusLg),
      ),
      child: StudioModalPanel(
        width: 620,
        padding: EdgeInsets.zero,
        child: Theme(
          data: _lessonTheme(context),
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
                          color: const Color(0xFF6B1328).withValues(alpha: .22),
                          borderRadius: BorderRadius.circular(
                            LawrenceTheme.radiusMd,
                          ),
                        ),
                        child: const Icon(
                          Icons.play_lesson_outlined,
                          color: Color(0xFFA63B5E),
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
                                color: Colors.white,
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
                                color: Color(0xFFB8C1DD),
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
                    validator: (value) =>
                        value == null || value.trim().length < 3
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
                            return order == null || order < 1
                                ? 'Ordem inválida'
                                : null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: _status,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Status da aula',
                            prefixIcon: Icon(Icons.visibility_outlined),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'draft',
                              child: Text('Rascunho'),
                            ),
                            DropdownMenuItem(
                              value: 'published',
                              child: Text(
                                'Pronta para publicar',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                          onChanged: (value) => _status = value ?? 'draft',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _estimatedDuration,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Duração estimada (minutos)',
                      helperText: _videoSource == 'link'
                          ? 'Obrigatória para calcular o progresso da aula externa.'
                          : 'Após o processamento, a duração real será calculada automaticamente.',
                    ),
                    validator: (value) {
                      if ((value ?? '').trim().isEmpty) {
                        return _videoSource == 'link'
                            ? 'Informe a duração da aula por link'
                            : null;
                      }
                      final minutes = int.tryParse(value!);
                      return minutes == null || minutes < 1 || minutes > 1440
                          ? 'Informe de 1 a 1440 minutos'
                          : null;
                    },
                  ),
                  Material(
                    type: MaterialType.transparency,
                    child: SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Aula obrigatória'),
                      subtitle: const Text(
                        'Recomendação de estrutura; impacto no certificado depende da regra de produto.',
                      ),
                      value: _isRequired,
                      onChanged: (value) => setState(() => _isRequired = value),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Fonte do vídeo',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(
                          value: 'upload',
                          icon: Icon(Icons.upload_file_outlined),
                          label: Text('Enviar arquivo'),
                        ),
                        ButtonSegment(
                          value: 'link',
                          icon: Icon(Icons.link_outlined),
                          label: Text('Usar link'),
                        ),
                      ],
                      selected: {_videoSource},
                      showSelectedIcon: false,
                      onSelectionChanged: (selection) {
                        setState(() => _videoSource = selection.single);
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_videoSource == 'link') ...[
                    TextFormField(
                      controller: _videoUrl,
                      keyboardType: TextInputType.url,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.url],
                      decoration: InputDecoration(
                        labelText: 'Link do vídeo',
                        hintText: 'https://www.youtube.com/watch?v=...',
                        prefixIcon: const Icon(Icons.ondemand_video_outlined),
                        helperText:
                            _isEditing &&
                                (widget.lesson?.videoSourceType == 'youtube' ||
                                    widget.lesson?.videoSourceType == 'vimeo')
                            ? 'Vídeo ${widget.lesson!.videoSourceType == 'youtube' ? 'do YouTube' : 'do Vimeo'} já vinculado. Deixe vazio para manter ou cole outro link.'
                            : 'Aceita links HTTPS oficiais do YouTube e Vimeo.',
                      ),
                      validator: (value) {
                        final raw = value?.trim() ?? '';
                        final hasExistingExternal =
                            _isEditing &&
                            (widget.lesson?.videoSourceType == 'youtube' ||
                                widget.lesson?.videoSourceType == 'vimeo');
                        if (raw.isEmpty) {
                          return hasExistingExternal
                              ? null
                              : 'Cole o link do vídeo';
                        }
                        return _externalVideoUrlError(raw);
                      },
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'O aluno abre o vídeo somente após a plataforma validar o acesso ao curso.',
                      style: TextStyle(color: Color(0xFFB8C1DD), fontSize: 13),
                    ),
                  ] else ...[
                    Semantics(
                      button: true,
                      label: _isEditing
                          ? 'Selecionar novo vídeo para esta aula'
                          : 'Selecionar vídeo da aula',
                      child: InkWell(
                        onTap: _pickVideo,
                        borderRadius: BorderRadius.circular(
                          LawrenceTheme.radiusMd,
                        ),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0x99181315),
                            borderRadius: BorderRadius.circular(
                              LawrenceTheme.radiusMd,
                            ),
                            border: Border.all(
                              color: LawrenceColors.borderMist,
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.video_file_outlined,
                                color: Color(0xFFA63B5E),
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
                                        color: Colors.white,
                                        fontSize: 17,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    const Text(
                                      'MP4, MOV ou M4V • até 50 MB • processamento automático em HLS',
                                      style: TextStyle(
                                        color: Color(0xFFB8C1DD),
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
                    if (_videoMetadata?.controller?.value.isInitialized ==
                        true) ...[
                      const SizedBox(height: 16),
                      _LessonVideoPreview(
                        controller: _videoMetadata!.controller!,
                        filename: _video?.name ?? 'Vídeo selecionado',
                      ),
                    ],
                  ],
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
      ),
    );
  }

  String? _externalVideoUrlError(String value) {
    final uri = Uri.tryParse(value);
    if (uri == null ||
        uri.scheme != 'https' ||
        uri.userInfo.isNotEmpty ||
        uri.hasPort) {
      return 'Informe um link HTTPS oficial';
    }
    final host = uri.host.toLowerCase();
    final parts = uri.pathSegments.where((part) => part.isNotEmpty).toList();
    String? videoId;
    if (const {
      'youtube.com',
      'www.youtube.com',
      'm.youtube.com',
    }.contains(host)) {
      if (uri.path == '/watch') {
        videoId = uri.queryParameters['v'];
      } else if (parts.length == 2 &&
          const {'embed', 'shorts', 'live'}.contains(parts.first)) {
        videoId = parts.last;
      }
      if (videoId != null && RegExp(r'^[A-Za-z0-9_-]{11}$').hasMatch(videoId)) {
        return null;
      }
    } else if (host == 'youtu.be' && parts.length == 1) {
      videoId = parts.single;
      if (RegExp(r'^[A-Za-z0-9_-]{11}$').hasMatch(videoId)) return null;
    } else if (const {'vimeo.com', 'www.vimeo.com'}.contains(host) &&
        parts.length == 1) {
      if (RegExp(r'^[0-9]{1,20}$').hasMatch(parts.single)) return null;
    } else if (host == 'player.vimeo.com' &&
        parts.length == 2 &&
        parts.first == 'video') {
      if (RegExp(r'^[0-9]{1,20}$').hasMatch(parts.last)) return null;
    }
    return 'Use um link válido de vídeo do YouTube ou Vimeo';
  }

  String _contentType(String? extension) =>
      switch ((extension ?? '').toLowerCase()) {
        'mov' => 'video/quicktime',
        'm4v' => 'video/x-m4v',
        _ => 'video/mp4',
      };

  String _titleFromFilename(String filename) {
    final extension = filename.lastIndexOf('.');
    final raw = extension > 0 ? filename.substring(0, extension) : filename;
    final words = raw
        .replaceAll(RegExp(r'[_\-.]+'), ' ')
        .replaceAll(RegExp(r'^\s*\d+\s*'), '')
        .trim()
        .split(RegExp(r'\s+'));
    if (words.isEmpty || words.first.isEmpty) return 'Nova aula';
    return words
        .map(
          (word) => word.isEmpty
              ? word
              : '${word[0].toUpperCase()}${word.substring(1)}',
        )
        .join(' ');
  }

  ThemeData _lessonTheme(BuildContext context) {
    final base = Theme.of(context);
    return base.copyWith(
      brightness: Brightness.dark,
      colorScheme: base.colorScheme.copyWith(
        brightness: Brightness.dark,
        primary: const Color(0xFFA63B5E),
        surface: const Color(0xFF2C111B),
        onSurface: Colors.white,
      ),
      textTheme: base.textTheme.apply(
        bodyColor: Colors.white,
        displayColor: Colors.white,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xB20A1022),
        labelStyle: const TextStyle(color: Color(0xFFB8C1DD)),
        hintStyle: const TextStyle(color: Color(0xFF7885A5)),
        helperStyle: const TextStyle(color: Color(0xFF8F9AB7)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0x406B4A55)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFA63B5E), width: 2),
        ),
      ),
    );
  }
}

class _LessonVideoPreview extends StatefulWidget {
  const _LessonVideoPreview({required this.controller, required this.filename});

  final VideoPlayerController controller;
  final String filename;

  @override
  State<_LessonVideoPreview> createState() => _LessonVideoPreviewState();
}

class _LessonVideoPreviewState extends State<_LessonVideoPreview> {
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: const Color(0xCC070B18),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: const Color(0x55A63B5E)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: AspectRatio(
            aspectRatio: widget.controller.value.aspectRatio == 0
                ? 16 / 9
                : widget.controller.value.aspectRatio,
            child: VideoPlayer(widget.controller),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            IconButton.filled(
              tooltip: widget.controller.value.isPlaying
                  ? 'Pausar prévia'
                  : 'Reproduzir prévia',
              onPressed: () async {
                widget.controller.value.isPlaying
                    ? await widget.controller.pause()
                    : await widget.controller.play();
                if (mounted) setState(() {});
              },
              icon: Icon(
                widget.controller.value.isPlaying
                    ? Icons.pause
                    : Icons.play_arrow,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.filename,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    '${widget.controller.value.duration.inMinutes} min · prévia local',
                    style: const TextStyle(
                      color: Color(0xFFB8C1DD),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
