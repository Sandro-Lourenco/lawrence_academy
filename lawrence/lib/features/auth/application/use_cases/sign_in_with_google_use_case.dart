import '../../domain/repositories/auth_repository_interface.dart';

class SignInWithGoogleUseCase {
  final IAuthRepository _authRepository;

  const SignInWithGoogleUseCase(this._authRepository);

  Future<bool> execute() => _authRepository.signInWithGoogle();
}
