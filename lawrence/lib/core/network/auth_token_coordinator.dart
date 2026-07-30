typedef ReadAccessToken = String? Function();
typedef RefreshAccessToken = Future<String?> Function();
typedef IsAccessTokenExpired = bool Function();

/// Coordinates access-token reads and refreshes for API requests.
///
/// Supabase refresh tokens rotate. A single-flight refresh prevents concurrent
/// 401 responses from trying to consume the same refresh token more than once.
class AuthTokenCoordinator {
  final ReadAccessToken readAccessToken;
  final RefreshAccessToken refreshAccessToken;
  final IsAccessTokenExpired isAccessTokenExpired;

  Future<String?>? _refreshInFlight;

  AuthTokenCoordinator({
    required this.readAccessToken,
    required this.refreshAccessToken,
    required this.isAccessTokenExpired,
  });

  Future<String?> tokenForRequest() async {
    if (!isAccessTokenExpired()) return readAccessToken();
    return refresh();
  }

  Future<String?> refresh() {
    final existing = _refreshInFlight;
    if (existing != null) return existing;

    final refresh = refreshAccessToken();
    _refreshInFlight = refresh;
    return refresh.whenComplete(() {
      if (identical(_refreshInFlight, refresh)) {
        _refreshInFlight = null;
      }
    });
  }
}
