import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/providers/learning_repositories.dart';
import '../../application/use_cases/check_lesson_access_use_case.dart';
import '../../application/use_cases/get_lesson_use_case.dart';
import '../../application/use_cases/list_course_lessons_use_case.dart';
import '../../domain/entities/lesson_entity.dart';

final getLessonUseCaseProvider = Provider<GetLessonUseCase>((ref) {
  final repo = ref.watch(lessonRepositoryProvider);
  return GetLessonUseCase(repo);
});

final listCourseLessonsUseCaseProvider = Provider<ListCourseLessonsUseCase>((
  ref,
) {
  final repo = ref.watch(lessonRepositoryProvider);
  return ListCourseLessonsUseCase(repo);
});

final checkLessonAccessUseCaseProvider = Provider<CheckLessonAccessUseCase>((
  ref,
) {
  final repo = ref.watch(lessonRepositoryProvider);
  return CheckLessonAccessUseCase(repo);
});

// Provedor para listar as aulas de um curso
final courseLessonsProvider = FutureProvider.autoDispose
    .family<List<LessonEntity>, String>((ref, courseId) async {
      final useCase = ref.watch(listCourseLessonsUseCaseProvider);
      return await useCase.execute(courseId);
    });

// Provedor para verificar se o aluno tem acesso a uma lição (BOLA-safe interpretado)
final lessonAccessProvider = FutureProvider.autoDispose
    .family<bool, ({String courseId, String lessonId})>((ref, arg) async {
      final useCase = ref.watch(checkLessonAccessUseCaseProvider);
      return await useCase.execute(arg.courseId, arg.lessonId);
    });

// Provedor para obter os detalhes de uma lição específica
final lessonDetailProvider = FutureProvider.autoDispose
    .family<LessonEntity, ({String courseId, String lessonId})>((
      ref,
      arg,
    ) async {
      final useCase = ref.watch(getLessonUseCaseProvider);
      return await useCase.execute(arg.courseId, arg.lessonId);
    });
