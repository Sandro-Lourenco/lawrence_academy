import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../design_system/tokens/lawrence_theme.dart';
import '../../../../design_system/widgets/state_widgets.dart';
import '../../../../design_system/widgets/status_badge.dart';
import '../../../../design_system/widgets/student_page_scaffold.dart';
import '../../domain/entities/activity.dart';
import '../controllers/activities_controller.dart';
import '../controllers/project_detail_controller.dart';
import '../widgets/activity_status_presentation.dart';

class ProjectDetailPage extends ConsumerWidget {
  final String projectId;

  const ProjectDetailPage({super.key, required this.projectId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final project = ref.watch(projectDetailProvider(projectId));
    return project.when(
      loading: () => StudentPageScaffold(
        title: 'Detalhes do projeto',
        leading: _BackButton(onPressed: () => context.go('/dashboard/projects')),
        body: const SizedBox(
          height: 420,
          child: AppLoadingState(message: 'Carregando projeto'),
        ),
      ),
      error: (_, _) => StudentPageScaffold(
        title: 'Detalhes do projeto',
        leading: _BackButton(onPressed: () => context.go('/dashboard/projects')),
        body: SizedBox(
          height: 420,
          child: AppErrorState(
            title: 'Não foi possível carregar este projeto',
            message: 'Verifique sua conexão e tente novamente.',
            onRetry: () => ref
                .read(activitiesNotifierProvider.notifier)
                .loadActivities(),
          ),
        ),
      ),
      data: (item) => item == null
          ? StudentPageScaffold(
              title: 'Projeto indisponível',
              leading: _BackButton(
                onPressed: () => context.go('/dashboard/projects'),
              ),
              body: SizedBox(
                height: 420,
                child: AppEmptyState(
                  title: 'Projeto não encontrado',
                  description:
                      'Este projeto não está disponível para a sua conta ou deixou de existir.',
                  icon: Icons.lock_outline_rounded,
                  actionLabel: 'Voltar aos projetos',
                  onActionPressed: () => context.go('/dashboard/projects'),
                ),
              ),
            )
          : _ProjectDetailContent(project: item),
    );
  }
}

class _ProjectDetailContent extends StatelessWidget {
  final Activity project;

  const _ProjectDetailContent({required this.project});

  @override
  Widget build(BuildContext context) {
    final status = activityStatusPresentation(project.status);
    return StudentPageScaffold(
      title: project.title,
      subtitle: project.courseName,
      leading: _BackButton(onPressed: () => context.go('/dashboard/projects')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 900;
          final overview = _ProjectOverview(project: project, status: status);
          const side = _ProjectContext();
          if (!wide) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                overview,
                const SizedBox(height: LawrenceSpacing.md),
                side,
              ],
            );
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 2, child: overview),
              const SizedBox(width: LawrenceSpacing.lg),
              Expanded(child: side),
            ],
          );
        },
      ),
    );
  }
}

class _ProjectOverview extends StatelessWidget {
  final Activity project;
  final ActivityStatusPresentation status;

  const _ProjectOverview({required this.project, required this.status});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(LawrenceSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppStatusBadge(
              label: status.label,
              icon: status.icon,
              tone: status.tone,
            ),
            const SizedBox(height: LawrenceSpacing.lg),
            Text(
              'Visão geral',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: LawrenceSpacing.md),
            _DetailRow(
              icon: Icons.school_outlined,
              label: 'Curso',
              value: project.courseName,
            ),
            const Divider(height: LawrenceSpacing.xl),
            _DetailRow(
              icon: Icons.person_outline_rounded,
              label: 'Responsável',
              value: project.teacherName,
            ),
            const Divider(height: LawrenceSpacing.xl),
            _DetailRow(
              icon: Icons.calendar_today_outlined,
              label: 'Prazo',
              value: project.deadline == null
                  ? 'Sem prazo definido'
                  : DateFormat('dd/MM/yyyy').format(project.deadline!),
            ),
            if (project.grade != null) ...[
              const Divider(height: LawrenceSpacing.xl),
              _DetailRow(
                icon: Icons.workspace_premium_outlined,
                label: 'Nota',
                value: NumberFormat('0.##', 'pt_BR').format(project.grade),
              ),
            ],
            if (project.feedback?.trim().isNotEmpty ?? false) ...[
              const SizedBox(height: LawrenceSpacing.xl),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(LawrenceSpacing.md),
                decoration: BoxDecoration(
                  color: LawrenceColors.successSurface,
                  borderRadius: BorderRadius.circular(LawrenceRadii.control),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Feedback recebido',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: LawrenceColors.success,
                      ),
                    ),
                    const SizedBox(height: LawrenceSpacing.xs),
                    Text(project.feedback!),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ProjectContext extends StatelessWidget {
  const _ProjectContext();

  @override
  Widget build(BuildContext context) {
    return Card(
      color: LawrenceColors.practiceSurface,
      child: Padding(
        padding: const EdgeInsets.all(LawrenceSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.architecture_outlined,
              color: LawrenceColors.practice,
              size: 32,
            ),
            const SizedBox(height: LawrenceSpacing.md),
            Text(
              'Projeto vinculado ao curso',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: LawrenceSpacing.xs),
            Text(
              'As orientações, entregas e permissões aparecem aqui somente quando forem disponibilizadas pelo curso.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: LawrenceSpacing.lg),
            OutlinedButton.icon(
              onPressed: () => context.go('/dashboard/activities'),
              icon: const Icon(Icons.assignment_outlined),
              label: const Text('Ver atividades'),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: LawrenceColors.textSecondary),
        const SizedBox(width: LawrenceSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: LawrenceSpacing.xxs),
              Text(value, style: Theme.of(context).textTheme.titleLarge),
            ],
          ),
        ),
      ],
    );
  }
}

class _BackButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _BackButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Voltar aos projetos',
      onPressed: onPressed,
      icon: const Icon(Icons.arrow_back_rounded),
    );
  }
}
