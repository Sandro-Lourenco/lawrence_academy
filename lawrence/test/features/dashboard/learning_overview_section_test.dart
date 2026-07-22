import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lawrence/features/courses/domain/entities/course.dart';
import 'package:lawrence/features/dashboard/presentation/widgets/learning_overview_section.dart';
import 'package:lawrence/features/lesson_progress/domain/entities/lesson_progress_entity.dart';

void main() {
  testWidgets('resume dados reais de progresso com semântica acessível', (
    tester,
  ) async {
    const lessons = [
      Lesson(
        id: 'lesson-1',
        moduleId: 'module-1',
        courseId: 'course-1',
        title: 'Introdução',
        status: 'published',
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
        title: 'Prática',
        status: 'published',
        durationSeconds: 900,
        aiSummary: AISummary(
          title: '',
          executiveSummary: '',
          keyTakeaways: [],
          stepByStepExecution: [],
          technicalGlossary: [],
        ),
      ),
    ];
    const course = Course(
      id: 'course-1',
      instructorId: 'teacher-1',
      title: 'Modelagem',
      slug: 'modelagem',
      category: 'modelagem',
      level: 'iniciante',
      summary: 'Curso',
      status: 'published',
      modules: [
        Module(
          id: 'module-1',
          courseId: 'course-1',
          title: 'Fundamentos',
          orderIndex: 0,
          lessons: lessons,
        ),
      ],
    );
    final progress = [
      LessonProgressEntity(
        courseId: 'course-1',
        lessonId: 'lesson-1',
        watchedSeconds: 600,
        progressPercentage: 100,
        completed: true,
      ),
      LessonProgressEntity(
        courseId: 'course-1',
        lessonId: 'lesson-2',
        watchedSeconds: 300,
        progressPercentage: 50,
        completed: false,
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LearningOverviewSection(
            courses: const [course],
            progress: progress,
          ),
        ),
      ),
    );

    expect(find.text('75%'), findsOneWidget);
    expect(find.text('15min'), findsOneWidget);
    expect(find.text('1', skipOffstage: false), findsNWidgets(2));
    expect(
      find.bySemanticsLabel(RegExp('Progresso geral 75 por cento')),
      findsOneWidget,
    );
  });
}
