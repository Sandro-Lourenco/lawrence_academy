import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:lawrence/app/providers/learning_repositories.dart';
import 'package:lawrence/features/courses/domain/entities/course.dart';
import 'package:lawrence/features/courses/domain/repositories/course_repository_interface.dart';
import 'package:lawrence/features/courses/presentation/pages/public_catalog_page.dart';

class _CatalogRepository implements ICourseRepository {
  const _CatalogRepository(this.courses);

  final List<Course> courses;

  @override
  Future<List<Course>> fetchPublishedCourses() async => courses;

  @override
  Future<Course?> fetchCourseBySlug(String slug) async => null;

  @override
  Future<Course?> fetchCourseDetails(String courseId) async => null;
}

void main() {
  final courses = [
    const Course(
      id: 'costura-1',
      instructorId: 'teacher-1',
      title: 'Costura Clássica',
      slug: 'costura-classica',
      category: 'costura',
      level: 'iniciante',
      summary: 'Domine fundamentos e acabamentos precisos.',
      status: 'published',
      isFeatured: true,
      monthlyPrice: 89,
      modules: [],
    ),
    const Course(
      id: 'modelagem-1',
      instructorId: 'teacher-1',
      title: 'Modelagem Essencial',
      slug: 'modelagem-essencial',
      category: 'modelagem',
      level: 'intermediario',
      summary: 'Transforme medidas em moldes com segurança.',
      status: 'published',
      modules: [],
    ),
  ];

  testWidgets('renders editorial courses and future digital library', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          courseRepositoryProvider.overrideWithValue(
            _CatalogRepository(courses),
          ),
        ],
        child: const MaterialApp(home: PublicCatalogPage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Técnica para vestir a sua assinatura.'), findsOneWidget);
    expect(find.text('Costura Clássica'), findsWidgets);
    expect(find.text('Todos os cursos'), findsOneWidget);
    expect(find.text('BIBLIOTECA DIGITAL · EM PREPARAÇÃO'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('restores search from the URL and filters courses', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(900, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final router = GoRouter(
      initialLocation: '/courses?q=modelagem',
      routes: [
        GoRoute(path: '/courses', builder: (_, _) => const PublicCatalogPage()),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          courseRepositoryProvider.overrideWithValue(
            _CatalogRepository(courses),
          ),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Modelagem Essencial'), findsOneWidget);
    expect(find.text('Costura Clássica'), findsNothing);
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller?.text,
      'modelagem',
    );
    expect(tester.takeException(), isNull);
  });
}
