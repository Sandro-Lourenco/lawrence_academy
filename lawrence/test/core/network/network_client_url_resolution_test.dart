import 'package:flutter_test/flutter_test.dart';
import 'package:lawrence/core/network/auth_token_coordinator.dart';
import 'package:lawrence/core/network/network_client.dart';

void main() {
  late NetworkClient client;

  setUp(() {
    client = NetworkClient(
      baseUrl: 'https://api.lawrence.example',
      tokenCoordinator: AuthTokenCoordinator(
        readAccessToken: () => null,
        isAccessTokenExpired: () => false,
        refreshAccessToken: () async => null,
      ),
    );
  });

  test('resolves protected playback paths against the public API origin', () {
    expect(
      client.resolveUrl('/api/v1/courses/c1/lessons/l1/hls/master.m3u8?t=x'),
      'https://api.lawrence.example/api/v1/courses/c1/lessons/l1/hls/master.m3u8?t=x',
    );
  });

  test('preserves absolute storage URLs', () {
    expect(
      client.resolveUrl('https://storage.example/video/master.m3u8?t=x'),
      'https://storage.example/video/master.m3u8?t=x',
    );
  });
}
