import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../../../../app/providers/service_repositories.dart';

class AuthNotifierState {
  final supabase.User? user;
  final supabase.Session? session;
  final bool isLoading;
  final String? errorMessage;
  final bool isMfaEnabled;

  AuthNotifierState({
    this.user,
    this.session,
    this.isLoading = false,
    this.errorMessage,
    this.isMfaEnabled = false,
  });

  AuthNotifierState copyWith({
    supabase.User? user,
    supabase.Session? session,
    bool? isLoading,
    String? errorMessage,
    bool? isMfaEnabled,
  }) {
    return AuthNotifierState(
      user: user ?? this.user,
      session: session ?? this.session,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      isMfaEnabled: isMfaEnabled ?? this.isMfaEnabled,
    );
  }
}

class AuthNotifier extends Notifier<AuthNotifierState> {
  @override
  AuthNotifierState build() {
    final restoreUseCase = ref.watch(restoreSessionUseCaseProvider);

    // Escutar mudanças de autenticação do Supabase
    final authSubscription = restoreUseCase.onAuthStateChange.listen((data) {
      final session = data.session;
      final event = data.event;
      if (kDebugMode) debugPrint('[AuthNotifier] Auth state changed: $event');

      state = AuthNotifierState(
        user: session?.user,
        session: session,
        isMfaEnabled: _checkMfaEnabled(session),
      );
    });
    ref.onDispose(authSubscription.cancel);

    final currentSession = restoreUseCase.execute();
    if (kDebugMode) debugPrint('[AuthNotifier] Session restore completed.');
    return AuthNotifierState(
      user: currentSession?.user,
      session: currentSession,
      isMfaEnabled: _checkMfaEnabled(currentSession),
    );
  }

  bool _checkMfaEnabled(supabase.Session? session) {
    if (session == null) return false;
    final amr = session.user.appMetadata['amr'];
    if (amr is List) {
      return amr.contains('mfa');
    }
    return false;
  }

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final loginUseCase = ref.read(loginUseCaseProvider);
      await loginUseCase.execute(email: email, password: password);
      if (kDebugMode) debugPrint('[AuthNotifier] Sign in completed.');
    } on supabase.AuthException catch (_) {
      if (kDebugMode) debugPrint('[AuthNotifier] Sign in rejected.');
      state = state.copyWith(
        isLoading: false,
        errorMessage:
            "Credenciais inválidas ou link de verificação expirado.", // OWASP obfuscation
      );
    } catch (_) {
      if (kDebugMode) debugPrint('[AuthNotifier] Sign in failed.');
      state = state.copyWith(
        isLoading: false,
        errorMessage: "Ocorreu um erro interno no processamento dos dados.",
      );
    }
  }

  Future<void> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final registerUseCase = ref.read(registerUseCaseProvider);
      await registerUseCase.execute(
        email: email,
        password: password,
        fullName: fullName,
      );
      if (kDebugMode) debugPrint('[AuthNotifier] Sign up request completed.');
      state = state.copyWith(isLoading: false);
    } on supabase.AuthException catch (e) {
      if (kDebugMode) debugPrint('[AuthNotifier] Sign up rejected.');
      state = state.copyWith(
        isLoading: false,
        errorMessage: "Erro ao cadastrar conta: ${e.message}",
      );
    } catch (_) {
      if (kDebugMode) debugPrint('[AuthNotifier] Sign up failed.');
      state = state.copyWith(
        isLoading: false,
        errorMessage: "Ocorreu um erro interno no processamento dos dados.",
      );
    }
  }

  Future<void> signOut() async {
    state = state.copyWith(isLoading: true);
    try {
      final logoutUseCase = ref.read(logoutUseCaseProvider);
      await logoutUseCase.execute();
      if (kDebugMode) debugPrint('[AuthNotifier] Sign out completed.');
    } catch (_) {
      if (kDebugMode) debugPrint('[AuthNotifier] Sign out failed.');
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> requestPasswordReset({required String email}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final resetUseCase = ref.read(requestPasswordResetUseCaseProvider);
      await resetUseCase.execute(email: email);
      if (kDebugMode) {
        debugPrint('[AuthNotifier] Password reset request completed.');
      }
      state = state.copyWith(isLoading: false);
    } catch (_) {
      if (kDebugMode) debugPrint('[AuthNotifier] Password reset failed.');
      state = state.copyWith(
        isLoading: false,
        errorMessage: "Ocorreu um erro interno no processamento dos dados.",
      );
    }
  }
}

final authNotifierProvider = NotifierProvider<AuthNotifier, AuthNotifierState>(
  AuthNotifier.new,
);
