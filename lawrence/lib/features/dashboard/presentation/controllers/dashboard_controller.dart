import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers/learning_repositories.dart';
import '../../../../app/providers/service_repositories.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../courses/domain/entities/course.dart';
import '../../../courses/presentation/controllers/catalog_controller.dart';
import '../../../lesson_progress/domain/entities/lesson_progress_entity.dart';
import '../../domain/entities/learning_resume_target.dart';

class DashboardResume {
  final Course course;
  final double progressPercentage;
  final String lessonId;
  final String lessonTitle;
  final LearningResumeView view;

  const DashboardResume({
    required this.course,
    required this.progressPercentage,
    required this.lessonId,
    required this.lessonTitle,
    required this.view,
  });

  String get destination {
    final base = '/dashboard/courses/${course.id}/lessons/$lessonId';
    return view == LearningResumeView.watch
        ? base
        : '$base?view=${view.queryValue}';
  }
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
  List<LessonProgressEntity> progress, [
  Map<String, LearningResumeTarget> savedTargets = const {},
]) {
  if (courses.isEmpty) return null;

  DashboardResume? bestResume;
  DateTime? bestActivityAt;
  for (final course in courses) {
    final lessons = [for (final module in course.modules) ...module.lessons];
    if (lessons.isEmpty) continue;
    final courseProgress = progress
        .where((item) => item.courseId == course.id)
        .toList(growable: false);
    final progressByLesson = {
      for (final item in courseProgress) item.lessonId: item,
    };
    final percentage =
        lessons.fold<double>(0, (total, lesson) {
          final item = progressByLesson[lesson.id];
          return total +
              (item?.completed == true
                  ? 100
                  : (item?.progressPercentage ?? 0).clamp(0, 100));
        }) /
        lessons.length;

    final saved = savedTargets[course.id];
    final savedLesson = saved == null
        ? null
        : _firstWhereOrNull(lessons, (lesson) => lesson.id == saved.lessonId);
    final viewedProgress =
        courseProgress
            .where((item) => item.progressPercentage > 0 && !item.completed)
            .toList()
          ..sort(
            (a, b) => (b.lastSyncedAt ?? DateTime.fromMillisecondsSinceEpoch(0))
                .compareTo(
                  a.lastSyncedAt ?? DateTime.fromMillisecondsSinceEpoch(0),
                ),
          );
    final viewedLesson = viewedProgress.isEmpty
        ? null
        : _firstWhereOrNull(
            lessons,
            (lesson) => lesson.id == viewedProgress.first.lessonId,
          );
    final firstIncomplete = _firstWhereOrNull(
      lessons,
      (lesson) => progressByLesson[lesson.id]?.completed != true,
    );
    final targetLesson =
        savedLesson ?? viewedLesson ?? firstIncomplete ?? lessons.last;
    final activityAt =
        saved?.updatedAt ??
        (viewedProgress.isEmpty ? null : viewedProgress.first.lastSyncedAt);

    final candidate = DashboardResume(
      course: course,
      progressPercentage: percentage.clamp(0.0, 100.0).toDouble(),
      lessonId: targetLesson.id,
      lessonTitle: targetLesson.title,
      view: savedLesson == null ? LearningResumeView.watch : saved!.view,
    );
    final candidateStarted = percentage > 0 || savedLesson != null;
    final bestStarted =
        bestResume != null &&
        (bestResume.progressPercentage > 0 ||
            savedTargets.containsKey(bestResume.course.id));

    if (bestResume == null ||
        (candidateStarted && !bestStarted) ||
        (candidateStarted &&
            bestStarted &&
            activityAt != null &&
            (bestActivityAt == null || activityAt.isAfter(bestActivityAt)))) {
      bestResume = candidate;
      bestActivityAt = activityAt;
    }
  }

  return bestResume;
}

T? _firstWhereOrNull<T>(Iterable<T> values, bool Function(T) test) {
  for (final value in values) {
    if (test(value)) return value;
  }
  return null;
}

class DashboardNotifier extends AutoDisposeAsyncNotifier<DashboardState> {
  @override
  Future<DashboardState> build() async {
    final studentId = ref.watch(
      authNotifierProvider.select((state) => state.user?.id),
    );
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
        progress.addAll(await progressRepository.getCourseProgress(course.id));
      }
    }

    final savedTargets = <String, LearningResumeTarget>{};
    Set<String> accessibleCourseIds;
    try {
      final subscriptions = await ref
          .watch(getSubscriptionsUseCaseProvider)
          .execute();
      accessibleCourseIds = subscriptions
          .where((subscription) => subscription.hasAccess)
          .map((subscription) => subscription.courseId)
          .toSet();
      // Cursos gratuitos iniciados geram progresso, mas não necessariamente
      // uma assinatura. O progresso também é uma prova de matrícula ativa.
      accessibleCourseIds.addAll(progress.map((item) => item.courseId));
    } catch (_) {
      isUsingCachedAccess = true;
      accessibleCourseIds = progress.map((item) => item.courseId).toSet();
    }

    if (studentId != null) {
      final resumeRepository = ref.watch(learningResumeRepositoryProvider);
      final targets = await Future.wait(
        catalog.map(
          (course) => resumeRepository.getForCourse(
            studentId: studentId,
            courseId: course.id,
          ),
        ),
      );
      for (final target in targets.whereType<LearningResumeTarget>()) {
        savedTargets[target.courseId] = target;
        accessibleCourseIds.add(target.courseId);
      }
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
      resume: buildDashboardResume(courses, accessibleProgress, savedTargets),
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
