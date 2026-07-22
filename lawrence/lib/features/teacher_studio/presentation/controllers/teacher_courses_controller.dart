import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/providers/service_repositories.dart';
import '../../../../features/courses/domain/entities/course.dart';

class TeacherCoursesController extends AsyncNotifier<List<Course>> {
  @override
  FutureOr<List<Course>> build() async {
    return _fetchCourses();
  }

  Future<List<Course>> _fetchCourses() async {
    final usecases = ref.read(teacherCourseUseCasesProvider);
    return usecases.listCourses();
  }

  Future<void> reload() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_fetchCourses);
  }

  Future<void> archiveCourse(String courseId) async {
    try {
      final usecases = ref.read(teacherCourseUseCasesProvider);
      await usecases.archiveCourse(courseId);
      // Remove from list
      if (state.hasValue) {
        final currentList = state.value!;
        state = AsyncValue.data(
          currentList.where((c) => c.id != courseId).toList(),
        );
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

final teacherCoursesControllerProvider =
    AsyncNotifierProvider<TeacherCoursesController, List<Course>>(() {
      return TeacherCoursesController();
    });
