abstract class Failure {
  final String message;
  final String? code;

  const Failure(this.message, {this.code});

  @override
  String toString() => 'Failure(code: $code, message: $message)';
}

class ServerFailure extends Failure {
  const ServerFailure({
    String message = 'Erro de comunicação com o servidor remoto.',
    String? code,
  }) : super(message, code: code ?? 'SERVER_ERROR');
}

class CacheFailure extends Failure {
  const CacheFailure({
    String message = 'Falha na persistência ou leitura dos dados locais.',
    String? code,
  }) : super(message, code: code ?? 'CACHE_ERROR');
}

class NetworkFailure extends Failure {
  const NetworkFailure({
    String message = 'Sem conexão com a internet. Verifique sua rede.',
    String? code,
  }) : super(message, code: code ?? 'NO_CONNECTION');
}

class AuthFailure extends Failure {
  const AuthFailure({
    String message = 'Credenciais inválidas ou sessão expirada.',
    String? code,
  }) : super(message, code: code ?? 'UNAUTHORIZED');
}
