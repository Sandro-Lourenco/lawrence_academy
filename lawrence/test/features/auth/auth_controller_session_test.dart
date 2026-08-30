import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lawrence/app/providers/service_repositories.dart';
import 'package:lawrence/features/auth/domain/repositories/auth_repository_interface.dart';
import 'package:lawrence/features/auth/presentation/controllers/auth_controller.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  group('signInErrorMessage', () {
    test(
      'identifies invalid credentials without mentioning an expired link',
      () {
        final message = signInErrorMessage(
          const AuthException(
            'Invalid login credentials',
            code: 'invalid_credentials',
          ),
        );

        expect(message, contains('E-mail ou senha incorretos'));
        expect(message, isNot(contains('link')));
      },
    );

    test('keeps email confirmation guidance specific', () {
      final message = signInErrorMessage(
        const AuthException('Email not confirmed', code: 'email_not_confirmed'),
      );

      expect(message, contains('Confirme seu e-mail'));
    });
  });

  test(
    'publishes login response session without waiting for auth stream',
    () async {
      final session = _session(role: 'student');
      final repository = _FakeAuthRepository(
        loginResponse: AuthResponse(session: session, user: session.user),
      );
      final container = ProviderContainer(
        overrides: [authRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(() async {
        container.dispose();
        await repository.dispose();
      });

      final notifier = container.read(authNotifierProvider.notifier);
      await notifier.signInWithEmail(
        email: 'aluno@lawrence.test',
        password: 'secure-password',
      );

      final state = container.read(authNotifierProvider);
      expect(state.user?.id, session.user.id);
      expect(state.session?.accessToken, 'access-token');
      expect(state.isLoading, isFalse);
      expect(state.errorMessage, isNull);
    },
  );

  test(
    'keeps valid session when auth stream reports a network error',
    () async {
      final session = _session(role: 'teacher');
      final repository = _FakeAuthRepository(
        initialSession: session,
        loginResponse: AuthResponse(session: session, user: session.user),
      );
      final container = ProviderContainer(
        overrides: [authRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(() async {
        container.dispose();
        await repository.dispose();
      });

      expect(container.read(authNotifierProvider).user?.id, session.user.id);
      repository.emitError(Exception('offline refresh failed'));
      await Future<void>.delayed(Duration.zero);

      expect(container.read(authNotifierProvider).user?.id, session.user.id);
      expect(container.read(authNotifierProvider).session, same(session));
    },
  );
}

Session _session({required String role}) {
  final user = User(
    id: '00000000-0000-0000-0000-000000000001',
    appMetadata: {'role': role},
    userMetadata: const {},
    aud: 'authenticated',
    email: 'user@lawrence.test',
    createdAt: '2026-01-01T00:00:00.000Z',
  );
  return Session(
    accessToken: 'access-token',
    refreshToken: 'refresh-token',
    tokenType: 'bearer',
    expiresIn: 3600,
    user: user,
  );
}

class _FakeAuthRepository implements IAuthRepository {
  final StreamController<AuthState> _authEvents =
      StreamController<AuthState>.broadcast();
  final AuthResponse loginResponse;
  final Session? initialSession;

  _FakeAuthRepository({required this.loginResponse, this.initialSession});

  @override
  Session? get currentSession => initialSession;

  @override
  User? get currentUser => initialSession?.user;

  @override
  Stream<AuthState> get onAuthStateChange => _authEvents.stream;

  void emitError(Object error) => _authEvents.addError(error);

  Future<void> dispose() => _authEvents.close();

  @override
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return loginResponse;
  }

  @override
  Future<bool> signInWithGoogle() async => true;

  @override
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
    String? referralCode,
  }) async {
    return loginResponse;
  }

  @override
  Future<void> resetPassword({required String email}) async {}

  @override
  Future<void> updatePassword({required String password}) async {}

  @override
  Future<void> signOut() async {}
}
