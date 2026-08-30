import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:lawrence/design_system/layouts/public_layout.dart';
import 'package:lawrence/design_system/tokens/lawrence_theme.dart';
import 'package:lawrence/features/auth/presentation/controllers/auth_controller.dart';
import 'package:lawrence/features/courses/domain/entities/course.dart';
import 'package:lawrence/features/courses/presentation/pages/public_course_detail_page.dart';
import 'package:lawrence/features/courses/presentation/providers/course_detail_provider.dart';

class _AnonymousAuthNotifier extends AuthNotifier {
  @override
  AuthNotifierState build() => AuthNotifierState();
}

void main() {
  const course = Course(
    id: 'course-1',
    instructorId: 'teacher-1',
    title: 'Modelagem profissional',
    slug: 'modelagem-profissional',
    category: 'Modelagem',
    level: 'intermediário',
    summary: 'Aprenda a construir bases e interpretar modelos.',
    description:
        'Uma formação prática para transformar medidas em moldes consistentes.',
    estimatedDurationMinutes: 510,
    learningObjectives: [
      'Construir uma base de modelagem',
      'Interpretar diferentes modelos',
    ],
    targetAudience: ['Estudantes e profissionais de moda'],
    requirements: ['Conhecimentos básicos de costura'],
    requiredMaterials: ['Papel, régua e fita métrica'],
    status: 'published',
    modules: [
      Module(
        id: 'module-1',
        courseId: 'course-1',
        title: 'Fundamentos',
        orderIndex: 0,
        lessons: [
          Lesson(
            id: 'lesson-1',
            moduleId: 'module-1',
            courseId: 'course-1',
            title: 'Medidas e proporções',
            status: 'published',
            durationSeconds: 1200,
            aiSummary: AISummary(
              title: '',
              executiveSummary: '',
              keyTakeaways: [],
              stepByStepExecution: [],
              technicalGlossary: [],
            ),
          ),
        ],
      ),
    ],
  );

  Widget pageAt(Size size) {
    return ProviderScope(
      overrides: [
        authNotifierProvider.overrideWith(_AnonymousAuthNotifier.new),
        courseDetailBySlugProvider.overrideWith((ref, slug) async => course),
      ],
      child: MaterialApp(
        theme: LawrenceTheme.lightTheme,
        home: MediaQuery(
          data: MediaQueryData(size: size),
          child: const Scaffold(
            body: PublicCourseDetailPage(slug: 'modelagem-profissional'),
          ),
        ),
      ),
    );
  }

  testWidgets('renders only real course facts and conversion sections', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1280, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(pageAt(const Size(1280, 900)));
    await tester.pumpAndSettle();

    expect(find.text('Modelagem profissional'), findsOneWidget);
    expect(find.text('8h 30min'), findsOneWidget);
    expect(find.text('O QUE VOCÊ LEVA'), findsOneWidget);
    expect(find.text('Para quem é'), findsOneWidget);
    expect(find.text('O que você precisa'), findsOneWidget);
    expect(find.text('PROGRAMA DO CURSO'), findsOneWidget);
    expect(find.text('FILME DE APRESENTAÇÃO · CADERNO 02'), findsOneWidget);
    expect(find.text('TRAILER EM PREPARAÇÃO'), findsOneWidget);
    expect(find.text('PERGUNTAS FREQUENTES'), findsOneWidget);
    expect(find.text('Entrar para acessar'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('keeps the course page usable on a phone', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(pageAt(const Size(390, 844)));
    await tester.pumpAndSettle();

    expect(find.text('Modelagem profissional'), findsOneWidget);
    expect(find.text('Entrar para acessar'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('owns scroll and reaches content below the fold', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1280, 600));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(pageAt(const Size(1280, 600)));
    await tester.pumpAndSettle();

    final scroll = find.byKey(
      const PageStorageKey<String>('public-course-detail'),
    );
    expect(scroll, findsOneWidget);
    final titleBefore = tester
        .getTopLeft(find.text('Modelagem profissional'))
        .dy;
    await tester.drag(scroll, const Offset(0, -500));
    await tester.pumpAndSettle();
    final titleAfter = tester
        .getTopLeft(find.text('Modelagem profissional'))
        .dy;

    expect(titleAfter, lessThan(titleBefore));
    final scrollableState = tester.state<ScrollableState>(
      find.descendant(of: scroll, matching: find.byType(Scrollable)),
    );
    expect(scrollableState.position.pixels, greaterThan(0));
    expect(tester.takeException(), isNull);
  });

  testWidgets('public header hides desktop navigation on a phone', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => const PublicLayout(child: SizedBox(height: 100)),
        ),
        GoRoute(
          path: '/courses',
          builder: (_, _) => const Scaffold(body: Text('Catálogo')),
        ),
      ],
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authNotifierProvider.overrideWith(_AnonymousAuthNotifier.new),
        ],
        child: MaterialApp.router(
          theme: LawrenceTheme.lightTheme,
          routerConfig: router,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(size: const Size(390, 844)),
            child: child!,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('CURSOS').hitTestable(), findsNothing);
    expect(find.byTooltip('Abrir menu'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('public header keeps catalog navigation visible on desktop', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1280, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => const PublicLayout(child: SizedBox(height: 100)),
        ),
        GoRoute(
          path: '/courses',
          builder: (_, _) => const Scaffold(body: Text('Catálogo')),
        ),
      ],
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authNotifierProvider.overrideWith(_AnonymousAuthNotifier.new),
        ],
        child: MaterialApp.router(
          theme: LawrenceTheme.lightTheme,
          routerConfig: router,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(size: const Size(1280, 900)),
            child: child!,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('CURSOS').hitTestable(), findsOneWidget);
    expect(find.text('ENTRAR'), findsOneWidget);
    expect(find.byTooltip('Abrir menu'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
