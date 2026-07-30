import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lawrence/features/courses/presentation/pages/catalog_page.dart';
import 'package:lawrence/features/courses/domain/repositories/course_repository_interface.dart';
import 'package:lawrence/features/courses/domain/entities/course.dart';
import 'package:lawrence/app/providers/learning_repositories.dart';

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
  testWidgets('CatalogPage layouts successfully inside a Scrollable parent (PublicLayout context)', (WidgetTester tester) async {
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
          courseRepositoryProvider.overrideWithValue(MockCourseRepository(mockCourses)),
        ],
        child: MaterialApp(
          home: SingleChildScrollView(
            child: Column(
              children: const [
                CatalogPage(),
              ],
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify it rendered successfully without errors
    expect(find.byType(CatalogPage), findsOneWidget);
    expect(find.text('Curso de Costura 1'), findsOneWidget);
  });

  testWidgets('CatalogPage layouts successfully inside a non-scrollable parent (StudentLayout context)', (WidgetTester tester) async {
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
          courseRepositoryProvider.overrideWithValue(MockCourseRepository(mockCourses)),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: Column(
              children: const [
                Expanded(
                  child: CatalogPage(),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(CatalogPage), findsOneWidget);
    expect(find.text('Curso de Costura 1'), findsOneWidget);
  });
}
