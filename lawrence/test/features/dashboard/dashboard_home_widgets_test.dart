import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:lawrence/features/courses/domain/entities/course.dart';
import 'package:lawrence/features/dashboard/presentation/widgets/continue_watching_section.dart';
import 'package:lawrence/features/dashboard/presentation/widgets/my_courses_section.dart';

void main() {
  const course = Course(
    id: 'course-1',
    instructorId: 'teacher-1',
    title: 'Costura para iniciantes',
    slug: 'costura-iniciantes',
    category: 'costura',
    level: 'iniciante',
    summary: 'Curso de costura',
    status: 'published',
    modules: [],
  );

  Widget app(Widget child) {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(path: '/', builder: (_, _) => Scaffold(body: child)),
        GoRoute(
          path: '/dashboard/courses',
          builder: (_, _) => const Scaffold(body: Text('Catálogo')),
        ),
        GoRoute(
          path: '/dashboard/courses/:courseId',
          builder: (_, _) => const Scaffold(body: Text('Curso')),
        ),
        GoRoute(
          path: '/dashboard/courses/:courseId/lessons/:lessonId',
          builder: (_, _) => const Scaffold(body: Text('Aula')),
        ),
      ],
    );
    return MaterialApp.router(routerConfig: router);
  }

  testWidgets('continuar aprendendo empilha conteúdo no mobile', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      app(
        const SingleChildScrollView(
          child: ContinueWatchingSection(
            course: course,
            progress: 40,
            nextLessonId: 'lesson-2',
          ),
        ),
      ),
    );

    expect(find.text('Continue aprendendo'), findsOneWidget);
    expect(find.text('40%'), findsOneWidget);
    expect(find.text('Continuar aula'), findsOneWidget);
    expect(find.byType(IntrinsicHeight), findsNothing);
  });

  testWidgets('estado vazio oferece descoberta de cursos', (tester) async {
    await tester.pumpWidget(
      app(const MyCoursesSection(courses: [], progressList: [])),
    );

    expect(find.text('Você ainda não possui cursos'), findsOneWidget);
    expect(find.text('Explorar cursos'), findsOneWidget);
  });
}

