import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../design_system/tokens/lawrence_theme.dart';
import '../../../../design_system/widgets/state_widgets.dart';
import '../../../../design_system/widgets/status_badge.dart';
import '../../../../design_system/widgets/student_page_scaffold.dart';
import '../../domain/entities/user_profile.dart';
import '../controllers/student_profile_controller.dart';
import '../widgets/student_avatar.dart';

class StudentProfilePage extends ConsumerWidget {
  const StudentProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(studentProfileProvider);
    return StudentPageScaffold(
      title: 'Perfil',
      subtitle: 'Sua identidade e preferências na Lawrence Academy.',
      onRefresh: () async {
        ref.invalidate(studentProfileProvider);
        await ref.read(studentProfileProvider.future);
      },
      body: profile.when(
        loading: () => const _ProfileLoading(),
        error: (_, _) => SizedBox(
          height: 380,
          child: AppErrorState(
            title: 'Não foi possível carregar seu perfil',
            message: 'Verifique sua conexão e tente novamente.',
            onRetry: () => ref.invalidate(studentProfileProvider),
          ),
        ),
        data: (value) => _ProfileOverview(profile: value),
      ),
    );
  }
}

class _ProfileOverview extends StatelessWidget {
  const _ProfileOverview({required this.profile});
  final UserProfile profile;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final main = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _IdentityPanel(profile: profile),
          const SizedBox(height: LawrenceSpacing.lg),
          _AboutPanel(profile: profile),
          if (profile.academicFormations.isNotEmpty) ...[
            const SizedBox(height: LawrenceSpacing.lg),
            _FormationPanel(formations: profile.academicFormations),
          ],
        ],
      );
      if (constraints.maxWidth < 920) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            main,
            const SizedBox(height: LawrenceSpacing.lg),
            const _AccountPanel(),
          ],
        );
      }
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 7, child: main),
          const SizedBox(width: LawrenceSpacing.xl),
          const Expanded(flex: 4, child: _AccountPanel()),
        ],
      );
    },
  );
}

class _IdentityPanel extends StatelessWidget {
  const _IdentityPanel({required this.profile});
  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final name = _value(profile.fullName, 'Nome não informado');
    final professionalLine =
        [profile.occupation, profile.jobTitle, profile.company]
            .whereType<String>()
            .map((value) => value.trim())
            .where((value) => value.isNotEmpty)
            .join(' · ');
    return Container(
      padding: const EdgeInsets.all(LawrenceSpacing.xl),
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final identity = Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  const StudentAvatar(radius: 46),
                  Positioned(
                    right: -4,
                    bottom: -4,
                    child: IconButton.filled(
                      tooltip: 'Editar foto e perfil',
                      onPressed: () => context.push('/dashboard/profile/edit'),
                      icon: const Icon(Icons.edit_outlined, size: 18),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: LawrenceSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Semantics(
                      header: true,
                      child: Text(
                        name,
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),
                    ),
                    const SizedBox(height: LawrenceSpacing.xs),
                    Text(
                      profile.email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    if (professionalLine.isNotEmpty) ...[
                      const SizedBox(height: LawrenceSpacing.xs),
                      Text(
                        professionalLine,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: LawrenceSpacing.sm),
                    AppStatusBadge(
                      label: profileRoleLabel(profile.role),
                      icon: Icons.verified_user_outlined,
                      tone: AppStatusTone.info,
                    ),
                  ],
                ),
              ),
            ],
          );
          final edit = FilledButton.icon(
            onPressed: () => context.push('/dashboard/profile/edit'),
            icon: const Icon(Icons.edit_outlined),
            label: const Text('Editar perfil'),
          );
          return constraints.maxWidth < 620
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    identity,
                    const SizedBox(height: LawrenceSpacing.lg),
                    edit,
                  ],
                )
              : Row(
                  children: [
                    Expanded(child: identity),
                    const SizedBox(width: LawrenceSpacing.lg),
                    edit,
                  ],
                );
        },
      ),
    );
  }
}

class _AboutPanel extends StatelessWidget {
  const _AboutPanel({required this.profile});
  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    final biography = profile.biography?.trim();
    final empty = biography == null || biography.isEmpty;
    return _SectionPanel(
      title: 'Sobre você',
      actionLabel: empty ? 'Adicionar' : 'Atualizar',
      onAction: () => context.push('/dashboard/profile/edit'),
      child: Text(
        empty
            ? 'Conte um pouco sobre sua trajetória, interesses e objetivos de aprendizado.'
            : biography,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: empty ? Theme.of(context).colorScheme.onSurfaceVariant : null,
          height: 1.55,
        ),
      ),
    );
  }
}

class _FormationPanel extends StatelessWidget {
  const _FormationPanel({required this.formations});
  final List<AcademicFormation> formations;

  @override
  Widget build(BuildContext context) => _SectionPanel(
    title: 'Formação',
    actionLabel: 'Editar',
    onAction: () => context.push('/dashboard/profile/edit'),
    child: Column(
      children: [
        for (var index = 0; index < formations.length; index++) ...[
          if (index > 0) const Divider(height: LawrenceSpacing.xl),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.school_outlined),
            title: Text(formations[index].course),
            subtitle: Text(
              '${formations[index].institution} · ${formations[index].type}',
            ),
          ),
        ],
      ],
    ),
  );
}

class _AccountPanel extends StatelessWidget {
  const _AccountPanel();

  @override
  Widget build(BuildContext context) => _SectionPanel(
    title: 'Conta',
    child: Column(
      children: [
        _AccountLink(
          icon: Icons.settings_outlined,
          title: 'Configurações',
          subtitle: 'Conta, segurança e preferências',
          onTap: () => context.push('/dashboard/settings'),
        ),
        const Divider(height: 1),
        _AccountLink(
          icon: Icons.credit_card_outlined,
          title: 'Assinaturas',
          subtitle: 'Acesso aos seus cursos',
          onTap: () => context.go('/dashboard/subscriptions'),
        ),
        const Divider(height: 1),
        _AccountLink(
          icon: Icons.receipt_long_outlined,
          title: 'Faturas',
          subtitle: 'Histórico financeiro',
          onTap: () => context.go('/dashboard/invoices'),
        ),
        const Divider(height: 1),
        _AccountLink(
          icon: Icons.workspace_premium_outlined,
          title: 'Certificados',
          subtitle: 'Documentos conquistados',
          onTap: () => context.go('/dashboard/certificates'),
        ),
      ],
    ),
  );
}

class _SectionPanel extends StatelessWidget {
  const _SectionPanel({
    required this.title,
    required this.child,
    this.actionLabel,
    this.onAction,
  });
  final String title;
  final Widget child;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border.all(color: scheme.outlineVariant),
      ),
      padding: const EdgeInsets.all(LawrenceSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Semantics(
                  header: true,
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ),
              if (actionLabel != null)
                TextButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ),
          const SizedBox(height: LawrenceSpacing.md),
          child,
        ],
      ),
    );
  }
}

class _AccountLink extends StatelessWidget {
  const _AccountLink({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: const EdgeInsets.symmetric(vertical: LawrenceSpacing.xs),
    minVerticalPadding: LawrenceSpacing.sm,
    leading: Icon(icon),
    title: Text(title),
    subtitle: Text(subtitle),
    trailing: const Icon(Icons.arrow_forward_rounded, size: 18),
    onTap: onTap,
  );
}

class _ProfileLoading extends StatelessWidget {
  const _ProfileLoading();

  @override
  Widget build(BuildContext context) => const Column(
    children: [
      AppSkeletonState(width: double.infinity, height: 190, borderRadius: 0),
      SizedBox(height: LawrenceSpacing.lg),
      AppSkeletonState(width: double.infinity, height: 220, borderRadius: 0),
    ],
  );
}

String _value(String? value, String fallback) {
  final normalized = value?.trim();
  return normalized == null || normalized.isEmpty ? fallback : normalized;
}
