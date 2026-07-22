import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../design_system/tokens/lawrence_theme.dart';
import '../../../../design_system/widgets/liquid_glass_card.dart';
import '../../../../design_system/widgets/pill_button.dart';
import '../controllers/auth_controller.dart';
import '../controllers/form_controller.dart';

class LoginPage extends ConsumerStatefulWidget {
  final bool startInRegistrationMode;
  final bool startInPasswordRecoveryMode;

  const LoginPage({
    super.key,
    this.startInRegistrationMode = false,
    this.startInPasswordRecoveryMode = false,
  });

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  late bool _isLoginMode;
  bool _obscurePassword = true;
  late bool _isForgotPasswordMode;

  @override
  void initState() {
    super.initState();
    _isForgotPasswordMode = widget.startInPasswordRecoveryMode;
    _isLoginMode = !widget.startInRegistrationMode &&
        !widget.startInPasswordRecoveryMode;
  }

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
        if (_isForgotPasswordMode) {
          await authNotifier.requestPasswordReset(
            email: _emailController.text.trim(),
          );
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Instruções de recuperação de senha enviadas por e-mail.',
                ),
                backgroundColor: LawrenceColors.primary,
              ),
            );
            setState(() {
              _isForgotPasswordMode = false;
              _isLoginMode = true;
            });
          }
        } else if (_isLoginMode) {
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
            colors: [LawrenceColors.canvasParchment, Colors.white],
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
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 440),
                    child: LiquidGlassCard(
                    width: double.infinity,
                    borderRadius: LawrenceTheme.radiusLg, // 24px
                    borderColor: LawrenceColors.borderMist,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Logo minimalista
                        Center(
                          child: Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: LawrenceColors.primary,
                              borderRadius: BorderRadius.circular(
                                LawrenceTheme.radiusMd,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: LawrenceColors.primary.withValues(
                                    alpha: 0.24,
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
                          _isForgotPasswordMode
                              ? "RECUPERAR SENHA"
                              : "LAWRENCE ACADEMY",
                          style: theme.textTheme.headlineMedium?.copyWith(
                            letterSpacing: 2.0,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: LawrenceColors.textPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),

                        Text(
                          _isForgotPasswordMode
                              ? "Informe seu e-mail para receber as instruções de recuperação."
                              : _isLoginMode
                                  ? "Plataforma de Alta Costura & Modelagem"
                                  : "Crie sua conta de aluno (Atrito Zero)",
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: LawrenceColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),

                        // Campo Nome Completo (Apenas no modo Cadastro)
                        if (!_isForgotPasswordMode && !_isLoginMode) ...[
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
                        if (!_isForgotPasswordMode) ...[
                          _buildTextField(
                            controller: _passwordController,
                            hintText: "Senha",
                            icon: Icons.lock_outline,
                            validator: FormValidators.validatePassword,
                            obscureText: _obscurePassword,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                color: LawrenceColors.textSecondary,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                          if (_isLoginMode) ...[
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {
                                  setState(() {
                                    _isForgotPasswordMode = true;
                                    _formKey.currentState?.reset();
                                    _emailController.clear();
                                    _passwordController.clear();
                                    _nameController.clear();
                                  });
                                },
                                child: const Text(
                                  "Esqueci minha senha",
                                  style: TextStyle(
                                    color: LawrenceColors.primary,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 28),
                        ],

                        // Botão pílula resiliente (PillButton)
                        PillButton(
                          label: _isForgotPasswordMode
                              ? "Enviar Instruções"
                              : _isLoginMode
                                  ? "Entrar na Plataforma"
                                  : "Cadastrar Nova Conta",
                          isLoading: formState.isLoading,
                          onPressed: _handleFormSubmit,
                          width: double.infinity,
                          height: 52,
                        ),

                        const SizedBox(height: 20),

                        // Alternador entre Login e Cadastro
                        if (_isForgotPasswordMode)
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _isForgotPasswordMode = false;
                                _formKey.currentState?.reset();
                                _emailController.clear();
                                _passwordController.clear();
                                _nameController.clear();
                              });
                            },
                            child: const Text(
                              "Voltar para o Login",
                              style: TextStyle(
                                color: LawrenceColors.primary,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          )
                        else
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
                                color: LawrenceColors.primary,
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
                              color: LawrenceColors.danger.withValues(
                                alpha: 0.08,
                              ),
                              borderRadius: BorderRadius.circular(
                                LawrenceTheme.radiusXs,
                              ),
                            ),
                            child: Text(
                              formState.errorMessage!,
                              style: const TextStyle(
                                color: LawrenceColors.danger,
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
    Widget? suffixIcon,
  }) {
    return TextFormField(
      autofillHints: keyboardType == TextInputType.emailAddress
          ? const [AutofillHints.email]
          : obscureText
              ? const [AutofillHints.password]
              : const [AutofillHints.name],
      textInputAction: obscureText ? TextInputAction.done : TextInputAction.next,
      onFieldSubmitted: obscureText ? (_) => _handleFormSubmit() : null,
      controller: controller,
      validator: validator,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 15, color: LawrenceColors.textPrimary),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(
          color: LawrenceColors.textSecondary,
          fontSize: 15,
        ),
        prefixIcon: ExcludeSemantics(
          child: Icon(icon, size: 20, color: LawrenceColors.textSecondary),
        ),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.4),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(LawrenceTheme.radiusMd),
          borderSide: const BorderSide(
            color: LawrenceColors.borderMist,
            width: 1.5,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(LawrenceTheme.radiusMd),
          borderSide: const BorderSide(
            color: LawrenceColors.borderMist,
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(LawrenceTheme.radiusMd),
          borderSide: const BorderSide(
            color: LawrenceColors.primaryFocus,
            width: 2.0,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(LawrenceTheme.radiusMd),
          borderSide: const BorderSide(
            color: LawrenceColors.danger,
            width: 1.5,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(LawrenceTheme.radiusMd),
          borderSide: const BorderSide(
            color: LawrenceColors.danger,
            width: 2.0,
          ),
        ),
      ),
    );
  }
}
