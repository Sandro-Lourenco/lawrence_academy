import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../../app/config/env_config.dart';
import '../errors/app_exceptions.dart';

final networkClientProvider = Provider<NetworkClient>((ref) {
  final env = ref.watch(envConfigProvider);

  // Como não queremos importar SupabaseClient diretamente aqui para desacoplamento,
  // podemos obter a sessão ativa a partir do SDK Supabase global.
  return NetworkClient(
    baseUrl: env.apiBaseUrl,
    getSessionToken: () {
      try {
        final session = supabase.Supabase.instance.client.auth.currentSession;
        return session?.accessToken;
      } catch (_) {
        return null;
      }
    },
  );
});

class NetworkClient {
  final Dio _dio;

  NetworkClient({
    required String baseUrl,
    required String? Function() getSessionToken,
  }) : _dio = Dio(
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
        onRequest: (options, handler) {
          final token = getSessionToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
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
        onError: (DioException e, handler) {
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
    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw e.error as Failure;
    }
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
      throw e.error as Failure;
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
      throw e.error as Failure;
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
      throw e.error as Failure;
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
      throw e.error as Failure;
    }
  }
}
