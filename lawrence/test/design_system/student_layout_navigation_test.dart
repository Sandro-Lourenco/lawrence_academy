import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:lawrence/design_system/layouts/student_layout.dart';

void main() {
  Widget buildApp({required Size size}) {
    final router = GoRouter(
      initialLocation: '/dashboard/home',
      routes: [
        ShellRoute(
          builder: (context, state, child) => StudentLayout(body: child),
          routes: [
            for (final path in [
              '/dashboard/home',
              '/dashboard/courses',
              '/dashboard/projects',
              '/dashboard/achievements',
              '/dashboard/profile',
              '/dashboard/settings',
            ])
              GoRoute(
                path: path,
                builder: (context, state) => const Scaffold(
                  body: Center(child: Text('Conteúdo')),
                ),
              ),
          ],
        ),
      ],
    );

    return MediaQuery(
      data: MediaQueryData(size: size),
      child: MaterialApp.router(routerConfig: router),
    );
  }

  testWidgets('mobile mostra cinco destinos principais', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(buildApp(size: const Size(390, 844)));
    await tester.pumpAndSettle();

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('Início'), findsOneWidget);
    expect(find.text('Cursos'), findsOneWidget);
    expect(find.text('Projetos'), findsOneWidget);
    expect(find.text('Conquistas'), findsOneWidget);
    expect(find.text('Perfil'), findsOneWidget);
  });

  testWidgets('tablet usa navigation rail', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1024));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(buildApp(size: const Size(800, 1024)));
    await tester.pumpAndSettle();

    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
  });

  testWidgets('desktop usa sidebar e configurações válidas', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1440, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(buildApp(size: const Size(1440, 900)));
    await tester.pumpAndSettle();

    expect(find.text('LAWRENCE\nACADEMY'), findsOneWidget);
    expect(find.text('Configurações'), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
  });
}
