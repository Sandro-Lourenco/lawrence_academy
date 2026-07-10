import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Estado genérico para formulários resilientes
class FormSubmitState {
  final bool isLoading;
  final String? errorMessage;
  final bool isSuccess;

  const FormSubmitState({
    this.isLoading = false,
    this.errorMessage,
    this.isSuccess = false,
  });

  FormSubmitState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool? isSuccess,
  }) {
    return FormSubmitState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

// Notificador genérico de submissão de formulários (com Anti-Debounce mecânico)
class FormSubmitNotifier extends StateNotifier<FormSubmitState> {
  FormSubmitNotifier() : super(const FormSubmitState());

  /// Executa uma ação de envio de forma segura, bloqueando cliques múltiplos
  Future<void> submit(Future<void> Function() action) async {
    if (state.isLoading)
      return; // Anti-Debounce mecânico: impede chamadas paralelas

    state = const FormSubmitState(isLoading: true);

    try {
      await action();
      state = const FormSubmitState(isSuccess: true);
    } catch (e) {
      state = FormSubmitState(
        isLoading: false,
        errorMessage: e.toString().replaceAll("Exception: ", ""),
      );
    }
  }

  void reset() {
    state = const FormSubmitState();
  }
}

// Provedores auto-dispose individuais para login e cadastro
final loginFormControllerProvider =
    StateNotifierProvider.autoDispose<FormSubmitNotifier, FormSubmitState>((
      ref,
    ) {
      return FormSubmitNotifier();
    });

final registerFormControllerProvider =
    StateNotifierProvider.autoDispose<FormSubmitNotifier, FormSubmitState>((
      ref,
    ) {
      return FormSubmitNotifier();
    });

// ==========================================
// Validadores Locais Reutilizáveis (Regras de Negócio e UX)
// ==========================================
class FormValidators {
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "O e-mail é obrigatório.";
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,20}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return "Insira um endereço de e-mail válido.";
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return "A senha é obrigatória.";
    }
    if (value.length < 8) {
      return "A senha deve conter no mínimo 8 caracteres.";
    }
    return null;
  }

  static String? validateFullName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "O nome completo é obrigatório.";
    }
    if (value.trim().split(' ').length < 2) {
      return "Insira seu nome e sobrenome.";
    }
    return null;
  }
}
