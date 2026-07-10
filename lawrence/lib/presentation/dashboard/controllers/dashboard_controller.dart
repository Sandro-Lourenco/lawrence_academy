import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lawrence/data/models/course_dto.dart';
import 'package:lawrence/data/repositories/course_repository.dart';

class DashboardState {
  final List<Course> courses;
  final Course? lastWatchedCourse;
  final Lesson? lastWatchedLesson;
  final int lastPositionSeconds;
  final double progressPercentage; // Efeito Zeigarnik (0.0 a 1.0)
  final List<Map<String, dynamic>> upcomingLives;

  DashboardState({
    required this.courses,
    this.lastWatchedCourse,
    this.lastWatchedLesson,
    this.lastPositionSeconds = 0,
    this.progressPercentage = 0.0,
    required this.upcomingLives,
  });
}

class DashboardController extends AutoDisposeAsyncNotifier<DashboardState> {
  @override
  Future<DashboardState> build() async {
    final repo = ref.watch(courseRepositoryProvider);

    // Buscar cursos e progresso em paralelo
    final courses = await repo.fetchPublishedCourses();
    final progressList = await repo.fetchAllLessonProgress();

    Course? lastWatchedCourse;
    Lesson? lastWatchedLesson;
    int lastPos = 0;
    double percentage = 0.0;

    if (progressList.isNotEmpty) {
      // Ordenar progressList por updated_at descendente se existir
      progressList.sort((a, b) {
        final aTime =
            DateTime.tryParse(a['updated_at'] as String? ?? '') ??
            DateTime.fromMillisecondsSinceEpoch(0);
        final bTime =
            DateTime.tryParse(b['updated_at'] as String? ?? '') ??
            DateTime.fromMillisecondsSinceEpoch(0);
        return bTime.compareTo(aTime);
      });

      // Pegar o último registro de progresso (lição incompleta preferencialmente, ou a última assistida)
      final latestProgress = progressList.firstWhere(
        (p) => p['completed'] == false,
        orElse: () => progressList.first,
      );

      final targetLessonId = latestProgress['lesson_id'] as String;
      lastPos = latestProgress['last_position_seconds'] as int? ?? 0;

      // Encontrar a Lesson correspondente e o Course pai na lista de cursos
      outerLoop:
      for (final course in courses) {
        for (final module in course.modules) {
          for (final lesson in module.lessons) {
            if (lesson.id == targetLessonId) {
              lastWatchedLesson = lesson;
              lastWatchedCourse = course;
              break outerLoop;
            }
          }
        }
      }

      if (lastWatchedLesson != null && lastWatchedLesson.durationSeconds > 0) {
        percentage = lastPos / lastWatchedLesson.durationSeconds;
        if (percentage > 1.0) percentage = 1.0;
        if (percentage < 0.0) percentage = 0.0;
      }
    }

    // Se não houver progresso anterior, pega o primeiro curso e primeira aula como recomendação inicial
    if (lastWatchedLesson == null && courses.isNotEmpty) {
      final firstCourse = courses.first;
      if (firstCourse.modules.isNotEmpty &&
          firstCourse.modules.first.lessons.isNotEmpty) {
        lastWatchedCourse = firstCourse;
        lastWatchedLesson = firstCourse.modules.first.lessons.first;
        lastPos = 0;
        percentage = 0.0;
      }
    }

    // Mock das próximas lives da Lawrence Academy (Próximas Lives)
    final upcomingLives = [
      {
        'id': 'live-1',
        'title': 'Modelagem Avançada de Ombros e Mangas Puff',
        'instructor': 'Ariane Lawrence',
        'datetime': 'Amanhã, às 19:30',
        'tag': 'Live VIP',
      },
      {
        'id': 'live-2',
        'title': 'Modelagem Tridimensional e Draping',
        'instructor': 'Ariane Lawrence',
        'datetime': '12 de Julho, às 20:00',
        'tag': 'Masterclass',
      },
    ];

    return DashboardState(
      courses: courses,
      lastWatchedCourse: lastWatchedCourse,
      lastWatchedLesson: lastWatchedLesson,
      lastPositionSeconds: lastPos,
      progressPercentage: percentage,
      upcomingLives: upcomingLives,
    );
  }

  /// Registra progresso atualizado de uma aula e atualiza o estado local
  Future<void> updateProgress(
    String courseId,
    String lessonId,
    int seconds,
    bool completed,
  ) async {
    final repo = ref.read(courseRepositoryProvider);
    await repo.updateLessonProgress(
      courseId: courseId,
      lessonId: lessonId,
      watchedSeconds: seconds,
      completed: completed,
    );
    ref.invalidateSelf(); // Recarregar estado
  }
}

/// Provider do painel/dashboard de aluno.
final dashboardControllerProvider =
    AutoDisposeAsyncNotifierProvider<DashboardController, DashboardState>(
      DashboardController.new,
    );
