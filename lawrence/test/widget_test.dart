import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lawrence/app/router/app_router.dart';
import 'package:lawrence/app/app.dart';

void main() {
  testWidgets('App initialization smoke test', (WidgetTester tester) async {
    final mockRouter = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const Scaffold(body: Text('Mock Home')),
        ),
      ],
    );

    // Carrega o widget principal envolto no ProviderScope do Riverpod com overrides
    await tester.pumpWidget(
      ProviderScope(
        overrides: [routerProvider.overrideWithValue(mockRouter)],
        child: const LawrenceAcademyApp(),
      ),
    );

    // Verifica que o widget foi construído com sucesso
    expect(find.byType(LawrenceAcademyApp), findsOneWidget);
  });
}
