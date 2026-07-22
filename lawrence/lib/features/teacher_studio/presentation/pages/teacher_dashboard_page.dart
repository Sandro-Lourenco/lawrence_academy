import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../design_system/tokens/liquid_theme.dart';
import '../controllers/teacher_courses_controller.dart';

class TeacherDashboardPage extends ConsumerWidget {
  const TeacherDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coursesState = ref.watch(teacherCoursesControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Teacher Studio - Meus Cursos",
          style: TextStyle(fontFamily: 'Outfit', fontSize: 16),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/teacher/courses/new'),
          ),
        ],
      ),
      backgroundColor: LiquidTheme.background,
      body: coursesState.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: LiquidTheme.primary),
        ),
        error: (e, st) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.redAccent,
                size: 48,
              ),
              const SizedBox(height: 16),
              const Text(
                "Não foi possível carregar seus cursos.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 8),
              Text(
                e.toString(),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white38, fontSize: 12),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref
                    .read(teacherCoursesControllerProvider.notifier)
                    .reload(),
                child: const Text("Tentar Novamente"),
              ),
            ],
          ),
        ),
        data: (courses) {
          if (courses.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.school_outlined,
                    color: Colors.white30,
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Nenhum curso encontrado.",
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => context.push('/teacher/courses/new'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: LiquidTheme.primary,
                    ),
                    child: const Text(
                      "Criar Primeiro Curso",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () =>
                ref.read(teacherCoursesControllerProvider.notifier).reload(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: courses.length,
              itemBuilder: (context, index) {
                final c = courses[index];
                return Card(
                  color: Colors.white.withValues(alpha: 0.05),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: LiquidTheme.primary.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.play_lesson,
                        color: LiquidTheme.primary,
                      ),
                    ),
                    title: Text(
                      c.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      "${c.modules.length} módulos | Status: ${c.status}",
                      style: const TextStyle(color: Colors.white60),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.white70),
                          onPressed: () =>
                              context.push('/teacher/courses/${c.id}/edit'),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.redAccent,
                          ),
                          onPressed: () async {
                            final conf = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                backgroundColor: LiquidTheme.surface,
                                title: const Text(
                                  "Arquivar Curso?",
                                  style: TextStyle(color: Colors.white),
                                ),
                                content: const Text(
                                  "O curso não será deletado do banco de dados, mas ficará oculto para os alunos. Continuar?",
                                  style: TextStyle(color: Colors.white70),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, false),
                                    child: const Text("Cancelar"),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, true),
                                    child: const Text(
                                      "Arquivar",
                                      style: TextStyle(color: Colors.redAccent),
                                    ),
                                  ),
                                ],
                              ),
                            );
                            if (conf == true) {
                              ref
                                  .read(
                                    teacherCoursesControllerProvider.notifier,
                                  )
                                  .archiveCourse(c.id);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
