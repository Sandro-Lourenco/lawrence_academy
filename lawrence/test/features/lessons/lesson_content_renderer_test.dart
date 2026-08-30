import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lawrence/features/lessons/presentation/widgets/lesson_content_renderer.dart';

void main() {
  testWidgets('renders structured lesson blocks in student order', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: LessonContentRenderer(
              isPreview: true,
              blocks: [
                LessonContentBlock(
                  id: 'activity',
                  type: 'activity',
                  orderIndex: 2,
                  content: {
                    'question': 'Qual medida vem primeiro?',
                    'items': ['Cintura', 'Quadril'],
                  },
                ),
                LessonContentBlock(
                  id: 'learn-more',
                  type: 'learn_more',
                  orderIndex: 1,
                  content: {
                    'title': 'Saiba mais sobre folgas',
                    'text': 'A folga varia conforme o tecido.',
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );

    expect(find.text('Saiba mais sobre folgas'), findsOneWidget);
    expect(find.text('Qual medida vem primeiro?'), findsOneWidget);
    expect(
      find.text('Modo de prévia: respostas e envios não são registrados.'),
      findsOneWidget,
    );

    await tester.tap(find.text('Saiba mais sobre folgas'));
    await tester.pumpAndSettle();
    expect(find.text('A folga varia conforme o tecido.'), findsOneWidget);
  });
}
