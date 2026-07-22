import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../design_system/tokens/lawrence_theme.dart';
import '../../../../design_system/widgets/state_widgets.dart';
import '../../../../design_system/widgets/status_badge.dart';
import '../../../../design_system/widgets/student_page_scaffold.dart';
import '../../domain/entities/user_profile.dart';
import '../controllers/student_profile_controller.dart';

class StudentProfilePage extends ConsumerWidget {
  const StudentProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(studentProfileProvider);
    return profile.when(
      loading: () => const StudentPageScaffold(
        title: 'Perfil',
        subtitle: 'Sua identidade na Lawrence Academy.',
        body: SizedBox(
          height: 420,
          child: AppLoadingState(message: 'Carregando perfil'),
        ),
      ),
      error: (_, _) => StudentPageScaffold(
        title: 'Perfil',
        subtitle: 'Sua identidade na Lawrence Academy.',
        body: SizedBox(
          height: 420,
          child: AppErrorState(
            title: 'Não foi possível carregar seu perfil',
            message: 'Verifique sua conexão e tente novamente.',
            onRetry: () => ref.invalidate(studentProfileProvider),
          ),
        ),
      ),
      data: (value) => StudentPageScaffold(
        title: 'Perfil',
        subtitle: 'Sua identidade na Lawrence Academy.',
        actions: [
          IconButton(
            tooltip: 'Abrir configurações',
            onPressed: () => context.push('/dashboard/settings'),
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
        onRefresh: () async {
          ref.invalidate(studentProfileProvider);
          await ref.read(studentProfileProvider.future);
        },
        body: _ProfileContent(profile: value),
      ),
    );
  }
}

class _ProfileContent extends StatelessWidget {
  final UserProfile profile;

  const _ProfileContent({required this.profile});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 900;
        final identity = _IdentityCard(profile: profile);
        const navigation = _AccountNavigationCard();
        if (!wide) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              identity,
              const SizedBox(height: LawrenceSpacing.md),
              navigation,
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 2, child: identity),
            const SizedBox(width: LawrenceSpacing.lg),
            const Expanded(child: navigation),
          ],
        );
      },
    );
  }
}

class _IdentityCard extends StatelessWidget {
  final UserProfile profile;

  const _IdentityCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    final displayName = profile.fullName?.trim().isNotEmpty ?? false
        ? profile.fullName!.trim()
        : 'Nome não informado';
    return Semantics(
      container: true,
      label:
          '$displayName. ${profile.email}. ${profileRoleLabel(profile.role)}.',
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(LawrenceSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 44,
                backgroundColor: LawrenceColors.infoSurface,
                foregroundColor: LawrenceColors.brandNavy,
                child: Text(
                  profileInitials(profile.fullName, profile.email),
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
              ),
              const SizedBox(height: LawrenceSpacing.lg),
              Text(displayName, style: Theme.of(context).textTheme.headlineLarge),
              const SizedBox(height: LawrenceSpacing.xs),
              Text(profile.email, style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: LawrenceSpacing.md),
              AppStatusBadge(
                label: profileRoleLabel(profile.role),
                icon: Icons.verified_user_outlined,
                tone: AppStatusTone.info,
              ),
              const SizedBox(height: LawrenceSpacing.xl),
              const Divider(),
              const SizedBox(height: LawrenceSpacing.md),
              Text(
                'Seus dados são carregados pelo perfil protegido da conta.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AccountNavigationCard extends StatelessWidget {
  const _AccountNavigationCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          _ProfileLink(
            icon: Icons.settings_outlined,
            title: 'Configurações',
            subtitle: 'Conta, segurança e preferências disponíveis',
            onTap: () => context.push('/dashboard/settings'),
          ),
          const Divider(height: 1),
          _ProfileLink(
            icon: Icons.credit_card_outlined,
            title: 'Assinaturas',
            subtitle: 'Gerencie o acesso aos seus cursos',
            onTap: () => context.go('/dashboard/subscriptions'),
          ),
          const Divider(height: 1),
          _ProfileLink(
            icon: Icons.receipt_long_outlined,
            title: 'Faturas',
            subtitle: 'Consulte seu histórico financeiro',
            onTap: () => context.go('/dashboard/invoices'),
          ),
        ],
      ),
    );
  }
}

class _ProfileLink extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ProfileLink({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      minTileHeight: 72,
      leading: Icon(icon, color: LawrenceColors.actionPrimary),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    );
  }
}
