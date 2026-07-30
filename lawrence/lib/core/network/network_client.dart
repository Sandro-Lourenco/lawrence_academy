import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../../app/config/env_config.dart';
import '../errors/app_exceptions.dart';
import 'auth_token_coordinator.dart';

final networkClientProvider = Provider<NetworkClient>((ref) {
  final env = ref.watch(envConfigProvider);
  final tokenCoordinator = AuthTokenCoordinator(
    readAccessToken: () {
      try {
        return supabase
            .Supabase
            .instance
            .client
            .auth
            .currentSession
            ?.accessToken;
      } catch (_) {
        return null;
      }
    },
    isAccessTokenExpired: () {
      try {
        return supabase
                .Supabase
                .instance
                .client
                .auth
                .currentSession
                ?.isExpired ??
            false;
      } catch (_) {
        return false;
      }
    },
    refreshAccessToken: () async {
      final authClient = supabase.Supabase.instance.client.auth;
      try {
        final response = await authClient.refreshSession();
        return response.session?.accessToken;
      } on supabase.AuthRetryableFetchException {
        rethrow;
      } on supabase.AuthException {
        // A rejected refresh token cannot recover (for example after a local
        // Supabase reset). Remove only this device's stale persisted session.
        await authClient.signOut(scope: supabase.SignOutScope.local);
        rethrow;
      }
    },
  );

  // Como não queremos importar SupabaseClient diretamente aqui para desacoplamento,
  // podemos obter a sessão ativa a partir do SDK Supabase global.
  return NetworkClient(
    baseUrl: env.apiBaseUrl,
    tokenCoordinator: tokenCoordinator,
  );
});

class NetworkClient {
  final Dio _dio;
  static const _maxReadAttempts = 3;
  static const _authRetryKey = 'authRetryAttempted';
  static const _forcedAuthTokenKey = 'forcedAuthToken';

  NetworkClient({
    required String baseUrl,
    required AuthTokenCoordinator tokenCoordinator,
    Dio? dio,
  }) : _dio =
           dio ??
           Dio(
             BaseOptions(
               baseUrl: baseUrl,
               connectTimeout: const Duration(seconds: 15),
               receiveTimeout: const Duration(seconds: 15),
               headers: {
                 'Content-Type': 'application/json',
                 'Accept': 'application/json',
               },
             ),
           ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          try {
            final forcedToken =
                options.extra.remove(_forcedAuthTokenKey) as String?;
            final token =
                forcedToken ?? await tokenCoordinator.tokenForRequest();
            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
            } else {
              options.headers.remove('Authorization');
            }
          } catch (error) {
            if (kDebugMode) {
              debugPrint(
                '[HTTP] Session refresh before request failed: $error',
              );
            }
          }
          options.extra['startTime'] = DateTime.now();
          if (kDebugMode) {
            debugPrint('[HTTP] ${options.method} ${options.uri.path}');
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          final startTime =
              response.requestOptions.extra['startTime'] as DateTime?;
          final duration = startTime != null
              ? DateTime.now().difference(startTime).inMilliseconds
              : null;
          if (kDebugMode) {
            debugPrint(
              '[HTTP] ${response.statusCode} '
              '${response.requestOptions.method} '
              '${response.requestOptions.uri.path} (${duration}ms)',
            );
          }
          return handler.next(response);
        },
        onError: (DioException e, handler) async {
          if (e.response?.statusCode == 401 &&
              e.requestOptions.extra[_authRetryKey] != true) {
            e.requestOptions.extra[_authRetryKey] = true;
            try {
              final refreshedToken = await tokenCoordinator.refresh();
              if (refreshedToken != null && refreshedToken.isNotEmpty) {
                e.requestOptions.headers['Authorization'] =
                    'Bearer $refreshedToken';
                e.requestOptions.extra[_forcedAuthTokenKey] = refreshedToken;
                final response = await _dio.fetch<dynamic>(e.requestOptions);
                return handler.resolve(response);
              }
            } catch (error) {
              if (kDebugMode) {
                debugPrint('[HTTP] Session refresh after 401 failed: $error');
              }
            }
          }

          final startTime = e.requestOptions.extra['startTime'] as DateTime?;
          final duration = startTime != null
              ? DateTime.now().difference(startTime).inMilliseconds
              : null;
          if (kDebugMode) {
            debugPrint(
              '[HTTP] ${e.response?.statusCode ?? 'network_error'} '
              '${e.requestOptions.method} '
              '${e.requestOptions.uri.path} (${duration}ms)',
            );
          }
          final failure = _handleDioError(e);
          return handler.next(
            DioException(
              requestOptions: e.requestOptions,
              response: e.response,
              type: e.type,
              error: failure,
              message: failure.message,
            ),
          );
        },
      ),
    );
  }

  Failure _handleDioError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout) {
      return const NetworkFailure(
        message: 'Tempo de conexão limite atingido (ConnectionTimeout).',
        code: 'CONNECTION_TIMEOUT',
      );
    } else if (e.type == DioExceptionType.sendTimeout) {
      return const NetworkFailure(
        message: 'Tempo de envio limite atingido (SendTimeout).',
        code: 'SEND_TIMEOUT',
      );
    } else if (e.type == DioExceptionType.receiveTimeout) {
      return const NetworkFailure(
        message: 'Tempo de recebimento limite atingido (ReceiveTimeout).',
        code: 'RECEIVE_TIMEOUT',
      );
    } else if (e.type == DioExceptionType.connectionError) {
      return NetworkFailure(
        message:
            'Erro de conexão física ou rede inacessível (ConnectionError). Detalhes: ${e.error}',
        code: 'CONNECTION_ERROR',
      );
    }

    final response = e.response;
    if (response != null) {
      final statusCode = response.statusCode;
      final data = response.data;

      String message = 'Erro do servidor (Status: $statusCode).';
      String? errorCode = 'HTTP_$statusCode';

      if (data is Map<String, dynamic>) {
        if (data['error'] != null) {
          if (data['error'] is Map) {
            message = data['error']['message'] ?? message;
            errorCode = data['error']['code']?.toString() ?? errorCode;
          } else {
            message = data['error'].toString();
          }
        } else if (data['message'] != null) {
          message = data['message'].toString();
        } else if (data['detail'] != null) {
          message = data['detail'].toString();
        }
      }

      if (statusCode == 401 || statusCode == 403) {
        return AuthFailure(message: message, code: errorCode);
      }
      return ServerFailure(message: message, code: errorCode);
    }

    return ServerFailure(
      message: 'Falha inesperada na requisição: ${e.message}',
      code: 'UNKNOWN_FAILURE',
    );
  }

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    for (var attempt = 1; attempt <= _maxReadAttempts; attempt++) {
      try {
        return await _dio.get<T>(
          path,
          queryParameters: queryParameters,
          options: options,
          cancelToken: cancelToken,
        );
      } on DioException catch (error) {
        if (attempt == _maxReadAttempts ||
            !_isRetryableRead(error) ||
            cancelToken?.isCancelled == true) {
          throw _failureFrom(error);
        }
        await Future<void>.delayed(
          Duration(milliseconds: 200 * (1 << (attempt - 1))),
        );
      }
    }
    throw StateError('Unreachable retry state.');
  }

  bool _isRetryableRead(DioException error) {
    if (error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return true;
    }
    return const {408, 429, 502, 503, 504}.contains(error.response?.statusCode);
  }

  Failure _failureFrom(DioException error) {
    final mapped = error.error;
    return mapped is Failure
        ? mapped
        : NetworkFailure(
            message: 'Não foi possível acessar o serviço.',
            code: 'TRANSPORT_ERROR',
          );
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _failureFrom(e);
    }
  }

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _failureFrom(e);
    }
  }

  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.patch<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _failureFrom(e);
    }
  }

  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _failureFrom(e);
    }
  }
}
