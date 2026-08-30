String authenticatedHomeForRole(String? role) {
  return role == 'teacher' || role == 'super_admin'
      ? '/teacher'
      : '/dashboard/home';
}

String postAuthDestinationForRole(String? role, Uri loginUri) {
  if (role == 'teacher' || role == 'super_admin') {
    return '/teacher';
  }

  return safePostAuthRedirect(loginUri) ?? authenticatedHomeForRole(role);
}

bool shouldRedirectAuthenticatedFromPublicEntry(String path) =>
    path == '/' ||
    path == '/login' ||
    path == '/register' ||
    path == '/forgot-password';

String loginLocationFor(Uri destination) => Uri(
  path: '/login',
  queryParameters: {'redirect': destination.toString()},
).toString();

String? safePostAuthRedirect(Uri uri) {
  final destination = uri.queryParameters['redirect'];
  if (destination == null ||
      !destination.startsWith('/') ||
      destination.startsWith('//') ||
      destination.contains('\\') ||
      destination.contains(RegExp(r'[\u0000-\u001F\u007F]'))) {
    return null;
  }
  try {
    return shouldRedirectAuthenticatedFromPublicEntry(
          Uri.parse(destination).path,
        )
        ? null
        : destination;
  } on FormatException {
    return null;
  }
}

bool isLoginCallbackUri(Uri uri) =>
    uri.path == '/login-callback' ||
    (uri.scheme == 'lawrence' && uri.host == 'login-callback');
