import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../data/repositories/supabase_auth_repository.dart';

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

class AuthNotifier extends AutoDisposeNotifier<AuthNotifierState> {
  @override
  AuthNotifierState build() {
    final repo = ref.watch(authRepositoryProvider);

    // Escutar mudanças de autenticação do Supabase
    repo.onAuthStateChange.listen((data) {
      final session = data.session;
      state = AuthNotifierState(
        user: session?.user,
        session: session,
        isMfaEnabled: _checkMfaEnabled(session),
      );
    });

    final currentSession = repo.currentSession;
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
      final repo = ref.read(authRepositoryProvider);
      await repo.signIn(email: email, password: password);
    } on supabase.AuthException catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage:
            "Credenciais inválidas ou link de verificação expirado.", // OWASP obfuscation
      );
    } catch (_) {
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
      final repo = ref.read(authRepositoryProvider);
      await repo.signUp(email: email, password: password, fullName: fullName);
      state = state.copyWith(isLoading: false);
    } on supabase.AuthException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: "Erro ao cadastrar conta: ${e.message}",
      );
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: "Ocorreu um erro interno no processamento dos dados.",
      );
    }
  }

  Future<void> signOut() async {
    state = state.copyWith(isLoading: true);
    try {
      final repo = ref.read(authRepositoryProvider);
      await repo.signOut();
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }
}

final authNotifierProvider =
    AutoDisposeNotifierProvider<AuthNotifier, AuthNotifierState>(
      AuthNotifier.new,
    );
