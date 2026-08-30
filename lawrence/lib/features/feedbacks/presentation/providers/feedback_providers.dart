import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/network_client.dart';
import '../../data/course_completion_repository.dart';
import '../../domain/entities/course_completion.dart';

final courseCompletionRepositoryProvider = Provider<CourseCompletionRepository>(
  (ref) => CourseCompletionRepository(ref.watch(networkClientProvider)),
);

final courseCompletionProvider =
    FutureProvider.family<CourseCompletion, String>(
      (ref, courseId) =>
          ref.watch(courseCompletionRepositoryProvider).getCompletion(courseId),
    );

final feedbacksProvider = FutureProvider<List<CourseFeedback>>(
  (ref) => ref.watch(courseCompletionRepositoryProvider).listFeedbacks(),
);
