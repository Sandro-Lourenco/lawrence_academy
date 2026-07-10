import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/network/supabase_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/auth_repository_interface.dart';

class SupabaseAuthRepository implements IAuthRepository {
  final SupabaseClient _client;

  SupabaseAuthRepository(this._client);

  @override
  Session? get currentSession => _client.auth.currentSession;

  @override
  User? get currentUser => _client.auth.currentUser;

  @override
  Stream<AuthState> get onAuthStateChange => _client.auth.onAuthStateChange;

  @override
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  @override
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
    String? referralCode,
  }) async {
    return await _client.auth.signUp(
      email: email,
      password: password,
      data: {
        'full_name': fullName,
        if (referralCode != null) 'referred_by_code': referralCode,
      },
    );
  }

  @override
  Future<void> signOut() async {
    await _client.auth.signOut();
  }
}

final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SupabaseAuthRepository(client);
});
