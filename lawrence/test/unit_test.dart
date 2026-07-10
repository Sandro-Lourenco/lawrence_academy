import 'package:flutter_test/flutter_test.dart';
import 'package:lawrence/presentation/form_controller.dart';

void main() {
  group("FormValidators Unit Tests", () {
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

  group("FormSubmitNotifier Unit Tests", () {
    test("submit - success flow transition", () async {
      final notifier = FormSubmitNotifier();
      expect(notifier.state.isLoading, false);
      expect(notifier.state.isSuccess, false);

      final future = notifier.submit(() async {
        await Future.delayed(const Duration(milliseconds: 10));
      });

      // Durante a execução, o estado deve ser loading
      expect(notifier.state.isLoading, true);

      await future;

      // Ao finalizar, o estado deve ser sucesso
      expect(notifier.state.isLoading, false);
      expect(notifier.state.isSuccess, true);
    });

    test("submit - error flow transition", () async {
      final notifier = FormSubmitNotifier();

      await notifier.submit(() async {
        throw Exception("Conexão falhou no servidor.");
      });

      expect(notifier.state.isLoading, false);
      expect(notifier.state.isSuccess, false);
      expect(notifier.state.errorMessage, "Conexão falhou no servidor.");
    });
  });
}
