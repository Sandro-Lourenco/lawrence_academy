import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lawrence/features/lessons/domain/entities/lesson_entity.dart';
import 'package:lawrence/features/player/presentation/controllers/lesson_navigation_presentation.dart';
import 'package:lawrence/features/player/presentation/widgets/learning_workspace.dart';

void main() {
  final lesson = LessonEntity(
    id: 'lesson-1',
    moduleId: 'module-1',
    courseId: 'course-1',
    title: 'Introdução à modelagem',
    description: 'Objetivos da aula',
    orderIndex: 0,
    durationSeconds: 600,
    hlsStoragePath: 'protected/path',
    status: 'published',
    blocks: const [
      {
        'id': 'activity-1',
        'block_type': 'activity',
        'order_index': 0,
        'content': {
          'question': 'Qual é o primeiro passo?',
          'items': ['Medir', 'Cortar'],
        },
      },
      {
        'id': 'more-1',
        'block_type': 'summary',
        'order_index': 1,
        'content': {'title': 'Resumo', 'text': 'Revise as medidas.'},
      },
    ],
  );

  testWidgets('separa assistir, atividades e saber mais', (tester) async {
    tester.view.physicalSize = const Size(1440, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: LearningWorkspace(
          title: lesson.title,
          lesson: lesson,
          lessons: [lesson],
          navigation: const LessonNavigation(previous: null, next: null),
          progressPercentage: 30,
          player: const ColoredBox(color: Colors.black),
          onBack: () {},
          onOpenLesson: (_) async {},
          onOpenActivities: () {},
        ),
      ),
    );

    expect(find.text('AULA ATUAL'), findsOneWidget);

    await tester.tap(find.text('Atividades'));
    await tester.pumpAndSettle();
    expect(find.text('PRÁTICA GUIADA'), findsOneWidget);
    expect(find.text('Qual é o primeiro passo?'), findsWidgets);

    await tester.tap(find.text('Saber mais'));
    await tester.pumpAndSettle();
    expect(find.text('APROFUNDE O OLHAR'), findsOneWidget);
    expect(find.text('Resumo'), findsWidgets);
  });
}
