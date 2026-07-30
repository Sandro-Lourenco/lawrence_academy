import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:lawrence/core/network/auth_token_coordinator.dart';

void main() {
  test('uses the current token while it is valid', () async {
    var refreshCalls = 0;
    final coordinator = AuthTokenCoordinator(
      readAccessToken: () => 'current-token',
      isAccessTokenExpired: () => false,
      refreshAccessToken: () async {
        refreshCalls++;
        return 'refreshed-token';
      },
    );

    expect(await coordinator.tokenForRequest(), 'current-token');
    expect(refreshCalls, 0);
  });

  test('refreshes an expired token before the request', () async {
    var refreshCalls = 0;
    final coordinator = AuthTokenCoordinator(
      readAccessToken: () => 'expired-token',
      isAccessTokenExpired: () => true,
      refreshAccessToken: () async {
        refreshCalls++;
        return 'refreshed-token';
      },
    );

    expect(await coordinator.tokenForRequest(), 'refreshed-token');
    expect(refreshCalls, 1);
  });

  test('deduplicates concurrent refreshes to protect token rotation', () async {
    var refreshCalls = 0;
    final refreshCompleter = Completer<String?>();
    final coordinator = AuthTokenCoordinator(
      readAccessToken: () => 'expired-token',
      isAccessTokenExpired: () => true,
      refreshAccessToken: () {
        refreshCalls++;
        return refreshCompleter.future;
      },
    );

    final first = coordinator.refresh();
    final second = coordinator.refresh();
    final third = coordinator.tokenForRequest();
    refreshCompleter.complete('refreshed-token');

    expect(await Future.wait([first, second, third]), [
      'refreshed-token',
      'refreshed-token',
      'refreshed-token',
    ]);
    expect(refreshCalls, 1);
  });

  test('allows a later refresh after the single flight completes', () async {
    var refreshCalls = 0;
    final coordinator = AuthTokenCoordinator(
      readAccessToken: () => null,
      isAccessTokenExpired: () => true,
      refreshAccessToken: () async => 'token-${++refreshCalls}',
    );

    expect(await coordinator.refresh(), 'token-1');
    expect(await coordinator.refresh(), 'token-2');
    expect(refreshCalls, 2);
  });
}
