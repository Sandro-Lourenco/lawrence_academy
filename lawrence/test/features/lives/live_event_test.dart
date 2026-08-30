import 'package:flutter_test/flutter_test.dart';
import 'package:lawrence/features/lives/domain/entities/live_event.dart';

void main() {
  test('parses canonical API payload and serializes UTC input', () {
    final event = LiveEvent.fromJson({
      'id': 'event-1',
      'instructor_id': 'teacher-1',
      'instructor_name': 'Marisa',
      'title': 'Moulage ao vivo',
      'description': 'Draping clássico',
      'scheduled_for': '2026-08-20T22:00:00Z',
      'duration_minutes': 60,
      'status': 'scheduled',
      'tag': 'Moulage',
      'youtube_url': 'https://youtube.com/live/abc_123',
      'timezone': 'America/Sao_Paulo',
    });
    expect(event.instructor, 'Marisa');
    expect(event.safeYoutubeUri, isNotNull);
    expect(event.toInputJson()['scheduled_for'], '2026-08-20T22:00:00.000Z');
  });

  LiveEvent event(String url) => LiveEvent(
    id: 'event-1',
    title: 'Workshop',
    instructor: 'Lawrence',
    scheduledFor: DateTime.utc(2026, 8, 1),
    durationMinutes: 60,
    status: 'scheduled',
    tag: 'Workshop',
    youtubeUrl: url,
  );

  test('aceita apenas links HTTPS oficiais do YouTube', () {
    expect(
      event('https://www.youtube.com/watch?v=abc').safeYoutubeUri,
      isNotNull,
    );
    expect(event('https://youtu.be/abc').safeYoutubeUri, isNotNull);
    expect(event('http://youtube.com/watch?v=abc').safeYoutubeUri, isNull);
    expect(
      event('https://youtube.com.evil.test/watch?v=abc').safeYoutubeUri,
      isNull,
    );
  });
}
