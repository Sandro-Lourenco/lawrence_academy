import 'package:flutter_test/flutter_test.dart';
import 'package:lawrence/features/lives/domain/entities/live_event.dart';

void main() {
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
