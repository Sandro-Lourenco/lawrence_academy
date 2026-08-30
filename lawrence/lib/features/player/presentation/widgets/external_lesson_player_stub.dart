import 'package:flutter/material.dart';

class ExternalLessonPlayer extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final label = provider == 'youtube' ? 'YouTube' : 'Vimeo';
    return ColoredBox(
      color: const Color(0xFF30101A),
      child: Center(
        child: FilledButton.icon(
          onPressed: onOpenExternal,
          icon: const Icon(Icons.open_in_new_rounded),
          label: Text('Assistir no $label'),
        ),
      ),
    );
  }
}
