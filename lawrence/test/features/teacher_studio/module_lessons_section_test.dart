import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lawrence/features/courses/domain/entities/course.dart';
import 'package:lawrence/features/teacher_studio/presentation/pages/components/module_lessons_section.dart';

void main() {
  testWidgets('renders each lesson separately inside its module', (
    tester,
  ) async {
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
          id: 'lesson-2',
          moduleId: 'module-1',
          courseId: 'course-1',
          title: 'Aula 02 — Materiais',
          status: 'published',
          durationSeconds: 0,
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
            onReplaceVideo: (_) {},
            onDeleteLesson: (_) {},
            onEditModule: () {},
            onDeleteModule: () {},
          ),
        ),
      ),
    );

    expect(find.text('Aula 01 — Introdução'), findsOneWidget);
    expect(find.text('Aula 02 — Materiais'), findsOneWidget);
    expect(find.text('2 aulas'), findsOneWidget);
    expect(find.text('Adicionar outra aula'), findsOneWidget);
  });
}
