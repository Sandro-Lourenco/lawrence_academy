import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

import '../../../../../design_system/public/public_editorial_colors.dart';
import '../../../../../design_system/public/public_editorial_typography.dart';
import '../../../domain/entities/course.dart';
import '../../providers/course_trailer_provider.dart';
import 'external_course_trailer.dart';

class PublicCourseTrailer extends ConsumerStatefulWidget {
  const PublicCourseTrailer({super.key, required this.course});

  final Course course;

  @override
  ConsumerState<PublicCourseTrailer> createState() =>
      _PublicCourseTrailerState();
}

class _PublicCourseTrailerState extends ConsumerState<PublicCourseTrailer> {
  VideoPlayerController? _controller;
  bool _loading = false;
  String? _error;
  bool _externalActive = false;

  bool get _hasUploadedTrailer =>
      widget.course.trailerSourceType == 'upload' &&
      widget.course.trailerStatus == 'ready';
  bool get _hasExternalTrailer =>
      (widget.course.trailerSourceType == 'youtube' ||
          widget.course.trailerSourceType == 'vimeo') &&
      (widget.course.trailerExternalVideoId?.isNotEmpty ?? false);
  bool get _hasTrailer => _hasUploadedTrailer || _hasExternalTrailer;

  Future<void> _play() async {
    if (!_hasTrailer || _loading) return;
    if (_hasExternalTrailer) {
      setState(() => _externalActive = true);
      return;
    }
    final existing = _controller;
    if (existing != null) {
      await existing.play();
      if (mounted) setState(() {});
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final url = await ref.read(
        courseTrailerStreamProvider(widget.course.id).future,
      );
      final controller = VideoPlayerController.networkUrl(Uri.parse(url));
      await controller.initialize();
      controller.addListener(_refreshControls);
      await controller.play();
      if (!mounted) {
        await controller.dispose();
        return;
      }
      setState(() => _controller = controller);
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Não foi possível abrir o trailer agora.');
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _refreshControls() {
    if (mounted) setState(() {});
  }

  Future<void> _togglePlayback() async {
    final controller = _controller;
    if (controller == null) return _play();
    controller.value.isPlaying
        ? await controller.pause()
        : await controller.play();
  }

  @override
  void dispose() {
    final controller = _controller;
    if (controller != null) {
      controller.removeListener(_refreshControls);
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mobile = MediaQuery.sizeOf(context).width < 700;
    return ColoredBox(
      color: PublicEditorialColors.noir,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1440),
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              mobile ? 24 : 72,
              mobile ? 84 : 126,
              mobile ? 24 : 72,
              mobile ? 92 : 136,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'FILME DE APRESENTAÇÃO · CADERNO 02',
                  style: PublicEditorialTypography.eyebrow(
                    color: PublicEditorialColors.champagne,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Entre no ateliê\nantes da primeira aula.',
                  style: PublicEditorialTypography.sectionDisplay(
                    color: PublicEditorialColors.ivory,
                    size: mobile ? 50 : 78,
                  ).copyWith(height: .94),
                ),
                const SizedBox(height: 42),
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: _TrailerFrame(
                    course: widget.course,
                    controller: _controller,
                    loading: _loading,
                    error: _error,
                    hasTrailer: _hasTrailer,
                    externalActive: _externalActive,
                    onPressed: _togglePlayback,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TrailerFrame extends StatelessWidget {
  const _TrailerFrame({
    required this.course,
    required this.controller,
    required this.loading,
    required this.error,
    required this.hasTrailer,
    required this.externalActive,
    required this.onPressed,
  });

  final Course course;
  final VideoPlayerController? controller;
  final bool loading;
  final String? error;
  final bool hasTrailer;
  final bool externalActive;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final ready = controller?.value.isInitialized ?? false;
    final hasExternal =
        (course.trailerSourceType == 'youtube' ||
            course.trailerSourceType == 'vimeo') &&
        (course.trailerExternalVideoId?.isNotEmpty ?? false);
    return RepaintBoundary(
      child: ClipRect(
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (hasExternal && externalActive)
              ExternalCourseTrailer(
                provider: course.trailerSourceType,
                videoId: course.trailerExternalVideoId!,
              )
            else if (ready)
              FittedBox(
                fit: BoxFit.contain,
                child: SizedBox(
                  width: controller!.value.size.width,
                  height: controller!.value.size.height,
                  child: VideoPlayer(controller!),
                ),
              )
            else
              Image.asset(
                'assets/images/couture_pattern_table.webp',
                fit: BoxFit.cover,
                semanticLabel: 'Prévia do trailer do curso ${course.title}',
              ),
            if (!ready && !(hasExternal && externalActive))
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0x25100C0D), Color(0xB8100C0D)],
                  ),
                ),
              ),
            if (!(hasExternal && externalActive))
              Center(
                child: loading
                    ? const CircularProgressIndicator(
                        color: PublicEditorialColors.ivory,
                      )
                    : IconButton(
                        onPressed: hasTrailer ? onPressed : null,
                        tooltip: ready && controller!.value.isPlaying
                            ? 'Pausar trailer'
                            : 'Assistir ao trailer',
                        style: IconButton.styleFrom(
                          minimumSize: const Size(72, 72),
                          foregroundColor: PublicEditorialColors.wine,
                          backgroundColor: PublicEditorialColors.ivory,
                          disabledBackgroundColor: PublicEditorialColors.ivory
                              .withValues(alpha: .86),
                          disabledForegroundColor: PublicEditorialColors.wine
                              .withValues(alpha: .52),
                          side: const BorderSide(
                            color: PublicEditorialColors.champagne,
                          ),
                        ),
                        icon: Icon(
                          ready && controller!.value.isPlaying
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          size: 34,
                        ),
                      ),
              ),
            Positioned(
              left: 22,
              right: 22,
              bottom: 18,
              child: Text(
                error ??
                    (hasTrailer
                        ? 'TRAILER OFICIAL · ${course.title.toUpperCase()}'
                        : 'TRAILER EM PREPARAÇÃO'),
                textAlign: TextAlign.center,
                style: PublicEditorialTypography.eyebrow(
                  color: PublicEditorialColors.ivory,
                ).copyWith(fontSize: 10),
              ),
            ),
            if (ready)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: VideoProgressIndicator(
                  controller!,
                  allowScrubbing: true,
                  colors: const VideoProgressColors(
                    playedColor: PublicEditorialColors.champagne,
                    bufferedColor: PublicEditorialColors.antiqueRose,
                    backgroundColor: Color(0x66100C0D),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
