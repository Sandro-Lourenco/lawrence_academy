import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../../../../app/providers/service_repositories.dart';

String signInErrorMessage(supabase.AuthException exception) {
  switch (exception.code) {
    case 'invalid_credentials':
      return 'E-mail ou senha incorretos. Confira os dados e tente novamente.';
    case 'email_not_confirmed':
      return 'Confirme seu e-mail antes de entrar. Solicite um novo link se necessário.';
    case 'over_request_rate_limit':
    case 'over_email_send_rate_limit':
      return 'Muitas tentativas de acesso. Aguarde alguns minutos e tente novamente.';
    default:
      return 'Não foi possível entrar agora. Tente novamente em instantes.';
  }
}

class AuthNotifierState {
  final supabase.User? user;
  final supabase.Session? session;
  final bool isLoading;
  final String? errorMessage;
  final bool isMfaEnabled;
  final bool registrationRequiresEmailConfirmation;

  AuthNotifierState({
    this.user,
    this.session,
    this.isLoading = false,
    this.errorMessage,
    this.isMfaEnabled = false,
    this.registrationRequiresEmailConfirmation = false,
  });

  AuthNotifierState copyWith({
    supabase.User? user,
    supabase.Session? session,
    bool? isLoading,
    String? errorMessage,
    bool? isMfaEnabled,
    bool? registrationRequiresEmailConfirmation,
  }) {
    return AuthNotifierState(
      user: user ?? this.user,
      session: session ?? this.session,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      isMfaEnabled: isMfaEnabled ?? this.isMfaEnabled,
      registrationRequiresEmailConfirmation:
          registrationRequiresEmailConfirmation ??
          this.registrationRequiresEmailConfirmation,
    );
  }
}

class AuthNotifier extends Notifier<AuthNotifierState> {
  @override
  AuthNotifierState build() {
    final restoreUseCase = ref.watch(restoreSessionUseCaseProvider);

    // Escutar mudanças de autenticação do Supabase
    final authSubscription = restoreUseCase.onAuthStateChange.listen(
      (data) {
        final session = data.session;
        final event = data.event;
        if (kDebugMode) debugPrint('[AuthNotifier] Auth state changed: $event');

        state = AuthNotifierState(
          user: session?.user,
          session: session,
          isMfaEnabled: _checkMfaEnabled(session),
        );
      },
      onError: (Object error, StackTrace _) {
        // Offline refresh failures are stream errors. Keep the last valid
        // session and handle the error so it cannot escape the Dart zone.
        if (kDebugMode) {
          debugPrint('[AuthNotifier] Auth state stream error: $error');
        }
        state = state.copyWith(isLoading: false);
      },
    );
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
      final response = await loginUseCase.execute(
        email: email,
        password: password,
      );
      final session = response.session;
      if (session == null) {
        throw const supabase.AuthException(
          'A autenticação não retornou uma sessão válida.',
        );
      }
      if (kDebugMode) debugPrint('[AuthNotifier] Sign in completed.');
      // The auth event is asynchronous. Publish the response session now so
      // login navigation and protected requests cannot race the event stream.
      state = AuthNotifierState(
        user: session.user,
        session: session,
        isMfaEnabled: _checkMfaEnabled(session),
      );
    } on supabase.AuthException catch (error) {
      if (kDebugMode) debugPrint('[AuthNotifier] Sign in rejected.');
      state = state.copyWith(
        isLoading: false,
        errorMessage: signInErrorMessage(error),
      );
    } catch (_) {
      if (kDebugMode) debugPrint('[AuthNotifier] Sign in failed.');
      state = state.copyWith(
        isLoading: false,
        errorMessage: "Ocorreu um erro interno no processamento dos dados.",
      );
    }
  }

  Future<void> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final launched = await ref
          .read(signInWithGoogleUseCaseProvider)
          .execute();
      if (!launched) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Não foi possível abrir o acesso com Google.',
        );
      }
    } on supabase.AuthException catch (error) {
      if (kDebugMode) debugPrint('[AuthNotifier] Google sign in rejected.');
      state = state.copyWith(
        isLoading: false,
        errorMessage: signInErrorMessage(error),
      );
    } catch (_) {
      if (kDebugMode) debugPrint('[AuthNotifier] Google sign in failed.');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Não foi possível entrar com Google agora.',
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
      final response = await registerUseCase.execute(
        email: email,
        password: password,
        fullName: fullName,
      );
      if (kDebugMode) debugPrint('[AuthNotifier] Sign up request completed.');
      final session = response.session;
      state = session == null
          ? AuthNotifierState(
              isLoading: false,
              registrationRequiresEmailConfirmation: true,
            )
          : AuthNotifierState(
              user: session.user,
              session: session,
              isMfaEnabled: _checkMfaEnabled(session),
            );
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
      state = AuthNotifierState();
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

  Future<bool> updatePassword({required String password}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await ref.read(updatePasswordUseCaseProvider).execute(password: password);
      state = state.copyWith(isLoading: false);
      return true;
    } on FormatException catch (error) {
      state = state.copyWith(isLoading: false, errorMessage: error.message);
      return false;
    } on supabase.AuthException catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: signInErrorMessage(error),
      );
      return false;
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Não foi possível atualizar sua senha agora.',
      );
      return false;
    }
  }
}

final authNotifierProvider = NotifierProvider<AuthNotifier, AuthNotifierState>(
  AuthNotifier.new,
);
