import 'package:flutter_test/flutter_test.dart';
import 'package:lawrence/core/error/app_error.dart';
import 'package:lawrence/core/errors/app_exceptions.dart';

void main() {
  test('maps Supabase oversized object to an actionable video error', () {
    final error = AppError.fromException(
      'StorageException(message: The object exceeded the maximum allowed size, statusCode: 413)',
    );

    expect(error.title, 'Vídeo muito grande');
    expect(error.message, contains('até 50 MB'));
    expect(error.message, isNot(contains('StorageException')));
    expect(error.type, ErrorType.validation);
  });

  test('does not report a backend failure as an offline connection', () {
    final error = AppError.fromException(
      const ServerFailure(
        message: 'database connection failed',
        code: 'HTTP_500',
      ),
    );

    expect(error.type, ErrorType.server);
    expect(error.title, 'Instabilidade no servidor');
  });

  test('reports only a real network failure as offline', () {
    final error = AppError.fromException(const NetworkFailure());

    expect(error.type, ErrorType.network);
    expect(error.title, 'Sem conexão');
  });
}
