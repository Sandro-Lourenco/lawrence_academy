import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../design_system/tokens/lawrence_theme.dart';
import '../../../../design_system/widgets/state_widgets.dart';
import '../../domain/entities/teacher_course_student.dart';
import '../controllers/course_students_controller.dart';

class TeacherCourseStudentsPage extends ConsumerWidget {
  const TeacherCourseStudentsPage({required this.courseId, super.key});

  final String courseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final students = ref.watch(courseStudentsProvider(courseId));
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Voltar ao painel',
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/teacher'),
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text('Alunos do curso'),
      ),
      body: students.when(
        loading: () =>
            const AppLoadingState(message: 'Carregando alunos do curso'),
        error: (_, _) => AppErrorState(
          title: 'Não foi possível carregar os alunos',
          message: 'Confira sua conexão e tente novamente.',
          onRetry: () => ref.invalidate(courseStudentsProvider(courseId)),
        ),
        data: (items) => items.isEmpty
            ? const AppEmptyState(
                icon: Icons.group_outlined,
                title: 'Nenhum aluno neste curso',
                description: 'As matrículas aparecerão aqui automaticamente.',
              )
            : _StudentList(students: items),
      ),
    );
  }
}

class _StudentList extends StatelessWidget {
  const _StudentList({required this.students});
  final List<TeacherCourseStudent> students;

  @override
  Widget build(BuildContext context) => Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 1120),
      child: ListView.separated(
        padding: const EdgeInsets.all(LawrenceSpacing.lg),
        itemCount: students.length + 1,
        separatorBuilder: (_, _) => const SizedBox(height: LawrenceSpacing.sm),
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: LawrenceSpacing.md),
              child: Text(
                '${students.length} ${students.length == 1 ? 'aluno cadastrado' : 'alunos cadastrados'}',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            );
          }
          return _StudentCard(student: students[index - 1]);
        },
      ),
    ),
  );
}

class _StudentCard extends StatelessWidget {
  const _StudentCard({required this.student});
  final TeacherCourseStudent student;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      label:
          '${student.fullName}, ${student.progressPercentage.round()} por cento concluído',
      child: Container(
        padding: const EdgeInsets.all(LawrenceSpacing.md),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLowest,
          border: Border.all(color: scheme.outlineVariant),
          borderRadius: BorderRadius.circular(LawrenceTheme.radiusSm),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final identity = Row(
              children: [
                CircleAvatar(
                  backgroundColor: scheme.primaryContainer,
                  foregroundColor: scheme.onPrimaryContainer,
                  child: Text(
                    student.fullName.trim().isEmpty
                        ? '?'
                        : student.fullName.trim()[0].toUpperCase(),
                  ),
                ),
                const SizedBox(width: LawrenceSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        student.fullName,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      Text(
                        student.email,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
            final progress = SizedBox(
              width: constraints.maxWidth < 620 ? double.infinity : 260,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${student.completedLessons}/${student.totalLessons} aulas • ${student.progressPercentage.round()}%',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: student.progressPercentage / 100,
                    color: scheme.primary,
                    backgroundColor: scheme.surfaceContainerHighest,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _statusLabel(student.accessStatus),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            );
            if (constraints.maxWidth < 620) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [identity, const SizedBox(height: 18), progress],
              );
            }
            return Row(
              children: [
                Expanded(child: identity),
                const SizedBox(width: 24),
                progress,
              ],
            );
          },
        ),
      ),
    );
  }
}

String _statusLabel(String value) => switch (value) {
  'active' || 'trialing' => 'Acesso ativo',
  'free' => 'Curso gratuito',
  'past_due' => 'Pagamento pendente',
  'canceled' => 'Assinatura cancelada',
  _ => 'Acesso: $value',
};
