import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/repositories/auth_repository_interface.dart';

class RestoreSessionUseCase {
  final IAuthRepository _authRepository;

  RestoreSessionUseCase(this._authRepository);

  Session? execute() {
    return _authRepository.currentSession;
  }

  Stream<AuthState> get onAuthStateChange => _authRepository.onAuthStateChange;
}
