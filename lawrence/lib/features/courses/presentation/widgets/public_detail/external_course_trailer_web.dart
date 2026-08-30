import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

class ExternalCourseTrailer extends StatefulWidget {
  const ExternalCourseTrailer({
    super.key,
    required this.provider,
    required this.videoId,
  });

  final String provider;
  final String videoId;

  @override
  State<ExternalCourseTrailer> createState() => _ExternalCourseTrailerState();
}

class _ExternalCourseTrailerState extends State<ExternalCourseTrailer> {
  late final String _viewType;

  @override
  void initState() {
    super.initState();
    _viewType =
        'course-trailer-${widget.provider}-${widget.videoId}-${identityHashCode(this)}';
    ui_web.platformViewRegistry.registerViewFactory(_viewType, (int _) {
      final iframe = web.HTMLIFrameElement()
        ..src = _embedUrl
        ..title = 'Vídeo de apresentação do curso'
        ..allow = 'accelerometer; autoplay; encrypted-media; picture-in-picture'
        ..setAttribute('allowfullscreen', 'true')
        ..setAttribute('referrerpolicy', 'strict-origin-when-cross-origin')
        ..style.border = '0'
        ..style.width = '100%'
        ..style.height = '100%';
      return iframe;
    });
  }

  String get _embedUrl => widget.provider == 'youtube'
      ? 'https://www.youtube-nocookie.com/embed/${widget.videoId}?autoplay=1&rel=0'
      : 'https://player.vimeo.com/video/${widget.videoId}?autoplay=1&title=0&byline=0&portrait=0';

  @override
  Widget build(BuildContext context) => HtmlElementView(viewType: _viewType);
}
