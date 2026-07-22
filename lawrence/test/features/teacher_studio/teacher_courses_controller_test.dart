import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lawrence/app/providers/service_repositories.dart';
import 'package:lawrence/features/teacher_studio/presentation/controllers/teacher_courses_controller.dart';
import 'package:lawrence/features/courses/domain/entities/course.dart';
import 'package:lawrence/features/teacher_studio/domain/repositories/teacher_course_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockTeacherCourseRepository extends Mock
    implements ITeacherCourseRepository {}

void main() {
  late MockTeacherCourseRepository mockRepo;
  late ProviderContainer container;

  setUp(() {
    mockRepo = MockTeacherCourseRepository();
    container = ProviderContainer(
      overrides: [teacherCourseRepositoryProvider.overrideWithValue(mockRepo)],
    );
  });

  tearDown(() {
    container.dispose();
  });

  test('TeacherCoursesController fetches courses successfully', () async {
    final mockCourses = [
      const Course(
        id: '1',
        instructorId: 'prof',
        title: 'Curso',
        slug: 'curso',
        category: 'cat',
        level: 'iniciante',
        summary: 'sum',
        status: 'draft',
        modules: [],
      ),
    ];

    when(
      () => mockRepo.getTeacherCourses(),
    ).thenAnswer((_) async => mockCourses);

    final sub = container.listen(teacherCoursesControllerProvider, (_, _) {});

    await Future.microtask(() {}); // Permite processar build

    final state = container.read(teacherCoursesControllerProvider);
    expect(state.isLoading, false);
    expect(state.hasValue, true);
    expect(state.value, equals(mockCourses));

    sub.close();
  });

  test(
    'TeacherCoursesController handles error gracefully (Unauthorized)',
    () async {
      when(
        () => mockRepo.getTeacherCourses(),
      ).thenThrow(Exception('Unauthorized 403'));

      final sub = container.listen(teacherCoursesControllerProvider, (_, _) {});

      await Future.microtask(() {});

      final state = container.read(teacherCoursesControllerProvider);
      expect(state.hasError, true);
      expect(state.error.toString(), contains('Unauthorized'));

      sub.close();
    },
  );
}
