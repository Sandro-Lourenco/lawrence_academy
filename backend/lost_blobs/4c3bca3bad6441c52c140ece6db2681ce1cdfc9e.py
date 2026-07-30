import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AppEnvironment {
  dev,
  stage,
  prod,
}

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
    const environmentValue = String.fromEnvironment(
      'ENV',
      defaultValue: 'dev',
    );

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
    );
  }

  static EnvConfig resolveEnvironment({
    required String environmentValue,
    required String providedApiBaseUrl,
    required String providedSupabaseUrl,
    required String providedSupabaseAnonKey,
  }) {
    final environment = switch (environmentValue.toLowerCase()) {
      'dev' || 'development' => AppEnvironment.dev,
      'stage' || 'staging' => AppEnvironment.stage,
      'prod' || 'production' => AppEnvironment.prod,
      _ => throw StateError('Ambiente inválido: $environmentValue'),
    };

    final defaultApiBaseUrl = switch (environment) {
      AppEnvironment.dev => 'http://192.168.0.15:8000',
      AppEnvironment.stage => 'https://stage-api.lawrenceacademy.com',
      AppEnvironment.prod => 'https://api.lawrenceacademy.com',
    };

    final defaultSupabaseUrl = switch (environment) {
      AppEnvironment.dev || AppEnvironment.stage => 'https://xblesfvcrnbsfhlmoffz.supabase.co',
      AppEnvironment.prod => '',
    };

    final defaultSupabaseAnonKey = switch (environment) {
      AppEnvironment.dev || AppEnvironment.stage =>
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.'
        'eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InhibGVzZnZjcm5ic2ZobG1vZmZ6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODMzNjUwMzIsImV4cCI6MjA5ODk0MTAzMn0.'
        'L-mzinsIY8qJVw6oVYZgdBdV0aJqJzCq15DXNAUCEo0',
      AppEnvironment.prod => '',
    };

    final apiBaseUrl = providedApiBaseUrl.isNotEmpty ? providedApiBaseUrl : defaultApiBaseUrl;
    final supabaseUrl = providedSupabaseUrl.isNotEmpty ? providedSupabaseUrl : defaultSupabaseUrl;
    final supabaseAnonKey = providedSupabaseAnonKey.isNotEmpty ? providedSupabaseAnonKey : defaultSupabaseAnonKey;

    final config = EnvConfig(
      environment: environment,
      apiBaseUrl: apiBaseUrl,
      supabaseUrl: supabaseUrl,
      supabaseAnonKey: supabaseAnonKey,
    );

    config.validate();
    return config;
  }

  void validate() {
    final uri = Uri.tryParse(apiBaseUrl);
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
      throw StateError('API_BASE_URL inválida.');
    }

    if (isProduction) {
      if (uri.scheme != 'https') {
        throw StateError('Produção exige HTTPS.');
      }

      if (_isPrivateOrLocalHost(uri.host)) {
        throw StateError('Produção não pode usar endereço local ou privado.');
      }

      if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
        throw StateError('Configuração Supabase obrigatória em produção.');
      }
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

    final parts = normalized.split('.').map(int.tryParse).toList(growable: false);

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
