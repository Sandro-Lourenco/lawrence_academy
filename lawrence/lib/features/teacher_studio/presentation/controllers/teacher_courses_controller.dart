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

  Future<void> archiveCourse(String courseId, {String? reason}) async {
    try {
      final usecases = ref.read(teacherCourseUseCasesProvider);
      await usecases.archiveCourse(courseId, reason: reason);
      await reload();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<bool> unpublishCourse(String courseId, {String? reason}) async {
    try {
      await ref
          .read(teacherCourseUseCasesProvider)
          .unpublishCourse(courseId, reason: reason);
      await reload();
      return true;
    } catch (error, stack) {
      state = AsyncValue.error(error, stack);
      return false;
    }
  }

  Future<bool> restoreCourse(String courseId, {String? reason}) async {
    try {
      await ref
          .read(teacherCourseUseCasesProvider)
          .restoreCourse(courseId, reason: reason);
      await reload();
      return true;
    } catch (error, stack) {
      state = AsyncValue.error(error, stack);
      return false;
    }
  }
}

final teacherCoursesControllerProvider =
    AsyncNotifierProvider<TeacherCoursesController, List<Course>>(() {
      return TeacherCoursesController();
    });
