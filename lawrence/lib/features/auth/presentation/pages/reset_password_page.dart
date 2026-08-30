import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../design_system/tokens/lawrence_theme.dart';
import '../controllers/auth_controller.dart';

class ResetPasswordPage extends ConsumerStatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  ConsumerState<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends ConsumerState<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmationController = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmationController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final updated = await ref
        .read(authNotifierProvider.notifier)
        .updatePassword(password: _passwordController.text);
    if (!mounted) return;
    if (updated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Senha atualizada com sucesso.')),
      );
      context.go('/dashboard/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authNotifierProvider);
    return Scaffold(
      backgroundColor: LawrenceColors.canvas,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Redefinir senha'),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(LawrenceSpacing.lg),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Crie uma nova senha',
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                    const SizedBox(height: LawrenceSpacing.sm),
                    const Text(
                      'Use pelo menos 8 caracteres e não reutilize uma senha antiga.',
                    ),
                    const SizedBox(height: LawrenceSpacing.xl),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscure,
                      autofillHints: const [AutofillHints.newPassword],
                      decoration: InputDecoration(
                        labelText: 'Nova senha',
                        prefixIcon: const Icon(Icons.lock_outline_rounded),
                        suffixIcon: IconButton(
                          tooltip: _obscure ? 'Mostrar senha' : 'Ocultar senha',
                          onPressed: () => setState(() => _obscure = !_obscure),
                          icon: Icon(
                            _obscure
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                      ),
                      validator: (value) => (value?.length ?? 0) < 8
                          ? 'Informe pelo menos 8 caracteres.'
                          : null,
                    ),
                    const SizedBox(height: LawrenceSpacing.md),
                    TextFormField(
                      controller: _confirmationController,
                      obscureText: _obscure,
                      autofillHints: const [AutofillHints.newPassword],
                      decoration: const InputDecoration(
                        labelText: 'Confirmar nova senha',
                        prefixIcon: Icon(Icons.lock_reset_rounded),
                      ),
                      validator: (value) => value != _passwordController.text
                          ? 'As senhas não coincidem.'
                          : null,
                    ),
                    if (auth.errorMessage != null) ...[
                      const SizedBox(height: LawrenceSpacing.md),
                      Text(
                        auth.errorMessage!,
                        style: const TextStyle(color: LawrenceColors.danger),
                      ),
                    ],
                    const SizedBox(height: LawrenceSpacing.xl),
                    FilledButton.icon(
                      onPressed: auth.isLoading ? null : _submit,
                      icon: const Icon(Icons.check_rounded),
                      label: Text(
                        auth.isLoading ? 'Atualizando...' : 'Atualizar senha',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
