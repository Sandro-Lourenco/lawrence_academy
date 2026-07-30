String authenticatedHomeForRole(String? role) {
  return role == 'teacher' || role == 'super_admin'
      ? '/teacher'
      : '/dashboard/home';
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
