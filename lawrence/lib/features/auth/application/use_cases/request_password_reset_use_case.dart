import '../../domain/repositories/auth_repository_interface.dart';

class RequestPasswordResetUseCase {
  final IAuthRepository _authRepository;

  RequestPasswordResetUseCase(this._authRepository);

  Future<void> execute({required String email}) async {
    await _authRepository.resetPassword(email: email);
  }
}
