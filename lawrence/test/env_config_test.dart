import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lawrence/app/config/env_config.dart';
import 'package:lawrence/core/network/network_client.dart';

void main() {
  group("EnvConfig Unit Tests", () {
    // 1. ambiente dev com URL padrão
    test("dev env com URL padrao", () {
      final config = EnvConfig.resolveEnvironment(
        environmentValue: 'dev',
        providedApiBaseUrl: '',
        providedSupabaseUrl: '',
        providedSupabaseAnonKey: '',
      );
      expect(config.environment, AppEnvironment.dev);
      expect(config.apiBaseUrl, 'http://localhost:8000');
    });

    // 2. override de API_BASE_URL
    test("override de API_BASE_URL", () {
      final config = EnvConfig.resolveEnvironment(
        environmentValue: 'dev',
        providedApiBaseUrl: 'http://custom-api.local',
        providedSupabaseUrl: '',
        providedSupabaseAnonKey: '',
      );
      expect(config.apiBaseUrl, 'http://custom-api.local');
    });

    // 3. ambiente inválido
    test("ambiente invalido", () {
      expect(
        () => EnvConfig.resolveEnvironment(
          environmentValue: 'invalid_env',
          providedApiBaseUrl: '',
          providedSupabaseUrl: '',
          providedSupabaseAnonKey: '',
        ),
        throwsStateError,
      );
    });

    // 4. produção sem URL (na verdade resolveEnvironment gera padrão do switch, mas se a gerada ou fornecida for inválida)
    test("producao exige HTTPS", () {
      // 5. produção com HTTP deve falhar
      expect(
        () => EnvConfig.resolveEnvironment(
          environmentValue: 'prod',
          providedApiBaseUrl: 'http://api.lawrence.com',
          providedSupabaseUrl: 'https://test.supabase.co',
          providedSupabaseAnonKey: 'test-key',
        ),
        throwsStateError,
      );
    });

    // 6. produção com localhost
    test("producao com localhost deve falhar", () {
      expect(
        () => EnvConfig.resolveEnvironment(
          environmentValue: 'prod',
          providedApiBaseUrl: 'https://localhost',
          providedSupabaseUrl: 'https://test.supabase.co',
          providedSupabaseAnonKey: 'test-key',
        ),
        throwsStateError,
      );
    });

    // 7. produção com 10.*
    test("producao com 10.* deve falhar", () {
      expect(
        () => EnvConfig.resolveEnvironment(
          environmentValue: 'prod',
          providedApiBaseUrl: 'https://10.0.0.1',
          providedSupabaseUrl: 'https://test.supabase.co',
          providedSupabaseAnonKey: 'test-key',
        ),
        throwsStateError,
      );
    });

    // 8. produção com 172.16.* a 172.31.*
    test("producao com 172.16.* deve falhar", () {
      expect(
        () => EnvConfig.resolveEnvironment(
          environmentValue: 'prod',
          providedApiBaseUrl: 'https://172.16.0.1',
          providedSupabaseUrl: 'https://test.supabase.co',
          providedSupabaseAnonKey: 'test-key',
        ),
        throwsStateError,
      );
    });

    // 9. produção com 192.168.*
    test("producao com 192.168.* deve falhar", () {
      expect(
        () => EnvConfig.resolveEnvironment(
          environmentValue: 'prod',
          providedApiBaseUrl: 'https://192.168.0.1',
          providedSupabaseUrl: 'https://test.supabase.co',
          providedSupabaseAnonKey: 'test-key',
        ),
        throwsStateError,
      );
    });

    // 10. produção com HTTPS público válido
    test("producao com HTTPS publico valido deve passar", () {
      final config = EnvConfig.resolveEnvironment(
        environmentValue: 'prod',
        providedApiBaseUrl: 'https://api.lawrenceacademy.com',
        providedSupabaseUrl: 'https://test.supabase.co',
        providedSupabaseAnonKey: 'test-key',
      );
      expect(config.environment, AppEnvironment.prod);
      expect(config.apiBaseUrl, 'https://api.lawrenceacademy.com');
    });

    // 11. Supabase ausente em produção
    test("Supabase ausente em producao deve falhar", () {
      expect(
        () => EnvConfig.resolveEnvironment(
          environmentValue: 'prod',
          providedApiBaseUrl: 'https://api.lawrenceacademy.com',
          providedSupabaseUrl: '', // Supabase vazio
          providedSupabaseAnonKey: '',
        ),
        throwsStateError,
      );
    });

    // 12. alinhamento entre EnvConfig e NetworkClient
    test("alinhamento entre EnvConfig e NetworkClient", () {
      final config = EnvConfig.resolveEnvironment(
        environmentValue: 'dev',
        providedApiBaseUrl: 'http://192.168.0.15:8000',
        providedSupabaseUrl: '',
        providedSupabaseAnonKey: '',
      );

      final container = ProviderContainer(
        overrides: [envConfigProvider.overrideWithValue(config)],
      );

      final client = container.read(networkClientProvider);
      // Podemos induzir o client de forma reflexiva se precisar,
      // ou apenas validar a injeção do provider
      expect(client, isNotNull);
    });
    test("rejeita service_role no cliente Flutter", () {
      const serviceRolePayload =
          'eyJyb2xlIjoic2VydmljZV9yb2xlIiwicmVmIjoidGVzdGUifQ';

      expect(
        () => EnvConfig.resolveEnvironment(
          environmentValue: 'dev',
          providedApiBaseUrl: 'http://10.0.2.2:8000',
          providedSupabaseUrl: 'https://test.supabase.co',
          providedSupabaseAnonKey: 'header.$serviceRolePayload.signature',
        ),
        throwsStateError,
      );
    });
  });
}
