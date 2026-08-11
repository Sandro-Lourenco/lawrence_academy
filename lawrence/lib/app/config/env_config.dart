import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';

enum AppEnvironment { dev, stage, prod }

class EnvConfig {
  final AppEnvironment environment;
  final String apiBaseUrl;
  final String supabaseUrl;
  final String supabaseAnonKey;

  const EnvConfig({
    required this.environment,
    required this.apiBaseUrl,
    required this.supabaseUrl,
    required this.supabaseAnonKey,
  });

  bool get isProduction => environment == AppEnvironment.prod;

  static EnvConfig fromEnvironment() {
    const environmentValue = String.fromEnvironment('ENV', defaultValue: 'dev');

    const providedApiBaseUrl = String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: '',
    );

    const providedSupabaseUrl = String.fromEnvironment(
      'SUPABASE_URL',
      defaultValue: '',
    );

    const providedSupabaseAnonKey = String.fromEnvironment(
      'SUPABASE_ANON_KEY',
      defaultValue: '',
    );

    return resolveEnvironment(
      environmentValue: environmentValue,
      providedApiBaseUrl: providedApiBaseUrl,
      providedSupabaseUrl: providedSupabaseUrl,
      providedSupabaseAnonKey: providedSupabaseAnonKey,
      defaultDevApiBaseUrl: _platformDevApiBaseUrl(),
    );
  }

  static EnvConfig resolveEnvironment({
    required String environmentValue,
    required String providedApiBaseUrl,
    required String providedSupabaseUrl,
    required String providedSupabaseAnonKey,
    String defaultDevApiBaseUrl = 'http://localhost:8000',
  }) {
    final environment = switch (environmentValue.toLowerCase()) {
      'dev' || 'development' => AppEnvironment.dev,
      'stage' || 'staging' => AppEnvironment.stage,
      'prod' || 'production' => AppEnvironment.prod,
      _ => throw StateError('Ambiente inválido: $environmentValue'),
    };

    final defaultApiBaseUrl = switch (environment) {
      AppEnvironment.dev => defaultDevApiBaseUrl,
      AppEnvironment.stage || AppEnvironment.prod => '',
    };

    final defaultSupabaseUrl = switch (environment) {
      AppEnvironment.dev || AppEnvironment.stage || AppEnvironment.prod => '',
    };

    final defaultSupabaseAnonKey = switch (environment) {
      AppEnvironment.dev || AppEnvironment.stage || AppEnvironment.prod => '',
    };

    final apiBaseUrl = providedApiBaseUrl.isNotEmpty
        ? providedApiBaseUrl
        : defaultApiBaseUrl;
    final supabaseUrl = providedSupabaseUrl.isNotEmpty
        ? providedSupabaseUrl
        : defaultSupabaseUrl;
    final supabaseAnonKey = providedSupabaseAnonKey.isNotEmpty
        ? providedSupabaseAnonKey
        : defaultSupabaseAnonKey;

    final config = EnvConfig(
      environment: environment,
      apiBaseUrl: apiBaseUrl,
      supabaseUrl: supabaseUrl,
      supabaseAnonKey: supabaseAnonKey,
    );

    config.validate();
    return config;
  }

  static String _platformDevApiBaseUrl() {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8000';
    }
    return 'http://localhost:8000';
  }

  void validate() {
    final uri = Uri.tryParse(apiBaseUrl);
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
      throw StateError('API_BASE_URL inválida.');
    }

    if (_isPrivilegedSupabaseKey(supabaseAnonKey)) {
      throw StateError(
        'SUPABASE_ANON_KEY cannot contain a service_role or secret key.',
      );
    }

    if (environment != AppEnvironment.dev) {
      if (uri.scheme != 'https') {
        throw StateError('Staging e produção exigem HTTPS.');
      }

      if (_isPrivateOrLocalHost(uri.host)) {
        throw StateError(
          'Staging e produção não podem usar endereço local ou privado.',
        );
      }

      if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
        throw StateError(
          'Configuração Supabase obrigatória em staging e produção.',
        );
      }

      final supabaseUri = Uri.tryParse(supabaseUrl);
      if (supabaseUri == null ||
          supabaseUri.scheme != 'https' ||
          supabaseUri.host.isEmpty ||
          _isPrivateOrLocalHost(supabaseUri.host)) {
        throw StateError('SUPABASE_URL deve ser um endpoint HTTPS público.');
      }
    }
  }

  static bool _isPrivilegedSupabaseKey(String key) {
    if (key.startsWith('sb_secret_')) return true;

    final parts = key.split('.');
    if (parts.length != 3) return false;

    try {
      final payload = utf8.decode(
        base64Url.decode(base64Url.normalize(parts[1])),
      );
      final claims = jsonDecode(payload);
      return claims is Map && claims['role'] == 'service_role';
    } catch (_) {
      return false;
    }
  }

  static bool _isPrivateOrLocalHost(String host) {
    final normalized = host.toLowerCase();

    if (normalized == 'localhost' ||
        normalized == '127.0.0.1' ||
        normalized == '::1' ||
        normalized == '10.0.2.2') {
      return true;
    }

    final parts = normalized
        .split('.')
        .map(int.tryParse)
        .toList(growable: false);

    if (parts.length != 4 || parts.any((part) => part == null)) {
      return false;
    }

    final a = parts[0]!;
    final b = parts[1]!;

    return a == 10 ||
        a == 127 ||
        (a == 172 && b >= 16 && b <= 31) ||
        (a == 192 && b == 168);
  }
}

final envConfigProvider = Provider<EnvConfig>((ref) {
  return EnvConfig.fromEnvironment();
});
