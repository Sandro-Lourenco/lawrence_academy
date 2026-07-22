import 'package:flutter_test/flutter_test.dart';
import 'package:lawrence/app/router/app_router.dart';

void main() {
  group('authenticatedHomeForRole', () {
    test('direciona professor para o Teacher Studio', () {
      expect(authenticatedHomeForRole('teacher'), '/teacher');
    });

    test('direciona super admin para o Teacher Studio', () {
      expect(authenticatedHomeForRole('super_admin'), '/teacher');
    });

    test('mantem aluno no painel do aluno', () {
      expect(authenticatedHomeForRole('student'), '/dashboard/home');
      expect(authenticatedHomeForRole(null), '/dashboard/home');
    });
  });

  group('authenticated public navigation', () {
    test('keeps the authenticated session in catalog routes', () {
      expect(shouldRedirectAuthenticatedFromPublicEntry('/'), isFalse);
      expect(shouldRedirectAuthenticatedFromPublicEntry('/courses'), isFalse);
      expect(
        shouldRedirectAuthenticatedFromPublicEntry('/courses/modelagem'),
        isFalse,
      );
    });

    test('redirects authenticated users away from authentication forms', () {
      expect(shouldRedirectAuthenticatedFromPublicEntry('/login'), isTrue);
      expect(shouldRedirectAuthenticatedFromPublicEntry('/register'), isTrue);
      expect(
        shouldRedirectAuthenticatedFromPublicEntry('/forgot-password'),
        isTrue,
      );
    });
  });
}
