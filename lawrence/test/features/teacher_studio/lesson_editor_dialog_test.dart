import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lawrence/features/teacher_studio/presentation/pages/components/lesson_editor_dialog.dart';

void main() {
  testWidgets('teacher can choose upload or a trusted video link', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1000, 1100));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => FilledButton(
              onPressed: () =>
                  LessonEditorDialog.show(context, defaultOrder: 0),
              child: const Text('Abrir editor'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Abrir editor'));
    await tester.pumpAndSettle();

    expect(find.text('Enviar arquivo'), findsOneWidget);
    expect(find.text('Usar link'), findsOneWidget);
    expect(
      find.text(
        'MP4, MOV ou M4V • até 50 MB • processamento automático em HLS',
      ),
      findsOneWidget,
    );
    expect(find.text('Status da aula'), findsOneWidget);
    await tester.tap(find.text('Rascunho'));
    await tester.pumpAndSettle();
    expect(find.text('Pronta para publicar'), findsOneWidget);
  });

  testWidgets('teacher creates a lesson using a YouTube link', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1000, 1100));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    LessonEditorResult? result;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => FilledButton(
              onPressed: () async {
                result = await LessonEditorDialog.show(
                  context,
                  defaultOrder: 0,
                );
              },
              child: const Text('Abrir editor'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Abrir editor'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Título da aula'),
      'Introdução à modelagem',
    );
    await tester.tap(find.text('Usar link'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Duração estimada (minutos)'),
      '15',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Link do vídeo'),
      'https://youtu.be/dQw4w9WgXcQ',
    );
    await tester.ensureVisible(find.text('Criar aula'));
    await tester.tap(find.text('Criar aula'));
    await tester.pumpAndSettle();

    expect(result, isNotNull);
    expect(result!.videoUrl, 'https://youtu.be/dQw4w9WgXcQ');
    expect(result!.video, isNull);
    expect(result!.estimatedDurationMinutes, 15);
  });

  testWidgets('teacher sees an error for an untrusted video host', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1000, 1100));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => FilledButton(
              onPressed: () =>
                  LessonEditorDialog.show(context, defaultOrder: 0),
              child: const Text('Abrir editor'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Abrir editor'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Título da aula'),
      'Aula externa',
    );
    await tester.tap(find.text('Usar link'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Duração estimada (minutos)'),
      '10',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Link do vídeo'),
      'https://video.example/aula',
    );
    await tester.ensureVisible(find.text('Criar aula'));
    await tester.tap(find.text('Criar aula'));
    await tester.pump();

    expect(
      find.text('Use um link válido de vídeo do YouTube ou Vimeo'),
      findsOneWidget,
    );
  });
}
