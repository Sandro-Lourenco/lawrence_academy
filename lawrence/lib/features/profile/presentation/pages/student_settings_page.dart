import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../design_system/tokens/lawrence_theme.dart';
import '../../../../design_system/widgets/student_page_scaffold.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';

class StudentSettingsPage extends ConsumerWidget {
  const StudentSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authNotifierProvider);
    return StudentPageScaffold(
      title: 'Configurações',
      subtitle: 'Gerencie opções disponíveis da sua conta.',
      leading: IconButton(
        tooltip: 'Voltar ao perfil',
        onPressed: () => context.go('/dashboard/profile'),
        icon: const Icon(Icons.arrow_back_rounded),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth >= 760
              ? 720.0
              : constraints.maxWidth;
          return Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: width,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _SettingsSection(
                    title: 'Aprendizagem',
                    children: [
                      _SettingsLink(
                        icon: Icons.download_outlined,
                        title: 'Downloads offline',
                        subtitle: 'Consulte conteúdos disponíveis no dispositivo',
                        onTap: () => context.go('/dashboard/downloads'),
                      ),
                    ],
                  ),
                  const SizedBox(height: LawrenceSpacing.lg),
                  _SettingsSection(
                    title: 'Conta e pagamentos',
                    children: [
                      _SettingsLink(
                        icon: Icons.credit_card_outlined,
                        title: 'Assinaturas',
                        subtitle: 'Gerencie as assinaturas de cada curso',
                        onTap: () => context.go('/dashboard/subscriptions'),
                      ),
                      _SettingsLink(
                        icon: Icons.receipt_long_outlined,
                        title: 'Faturas',
                        subtitle: 'Consulte cobranças e pagamentos',
                        onTap: () => context.go('/dashboard/invoices'),
                      ),
                    ],
                  ),
                  const SizedBox(height: LawrenceSpacing.lg),
                  _SettingsSection(
                    title: 'Sessão',
                    children: [
                      _SettingsLink(
                        icon: Icons.logout_rounded,
                        title: auth.isLoading ? 'Encerrando sessão…' : 'Sair da conta',
                        subtitle: 'Encerre esta sessão com segurança',
                        danger: true,
                        enabled: !auth.isLoading,
                        onTap: () => _confirmSignOut(context, ref),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _confirmSignOut(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Sair da conta?'),
        content: const Text(
          'Você precisará entrar novamente para acessar seus cursos.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Sair'),
          ),
        ],
      ),
    );
    if (!context.mounted) return;
    if (confirmed == true) {
      await ref.read(authNotifierProvider.notifier).signOut();
    }
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: LawrenceSpacing.sm),
        Card(child: Column(children: children)),
      ],
    );
  }
}

class _SettingsLink extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool danger;
  final bool enabled;

  const _SettingsLink({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.danger = false,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final color = danger ? LawrenceColors.danger : LawrenceColors.actionPrimary;
    return ListTile(
      enabled: enabled,
      minTileHeight: 72,
      leading: Icon(icon, color: color),
      title: Text(title, style: danger ? TextStyle(color: color) : null),
      subtitle: Text(subtitle),
      trailing: danger ? null : const Icon(Icons.chevron_right_rounded),
      onTap: enabled ? onTap : null,
    );
  }
}
