import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/repositories/auth_repository_interface.dart';

class LoginUseCase {
  final IAuthRepository _authRepository;

  LoginUseCase(this._authRepository);

  Future<AuthResponse> execute({
    required String email,
    required String password,
  }) {
    return _authRepository.signIn(email: email, password: password);
  }
}
