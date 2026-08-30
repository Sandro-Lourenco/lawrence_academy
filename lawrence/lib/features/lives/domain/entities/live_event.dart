class LiveEvent {
  final String id;
  final String title;
  final String instructor;
  final String instructorAvatarUrl;
  final String instructorId;
  final String description;
  final DateTime scheduledFor;
  final int durationMinutes;
  final String status; // 'live', 'scheduled', 'ended'
  final String tag;
  final String? bannerUrl;
  final String? youtubeUrl;
  final String timezone;

  const LiveEvent({
    required this.id,
    required this.title,
    required this.instructor,
    this.instructorAvatarUrl = '',
    this.instructorId = '',
    this.description = '',
    required this.scheduledFor,
    required this.durationMinutes,
    required this.status,
    required this.tag,
    this.bannerUrl,
    this.youtubeUrl,
    this.timezone = 'America/Sao_Paulo',
  });

  factory LiveEvent.fromJson(Map<String, dynamic> json) => LiveEvent(
        id: json['id'] as String,
        instructorId: json['instructor_id'] as String? ?? '',
        instructor: json['instructor_name'] as String? ?? 'Lawrence Academy',
        title: json['title'] as String,
        description: json['description'] as String? ?? '',
        scheduledFor: DateTime.parse(json['scheduled_for'] as String),
        durationMinutes: json['duration_minutes'] as int,
        status: json['status'] as String,
        tag: json['tag'] as String,
        bannerUrl: json['banner_url'] as String?,
        youtubeUrl: json['youtube_url'] as String?,
        timezone: json['timezone'] as String? ?? 'America/Sao_Paulo',
      );

  Map<String, dynamic> toInputJson() => {
        'title': title.trim(),
        'description': description.trim(),
        'tag': tag.trim(),
        'scheduled_for': scheduledFor.toUtc().toIso8601String(),
        'timezone': timezone,
        'duration_minutes': durationMinutes,
        'status': status,
        'youtube_url': youtubeUrl,
        'banner_url': bannerUrl,
      };

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
