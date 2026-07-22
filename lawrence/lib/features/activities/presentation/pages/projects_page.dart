import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../design_system/tokens/lawrence_theme.dart';
import '../../../../design_system/widgets/status_badge.dart';
import '../../../../design_system/widgets/state_widgets.dart';
import '../../../../design_system/widgets/student_page_scaffold.dart';
import '../../domain/entities/activity.dart';
import '../controllers/activities_controller.dart';
import '../widgets/activity_status_presentation.dart';

List<Activity> selectProjectActivities(Iterable<Activity> activities) {
  return activities
      .where((activity) => activity.type == ActivityType.project)
      .toList(growable: false);
}

class ProjectsPage extends ConsumerWidget {
  const ProjectsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projects = ref
        .watch(activitiesNotifierProvider)
        .whenData(selectProjectActivities);

    return projects.when(
      loading: () => const StudentPageScaffold(
        title: 'Projetos',
        subtitle: 'Pratique as habilidades aprendidas nos seus cursos.',
        body: SizedBox(
          height: 360,
          child: AppLoadingState(message: 'Carregando projetos'),
        ),
      ),
      error: (_, _) => StudentPageScaffold(
        title: 'Projetos',
        subtitle: 'Pratique as habilidades aprendidas nos seus cursos.',
        body: SizedBox(
          height: 420,
          child: AppErrorState(
            title: 'Não foi possível carregar seus projetos',
            message: 'Verifique sua conexão e tente novamente.',
            onRetry: () => ref
                .read(activitiesNotifierProvider.notifier)
                .loadActivities(),
          ),
        ),
      ),
      data: (items) => StudentPageScaffold(
        title: 'Projetos',
        subtitle: items.isEmpty
            ? 'Pratique as habilidades aprendidas nos seus cursos.'
            : '${items.length} ${items.length == 1 ? 'projeto vinculado' : 'projetos vinculados'} aos seus cursos.',
        onRefresh: () => ref
            .read(activitiesNotifierProvider.notifier)
            .loadActivities(),
        body: items.isEmpty
            ? const SizedBox(
                height: 420,
                child: AppEmptyState(
                  title: 'Nenhum projeto liberado ainda',
                  description:
                      'Os projetos práticos aparecerão aqui quando forem liberados nos seus cursos.',
                  icon: Icons.architecture_outlined,
                ),
              )
            : LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;
                  final columns = width >= 1040 ? 3 : (width >= 620 ? 2 : 1);
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      mainAxisSpacing: LawrenceSpacing.md,
                      crossAxisSpacing: LawrenceSpacing.md,
                      mainAxisExtent: 220,
                    ),
                    itemCount: items.length,
                    itemBuilder: (context, index) =>
                        _ProjectCard(project: items[index]),
                  );
                },
              ),
      ),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  final Activity project;

  const _ProjectCard({required this.project});

  @override
  Widget build(BuildContext context) {
    final status = activityStatusPresentation(project.status);
    final deadline = project.deadline == null
        ? 'Sem prazo definido'
        : 'Prazo: ${DateFormat('dd/MM/yyyy').format(project.deadline!)}';

    return Semantics(
      container: true,
      label:
          '${project.title}. Curso ${project.courseName}. ${status.label}. $deadline.',
      button: true,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => context.go('/dashboard/projects/${project.id}'),
          child: Padding(
            padding: const EdgeInsets.all(LawrenceSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: AppStatusBadge(
                    label: status.label,
                    icon: status.icon,
                    tone: status.tone,
                  ),
                ),
                const SizedBox(height: LawrenceSpacing.md),
                Text(
                  project.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: LawrenceColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: LawrenceSpacing.xs),
                Text(
                  project.courseName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: LawrenceColors.textSecondary,
                  ),
                ),
                const Spacer(),
                const Divider(),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 18,
                      color: LawrenceColors.textSecondary,
                    ),
                    const SizedBox(width: LawrenceSpacing.xs),
                    Expanded(
                      child: Text(
                        deadline,
                        style: const TextStyle(
                          color: LawrenceColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
