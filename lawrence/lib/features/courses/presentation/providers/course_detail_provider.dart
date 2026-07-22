import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/providers/learning_repositories.dart';
import '../../application/use_cases/get_course_detail_use_case.dart';
import '../../domain/entities/course.dart';

final getCourseDetailUseCaseProvider = Provider<GetCourseDetailUseCase>((ref) {
  final repo = ref.watch(courseRepositoryProvider);
  return GetCourseDetailUseCase(repo);
});

final courseDetailBySlugProvider = FutureProvider.autoDispose
    .family<Course?, String>((ref, slug) async {
      final useCase = ref.watch(getCourseDetailUseCaseProvider);
      return await useCase.executeWithSlug(slug);
    });

final courseDetailByIdProvider = FutureProvider.autoDispose
    .family<Course?, String>((ref, id) async {
      final useCase = ref.watch(getCourseDetailUseCaseProvider);
      return await useCase.executeWithId(id);
    });
