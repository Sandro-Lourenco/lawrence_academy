import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

import '../../../../design_system/tokens/lawrence_theme.dart';

class ExternalLessonPlayer extends StatefulWidget {
  const ExternalLessonPlayer({
    super.key,
    required this.provider,
    required this.url,
    required this.completed,
    required this.onOpenExternal,
    required this.onComplete,
    required this.onPlaybackStarted,
  });

  final String provider;
  final Uri url;
  final bool completed;
  final VoidCallback onOpenExternal;
  final VoidCallback onComplete;
  final VoidCallback onPlaybackStarted;

  @override
  State<ExternalLessonPlayer> createState() => _ExternalLessonPlayerState();
}

class _ExternalLessonPlayerState extends State<ExternalLessonPlayer> {
  late final String _viewType;
  late final String? _embedUrl;

  @override
  void initState() {
    super.initState();
    _embedUrl = _buildEmbedUrl(widget.provider, widget.url);
    _viewType = 'external-lesson-${widget.provider}-${identityHashCode(this)}';
    if (_embedUrl != null) {
      ui_web.platformViewRegistry.registerViewFactory(_viewType, (int _) {
        final iframe = web.HTMLIFrameElement()
          ..src = _embedUrl
          ..title = 'Player da aula'
          ..allow =
              'accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share'
          ..setAttribute('allowfullscreen', 'true')
          ..setAttribute('referrerpolicy', 'strict-origin-when-cross-origin')
          ..style.border = '0'
          ..style.width = '100%'
          ..style.height = '100%';
        iframe.onLoad.listen((_) => widget.onPlaybackStarted());
        return iframe;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_embedUrl == null) {
      return _Fallback(onOpenExternal: widget.onOpenExternal);
    }
    return ColoredBox(
      color: Colors.black,
      child: Stack(
        children: [
          Positioned.fill(child: HtmlElementView(viewType: _viewType)),
          Positioned(
            right: LawrenceSpacing.md,
            bottom: LawrenceSpacing.md,
            child: Wrap(
              spacing: LawrenceSpacing.sm,
              children: [
                _OverlayButton(
                  icon: Icons.open_in_new_rounded,
                  label: 'Abrir no provedor',
                  onPressed: widget.onOpenExternal,
                ),
                _OverlayButton(
                  icon: widget.completed
                      ? Icons.check_circle
                      : Icons.task_alt_rounded,
                  label: widget.completed ? 'Concluída' : 'Marcar assistida',
                  onPressed: widget.completed ? null : widget.onComplete,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String? _buildEmbedUrl(String provider, Uri url) {
  if (provider == 'youtube') {
    final host = url.host.toLowerCase();
    final id = host == 'youtu.be'
        ? url.pathSegments.firstOrNull
        : url.queryParameters['v'] ??
              (url.pathSegments.contains('embed')
                  ? url.pathSegments.lastOrNull
                  : null);
    if (id == null || !RegExp(r'^[A-Za-z0-9_-]{6,20}$').hasMatch(id)) {
      return null;
    }
    return 'https://www.youtube-nocookie.com/embed/$id?rel=0&playsinline=1';
  }
  if (provider == 'vimeo') {
    final id = url.pathSegments.where((part) => part.isNotEmpty).lastOrNull;
    if (id == null || !RegExp(r'^\d+$').hasMatch(id)) return null;
    return 'https://player.vimeo.com/video/$id?title=0&byline=0&portrait=0';
  }
  return null;
}

class _OverlayButton extends StatelessWidget {
  const _OverlayButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => FilledButton.icon(
    onPressed: onPressed,
    icon: Icon(icon, size: 18),
    label: Text(label),
    style: FilledButton.styleFrom(
      backgroundColor: const Color(0xE66B1328),
      foregroundColor: Colors.white,
    ),
  );
}

class _Fallback extends StatelessWidget {
  const _Fallback({required this.onOpenExternal});

  final VoidCallback onOpenExternal;

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: LawrenceColors.plum,
    child: Center(
      child: FilledButton.icon(
        onPressed: onOpenExternal,
        icon: const Icon(Icons.open_in_new_rounded),
        label: const Text('Abrir vídeo'),
      ),
    ),
  );
}
