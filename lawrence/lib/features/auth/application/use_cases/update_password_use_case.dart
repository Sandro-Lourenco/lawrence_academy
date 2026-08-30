import '../../domain/repositories/auth_repository_interface.dart';

class UpdatePasswordUseCase {
  const UpdatePasswordUseCase(this._repository);

  final IAuthRepository _repository;

  Future<void> execute({required String password}) {
    if (password.length < 8) {
      throw const FormatException('A senha deve ter pelo menos 8 caracteres.');
    }
    return _repository.updatePassword(password: password);
  }
}
