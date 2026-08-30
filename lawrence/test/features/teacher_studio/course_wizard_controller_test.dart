import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lawrence/app/providers/service_repositories.dart';
import 'package:lawrence/features/teacher_studio/presentation/controllers/course_wizard_controller.dart';
import 'package:lawrence/features/courses/domain/entities/course.dart';
import 'package:lawrence/features/teacher_studio/domain/entities/upload_file_payload.dart';
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
        () => mockRepo.createCourse(
          any(),
          idempotencyKey: any(named: 'idempotencyKey'),
        ),
      ).thenAnswer((_) async => mockCourse);

      final success = await controller.saveDraft({"title": "Title"});

      expect(success, true);
      final state = container.read(courseWizardControllerProvider);
      expect(state.value!.course!.id, 'course_123');
      expect(state.value!.hasUnsavedChanges, false);
    },
  );

  test('concurrent draft saves create only one course', () async {
    final controller = container.read(courseWizardControllerProvider.notifier);
    controller.init(null);
    await Future.microtask(() {});

    final completion = Completer<Course>();
    when(
      () => mockRepo.createCourse(
        any(),
        idempotencyKey: any(named: 'idempotencyKey'),
      ),
    ).thenAnswer((_) => completion.future);

    final first = controller.saveDraft({'title': 'Title'});
    final second = controller.saveDraft({'title': 'Title'});
    completion.complete(_course());

    expect(await first, true);
    expect(await second, false);
    verify(
      () => mockRepo.createCourse(
        any(),
        idempotencyKey: any(named: 'idempotencyKey'),
      ),
    ).called(1);
  });

  test('draft retry reuses intent key until creation succeeds', () async {
    final controller = container.read(courseWizardControllerProvider.notifier);
    controller.init(null);
    await Future.microtask(() {});

    final keys = <String>[];
    var attempts = 0;
    when(
      () => mockRepo.createCourse(
        any(),
        idempotencyKey: any(named: 'idempotencyKey'),
      ),
    ).thenAnswer((invocation) async {
      keys.add(invocation.namedArguments[#idempotencyKey] as String);
      if (attempts++ == 0) throw Exception('temporary');
      return _course();
    });

    expect(await controller.saveDraft({'title': 'Title'}), false);
    expect(await controller.saveDraft({'title': 'Title'}), true);
    expect(keys, hasLength(2));
    expect(keys[1], keys[0]);
  });

  test('changed draft payload rotates the failed intent key', () async {
    final controller = container.read(courseWizardControllerProvider.notifier);
    controller.init(null);
    await Future.microtask(() {});

    final keys = <String>[];
    when(
      () => mockRepo.createCourse(
        any(),
        idempotencyKey: any(named: 'idempotencyKey'),
      ),
    ).thenAnswer((invocation) async {
      keys.add(invocation.namedArguments[#idempotencyKey] as String);
      if (keys.length == 1) throw Exception('temporary');
      return _course();
    });

    expect(await controller.saveDraft({'title': 'First'}), false);
    expect(await controller.saveDraft({'title': 'Changed'}), true);
    expect(keys, hasLength(2));
    expect(keys[1], isNot(keys[0]));
  });

  test('ambiguous upload failure reuses the same upload intent key', () async {
    final controller = container.read(courseWizardControllerProvider.notifier);
    when(
      () => mockRepo.getTeacherCourse('course_123'),
    ).thenAnswer((_) async => _course());
    controller.init('course_123');
    await Future<void>.delayed(Duration.zero);

    const lesson = Lesson(
      id: 'lesson_1',
      moduleId: 'module_1',
      courseId: 'course_123',
      title: 'Lesson',
      description: '',
      orderIndex: 0,
      status: 'draft',
      durationSeconds: 0,
      aiSummary: AISummary(
        title: '',
        executiveSummary: '',
        keyTakeaways: [],
        stepByStepExecution: [],
        technicalGlossary: [],
      ),
    );
    final file = UploadFilePayload(
      filename: 'lesson.mp4',
      sizeBytes: 42,
      contentType: 'video/mp4',
      bytes: Uint8List.fromList([1, 2, 3]),
    );
    final uploadKeys = <String>[];
    when(
      () => mockRepo.createLesson(
        'course_123',
        'module_1',
        any(),
        idempotencyKey: any(named: 'idempotencyKey'),
      ),
    ).thenAnswer((_) async => lesson);
    when(
      () => mockRepo.uploadLessonVideo(
        courseId: 'course_123',
        lessonId: 'lesson_1',
        file: file,
        idempotencyKey: any(named: 'idempotencyKey'),
      ),
    ).thenAnswer((invocation) async {
      uploadKeys.add(invocation.namedArguments[#idempotencyKey] as String);
      if (uploadKeys.length == 1) throw Exception('timeout');
    });
    when(
      () => mockRepo.getTeacherCourse('course_123'),
    ).thenAnswer((_) async => _course());

    final data = {'title': 'Lesson', 'order_index': 0};
    expect(
      await controller.addLesson(
        moduleId: 'module_1',
        lessonData: data,
        video: file,
      ),
      false,
    );
    expect(
      await controller.addLesson(
        moduleId: 'module_1',
        lessonData: data,
        video: file,
      ),
      true,
    );
    expect(uploadKeys, hasLength(2));
    expect(uploadKeys[1], uploadKeys[0]);
  });

  test('video polling cannot overwrite a newer lesson edit', () async {
    final subscription = container.listen(
      courseWizardControllerProvider,
      (_, _) {},
      fireImmediately: true,
    );
    addTearDown(subscription.close);
    final controller = container.read(courseWizardControllerProvider.notifier);
    final staleRefresh = Completer<Course>();
    var reads = 0;
    final initial = _courseWith(
      modules: [_moduleWithLesson(title: 'Original')],
    );
    final edited = _courseWith(modules: [_moduleWithLesson(title: 'Editada')]);

    when(() => mockRepo.getTeacherCourse('course_123')).thenAnswer((_) {
      reads += 1;
      if (reads == 1) return Future.value(initial);
      if (reads == 2) return staleRefresh.future;
      return Future.value(edited);
    });
    when(
      () =>
          mockRepo.updateLesson('course_123', 'lesson_1', {'title': 'Editada'}),
    ).thenAnswer((_) async => _lesson(title: 'Editada'));

    controller.init('course_123');
    await Future<void>.delayed(Duration.zero);

    final polling = controller.refreshVideoStatuses();
    await Future<void>.delayed(Duration.zero);
    expect(
      await controller.editLesson(
        lessonId: 'lesson_1',
        lessonData: {'title': 'Editada'},
      ),
      true,
    );

    staleRefresh.complete(initial);
    await polling;

    final course = container
        .read(courseWizardControllerProvider)
        .requireValue
        .course!;
    expect(course.modules.single.lessons.single.title, 'Editada');
  });

  test('autosave debounce persists only the latest draft', () async {
    final subscription = container.listen(
      courseWizardControllerProvider,
      (_, _) {},
      fireImmediately: true,
    );
    addTearDown(subscription.close);
    final controller = container.read(courseWizardControllerProvider.notifier);
    when(
      () => mockRepo.getTeacherCourse('course_123'),
    ).thenAnswer((_) async => _course());
    when(
      () => mockRepo.updateCourse('course_123', any()),
    ).thenAnswer((_) async => _course());
    controller.init('course_123');
    await Future<void>.delayed(Duration.zero);

    controller.scheduleAutosave({
      'title': 'Primeiro',
    }, debounce: const Duration(milliseconds: 20));
    controller.scheduleAutosave({
      'title': 'Último',
    }, debounce: const Duration(milliseconds: 20));
    await Future<void>.delayed(const Duration(milliseconds: 40));

    verify(
      () => mockRepo.updateCourse('course_123', {
        'title': 'Último',
        'expected_authoring_revision': 0,
      }),
    ).called(1);
    verifyNever(
      () => mockRepo.updateCourse('course_123', {
        'title': 'Primeiro',
        'expected_authoring_revision': 0,
      }),
    );
  });

  test('autosave merges different pending fields before persisting', () async {
    final subscription = container.listen(
      courseWizardControllerProvider,
      (_, _) {},
      fireImmediately: true,
    );
    addTearDown(subscription.close);
    final controller = container.read(courseWizardControllerProvider.notifier);
    when(
      () => mockRepo.getTeacherCourse('course_123'),
    ).thenAnswer((_) async => _course());
    when(
      () => mockRepo.updateCourse('course_123', any()),
    ).thenAnswer((_) async => _course());
    controller.init('course_123');
    await Future<void>.delayed(Duration.zero);

    controller.scheduleAutosave({
      'title': 'Curso atualizado',
    }, debounce: const Duration(milliseconds: 20));
    controller.scheduleAutosave({
      'course_type': 'quick',
    }, debounce: const Duration(milliseconds: 20));
    await Future<void>.delayed(const Duration(milliseconds: 40));

    verify(
      () => mockRepo.updateCourse('course_123', {
        'title': 'Curso atualizado',
        'course_type': 'quick',
        'expected_authoring_revision': 0,
      }),
    ).called(1);
  });

  test('autosaves are serialized and keep newer revision unsaved', () async {
    final subscription = container.listen(
      courseWizardControllerProvider,
      (_, _) {},
      fireImmediately: true,
    );
    addTearDown(subscription.close);
    final controller = container.read(courseWizardControllerProvider.notifier);
    final firstSave = Completer<Course>();
    final secondSave = Completer<Course>();
    var calls = 0;
    when(
      () => mockRepo.getTeacherCourse('course_123'),
    ).thenAnswer((_) async => _course());
    when(() => mockRepo.updateCourse('course_123', any())).thenAnswer((_) {
      calls += 1;
      return calls == 1 ? firstSave.future : secondSave.future;
    });
    controller.init('course_123');
    await Future<void>.delayed(Duration.zero);

    controller.scheduleAutosave({'title': 'Primeiro'});
    final flush = controller.flushPendingAutosave();
    await Future<void>.delayed(Duration.zero);
    controller.scheduleAutosave({'title': 'Mais recente'});
    firstSave.complete(_course());
    await flush;

    expect(
      container
          .read(courseWizardControllerProvider)
          .requireValue
          .hasUnsavedChanges,
      true,
    );
    await Future<void>.delayed(Duration.zero);
    expect(calls, 2);
    secondSave.complete(_course());
    await Future<void>.delayed(Duration.zero);

    expect(
      container
          .read(courseWizardControllerProvider)
          .requireValue
          .hasUnsavedChanges,
      false,
    );
    verify(
      () => mockRepo.updateCourse('course_123', {
        'title': 'Primeiro',
        'expected_authoring_revision': 0,
      }),
    ).called(1);
    verify(
      () => mockRepo.updateCourse('course_123', {
        'title': 'Mais recente',
        'expected_authoring_revision': 0,
      }),
    ).called(1);
  });

  test(
    'failed autosave preserves draft and retries on explicit flush',
    () async {
      final subscription = container.listen(
        courseWizardControllerProvider,
        (_, _) {},
        fireImmediately: true,
      );
      addTearDown(subscription.close);
      final controller = container.read(
        courseWizardControllerProvider.notifier,
      );
      var attempts = 0;
      when(
        () => mockRepo.getTeacherCourse('course_123'),
      ).thenAnswer((_) async => _course());
      when(() => mockRepo.updateCourse('course_123', any())).thenAnswer((
        _,
      ) async {
        attempts += 1;
        if (attempts == 1) throw Exception('connection_error');
        return _course();
      });
      controller.init('course_123');
      await Future<void>.delayed(Duration.zero);

      controller.scheduleAutosave({'title': 'Preservado'});
      await controller.flushPendingAutosave();
      var wizardState = container
          .read(courseWizardControllerProvider)
          .requireValue;
      expect(wizardState.hasUnsavedChanges, true);
      expect(wizardState.error, contains('connection_error'));

      await controller.flushPendingAutosave();
      wizardState = container.read(courseWizardControllerProvider).requireValue;
      expect(attempts, 2);
      expect(wizardState.hasUnsavedChanges, false);
      expect(wizardState.error, isNull);
    },
  );

  test('autosave sends CAS revision and reconciles a stale conflict', () async {
    final subscription = container.listen(
      courseWizardControllerProvider,
      (_, _) {},
      fireImmediately: true,
    );
    addTearDown(subscription.close);
    final controller = container.read(courseWizardControllerProvider.notifier);
    var reads = 0;
    var saves = 0;
    when(() => mockRepo.getTeacherCourse('course_123')).thenAnswer((_) async {
      reads += 1;
      return _course(authoringRevision: reads == 1 ? 7 : 9);
    });
    when(() => mockRepo.updateCourse('course_123', any())).thenAnswer((
      _,
    ) async {
      saves += 1;
      if (saves == 1) throw Exception('HTTP_409 stale authoring revision');
      return _course(authoringRevision: 10);
    });
    controller.init('course_123');
    await Future<void>.delayed(Duration.zero);

    controller.scheduleAutosave({'title': 'Rascunho local'});
    await controller.flushPendingAutosave();
    var wizardState = container
        .read(courseWizardControllerProvider)
        .requireValue;
    expect(wizardState.hasRevisionConflict, true);
    expect(wizardState.hasUnsavedChanges, true);
    verify(
      () => mockRepo.updateCourse('course_123', {
        'title': 'Rascunho local',
        'expected_authoring_revision': 7,
      }),
    ).called(1);

    expect(await controller.refreshAfterRevisionConflict(), true);
    wizardState = container.read(courseWizardControllerProvider).requireValue;
    expect(wizardState.course!.authoringRevision, 9);
    expect(wizardState.hasRevisionConflict, false);
    expect(wizardState.hasUnsavedChanges, true);

    await controller.flushPendingAutosave();
    wizardState = container.read(courseWizardControllerProvider).requireValue;
    expect(wizardState.course!.authoringRevision, 10);
    expect(wizardState.hasUnsavedChanges, false);
    verify(
      () => mockRepo.updateCourse('course_123', {
        'title': 'Rascunho local',
        'expected_authoring_revision': 9,
      }),
    ).called(1);
  });

  test(
    'critical teacher flow propagates stable keys and publishes only once',
    () async {
      final controller = container.read(
        courseWizardControllerProvider.notifier,
      );
      controller.init(null);
      await Future.microtask(() {});

      const module = Module(
        id: 'module_1',
        courseId: 'course_123',
        title: 'Module',
        orderIndex: 0,
        lessons: [],
      );
      const lesson = Lesson(
        id: 'lesson_1',
        moduleId: 'module_1',
        courseId: 'course_123',
        title: 'Lesson',
        status: 'ready',
        durationSeconds: 60,
        aiSummary: AISummary(
          title: '',
          executiveSummary: '',
          keyTakeaways: [],
          stepByStepExecution: [],
          technicalGlossary: [],
        ),
      );
      const block = LessonBlock(
        id: 'block_1',
        lessonId: 'lesson_1',
        courseId: 'course_123',
        blockType: 'text',
        content: {'text': 'Content'},
      );
      final courseWithLesson = _courseWith(
        modules: [
          const Module(
            id: 'module_1',
            courseId: 'course_123',
            title: 'Module',
            orderIndex: 0,
            lessons: [lesson],
          ),
        ],
      );
      final courseWithBlock = _courseWith(
        modules: [
          const Module(
            id: 'module_1',
            courseId: 'course_123',
            title: 'Module',
            orderIndex: 0,
            lessons: [
              Lesson(
                id: 'lesson_1',
                moduleId: 'module_1',
                courseId: 'course_123',
                title: 'Lesson',
                status: 'ready',
                durationSeconds: 60,
                aiSummary: AISummary(
                  title: '',
                  executiveSummary: '',
                  keyTakeaways: [],
                  stepByStepExecution: [],
                  technicalGlossary: [],
                ),
                blocks: [block],
              ),
            ],
          ),
        ],
      );

      final keys = <String, List<String>>{};
      void capture(String operation, Invocation invocation) {
        keys
            .putIfAbsent(operation, () => [])
            .add(invocation.namedArguments[#idempotencyKey] as String);
      }

      when(
        () => mockRepo.createCourse(
          any(),
          idempotencyKey: any(named: 'idempotencyKey'),
        ),
      ).thenAnswer((invocation) async {
        capture('course', invocation);
        return _course();
      });
      when(
        () => mockRepo.createModule(
          'course_123',
          any(),
          idempotencyKey: any(named: 'idempotencyKey'),
        ),
      ).thenAnswer((invocation) async {
        capture('module', invocation);
        return module;
      });
      when(
        () => mockRepo.createLesson(
          'course_123',
          'module_1',
          any(),
          idempotencyKey: any(named: 'idempotencyKey'),
        ),
      ).thenAnswer((invocation) async {
        capture('lesson', invocation);
        return lesson;
      });
      var refreshes = 0;
      when(() => mockRepo.getTeacherCourse('course_123')).thenAnswer((_) async {
        refreshes += 1;
        return refreshes == 1 ? courseWithLesson : courseWithBlock;
      });
      var blockAttempts = 0;
      when(
        () => mockRepo.createLessonBlock(
          'course_123',
          'lesson_1',
          any(),
          idempotencyKey: any(named: 'idempotencyKey'),
        ),
      ).thenAnswer((invocation) async {
        capture('block', invocation);
        if (blockAttempts++ == 0) throw Exception('timeout');
        return block;
      });
      final publishCompletion = Completer<Course>();
      when(
        () => mockRepo.publishCourse(
          'course_123',
          idempotencyKey: any(named: 'idempotencyKey'),
        ),
      ).thenAnswer((invocation) {
        capture('publish', invocation);
        return publishCompletion.future;
      });

      expect(await controller.saveDraft({'title': 'Course'}), true);
      expect(
        await controller.addModule({'title': 'Module', 'order_index': 0}),
        true,
      );
      expect(
        await controller.addLesson(
          moduleId: 'module_1',
          lessonData: {'title': 'Lesson', 'order_index': 0},
        ),
        true,
      );
      final blockPayload = {
        'block_type': 'text',
        'content': {'text': 'Content'},
      };
      expect(await controller.saveLessonBlock('lesson_1', blockPayload), false);
      expect(await controller.saveLessonBlock('lesson_1', blockPayload), true);

      final firstPublish = controller.publishCourse();
      final duplicatePublish = controller.publishCourse();
      publishCompletion.complete(
        _courseWith(status: 'published', modules: courseWithBlock.modules),
      );
      expect(await firstPublish, true);
      expect(await duplicatePublish, false);

      expect(keys['course'], hasLength(1));
      expect(keys['module'], hasLength(1));
      expect(keys['lesson'], hasLength(1));
      expect(keys['block'], hasLength(2));
      expect(keys['block']![1], keys['block']![0]);
      expect(keys['publish'], hasLength(1));
      for (final operationKeys in keys.values) {
        expect(operationKeys.every((key) => key.isNotEmpty), true);
      }
      verify(
        () => mockRepo.publishCourse(
          'course_123',
          idempotencyKey: any(named: 'idempotencyKey'),
        ),
      ).called(1);
    },
  );

  test('intermediate video stages keep status polling active', () {
    for (final status in const [
      'validating',
      'transcoding',
      'generating_hls',
      'generating_thumbnail',
    ]) {
      expect(
        courseHasActiveVideoProcessing(
          _courseWith(
            modules: [
              _moduleWithLesson(title: 'Processamento', videoJobStatus: status),
            ],
          ),
        ),
        isTrue,
        reason: '$status must not stop polling',
      );
    }

    expect(
      courseHasActiveVideoProcessing(
        _courseWith(
          modules: [
            _moduleWithLesson(
              title: 'Falha terminal',
              videoJobStatus: 'dead_letter',
            ),
          ],
        ),
      ),
      isFalse,
    );
  });

  test('activity save forwards and preserves correct alternative', () async {
    when(
      () => mockRepo.getTeacherCourse('course_123'),
    ).thenAnswer((_) async => _course());
    final controller = container.read(courseWizardControllerProvider.notifier);
    controller.init('course_123');
    await Future<void>.delayed(Duration.zero);

    final payload = <String, dynamic>{
      'block_type': 'activity',
      'content': <String, dynamic>{
        'question': 'Qual opção está correta?',
        'activity_type': 'single_choice',
        'items': <String>['A', 'B', 'C'],
        'correct_index': 1,
      },
    };
    when(
      () => mockRepo.updateLessonBlock(
        'course_123',
        'lesson_1',
        'block_1',
        any(),
      ),
    ).thenAnswer(
      (_) async => const LessonBlock(
        id: 'block_1',
        lessonId: 'lesson_1',
        courseId: 'course_123',
        blockType: 'activity',
        content: {'correct_index': 1},
      ),
    );

    expect(
      await controller.saveLessonBlock(
        'lesson_1',
        payload,
        blockId: 'block_1',
      ),
      isTrue,
    );
    final captured = verify(
      () => mockRepo.updateLessonBlock(
        'course_123',
        'lesson_1',
        'block_1',
        captureAny(),
      ),
    ).captured.single as Map<String, dynamic>;
    expect(
      (captured['content'] as Map<String, dynamic>)['correct_index'],
      1,
    );
  });
}

Course _course({int authoringRevision = 0}) => Course(
  id: 'course_123',
  instructorId: 'prof',
  title: 'Title',
  slug: 'slug',
  category: 'cat',
  level: 'level',
  summary: 'sum',
  status: 'draft',
  authoringRevision: authoringRevision,
  modules: [],
);

Course _courseWith({
  String status = 'draft',
  List<Module> modules = const [],
}) => Course(
  id: 'course_123',
  instructorId: 'prof',
  title: 'Title',
  slug: 'slug',
  category: 'cat',
  level: 'level',
  summary: 'sum',
  status: status,
  modules: modules,
);

Module _moduleWithLesson({
  required String title,
  String videoJobStatus = 'processing',
}) => Module(
  id: 'module_1',
  courseId: 'course_123',
  title: 'Module',
  orderIndex: 0,
  lessons: [_lesson(title: title, videoJobStatus: videoJobStatus)],
);

Lesson _lesson({required String title, String videoJobStatus = 'processing'}) =>
    Lesson(
      id: 'lesson_1',
      moduleId: 'module_1',
      courseId: 'course_123',
      title: title,
      status: 'processing',
      durationSeconds: 0,
      videoJobStatus: videoJobStatus,
      aiSummary: const AISummary(
        title: '',
        executiveSummary: '',
        keyTakeaways: [],
        stepByStepExecution: [],
        technicalGlossary: [],
      ),
    );
