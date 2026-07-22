import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/repositories/auth_repository_interface.dart';

class RegisterUseCase {
  final IAuthRepository _authRepository;

  RegisterUseCase(this._authRepository);

  Future<AuthResponse> execute({
    required String email,
    required String password,
    required String fullName,
    String? referralCode,
  }) {
    return _authRepository.signUp(
      email: email,
      password: password,
      fullName: fullName,
      referralCode: referralCode,
    );
  }
}
