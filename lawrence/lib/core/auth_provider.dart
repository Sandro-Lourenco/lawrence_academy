import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Provedor para o cliente Supabase global
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

// Modelo de estado de autenticação
class AuthState {
  final User? user;
  final Session? session;
  final bool isLoading;
  final String? errorMessage;
  final bool isMfaEnabled;

  AuthState({
    this.user,
    this.session,
    this.isLoading = false,
    this.errorMessage,
    this.isMfaEnabled = false,
  });

  AuthState copyWith({
    User? user,
    Session? session,
    bool? isLoading,
    String? errorMessage,
    bool? isMfaEnabled,
  }) {
    return AuthState(
      user: user ?? this.user,
      session: session ?? this.session,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      isMfaEnabled: isMfaEnabled ?? this.isMfaEnabled,
    );
  }
}

// Notificador de estado de autenticação utilizando Riverpod Notifier
class AuthNotifier extends AutoDisposeNotifier<AuthState> {
  @override
  AuthState build() {
    final client = ref.watch(supabaseClientProvider);

    // Escutar mudanças de autenticação do Supabase
    client.auth.onAuthStateChange.listen((data) {
      final session = data.session;
      state = AuthState(
        user: session?.user,
        session: session,
        isMfaEnabled: _checkMfaEnabled(session),
      );
    });

    final currentSession = client.auth.currentSession;
    return AuthState(
      user: currentSession?.user,
      session: currentSession,
      isMfaEnabled: _checkMfaEnabled(currentSession),
    );
  }

  bool _checkMfaEnabled(Session? session) {
    if (session == null) return false;
    // Verifica se há claims MFA ativas na sessão decodificada (amr)
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
      final client = ref.read(supabaseClientProvider);
      await client.auth.signInWithPassword(email: email, password: password);
    } on AuthException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage:
            "Credenciais inválidas ou link de verificação expirado.", // Mensagem ofuscada conforme regras OWASP
      );
    } catch (e) {
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
    String? referralCode,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final client = ref.read(supabaseClientProvider);
      await client.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
          if (referralCode != null) 'referred_by_code': referralCode,
        },
      );
      state = state.copyWith(isLoading: false);
    } on AuthException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: "Erro ao cadastrar conta: ${e.message}",
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: "Erro de processamento interno.",
      );
    }
  }

  Future<void> signOut() async {
    state = state.copyWith(isLoading: true);
    try {
      final client = ref.read(supabaseClientProvider);
      await client.auth.signOut();
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }
}

// Provedor global do estado de autenticação
final authNotifierProvider =
    AutoDisposeNotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);
