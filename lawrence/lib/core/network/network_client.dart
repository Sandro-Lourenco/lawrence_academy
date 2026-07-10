import 'package:dio/dio.dart';
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
          return handler.next(options);
        },
        onError: (DioException e, handler) {
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
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError) {
      return const NetworkFailure();
    }

    final response = e.response;
    if (response != null) {
      final statusCode = response.statusCode;
      final data = response.data;

      String message = 'Ocorreu um erro inesperado.';
      String? errorCode;

      if (data is Map<String, dynamic>) {
        if (data['error'] != null) {
          if (data['error'] is Map) {
            message = data['error']['message'] ?? message;
            errorCode = data['error']['code'];
          } else {
            message = data['error'].toString();
          }
        }
      }

      if (statusCode == 401 || statusCode == 403) {
        return AuthFailure(message: message, code: errorCode);
      }
      return ServerFailure(message: message, code: errorCode);
    }

    return const ServerFailure();
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
