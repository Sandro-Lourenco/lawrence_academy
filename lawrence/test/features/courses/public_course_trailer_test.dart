import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lawrence/features/courses/domain/entities/course.dart';
import 'package:lawrence/features/courses/presentation/widgets/public_detail/external_course_trailer.dart';
import 'package:lawrence/features/courses/presentation/widgets/public_detail/public_course_trailer.dart';

void main() {
  testWidgets('opens a normalized external course trailer', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1400, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: PublicCourseTrailer(
                course: const Course(
                  id: 'course-1',
                  instructorId: 'teacher-1',
                  title: 'Modelagem',
                  slug: 'modelagem',
                  category: 'modelagem',
                  level: 'iniciante',
                  summary: 'Curso com apresentação externa',
                  status: 'published',
                  trailerSourceType: 'youtube',
                  trailerExternalVideoId: 'dQw4w9WgXcQ',
                  trailerStatus: 'ready',
                  modules: [],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    final play = find.widgetWithIcon(IconButton, Icons.play_arrow_rounded);
    expect(play, findsOneWidget);
    expect(tester.widget<IconButton>(play).onPressed, isNotNull);

    await tester.tap(play);
    await tester.pump();

    expect(find.byType(ExternalCourseTrailer), findsOneWidget);
  });
}
