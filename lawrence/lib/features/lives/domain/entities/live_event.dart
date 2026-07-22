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
  });
}
