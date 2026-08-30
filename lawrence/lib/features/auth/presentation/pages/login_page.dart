import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/auth_navigation.dart';
import '../../../../design_system/tokens/lawrence_theme.dart';
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

class _LoginPageState extends ConsumerState<LoginPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  late final AnimationController _entranceController;
  late bool _isLoginMode;
  late bool _isForgotPasswordMode;
  bool _obscurePassword = true;
  bool _isGoogleLoading = false;

  @override
  void initState() {
    super.initState();
    _isForgotPasswordMode = widget.startInPasswordRecoveryMode;
    _isLoginMode =
        !widget.startInRegistrationMode && !widget.startInPasswordRecoveryMode;
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    )..forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _entranceController.value = 1;
    }
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _emailController.clear();
    _passwordController.clear();
    _nameController.clear();
  }

  void _handleFormSubmit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
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
              content: Text('Instruções de recuperação enviadas por e-mail.'),
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
        final registrationState = ref.read(authNotifierProvider);
        if (registrationState.errorMessage == null && mounted) {
          if (registrationState.registrationRequiresEmailConfirmation) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Cadastro criado. Confirme o link enviado ao seu e-mail antes de entrar.',
                ),
                backgroundColor: LawrenceColors.primary,
              ),
            );
          }
          setState(() => _isLoginMode = true);
        }
      }

      final authState = ref.read(authNotifierProvider);
      if (authState.errorMessage != null) {
        throw Exception(authState.errorMessage);
      }
      if (!_isForgotPasswordMode && authState.user != null && mounted) {
        final role = authState.user?.appMetadata['role'] as String?;
        final currentUri = GoRouterState.of(context).uri;
        context.go(postAuthDestinationForRole(role, currentUri));
      }
    });
  }

  Future<void> _handleGoogleSignIn() async {
    if (_isGoogleLoading) return;
    setState(() => _isGoogleLoading = true);
    await ref.read(authNotifierProvider.notifier).signInWithGoogle();
    if (mounted) setState(() => _isGoogleLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final desktop =
        MediaQuery.sizeOf(context).width >= LawrenceBreakpoints.desktop;
    final formState = ref.watch(loginFormControllerProvider);

    return Scaffold(
      backgroundColor: LawrenceColors.canvas,
      body: Stack(
        children: [
          if (desktop)
            Row(
              children: [
                Expanded(flex: 11, child: _storyPanel()),
                Expanded(flex: 9, child: _formViewport(formState)),
              ],
            )
          else
            _compactLayout(formState),
          Positioned(
            top: MediaQuery.paddingOf(context).top + 16,
            left: 18,
            child: _BackHomeButton(onPressed: () => context.go('/')),
          ),
        ],
      ),
    );
  }

  Widget _compactLayout(FormSubmitState formState) {
    final accessibleText = MediaQuery.textScalerOf(context).scale(1) > 1.3;
    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!accessibleText)
              SizedBox(height: 330, child: _storyPanel(compact: true)),
            if (accessibleText)
              SizedBox(height: MediaQuery.paddingOf(context).top + 70),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 36, 22, 40),
              child: Center(child: _form(formState)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _storyPanel({bool compact = false}) {
    return ClipRect(
      child: AnimatedBuilder(
        animation: _entranceController,
        builder: (context, child) {
          final value = Curves.easeOutCubic.transform(
            _entranceController.value,
          );
          return Transform.scale(
            scale: 1.025 - (.025 * value),
            child: Opacity(opacity: value, child: child),
          );
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/images/login_atelier_editorial.webp',
              fit: BoxFit.cover,
              alignment: compact
                  ? const Alignment(.05, .25)
                  : const Alignment(.10, .05),
              filterQuality: FilterQuality.medium,
              semanticLabel:
                  'Criadora de moda em um ateliê clássico diante de uma mesa de modelagem e um manequim.',
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x22000000), Color(0xF01A0B10)],
                  stops: [.36, 1],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                compact ? 64 : 48,
                compact ? 34 : 42,
                compact ? 20 : 48,
                compact ? 24 : 48,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _BrandMark(light: true),
                  const Spacer(),
                  if (!compact) ...[
                    const Text(
                      'EDIÇÃO 01  ·  O OFÍCIO',
                      style: TextStyle(
                        color: LawrenceColors.goldHighlight,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2.2,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Toda grande\nassinatura começa\npelo domínio do traço.',
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        color: LawrenceColors.canvas,
                        fontSize: 54,
                        fontWeight: FontWeight.w400,
                        height: .98,
                        letterSpacing: -1.8,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      width: 92,
                      height: 2,
                      color: LawrenceColors.goldMid,
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Entre no ateliê. Retome sua técnica, sua prática e a construção de uma linguagem que seja só sua.',
                      style: TextStyle(
                        color: LawrenceColors.canvasParchment,
                        fontSize: 16,
                        height: 1.55,
                      ),
                    ),
                  ] else
                    Text(
                      'O conhecimento\ntambém se veste.',
                      style: Theme.of(context).textTheme.displayMedium
                          ?.copyWith(
                            color: LawrenceColors.canvas,
                            fontSize: 34,
                            fontWeight: FontWeight.w400,
                            height: .98,
                          ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _formViewport(FormSubmitState formState) {
    return ColoredBox(
      color: LawrenceColors.canvas,
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(56, 54, 56, 40),
            child: _form(formState),
          ),
        ),
      ),
    );
  }

  Widget _form(FormSubmitState formState) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final compact = MediaQuery.sizeOf(context).width < 480;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 470),
      child: FadeTransition(
        opacity: CurvedAnimation(
          parent: _entranceController,
          curve: const Interval(.12, 1, curve: Curves.easeOutCubic),
        ),
        child: Form(
          key: _formKey,
          child: AutofillGroup(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'ACESSO AO ATELIÊ  ·  LAWRENCE JOURNAL',
                  style: TextStyle(
                    color: LawrenceColors.brandNavy,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.7,
                  ),
                ),
                const SizedBox(height: 12),
                const Divider(
                  height: 1,
                  thickness: 2,
                  color: LawrenceColors.brandNavy,
                ),
                const SizedBox(height: 4),
                const Divider(height: 1, color: LawrenceColors.brandNavy),
                const SizedBox(height: 30),
                Semantics(
                  header: true,
                  child: Text(
                    _isForgotPasswordMode
                        ? 'Recupere seu acesso'
                        : _isLoginMode
                        ? 'Bem-vindo de volta'
                        : 'Crie sua conta',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      color: LawrenceColors.surfaceBlack,
                      fontSize: compact ? 38 : 48,
                      fontWeight: FontWeight.w400,
                      height: .98,
                      letterSpacing: -1.4,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _isForgotPasswordMode
                      ? 'Informe seu e-mail para receber as próximas instruções com segurança.'
                      : _isLoginMode
                      ? 'Abra seu caderno e continue exatamente de onde parou.'
                      : 'Seu primeiro capítulo começa com uma conta Lawrence.',
                  style: const TextStyle(
                    color: LawrenceColors.textSecondary,
                    fontSize: 16,
                    height: 1.55,
                  ),
                ),
                const SizedBox(height: 34),
                if (!_isForgotPasswordMode && !_isLoginMode) ...[
                  _textField(
                    controller: _nameController,
                    label: 'Nome completo',
                    icon: Icons.person_outline_rounded,
                    validator: FormValidators.validateFullName,
                    autofillHints: const [AutofillHints.name],
                    textCapitalization: TextCapitalization.words,
                  ),
                  const SizedBox(height: 16),
                ],
                _textField(
                  controller: _emailController,
                  label: 'E-mail',
                  icon: Icons.alternate_email_rounded,
                  validator: FormValidators.validateEmail,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [
                    AutofillHints.username,
                    AutofillHints.email,
                  ],
                  submitOnDone: _isForgotPasswordMode,
                ),
                if (!_isForgotPasswordMode) ...[
                  const SizedBox(height: 16),
                  _textField(
                    controller: _passwordController,
                    label: 'Senha',
                    icon: Icons.lock_outline_rounded,
                    validator: FormValidators.validatePassword,
                    obscureText: _obscurePassword,
                    autofillHints: [
                      _isLoginMode
                          ? AutofillHints.password
                          : AutofillHints.newPassword,
                    ],
                    submitOnDone: true,
                    suffixIcon: IconButton(
                      tooltip: _obscurePassword
                          ? 'Mostrar senha'
                          : 'Ocultar senha',
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: LawrenceColors.textSecondary,
                      ),
                    ),
                  ),
                ],
                if (_isLoginMode)
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        setState(() => _isForgotPasswordMode = true);
                        _resetForm();
                      },
                      child: const Text('Esqueci minha senha'),
                    ),
                  )
                else
                  const SizedBox(height: 20),
                if (formState.errorMessage != null) ...[
                  const SizedBox(height: 8),
                  _FormErrorMessage(message: formState.errorMessage!),
                ],
                const SizedBox(height: 14),
                FilledButton(
                  onPressed: formState.isLoading ? null : _handleFormSubmit,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(56),
                    backgroundColor: LawrenceColors.brandNavy,
                    foregroundColor: LawrenceColors.canvas,
                    shape: const RoundedRectangleBorder(),
                  ),
                  child: AnimatedSwitcher(
                    duration: reduceMotion
                        ? Duration.zero
                        : const Duration(milliseconds: 180),
                    child: formState.isLoading
                        ? const SizedBox(
                            key: ValueKey('loading'),
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                              color: LawrenceColors.canvas,
                            ),
                          )
                        : Row(
                            key: const ValueKey('label'),
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Flexible(
                                child: Text(
                                  _isForgotPasswordMode
                                      ? 'ENVIAR INSTRUÇÕES'
                                      : _isLoginMode
                                      ? 'ENTRAR NO ATELIÊ'
                                      : 'CRIAR MINHA CONTA',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Icon(Icons.arrow_forward_rounded, size: 19),
                            ],
                          ),
                  ),
                ),
                if (_isLoginMode && !_isForgotPasswordMode) ...[
                  const SizedBox(height: 22),
                  const _EditorialDivider(label: 'OU'),
                  const SizedBox(height: 22),
                  OutlinedButton(
                    onPressed: _isGoogleLoading || formState.isLoading
                        ? null
                        : _handleGoogleSignIn,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(54),
                      foregroundColor: LawrenceColors.brandNavy,
                      side: const BorderSide(color: LawrenceColors.brandNavy),
                      backgroundColor: LawrenceColors.canvas,
                      shape: const RoundedRectangleBorder(),
                    ),
                    child: _isGoogleLoading
                        ? const SizedBox(
                            width: 21,
                            height: 21,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: LawrenceColors.brandNavy,
                            ),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _GoogleMark(),
                              SizedBox(width: 12),
                              Flexible(
                                child: Text(
                                  'Entrar com Google',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontWeight: FontWeight.w700),
                                ),
                              ),
                            ],
                          ),
                  ),
                ],
                const SizedBox(height: 18),
                TextButton(
                  onPressed: () {
                    setState(() {
                      if (_isForgotPasswordMode) {
                        _isForgotPasswordMode = false;
                        _isLoginMode = true;
                      } else {
                        _isLoginMode = !_isLoginMode;
                      }
                    });
                    _resetForm();
                  },
                  child: Text(
                    _isForgotPasswordMode
                        ? 'Voltar para o login'
                        : _isLoginMode
                        ? 'Ainda não tem conta? Cadastre-se'
                        : 'Já tem uma conta? Faça login',
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Ao continuar, você concorda com os Termos de Uso e a Política de Privacidade.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: LawrenceColors.textSecondary,
                    fontSize: 12,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String? Function(String?) validator,
    bool obscureText = false,
    TextInputType? keyboardType,
    Widget? suffixIcon,
    Iterable<String>? autofillHints,
    TextCapitalization textCapitalization = TextCapitalization.none,
    bool submitOnDone = false,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      autocorrect: !obscureText && keyboardType != TextInputType.emailAddress,
      enableSuggestions:
          !obscureText && keyboardType != TextInputType.emailAddress,
      textInputAction: submitOnDone
          ? TextInputAction.done
          : TextInputAction.next,
      onFieldSubmitted: submitOnDone ? (_) => _handleFormSubmit() : null,
      autofillHints: autofillHints,
      style: const TextStyle(color: LawrenceColors.surfaceBlack, fontSize: 16),
      cursorColor: LawrenceColors.brandNavy,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: LawrenceColors.textSecondary),
        prefixIcon: ExcludeSemantics(
          child: Icon(icon, color: LawrenceColors.brandNavy, size: 20),
        ),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: const Color(0xFFFFFBF6),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),
        border: _inputBorder(LawrenceColors.borderMist),
        enabledBorder: _inputBorder(LawrenceColors.borderMist),
        focusedBorder: _inputBorder(LawrenceColors.brandNavy, width: 2),
        errorBorder: _inputBorder(LawrenceColors.danger),
        focusedErrorBorder: _inputBorder(LawrenceColors.danger, width: 2),
        errorStyle: const TextStyle(color: LawrenceColors.danger),
      ),
    );
  }

  OutlineInputBorder _inputBorder(Color color, {double width = 1}) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(color: color, width: width),
      );
}

class _BrandMark extends StatelessWidget {
  const _BrandMark({required this.light});

  final bool light;

  @override
  Widget build(BuildContext context) {
    final color = light ? LawrenceColors.canvas : LawrenceColors.brandNavy;
    return Semantics(
      label: 'Lawrence Academy',
      child: ExcludeSemantics(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'LAWRENCE',
              style: TextStyle(
                color: color,
                fontFamily: 'Georgia',
                fontSize: 22,
                letterSpacing: 2.4,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 42, height: 1, color: color),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 7),
                  child: Text(
                    'ACADEMY',
                    style: TextStyle(
                      color: color,
                      fontSize: 8,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.8,
                    ),
                  ),
                ),
                Container(width: 42, height: 1, color: color),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EditorialDivider extends StatelessWidget {
  const _EditorialDivider({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      const Expanded(child: Divider(color: LawrenceColors.borderMist)),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Text(
          label,
          style: const TextStyle(
            color: LawrenceColors.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.6,
          ),
        ),
      ),
      const Expanded(child: Divider(color: LawrenceColors.borderMist)),
    ],
  );
}

class _FormErrorMessage extends StatelessWidget {
  const _FormErrorMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) => Semantics(
    liveRegion: true,
    label: 'Erro: $message',
    child: Container(
      padding: const EdgeInsets.all(14),
      decoration: const BoxDecoration(
        color: LawrenceColors.dangerSurface,
        border: Border(
          left: BorderSide(color: LawrenceColors.danger, width: 3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: LawrenceColors.danger,
            size: 21,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: LawrenceColors.surfaceBlack,
                fontSize: 14,
                height: 1.4,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class _BackHomeButton extends StatelessWidget {
  const _BackHomeButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: 'Voltar para a página principal',
    child: Material(
      color: LawrenceColors.surfaceBlack.withValues(alpha: .80),
      shape: const CircleBorder(
        side: BorderSide(color: LawrenceColors.canvasParchment),
      ),
      child: IconButton(
        tooltip: 'Voltar para a página principal',
        onPressed: onPressed,
        icon: const Icon(
          Icons.arrow_back_rounded,
          color: LawrenceColors.canvas,
        ),
      ),
    ),
  );
}

class _GoogleMark extends StatelessWidget {
  const _GoogleMark();

  @override
  Widget build(BuildContext context) => Container(
    width: 24,
    height: 24,
    alignment: Alignment.center,
    decoration: const BoxDecoration(
      color: Colors.white,
      shape: BoxShape.circle,
      border: Border.fromBorderSide(
        BorderSide(color: LawrenceColors.borderMist),
      ),
    ),
    child: const Text(
      'G',
      style: TextStyle(
        color: Color(0xFF4285F4),
        fontSize: 15,
        fontWeight: FontWeight.w900,
      ),
    ),
  );
}
