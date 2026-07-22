import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/providers/learning_repositories.dart';
import '../../application/use_cases/list_courses_use_case.dart';
import '../../domain/entities/course.dart';

final listCoursesUseCaseProvider = Provider<ListCoursesUseCase>((ref) {
  final repo = ref.watch(courseRepositoryProvider);
  return ListCoursesUseCase(repo);
});

class CatalogNotifier extends AutoDisposeAsyncNotifier<List<Course>> {
  @override
  Future<List<Course>> build() async {
    final useCase = ref.watch(listCoursesUseCaseProvider);
    return await useCase.execute();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final useCase = ref.read(listCoursesUseCaseProvider);
      return await useCase.execute();
    });
  }
}

final catalogNotifierProvider =
    AutoDisposeAsyncNotifierProvider<CatalogNotifier, List<Course>>(
      CatalogNotifier.new,
    );
