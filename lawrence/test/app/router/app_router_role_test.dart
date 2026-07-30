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
    test('opens the role dashboard from the public home', () {
      expect(shouldRedirectAuthenticatedFromPublicEntry('/'), isTrue);
    });

    test('keeps the authenticated session in catalog routes', () {
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

  group('safePostAuthRedirect', () {
    test('preserva o curso que motivou o login', () {
      expect(
        safePostAuthRedirect(
          Uri.parse('/login?redirect=%2Fcourses%2Fmodelagem'),
        ),
        '/courses/modelagem',
      );
    });

    test('rejeita redirecionamentos externos e loops de autenticação', () {
      expect(
        safePostAuthRedirect(Uri.parse('/login?redirect=https%3A%2F%2Fevil.test')),
        isNull,
      );
      expect(
        safePostAuthRedirect(Uri.parse('/login?redirect=%2F%2Fevil.test')),
        isNull,
      );
      expect(
        safePostAuthRedirect(Uri.parse('/login?redirect=%2Fregister')),
        isNull,
      );
    });
  });

  test('loginLocationFor preserva uma rota protegida completa', () {
    final loginUri = Uri.parse(
      loginLocationFor(Uri.parse('/checkout/course-1?coupon=welcome')),
    );

    expect(loginUri.path, '/login');
    expect(
      loginUri.queryParameters['redirect'],
      '/checkout/course-1?coupon=welcome',
    );
  });
}
