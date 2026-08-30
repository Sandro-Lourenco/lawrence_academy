import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lawrence/features/courses/domain/entities/course.dart';
import 'package:lawrence/features/teacher_studio/presentation/pages/components/module_lessons_section.dart';

void main() {
  testWidgets('renders each lesson separately inside its module', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1000, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    var retriedLessonId = '';
    final module = Module(
      id: 'module-1',
      courseId: 'course-1',
      title: 'Fundamentos',
      orderIndex: 0,
      lessons: const [
        Lesson(
          id: 'lesson-1',
          moduleId: 'module-1',
          courseId: 'course-1',
          title: 'Aula 01 — Introdução',
          status: 'draft',
          videoJobStatus: 'processing',
          durationSeconds: 0,
          aiSummary: AISummary(
            title: '',
            executiveSummary: '',
            keyTakeaways: [],
            stepByStepExecution: [],
            technicalGlossary: [],
          ),
        ),
        Lesson(
          id: 'lesson-4',
          moduleId: 'module-1',
          courseId: 'course-1',
          title: 'Aula 04 — Referência externa',
          status: 'draft',
          videoSourceType: 'youtube',
          durationSeconds: 600,
          aiSummary: AISummary(
            title: '',
            executiveSummary: '',
            keyTakeaways: [],
            stepByStepExecution: [],
            technicalGlossary: [],
          ),
        ),
        Lesson(
          id: 'lesson-2',
          moduleId: 'module-1',
          courseId: 'course-1',
          title: 'Aula 02 — Materiais',
          status: 'published',
          hlsStoragePath: 'lessons/lesson-2/master.m3u8',
          durationSeconds: 0,
          aiSummary: AISummary(
            title: '',
            executiveSummary: '',
            keyTakeaways: [],
            stepByStepExecution: [],
            technicalGlossary: [],
          ),
        ),
        Lesson(
          id: 'lesson-3',
          moduleId: 'module-1',
          courseId: 'course-1',
          title: 'Aula 03 — Acabamento',
          status: 'draft',
          videoJobStatus: 'dead_letter',
          durationSeconds: 0,
          aiSummary: AISummary(
            title: '',
            executiveSummary: '',
            keyTakeaways: [],
            stepByStepExecution: [],
            technicalGlossary: [],
          ),
        ),
        Lesson(
          id: 'lesson-5',
          moduleId: 'module-1',
          courseId: 'course-1',
          title: 'Aula 05 — Substituição segura',
          status: 'draft',
          videoSourceType: 'youtube',
          videoJobStatus: 'transcoding',
          durationSeconds: 420,
          aiSummary: AISummary(
            title: '',
            executiveSummary: '',
            keyTakeaways: [],
            stepByStepExecution: [],
            technicalGlossary: [],
          ),
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ModuleLessonsSection(
            module: module,
            isBusy: false,
            onAddLesson: () {},
            onEditLesson: (_) {},
            onEditLessonContent: (_) {},
            onReplaceVideo: (lesson) => retriedLessonId = lesson.id,
            onDeleteLesson: (_) {},
            onEditModule: () {},
            onDeleteModule: () {},
            onMoveModuleUp: () {},
            onMoveModuleDown: () {},
            canMoveModuleUp: true,
            canMoveModuleDown: true,
            onMoveLessonUp: (_) {},
            onMoveLessonDown: (_) {},
            onMoveLessonToModule: (_) {},
            onReorderLessons: (_, _) {},
          ),
        ),
      ),
    );

    expect(find.text('Aula 01 — Introdução'), findsOneWidget);
    expect(find.text('Aula 02 — Materiais'), findsOneWidget);
    expect(find.textContaining('5 aulas'), findsOneWidget);
    expect(find.text('Processando vídeo'), findsOneWidget);
    expect(find.text('Vídeo pronto'), findsOneWidget);
    expect(find.text('Falha — envie novamente'), findsOneWidget);
    expect(find.text('Link do YouTube'), findsOneWidget);
    expect(
      find.text('Novo upload processando · link atual mantido'),
      findsOneWidget,
    );
    expect(find.text('Enviar vídeo novamente'), findsOneWidget);
    expect(find.text('Adicionar outra aula'), findsOneWidget);

    await tester.tap(find.text('Enviar vídeo novamente'));
    await tester.pump();
    expect(retriedLessonId, 'lesson-3');
  });
}
