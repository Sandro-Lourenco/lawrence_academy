import '../../domain/repositories/auth_repository_interface.dart';

class LogoutUseCase {
  final IAuthRepository _authRepository;

  LogoutUseCase(this._authRepository);

  Future<void> execute() {
    return _authRepository.signOut();
  }
}
