import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/network_client.dart';
import '../../core/offline_license_service.dart';
import '../../features/courses/data/repositories/course_repository.dart';
import '../../features/courses/domain/repositories/course_repository_interface.dart';
import '../../features/dashboard/data/repositories/hive_learning_resume_repository.dart';
import '../../features/dashboard/domain/repositories/learning_resume_repository.dart';
import '../../features/lesson_progress/data/datasources/hive_progress_datasource.dart';
import '../../features/lesson_progress/data/datasources/progress_local_datasource.dart';
import '../../features/lesson_progress/data/datasources/sqlite_progress_datasource.dart';
import '../../features/lesson_progress/data/repositories/lesson_progress_repository.dart';
import '../../features/lesson_progress/domain/repositories/lesson_progress_repository_interface.dart';
import '../../features/lessons/data/repositories/lesson_repository.dart';
import '../../features/lessons/domain/repositories/lesson_repository_interface.dart';

final courseRepositoryProvider = Provider<ICourseRepository>((ref) {
  return CourseRepository(ref.watch(networkClientProvider));
});

final lessonRepositoryProvider = Provider<ILessonRepository>((ref) {
  return LessonRepository(ref.watch(networkClientProvider));
});

final learningResumeRepositoryProvider = Provider<LearningResumeRepository>((
  ref,
) {
  return HiveLearningResumeRepository();
});

ProgressLocalDataSource createProgressLocalDataSource({required bool isWeb}) {
  return isWeb ? HiveProgressDataSource() : SQLiteProgressDataSource();
}

final progressLocalDataSourceProvider = Provider<ProgressLocalDataSource>((
  ref,
) {
  return createProgressLocalDataSource(isWeb: kIsWeb);
});

final offlineLicenseServiceProvider = Provider<OfflineLicenseService>((ref) {
  return OfflineLicenseService();
});

final lessonProgressRepositoryProvider = Provider<ILessonProgressRepository>((
  ref,
) {
  return LessonProgressRepository(
    ref.watch(progressLocalDataSourceProvider),
    ref.watch(networkClientProvider),
    ref.watch(offlineLicenseServiceProvider).getInstallationId,
  );
});
