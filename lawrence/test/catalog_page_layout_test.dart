import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lawrence/features/courses/presentation/pages/catalog_page.dart';
import 'package:lawrence/features/courses/domain/repositories/course_repository_interface.dart';
import 'package:lawrence/features/courses/domain/entities/course.dart';
import 'package:lawrence/app/providers/learning_repositories.dart';
import 'package:go_router/go_router.dart';

class MockCourseRepository implements ICourseRepository {
  final List<Course> courses;
  MockCourseRepository(this.courses);

  @override
  Future<List<Course>> fetchPublishedCourses() async => courses;

  @override
  Future<Course?> fetchCourseDetails(String courseId) async => null;

  @override
  Future<Course?> fetchCourseBySlug(String slug) async => null;
}

void main() {
  testWidgets(
    'CatalogPage layouts successfully inside a Scrollable parent (PublicLayout context)',
    (WidgetTester tester) async {
      final mockCourses = <Course>[
        Course(
          id: '1',
          instructorId: 'teacher-1',
          title: 'Curso de Costura 1',
          slug: 'curso-costura-1',
          category: 'costura',
          level: 'iniciante',
          summary: 'Resumo 1',
          status: 'published',
          modules: const [],
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            courseRepositoryProvider.overrideWithValue(
              MockCourseRepository(mockCourses),
            ),
          ],
          child: MaterialApp(
            home: SingleChildScrollView(
              child: Column(
                children: const [CatalogPage(embeddedInScrollView: true)],
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify it rendered successfully without errors
      expect(find.byType(CatalogPage), findsOneWidget);
      expect(find.text('Curso de Costura 1'), findsOneWidget);
    },
  );

  testWidgets(
    'CatalogPage layouts successfully inside a non-scrollable parent (StudentLayout context)',
    (WidgetTester tester) async {
      final mockCourses = <Course>[
        Course(
          id: '1',
          instructorId: 'teacher-1',
          title: 'Curso de Costura 1',
          slug: 'curso-costura-1',
          category: 'costura',
          level: 'iniciante',
          summary: 'Resumo 1',
          status: 'published',
          modules: const [],
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            courseRepositoryProvider.overrideWithValue(
              MockCourseRepository(mockCourses),
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Column(children: const [Expanded(child: CatalogPage())]),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(CatalogPage), findsOneWidget);
      expect(find.text('Curso de Costura 1'), findsOneWidget);
    },
  );

  testWidgets(
    'restores URL filters after the first frame without changing provider during build',
    (WidgetTester tester) async {
      final mockCourses = <Course>[
        Course(
          id: '1',
          instructorId: 'teacher-1',
          title: 'Curso de Costura',
          slug: 'curso-costura',
          category: 'costura',
          level: 'iniciante',
          summary: 'Aprenda costura',
          status: 'published',
          modules: const [],
        ),
        Course(
          id: '2',
          instructorId: 'teacher-1',
          title: 'Curso de Modelagem',
          slug: 'curso-modelagem',
          category: 'modelagem',
          level: 'intermediario',
          summary: 'Aprenda modelagem',
          status: 'published',
          modules: const [],
        ),
      ];
      final router = GoRouter(
        initialLocation: '/courses?q=modelagem&category=modelagem',
        routes: [
          GoRoute(path: '/courses', builder: (_, _) => const CatalogPage()),
        ],
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            courseRepositoryProvider.overrideWithValue(
              MockCourseRepository(mockCourses),
            ),
          ],
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Curso de Modelagem'), findsOneWidget);
      expect(find.text('Curso de Costura'), findsNothing);
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller?.text,
        'modelagem',
      );
    },
  );
}
