import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/providers/learning_repositories.dart';
import '../../../../core/network/network_client.dart';
import '../../../courses/domain/entities/course.dart';
import '../../../courses/presentation/controllers/catalog_controller.dart';
import '../../../lesson_progress/domain/entities/lesson_progress_entity.dart';

class DashboardState {
  final String studentName;
  final List<Course> courses;
  final List<LessonProgressEntity> progressList;

  DashboardState({
    required this.studentName,
    required this.courses,
    required this.progressList,
  });
}

class DashboardNotifier extends AutoDisposeAsyncNotifier<DashboardState> {
  @override
  Future<DashboardState> build() async {
    final netClient = ref.watch(networkClientProvider);

    // 1. Obter perfil do estudante
    String name = 'Estudante';
    try {
      final profileRes = await netClient.get('/students/me');
      name = profileRes.data['full_name'] as String? ?? 'Estudante';
    } catch (_) {
      // Fallback silencioso se offline
    }

    // 2. Obter lista de cursos publicados
    final coursesUseCase = ref.watch(listCoursesUseCaseProvider);
    final courses = await coursesUseCase.execute();

    // 3. Obter progresso geral das lições
    final progressRepo = ref.watch(lessonProgressRepositoryProvider);
    final List<LessonProgressEntity> progressList = [];

    try {
      final remoteProgress = await progressRepo.fetchAllRemoteProgress();
      progressList.addAll(remoteProgress);

      // Cachear no SQLite local para acesso offline resiliente
      for (final p in remoteProgress) {
        await progressRepo.saveProgressLocally(p);
      }
    } catch (_) {
      // Se offline ou falhar, buscar progresso local do SQLite
      for (final course in courses) {
        final localProg = await progressRepo.getCourseProgress(course.id);
        progressList.addAll(localProg);
      }
    }

    return DashboardState(
      studentName: name,
      courses: courses,
      progressList: progressList,
    );
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => build());
  }
}

final dashboardNotifierProvider =
    AutoDisposeAsyncNotifierProvider<DashboardNotifier, DashboardState>(
      DashboardNotifier.new,
    );
