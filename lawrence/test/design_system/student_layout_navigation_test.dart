import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:lawrence/design_system/layouts/student_layout.dart';

void main() {
  Widget buildApp(
    Size size, {
    TextScaler textScaler = TextScaler.noScaling,
    bool highContrast = false,
  }) {
    final router = GoRouter(
      initialLocation: '/dashboard/home',
      routes: [
        ShellRoute(
          builder: (context, state, child) => StudentLayout(body: child),
          routes: [
            for (final path in [
              '/dashboard/home',
              '/dashboard/courses',
              '/dashboard/profile',
            ])
              GoRoute(
                path: path,
                builder: (context, state) =>
                    const Scaffold(body: Center(child: Text('Conteúdo'))),
              ),
          ],
        ),
      ],
    );
    return ProviderScope(
      child: MediaQuery(
        data: MediaQueryData(
          size: size,
          textScaler: textScaler,
          highContrast: highContrast,
        ),
        child: MaterialApp.router(routerConfig: router),
      ),
    );
  }

  testWidgets('mobile mostra somente os três destinos principais', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(buildApp(const Size(390, 844)));
    await tester.pumpAndSettle();
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('Cursos'), findsOneWidget);
    expect(find.text('Perfil'), findsOneWidget);
    expect(find.text('Projetos'), findsNothing);
    expect(find.text('Agenda'), findsNothing);
  });

  testWidgets('mobile estreito suporta texto ampliado sem overflow', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 700));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      buildApp(
        const Size(320, 700),
        textScaler: const TextScaler.linear(1.3),
        highContrast: true,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('Projetos'), findsNothing);
    expect(find.text('Agenda'), findsNothing);
    expect(tester.takeException(), isNull);
    final navigationBar = tester.widget<NavigationBar>(
      find.byType(NavigationBar),
    );
    expect(navigationBar.height, greaterThanOrEqualTo(44));
  });

  testWidgets('tablet usa navegação compacta', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1024));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(buildApp(const Size(800, 1024)));
    await tester.pumpAndSettle();
    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
  });

  testWidgets('desktop usa navbar superior e menu de perfil', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1440, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(buildApp(const Size(1440, 900)));
    await tester.pumpAndSettle();
    expect(find.text('LAWRENCE'), findsOneWidget);
    expect(find.text('ACADEMY'), findsOneWidget);
    expect(find.byTooltip('Abrir menu da conta'), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
  });
}
