import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lawrence/core/network/auth_token_coordinator.dart';
import 'package:lawrence/core/network/network_client.dart';

class _AuthRetryAdapter implements HttpClientAdapter {
  int calls = 0;
  final List<String?> authorizationHeaders = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    calls++;
    authorizationHeaders.add(options.headers['Authorization'] as String?);
    if (calls == 1) {
      return ResponseBody.fromString(
        '{"detail":"expired token"}',
        401,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
    }
    return ResponseBody.fromString(
      '{"has_access":true}',
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  test('refreshes once and retries a protected request after 401', () async {
    var refreshCalls = 0;
    final adapter = _AuthRetryAdapter();
    final dio = Dio()..httpClientAdapter = adapter;
    final coordinator = AuthTokenCoordinator(
      readAccessToken: () => 'stale-token',
      isAccessTokenExpired: () => false,
      refreshAccessToken: () async {
        refreshCalls++;
        return 'fresh-token';
      },
    );
    final client = NetworkClient(
      baseUrl: 'https://api.lawrence.test',
      tokenCoordinator: coordinator,
      dio: dio,
    );

    final response = await client.get<Map<String, dynamic>>('/protected');

    expect(response.statusCode, 200);
    expect(response.data, {'has_access': true});
    expect(adapter.calls, 2);
    expect(refreshCalls, 1);
    expect(adapter.authorizationHeaders, [
      'Bearer stale-token',
      'Bearer fresh-token',
    ]);
  });

  test('does not loop when the retried request is still unauthorized', () async {
    var refreshCalls = 0;
    final dio = Dio()..httpClientAdapter = _AlwaysUnauthorizedAdapter();
    final coordinator = AuthTokenCoordinator(
      readAccessToken: () => 'stale-token',
      isAccessTokenExpired: () => false,
      refreshAccessToken: () async {
        refreshCalls++;
        return 'fresh-token';
      },
    );
    final client = NetworkClient(
      baseUrl: 'https://api.lawrence.test',
      tokenCoordinator: coordinator,
      dio: dio,
    );

    await expectLater(client.get<dynamic>('/protected'), throwsA(isNotNull));
    expect(refreshCalls, 1);
  });
}

class _AlwaysUnauthorizedAdapter implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return ResponseBody.fromString(
      '{"detail":"unauthorized"}',
      401,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
