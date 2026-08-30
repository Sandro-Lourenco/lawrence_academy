import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../../../../design_system/tokens/lawrence_theme.dart';
import '../../../../courses/domain/entities/course.dart';
import 'selected_video_preview.dart';

const _maxTrailerUploadBytes = 50 * 1024 * 1024;

class CourseMediaForm extends StatefulWidget {
  const CourseMediaForm({
    super.key,
    required this.isUploading,
    required this.course,
    required this.onUpload,
    required this.onBack,
    required this.onContinue,
    this.onExternalTrailerChanged,
  });
  final bool isUploading;
  final Course course;
  final Future<bool> Function(
    PlatformFile file,
    String type,
    String mime,
    String altText,
  )
  onUpload;
  final VoidCallback onBack;
  final VoidCallback onContinue;
  final Future<bool> Function(String? url, bool remove)?
  onExternalTrailerChanged;

  @override
  State<CourseMediaForm> createState() => _CourseMediaFormState();
}

class _CourseMediaFormState extends State<CourseMediaForm> {
  final _alt = TextEditingController();
  late final TextEditingController _trailerLink;
  String? _coverName;
  String? _trailerName;
  Uint8List? _coverPreview;
  SelectedVideoPreview? _trailerPreview;
  bool _isPreparingTrailerPreview = false;
  bool _savingLink = false;

  @override
  void initState() {
    super.initState();
    _trailerLink = TextEditingController(text: _externalTrailerUrl);
  }

  String get _externalTrailerUrl {
    final id = widget.course.trailerExternalVideoId;
    if (id == null || id.isEmpty) return '';
    return switch (widget.course.trailerSourceType) {
      'youtube' => 'https://www.youtube.com/watch?v=$id',
      'vimeo' => 'https://vimeo.com/$id',
      _ => '',
    };
  }

  @override
  void dispose() {
    _alt.dispose();
    _trailerLink.dispose();
    _trailerPreview?.dispose();
    super.dispose();
  }

  Future<void> _saveExternalTrailer({bool remove = false}) async {
    final callback = widget.onExternalTrailerChanged;
    if (callback == null || _savingLink) return;
    final url = _trailerLink.text.trim();
    if (!remove && !_isSupportedVideoUrl(url)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Informe um link válido do YouTube ou Vimeo.'),
        ),
      );
      return;
    }
    setState(() => _savingLink = true);
    final saved = await callback(remove ? null : url, remove);
    if (!mounted) return;
    setState(() {
      _savingLink = false;
      if (saved && remove) _trailerLink.clear();
    });
    if (saved) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            remove ? 'Link da prévia removido.' : 'Link da prévia salvo.',
          ),
        ),
      );
    }
  }

  bool _isSupportedVideoUrl(String value) {
    final uri = Uri.tryParse(value);
    if (uri == null || uri.scheme != 'https') return false;
    final host = uri.host.toLowerCase().replaceFirst(RegExp(r'^www\.'), '');
    return host == 'youtube.com' ||
        host == 'youtu.be' ||
        host == 'vimeo.com' ||
        host == 'player.vimeo.com';
  }

  Future<void> _pick(String type) async {
    final image = type == 'cover';
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: image
          ? ['jpg', 'jpeg', 'png', 'webp']
          : ['mp4', 'mov', 'm4v'],
      withData: kIsWeb || image,
    );
    final file = result?.files.single;
    if (file == null || (file.path == null && file.bytes == null)) return;
    if (!image && file.size > _maxTrailerUploadBytes) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'O trailer excede 50 MB. Comprima o arquivo ou escolha um vídeo menor.',
          ),
        ),
      );
      return;
    }
    final ext = file.extension?.toLowerCase();
    final mime = image
        ? (ext == 'png'
              ? 'image/png'
              : ext == 'webp'
              ? 'image/webp'
              : 'image/jpeg')
        : (ext == 'mov'
              ? 'video/quicktime'
              : ext == 'm4v'
              ? 'video/x-m4v'
              : 'video/mp4');
    if (image) {
      setState(() {
        _coverName = file.name;
        _coverPreview = file.bytes;
      });
    } else {
      await _setTrailerPreview(file, mime);
    }
    await widget.onUpload(file, type, mime, _alt.text.trim());
  }

  Future<void> _setTrailerPreview(PlatformFile file, String mime) async {
    setState(() {
      _trailerName = file.name;
      _isPreparingTrailerPreview = true;
    });
    final previous = _trailerPreview;
    final preview = await SelectedVideoPreview.create(file, mime);
    await previous?.dispose();
    if (!mounted) {
      await preview.dispose();
      return;
    }
    setState(() {
      _trailerPreview = preview;
      _isPreparingTrailerPreview = false;
    });
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Apresentação do curso',
        style: TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.w700,
        ),
      ),
      const SizedBox(height: 8),
      const Text(
        'Uma imagem-mestre alimenta capa, banner e miniatura por recortes responsivos. O trailer é público; vídeos de aulas continuam privados.',
        style: TextStyle(color: Color(0xFFB8C1DD)),
      ),
      const SizedBox(height: 24),
      _card(
        'Imagem-mestre',
        'JPG, PNG ou WebP • até 10 MB • recomendado 16:9',
        _coverName,
        () => _pick('cover'),
      ),
      if (_coverPreview != null) ...[
        const SizedBox(height: 12),
        _ExportPreviews(bytes: _coverPreview!),
      ] else if (widget.course.coverImagePath?.isNotEmpty == true) ...[
        const SizedBox(height: 12),
        const _PersistedMediaNotice(
          icon: Icons.image_outlined,
          title: 'Capa salva',
          message:
              'A imagem foi armazenada com segurança. Selecione outra para conferir o novo recorte antes de substituir.',
          color: LawrenceColors.success,
        ),
      ],
      const SizedBox(height: 12),
      TextField(
        controller: _alt,
        maxLength: 240,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: 'Texto alternativo da imagem',
          hintText: 'Manequim com molde de saia marcado em tecido cru',
          filled: true,
          fillColor: const Color(0xB20A1022),
          labelStyle: const TextStyle(color: Color(0xFFB8C1DD)),
          hintStyle: const TextStyle(color: Color(0xFF7885A5)),
          counterStyle: const TextStyle(color: Color(0xFF8F9AB7)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0x406B4A55)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFA63B5E), width: 2),
          ),
        ),
      ),
      const SizedBox(height: 20),
      _card(
        'Trailer público',
        'MP4, MOV ou M4V • processamento em segundo plano',
        _trailerName,
        () => _pick('trailer'),
      ),
      const SizedBox(height: 12),
      _trailerPreviewCard(),
      const SizedBox(height: 20),
      TextField(
        controller: _trailerLink,
        enabled: !widget.isUploading && !_savingLink,
        keyboardType: TextInputType.url,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: 'Link do vídeo de apresentação',
          hintText:
              'https://www.youtube.com/watch?v=... ou https://vimeo.com/...',
          helperText:
              'Use um vídeo público ou não listado do YouTube ou Vimeo.',
          prefixIcon: const Icon(Icons.link_rounded),
          filled: true,
          fillColor: const Color(0xB2180D11),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFA63B5E), width: 2),
          ),
        ),
      ),
      const SizedBox(height: 10),
      Wrap(
        spacing: 10,
        runSpacing: 8,
        children: [
          FilledButton.icon(
            key: const Key('save-external-trailer'),
            onPressed:
                widget.onExternalTrailerChanged == null ||
                    widget.isUploading ||
                    _savingLink
                ? null
                : _saveExternalTrailer,
            icon: _savingLink
                ? const SizedBox.square(
                    dimension: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.check_rounded),
            label: const Text('Salvar link'),
          ),
          if (_externalTrailerUrl.isNotEmpty)
            TextButton.icon(
              onPressed: _savingLink
                  ? null
                  : () => _saveExternalTrailer(remove: true),
              icon: const Icon(Icons.link_off_rounded),
              label: const Text('Remover link'),
            ),
        ],
      ),
      const SizedBox(height: 12),
      const Text(
        'Escolha uma fonte: o upload substitui o link externo, e o link substitui o upload anterior.',
        style: TextStyle(color: Color(0xFFB8C1DD)),
      ),
      const SizedBox(height: 28),
      Row(
        children: [
          TextButton(
            onPressed: widget.isUploading ? null : widget.onBack,
            child: const Text('Voltar'),
          ),
          const Spacer(),
          FilledButton(
            onPressed: widget.isUploading ? null : widget.onContinue,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF6B1328),
              foregroundColor: Colors.white,
            ),
            child: const Text('Continuar'),
          ),
        ],
      ),
    ],
  );

  Widget _card(String title, String help, String? name, VoidCallback action) =>
      Container(
        padding: const EdgeInsets.all(LawrenceSpacing.lg),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xCC2C111B), Color(0xCC181315)],
          ),
          border: Border.all(color: const Color(0x33A63B5E)),
          borderRadius: BorderRadius.circular(LawrenceRadii.card),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.cloud_upload_outlined,
              color: Color(0xFFA63B5E),
              size: 32,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    name ?? help,
                    style: const TextStyle(color: Color(0xFFB8C1DD)),
                  ),
                ],
              ),
            ),
            OutlinedButton(
              onPressed: widget.isUploading ? null : action,
              child: Text(name == null ? 'Selecionar' : 'Substituir'),
            ),
          ],
        ),
      );

  Widget _trailerPreviewCard() {
    if (_isPreparingTrailerPreview) {
      return const _PersistedMediaNotice(
        icon: Icons.hourglass_top,
        title: 'Preparando prévia do trailer',
        message: 'Validando o arquivo selecionado…',
        color: LawrenceColors.primary,
      );
    }
    final controller = _trailerPreview?.controller;
    if (controller != null && controller.value.isInitialized) {
      return _SelectedTrailerPreview(
        controller: controller,
        filename: _trailerName ?? 'Trailer selecionado',
      );
    }
    if (_trailerName != null) {
      return _PersistedMediaNotice(
        icon: Icons.video_file_outlined,
        title: 'Trailer selecionado',
        message:
            '$_trailerName foi enviado. A reprodução local não está disponível neste dispositivo.',
        color: LawrenceColors.primary,
      );
    }
    final status = widget.course.trailerStatus;
    if (_externalTrailerUrl.isNotEmpty) {
      return _PersistedMediaNotice(
        icon: Icons.ondemand_video_rounded,
        title:
            'Prévia por ${widget.course.trailerSourceType == 'youtube' ? 'YouTube' : 'Vimeo'}',
        message:
            'O link está validado e aparecerá na apresentação pública do curso.',
        color: LawrenceColors.success,
      );
    }
    return switch (status) {
      'ready' => const _PersistedMediaNotice(
        icon: Icons.play_circle_outline,
        title: 'Trailer pronto',
        message:
            'O trailer foi validado e convertido. Ele está pronto para a publicação.',
        color: LawrenceColors.success,
      ),
      'failed' || 'dead_letter' => const _PersistedMediaNotice(
        icon: Icons.error_outline,
        title: 'Falha no trailer',
        message:
            'O processamento não foi concluído. Selecione o arquivo novamente para tentar outro envio.',
        color: LawrenceColors.danger,
      ),
      'upload_pending' ||
      'uploaded' ||
      'processing_pending' ||
      'processing' ||
      'validating' ||
      'transcoding' ||
      'generating_hls' ||
      'generating_thumbnail' => const _PersistedMediaNotice(
        icon: Icons.schedule_outlined,
        title: 'Trailer em processamento',
        message:
            'Você pode continuar editando. O status será atualizado automaticamente.',
        color: LawrenceColors.warning,
      ),
      _ => const _PersistedMediaNotice(
        icon: Icons.ondemand_video_outlined,
        title: 'Prévia do trailer',
        message:
            'Selecione um trailer para validar o arquivo antes de publicar.',
        color: LawrenceColors.textSecondary,
      ),
    };
  }
}

class _ExportPreviews extends StatelessWidget {
  const _ExportPreviews({required this.bytes});

  final Uint8List bytes;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(LawrenceSpacing.lg),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xDD2C111B), Color(0xCC4B0C1B)],
      ),
      border: Border.all(color: const Color(0x55A63B5E)),
      borderRadius: BorderRadius.circular(22),
      boxShadow: const [
        BoxShadow(
          color: Color(0x33000000),
          blurRadius: 28,
          offset: Offset(0, 14),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.auto_awesome, color: Color(0xFFA63B5E), size: 20),
            SizedBox(width: 9),
            Expanded(
              child: Text(
                'PRÉVIAS DAS EXPORTAÇÕES',
                style: TextStyle(
                  color: Color(0xFFC8C2FF),
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            _ReadyBadge(),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          'Confira como a imagem-mestre será recortada em cada ponto da plataforma.',
          style: TextStyle(color: Color(0xFFB8C1DD)),
        ),
        const SizedBox(height: LawrenceSpacing.lg),
        LayoutBuilder(
          builder: (context, constraints) {
            final previews = [
              _ExportPreviewTile(
                bytes: bytes,
                label: 'Capa do curso',
                dimensions: '1600 × 900 · 16:9',
                aspectRatio: 16 / 9,
              ),
              _ExportPreviewTile(
                bytes: bytes,
                label: 'Banner',
                dimensions: '1800 × 600 · 3:1',
                aspectRatio: 3,
              ),
              _ExportPreviewTile(
                bytes: bytes,
                label: 'Miniatura',
                dimensions: '800 × 800 · 1:1',
                aspectRatio: 1,
              ),
            ];
            if (constraints.maxWidth < 720) {
              return Column(
                children: [
                  for (var i = 0; i < previews.length; i++) ...[
                    previews[i],
                    if (i < previews.length - 1)
                      const SizedBox(height: LawrenceSpacing.md),
                  ],
                ],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < previews.length; i++) ...[
                  Expanded(child: previews[i]),
                  if (i < previews.length - 1)
                    const SizedBox(width: LawrenceSpacing.md),
                ],
              ],
            );
          },
        ),
      ],
    ),
  );
}

class _ReadyBadge extends StatelessWidget {
  const _ReadyBadge();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
    decoration: BoxDecoration(
      color: const Color(0xFF31D18B).withValues(alpha: .12),
      borderRadius: BorderRadius.circular(99),
      border: Border.all(color: const Color(0x6631D18B)),
    ),
    child: const Text(
      '3 FORMATOS',
      style: TextStyle(
        color: Color(0xFF7BE4B5),
        fontSize: 10,
        fontWeight: FontWeight.w800,
      ),
    ),
  );
}

class _ExportPreviewTile extends StatelessWidget {
  const _ExportPreviewTile({
    required this.bytes,
    required this.label,
    required this.dimensions,
    required this.aspectRatio,
  });

  final Uint8List bytes;
  final String label;
  final String dimensions;
  final double aspectRatio;

  @override
  Widget build(BuildContext context) => Semantics(
    image: true,
    label: 'Prévia de $label, formato $dimensions',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: AspectRatio(
            aspectRatio: aspectRatio,
            child: Image.memory(
              bytes,
              fit: BoxFit.cover,
              gaplessPlayback: true,
              errorBuilder: (_, _, _) =>
                  const _PreviewUnavailable(label: 'Prévia indisponível'),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          dimensions,
          style: const TextStyle(color: Color(0xFF8F9AB7), fontSize: 11),
        ),
      ],
    ),
  );
}

class _SelectedTrailerPreview extends StatefulWidget {
  const _SelectedTrailerPreview({
    required this.controller,
    required this.filename,
  });

  final VideoPlayerController controller;
  final String filename;

  @override
  State<_SelectedTrailerPreview> createState() =>
      _SelectedTrailerPreviewState();
}

class _SelectedTrailerPreviewState extends State<_SelectedTrailerPreview> {
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(LawrenceSpacing.md),
    decoration: BoxDecoration(
      color: Colors.black,
      borderRadius: BorderRadius.circular(LawrenceRadii.card),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(LawrenceTheme.radiusMd),
          child: AspectRatio(
            aspectRatio: widget.controller.value.aspectRatio == 0
                ? 16 / 9
                : widget.controller.value.aspectRatio,
            child: VideoPlayer(widget.controller),
          ),
        ),
        const SizedBox(height: LawrenceSpacing.sm),
        Row(
          children: [
            IconButton.filledTonal(
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
            const SizedBox(width: LawrenceSpacing.sm),
            Expanded(
              child: Text(
                widget.filename,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

class _PersistedMediaNotice extends StatelessWidget {
  const _PersistedMediaNotice({
    required this.icon,
    required this.title,
    required this.message,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String message;
  final Color color;

  @override
  Widget build(BuildContext context) => Semantics(
    liveRegion: true,
    label: '$title. $message',
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.all(LawrenceSpacing.md),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .09),
        border: Border.all(color: color.withValues(alpha: .35)),
        borderRadius: BorderRadius.circular(LawrenceRadii.card),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(width: LawrenceSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(color: color, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(message, style: const TextStyle(color: Color(0xFFB8C1DD))),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _PreviewUnavailable extends StatelessWidget {
  const _PreviewUnavailable({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: Colors.black12,
    child: Center(
      child: Text(label, style: const TextStyle(color: Color(0xFFB8C1DD))),
    ),
  );
}
