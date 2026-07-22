import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

enum ErrorType {
  network,
  timeout,
  unauthorized,
  forbidden,
  notFound,
  validation,
  tooManyRequests,
  server,
  invalidResponse,
  unknown,
}

class AppError implements Exception {
  final String title;
  final String message;
  final ErrorType type;
  final IconData icon;

  const AppError({
    required this.title,
    required this.message,
    this.type = ErrorType.unknown,
    this.icon = Icons.error_outline,
  });

  factory AppError.fromException(dynamic exception) {
    String message = 'Ocorreu um erro inesperado. Tente novamente mais tarde.';
    String title = 'Ops, algo deu errado';
    ErrorType type = ErrorType.unknown;
    IconData icon = Icons.error_outline;

    if (exception is DioException) {
      if (exception.type == DioExceptionType.connectionTimeout ||
          exception.type == DioExceptionType.receiveTimeout ||
          exception.type == DioExceptionType.sendTimeout) {
        return const AppError(
          title: 'Tempo esgotado',
          message:
              'O servidor demorou muito para responder. Verifique sua conexão e tente novamente.',
          type: ErrorType.timeout,
          icon: Icons.timer_off_outlined,
        );
      }

      if (exception.type == DioExceptionType.connectionError) {
        return const AppError(
          title: 'Sem conexão',
          message:
              'Não foi possível conectar ao servidor. Verifique sua internet.',
          type: ErrorType.network,
          icon: Icons.wifi_off,
        );
      }

      if (exception.response != null) {
        final statusCode = exception.response!.statusCode;

        switch (statusCode) {
          case 401:
            return const AppError(
              title: 'Sessão expirada',
              message:
                  'Sua sessão expirou. Faça login novamente para continuar.',
              type: ErrorType.unauthorized,
              icon: Icons.lock_outline,
            );
          case 403:
            return const AppError(
              title: 'Acesso Negado',
              message: 'Você não tem permissão para acessar este recurso.',
              type: ErrorType.forbidden,
              icon: Icons.block,
            );
          case 404:
            return const AppError(
              title: 'Não encontrado',
              message: 'O recurso que você tentou acessar não está disponível.',
              type: ErrorType.notFound,
              icon: Icons.search_off,
            );
          case 422:
            return const AppError(
              title: 'Dados inválidos',
              message:
                  'As informações enviadas são inválidas. Verifique os dados e tente novamente.',
              type: ErrorType.validation,
              icon: Icons.warning_amber_rounded,
            );
          case 429:
            return const AppError(
              title: 'Muitas requisições',
              message:
                  'Você fez muitas requisições em pouco tempo. Aguarde alguns instantes.',
              type: ErrorType.tooManyRequests,
              icon: Icons.hourglass_empty,
            );
          case 500:
          case 502:
          case 503:
          case 504:
            return const AppError(
              title: 'Instabilidade no servidor',
              message:
                  'Nossos servidores estão passando por uma instabilidade. Tente novamente mais tarde.',
              type: ErrorType.server,
              icon: Icons.dns_outlined,
            );
          default:
            return const AppError(
              title: 'Resposta Inválida',
              message: 'O servidor retornou uma resposta não esperada.',
              type: ErrorType.invalidResponse,
              icon: Icons.error_outline,
            );
        }
      }
    }

    final str = exception.toString().toLowerCase();

    if (str.contains('socket') ||
        str.contains('network') ||
        str.contains('conexão') ||
        str.contains('connection_error') ||
        str.contains('no_connection')) {
      return const AppError(
        title: 'Sem conexão',
        message:
            'Parece que você está offline. Verifique sua internet e tente novamente.',
        type: ErrorType.network,
        icon: Icons.wifi_off,
      );
    }

    if (str.contains('timeout') || str.contains('tempo')) {
      return const AppError(
        title: 'Tempo esgotado',
        message: 'O servidor demorou muito para responder. Tente novamente.',
        type: ErrorType.timeout,
        icon: Icons.timer_off_outlined,
      );
    }

    if (str.contains('401') ||
        str.contains('unauthorized') ||
        str.contains('token')) {
      return const AppError(
        title: 'Sessão expirada',
        message: 'Sua sessão expirou. Faça login novamente para continuar.',
        type: ErrorType.unauthorized,
        icon: Icons.lock_outline,
      );
    }

    if (str.contains('403') || str.contains('forbidden')) {
      return const AppError(
        title: 'Acesso Negado',
        message: 'Você não tem permissão para acessar este recurso.',
        type: ErrorType.forbidden,
        icon: Icons.block,
      );
    }

    if (str.contains('404') ||
        str.contains('not found') ||
        str.contains('http_404')) {
      return const AppError(
        title: 'Não encontrado',
        message: 'O recurso que você tentou acessar não está mais disponível.',
        type: ErrorType.notFound,
        icon: Icons.search_off,
      );
    }

    if (str.contains('422') || str.contains('http_422')) {
      return const AppError(
        title: 'Dados inválidos',
        message:
            'As informações enviadas são inválidas. Verifique os dados e tente novamente.',
        type: ErrorType.validation,
        icon: Icons.warning_amber_rounded,
      );
    }

    if (str.contains('429') || str.contains('http_429')) {
      return const AppError(
        title: 'Muitas requisições',
        message:
            'Você fez muitas requisições em pouco tempo. Aguarde alguns instantes.',
        type: ErrorType.tooManyRequests,
        icon: Icons.hourglass_empty,
      );
    }

    if (str.contains('500') ||
        str.contains('server') ||
        str.contains('http_50')) {
      return const AppError(
        title: 'Instabilidade no servidor',
        message:
            'Nossos servidores estão passando por uma instabilidade. Tente novamente mais tarde.',
        type: ErrorType.server,
        icon: Icons.dns_outlined,
      );
    }

    return AppError(
      title: title,
      message: '$message\n\nDetalhes: $exception',
      type: type,
      icon: icon,
    );
  }
}
