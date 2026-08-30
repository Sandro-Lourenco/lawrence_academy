import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ExternalCourseTrailer extends StatelessWidget {
  const ExternalCourseTrailer({
    super.key,
    required this.provider,
    required this.videoId,
  });

  final String provider;
  final String videoId;

  @override
  Widget build(BuildContext context) => Center(
    child: FilledButton.icon(
      onPressed: () => launchUrl(
        Uri.parse(
          provider == 'youtube'
              ? 'https://www.youtube.com/watch?v=$videoId'
              : 'https://vimeo.com/$videoId',
        ),
        mode: LaunchMode.externalApplication,
      ),
      icon: const Icon(Icons.open_in_new_rounded),
      label: const Text('Assistir ao vídeo de apresentação'),
    ),
  );
}
