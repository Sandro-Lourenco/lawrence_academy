import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import '../../domain/repositories/auth_repository_interface.dart';
import '../datasources/supabase_auth_datasource.dart';

class SupabaseAuthRepository implements IAuthRepository {
  final SupabaseAuthDataSource _dataSource;

  SupabaseAuthRepository(this._dataSource);

  @override
  sb.Session? get currentSession => _dataSource.currentSession;

  @override
  sb.User? get currentUser => _dataSource.currentUser;

  @override
  Stream<sb.AuthState> get onAuthStateChange => _dataSource.onAuthStateChange;

  @override
  Future<sb.AuthResponse> signIn({
    required String email,
    required String password,
  }) {
    return _dataSource.signIn(email: email, password: password);
  }

  @override
  Future<sb.AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
    String? referralCode,
  }) {
    return _dataSource.signUp(
      email: email,
      password: password,
      data: {'full_name': fullName, 'referred_by_code': referralCode},
    );
  }

  @override
  Future<void> signOut() {
    return _dataSource.signOut();
  }

  @override
  Future<void> resetPassword({required String email}) {
    return _dataSource.resetPassword(email: email);
  }
}
