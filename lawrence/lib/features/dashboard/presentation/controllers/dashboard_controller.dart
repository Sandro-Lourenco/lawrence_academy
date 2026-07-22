import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers/learning_repositories.dart';
import '../../../../app/providers/service_repositories.dart';
import '../../../courses/domain/entities/course.dart';
import '../../../courses/presentation/controllers/catalog_controller.dart';
import '../../../lesson_progress/domain/entities/lesson_progress_entity.dart';

class DashboardResume {
  final Course course;
  final double progressPercentage;
  final String? nextLessonId;

  const DashboardResume({
    required this.course,
    required this.progressPercentage,
    required this.nextLessonId,
  });
}

class DashboardState {
  final String studentName;
  final List<Course> courses;
  final List<LessonProgressEntity> progressList;
  final DashboardResume? resume;
  final bool isUsingCachedAccess;

  const DashboardState({
    required this.studentName,
    required this.courses,
    required this.progressList,
    required this.resume,
    required this.isUsingCachedAccess,
  });
}

DashboardResume? buildDashboardResume(
  List<Course> courses,
  List<LessonProgressEntity> progress,
) {
  if (courses.isEmpty) return null;

  DashboardResume? bestResume;
  for (final course in courses) {
    final courseProgress = progress
        .where((item) => item.courseId == course.id)
        .toList(growable: false);
    final percentage = courseProgress.isEmpty
        ? 0.0
        : courseProgress.fold<double>(
                0,
                (total, item) => total + item.progressPercentage,
              ) /
              courseProgress.length;

    String? nextLessonId;
    for (final module in course.modules) {
      for (final lesson in module.lessons) {
        LessonProgressEntity? lessonProgress;
        for (final item in courseProgress) {
          if (item.lessonId == lesson.id) {
            lessonProgress = item;
            break;
          }
        }
        if (lessonProgress == null || !lessonProgress.completed) {
          nextLessonId = lesson.id;
          break;
        }
      }
      if (nextLessonId != null) break;
    }

    final candidate = DashboardResume(
      course: course,
      progressPercentage: percentage.clamp(0.0, 100.0).toDouble(),
      nextLessonId: nextLessonId,
    );
    final isInProgress = percentage > 0 && percentage < 100;
    final currentIsInProgress = bestResume != null &&
        bestResume.progressPercentage > 0 &&
        bestResume.progressPercentage < 100;

    if (bestResume == null ||
        (isInProgress && !currentIsInProgress) ||
        (isInProgress &&
            currentIsInProgress &&
            percentage > bestResume.progressPercentage)) {
      bestResume = candidate;
    }
  }

  return bestResume;
}

class DashboardNotifier extends AutoDisposeAsyncNotifier<DashboardState> {
  @override
  Future<DashboardState> build() async {
    var name = 'Estudante';
    try {
      final profile = await ref.watch(getMyProfileUseCaseProvider).execute();
      name = profile.fullName?.trim().isNotEmpty == true
          ? profile.fullName!.trim()
          : 'Estudante';
    } catch (_) {
      // O nome neutro mantém a Home utilizável quando o perfil não está em cache.
    }

    final catalog = await ref.watch(listCoursesUseCaseProvider).execute();
    final progressRepository = ref.watch(lessonProgressRepositoryProvider);
    final progress = <LessonProgressEntity>[];
    var isUsingCachedAccess = false;

    try {
      final remoteProgress = await progressRepository.fetchAllRemoteProgress();
      progress.addAll(remoteProgress);
      for (final item in remoteProgress) {
        await progressRepository.saveProgressLocally(item);
      }
    } catch (_) {
      for (final course in catalog) {
        progress.addAll(
          await progressRepository.getCourseProgress(course.id),
        );
      }
    }

    Set<String> accessibleCourseIds;
    try {
      final subscriptions = await ref
          .watch(getSubscriptionsUseCaseProvider)
          .execute();
      accessibleCourseIds = subscriptions
          .where((subscription) => subscription.hasAccess)
          .map((subscription) => subscription.courseId)
          .toSet();
    } catch (_) {
      isUsingCachedAccess = true;
      accessibleCourseIds = progress.map((item) => item.courseId).toSet();
    }

    final courses = catalog
        .where((course) => accessibleCourseIds.contains(course.id))
        .toList(growable: false);
    final accessibleProgress = progress
        .where((item) => accessibleCourseIds.contains(item.courseId))
        .toList(growable: false);

    return DashboardState(
      studentName: name,
      courses: courses,
      progressList: accessibleProgress,
      resume: buildDashboardResume(courses, accessibleProgress),
      isUsingCachedAccess: isUsingCachedAccess,
    );
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(build);
  }
}

final dashboardNotifierProvider =
    AutoDisposeAsyncNotifierProvider<DashboardNotifier, DashboardState>(
      DashboardNotifier.new,
    );
