import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/entities/course.dart';
import '../data/repositories/course_repository.dart';

final courseDetailBySlugProvider = FutureProvider.autoDispose
    .family<Course?, String>((ref, slug) async {
      final repo = ref.watch(courseRepositoryProvider);
      return await repo.fetchCourseBySlug(slug);
    });

final courseDetailByIdProvider = FutureProvider.autoDispose
    .family<Course?, String>((ref, id) async {
      final repo = ref.watch(courseRepositoryProvider);
      return await repo.fetchCourseDetails(id);
    });
