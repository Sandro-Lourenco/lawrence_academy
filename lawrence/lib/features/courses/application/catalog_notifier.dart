import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/entities/course.dart';
import '../data/repositories/course_repository.dart';

class CatalogNotifier extends AutoDisposeAsyncNotifier<List<Course>> {
  @override
  Future<List<Course>> build() async {
    final repo = ref.watch(courseRepositoryProvider);
    return await repo.fetchPublishedCourses();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(courseRepositoryProvider);
      return await repo.fetchPublishedCourses();
    });
  }
}

final catalogNotifierProvider =
    AutoDisposeAsyncNotifierProvider<CatalogNotifier, List<Course>>(
      CatalogNotifier.new,
    );
