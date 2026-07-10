import 'package:supabase_flutter/supabase_flutter.dart';

abstract class IAuthRepository {
  Session? get currentSession;
  User? get currentUser;
  Stream<AuthState> get onAuthStateChange;

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  });

  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
    String? referralCode,
  });

  Future<void> signOut();
}
