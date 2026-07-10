import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lawrence/core/theme.dart';
import 'package:lawrence/core/auth_provider.dart';
import 'package:lawrence/presentation/form_controller.dart';
import 'package:lawrence/shared/widgets/liquid_glass_card.dart';
import 'package:lawrence/shared/widgets/pill_button.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoginMode = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleFormSubmit() {
    if (_formKey.currentState!.validate()) {
      final formNotifier = ref.read(loginFormControllerProvider.notifier);
      final authNotifier = ref.read(authNotifierProvider.notifier);

      formNotifier.submit(() async {
        if (_isLoginMode) {
          await authNotifier.signInWithEmail(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );
        } else {
          await authNotifier.signUpWithEmail(
            email: _emailController.text.trim(),
            password: _passwordController.text,
            fullName: _nameController.text.trim(),
          );
          setState(() {
            _isLoginMode = true;
          });
        }

        final authState = ref.read(authNotifierProvider);
        if (authState.errorMessage != null) {
          throw Exception(authState.errorMessage);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formState = ref.watch(loginFormControllerProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [LawrenceTheme.canvasParchment, Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Card Glassmorphic Liquid Glass
                  LiquidGlassCard(
                    width: 440,
                    borderRadius: LawrenceTheme.radiusLg, // 24px
                    borderColor: LawrenceTheme.borderMist,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Logo minimalista
                        Center(
                          child: Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: LawrenceTheme.primary,
                              borderRadius: BorderRadius.circular(
                                LawrenceTheme.radiusMd,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: LawrenceTheme.primary.withOpacity(
                                    0.24,
                                  ),
                                  blurRadius: 16,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.auto_awesome,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        Text(
                          "LAWRENCE ACADEMY",
                          style: theme.textTheme.headlineMedium?.copyWith(
                            letterSpacing: 2.0,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: LawrenceTheme.surfaceTile1,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),

                        Text(
                          _isLoginMode
                              ? "Plataforma de Alta Costura & Modelagem"
                              : "Crie sua conta de aluno (Atrito Zero)",
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: LawrenceTheme.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),

                        // Campo Nome Completo (Apenas no modo Cadastro)
                        if (!_isLoginMode) ...[
                          _buildTextField(
                            controller: _nameController,
                            hintText: "Nome Completo",
                            icon: Icons.person_outline,
                            validator: FormValidators.validateFullName,
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Campo E-mail
                        _buildTextField(
                          controller: _emailController,
                          hintText: "E-mail",
                          icon: Icons.email_outlined,
                          validator: FormValidators.validateEmail,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 16),

                        // Campo Senha
                        _buildTextField(
                          controller: _passwordController,
                          hintText: "Senha",
                          icon: Icons.lock_outline,
                          validator: FormValidators.validatePassword,
                          obscureText: true,
                        ),
                        const SizedBox(height: 28),

                        // Botão pílula resiliente (PillButton)
                        PillButton(
                          label: _isLoginMode
                              ? "Entrar na Plataforma"
                              : "Cadastrar Nova Conta",
                          isLoading: formState.isLoading,
                          onPressed: _handleFormSubmit,
                          width: double.infinity,
                          height: 52,
                        ),

                        const SizedBox(height: 20),

                        // Alternador entre Login e Cadastro
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _isLoginMode = !_isLoginMode;
                              _formKey.currentState?.reset();
                              _emailController.clear();
                              _passwordController.clear();
                              _nameController.clear();
                            });
                          },
                          child: Text(
                            _isLoginMode
                                ? "Não tem conta? Cadastre-se agora"
                                : "Já tem uma conta? Faça login",
                            style: const TextStyle(
                              color: LawrenceTheme.primary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),

                        if (formState.errorMessage != null) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: LawrenceTheme.danger.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(
                                LawrenceTheme.radiusXs,
                              ),
                            ),
                            child: Text(
                              formState.errorMessage!,
                              style: const TextStyle(
                                color: LawrenceTheme.danger,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    required String? Function(String?) validator,
    bool obscureText = false,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 15, color: LawrenceTheme.surfaceTile1),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(
          color: LawrenceTheme.textSecondary,
          fontSize: 15,
        ),
        prefixIcon: Icon(icon, size: 20, color: LawrenceTheme.textSecondary),
        filled: true,
        fillColor: Colors.white.withOpacity(0.4),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(LawrenceTheme.radiusMd),
          borderSide: const BorderSide(
            color: LawrenceTheme.borderMist,
            width: 1.5,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(LawrenceTheme.radiusMd),
          borderSide: const BorderSide(
            color: LawrenceTheme.borderMist,
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(LawrenceTheme.radiusMd),
          borderSide: const BorderSide(
            color: LawrenceTheme.primaryFocus,
            width: 2.0,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(LawrenceTheme.radiusMd),
          borderSide: const BorderSide(color: LawrenceTheme.danger, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(LawrenceTheme.radiusMd),
          borderSide: const BorderSide(color: LawrenceTheme.danger, width: 2.0),
        ),
      ),
    );
  }
}
