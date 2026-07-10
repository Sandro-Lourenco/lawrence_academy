import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lawrence/app/config/env_config.dart';
import 'package:lawrence/app/router/app_router.dart';
import 'package:lawrence/features/auth/presentation/controllers/form_controller.dart';
import 'package:lawrence/features/auth/application/auth_notifier.dart';

void main() {
  group("Phase 5A - FormValidators Unit Tests", () {
    test("validateEmail - invalid inputs", () {
      expect(FormValidators.validateEmail(null), "O e-mail é obrigatório.");
      expect(FormValidators.validateEmail(""), "O e-mail é obrigatório.");
      expect(
        FormValidators.validateEmail("plain_text"),
        "Insira um endereço de e-mail válido.",
      );
      expect(
        FormValidators.validateEmail("email@domain"),
        "Insira um endereço de e-mail válido.",
      );
    });

    test("validateEmail - valid inputs", () {
      expect(FormValidators.validateEmail("ariane@lawrence.academy"), null);
      expect(FormValidators.validateEmail("student.active@gmail.com"), null);
    });

    test("validatePassword - length check", () {
      expect(FormValidators.validatePassword(null), "A senha é obrigatória.");
      expect(FormValidators.validatePassword(""), "A senha é obrigatória.");
      expect(
        FormValidators.validatePassword("1234567"),
        "A senha deve conter no mínimo 8 caracteres.",
      );
      expect(FormValidators.validatePassword("12345678"), null);
    });

    test("validateFullName - name components check", () {
      expect(
        FormValidators.validateFullName(null),
        "O nome completo é obrigatório.",
      );
      expect(
        FormValidators.validateFullName(""),
        "O nome completo é obrigatório.",
      );
      expect(
        FormValidators.validateFullName("Ariane"),
        "Insira seu nome e sobrenome.",
      );
      expect(FormValidators.validateFullName("Ariane Instructor"), null);
    });
  });

  group("Phase 5A - Environment Configuration Tests", () {
    test("envConfigProvider - default is dev", () {
      final container = ProviderContainer();
      final env = container.read(envConfigProvider);

      expect(env.environment, AppEnvironment.dev);
      expect(env.apiBaseUrl, 'http://localhost:8000/api/v1');
    });
  });

  group("Phase 5A - Router Configuration Tests", () {
    test("routerProvider - initialization", () {
      final container = ProviderContainer(
        overrides: [
          authNotifierProvider.overrideWith(() => FakeAuthNotifier()),
        ],
      );
      final router = container.read(routerProvider);

      expect(router.configuration.routes.length, isPositive);
    });
  });
}

class FakeAuthNotifier extends AuthNotifier {
  @override
  AuthNotifierState build() {
    return AuthNotifierState(user: null, session: null);
  }
}
