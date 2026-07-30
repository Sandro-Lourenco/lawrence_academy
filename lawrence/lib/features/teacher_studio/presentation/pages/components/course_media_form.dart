import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../../../../design_system/tokens/lawrence_theme.dart';
import '../../../../courses/domain/entities/course.dart';
import 'selected_video_preview.dart';

class CourseMediaForm extends StatefulWidget {
  const CourseMediaForm({
    super.key,
    required this.isUploading,
    required this.course,
    required this.onUpload,
    required this.onBack,
    required this.onContinue,
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

  @override
  State<CourseMediaForm> createState() => _CourseMediaFormState();
}

class _CourseMediaFormState extends State<CourseMediaForm> {
  final _alt = TextEditingController();
  String? _coverName;
  String? _trailerName;
  Uint8List? _coverPreview;
  SelectedVideoPreview? _trailerPreview;
  bool _isPreparingTrailerPreview = false;

  @override
  void dispose() {
    _alt.dispose();
    _trailerPreview?.dispose();
    super.dispose();
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
          color: LawrenceColors.textPrimary,
          fontSize: 24,
          fontWeight: FontWeight.w700,
        ),
      ),
      const SizedBox(height: 8),
      const Text(
        'Uma imagem-mestre alimenta capa, banner e miniatura por recortes responsivos. O trailer é público; vídeos de aulas continuam privados.',
        style: TextStyle(color: LawrenceColors.textSecondary),
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
        _coverPreviewCard(),
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
        style: const TextStyle(color: LawrenceColors.textPrimary),
        decoration: const InputDecoration(
          labelText: 'Texto alternativo da imagem',
          hintText: 'Manequim com molde de saia marcado em tecido cru',
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
      const SizedBox(height: 12),
      const Text(
        'O arquivo bruto não fica público. A prévia será liberada apenas após validação e conversão.',
        style: TextStyle(color: LawrenceColors.textSecondary),
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
          color: LawrenceColors.canvas,
          border: Border.all(color: LawrenceColors.borderMist),
          borderRadius: BorderRadius.circular(LawrenceRadii.card),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.cloud_upload_outlined,
              color: LawrenceColors.textSecondary,
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
                      color: LawrenceColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    name ?? help,
                    style: const TextStyle(
                      color: LawrenceColors.textSecondary,
                    ),
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

  Widget _coverPreviewCard() => Semantics(
    label: 'Prévia da capa selecionada',
    image: true,
    child: ClipRRect(
      borderRadius: BorderRadius.circular(LawrenceRadii.card),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Image.memory(
          _coverPreview!,
          fit: BoxFit.cover,
          gaplessPlayback: true,
          errorBuilder: (_, _, _) => const _PreviewUnavailable(
            label: 'Não foi possível abrir a prévia desta imagem.',
          ),
        ),
      ),
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
        message: 'Selecione um trailer para validar o arquivo antes de publicar.',
        color: LawrenceColors.textSecondary,
      ),
    };
  }
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
                Text(
                  message,
                  style: const TextStyle(
                    color: LawrenceColors.textSecondary,
                  ),
                ),
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
      child: Text(
        label,
        style: const TextStyle(color: LawrenceColors.textSecondary),
      ),
    ),
  );
}
