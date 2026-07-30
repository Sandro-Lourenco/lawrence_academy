import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lawrence/features/courses/domain/entities/course.dart';
import 'package:lawrence/features/teacher_studio/presentation/pages/components/course_media_form.dart';

void main() {
  testWidgets('shows persisted cover and ready trailer validation', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: CourseMediaForm(
              course: _course(
                coverImagePath: 'courses/course-1/cover.webp',
                trailerStatus: 'ready',
              ),
              isUploading: false,
              onUpload: (_, _, _, _) async => true,
              onBack: () {},
              onContinue: () {},
            ),
          ),
        ),
      ),
    );

    expect(find.text('Capa salva'), findsOneWidget);
    expect(find.text('Trailer pronto'), findsOneWidget);
    expect(
      find.textContaining('pronto para a publicação'),
      findsOneWidget,
    );
  });

  testWidgets('shows trailer failure without falling back to empty state', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: CourseMediaForm(
              course: _course(trailerStatus: 'dead_letter'),
              isUploading: false,
              onUpload: (_, _, _, _) async => true,
              onBack: () {},
              onContinue: () {},
            ),
          ),
        ),
      ),
    );

    expect(find.text('Falha no trailer'), findsOneWidget);
    expect(find.textContaining('envio'), findsOneWidget);
    expect(find.text('Prévia do trailer'), findsNothing);
  });

  testWidgets('shows an explicit processing status', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: CourseMediaForm(
              course: _course(trailerStatus: 'processing'),
              isUploading: false,
              onUpload: (_, _, _, _) async => true,
              onBack: () {},
              onContinue: () {},
            ),
          ),
        ),
      ),
    );

    expect(find.text('Trailer em processamento'), findsOneWidget);
    expect(find.textContaining('automaticamente'), findsOneWidget);
  });
}

Course _course({
  String? coverImagePath,
  String trailerStatus = 'empty',
}) => Course(
  id: 'course-1',
  instructorId: 'teacher-1',
  title: 'Modelagem',
  slug: 'modelagem',
  category: 'modelagem',
  level: 'iniciante',
  summary: 'Curso',
  status: 'draft',
  coverImagePath: coverImagePath,
  trailerStatus: trailerStatus,
  modules: const [],
);
