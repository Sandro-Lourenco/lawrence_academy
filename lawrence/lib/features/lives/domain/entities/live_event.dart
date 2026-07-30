class LiveEvent {
  final String id;
  final String title;
  final String instructor;
  final String instructorAvatarUrl;
  final DateTime scheduledFor;
  final int durationMinutes;
  final String status; // 'live', 'scheduled', 'ended'
  final String tag;
  final String? bannerUrl;
  final String? youtubeUrl;

  const LiveEvent({
    required this.id,
    required this.title,
    required this.instructor,
    this.instructorAvatarUrl = '',
    required this.scheduledFor,
    required this.durationMinutes,
    required this.status,
    required this.tag,
    this.bannerUrl,
    this.youtubeUrl,
  });

  Uri? get safeYoutubeUri {
    final uri = Uri.tryParse(youtubeUrl ?? '');
    if (uri == null || uri.scheme != 'https') return null;
    final host = uri.host.toLowerCase();
    const allowedHosts = {
      'youtube.com',
      'www.youtube.com',
      'm.youtube.com',
      'youtu.be',
    };
    return allowedHosts.contains(host) ? uri : null;
  }
}
