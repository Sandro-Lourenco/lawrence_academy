import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lawrence/app/providers/service_repositories.dart';
import 'package:lawrence/features/teacher_studio/presentation/controllers/course_wizard_controller.dart';
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

  test('CourseWizardController init with empty creates empty state', () async {
    final controller = container.read(courseWizardControllerProvider.notifier);
    controller.init(null);

    await Future.microtask(() {});

    final state = container.read(courseWizardControllerProvider);
    expect(state.hasValue, true);
    expect(state.value!.course, isNull);
    expect(state.value!.hasUnsavedChanges, false);
  });

  test('CourseWizardController markUnsavedChanges works', () async {
    final controller = container.read(courseWizardControllerProvider.notifier);
    controller.init(null);

    await Future.microtask(() {});

    controller.markUnsavedChanges();

    final state = container.read(courseWizardControllerProvider);
    expect(state.value!.hasUnsavedChanges, true);
  });

  test(
    'CourseWizardController saveDraft creates course if none exists',
    () async {
      final controller = container.read(
        courseWizardControllerProvider.notifier,
      );
      controller.init(null);

      await Future.microtask(() {});

      final mockCourse = const Course(
        id: 'course_123',
        instructorId: 'prof',
        title: 'Title',
        slug: 'slug',
        category: 'cat',
        level: 'level',
        summary: 'sum',
        status: 'draft',
        modules: [],
      );

      when(
        () => mockRepo.createCourse(any()),
      ).thenAnswer((_) async => mockCourse);

      final success = await controller.saveDraft({"title": "Title"});

      expect(success, true);
      final state = container.read(courseWizardControllerProvider);
      expect(state.value!.course!.id, 'course_123');
      expect(state.value!.hasUnsavedChanges, false);
    },
  );
}
