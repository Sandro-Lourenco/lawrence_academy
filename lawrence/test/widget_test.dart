import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lawrence/app/router/app_router.dart';
import 'package:lawrence/app/app.dart';
import 'package:lawrence/features/auth/presentation/controllers/auth_controller.dart';

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

  testWidgets('usuário anônimo inicia no login em plataforma instalada', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authNotifierProvider.overrideWith(FakeAnonymousAuthNotifier.new),
        ],
        child: const LawrenceAcademyApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Entrar na Plataforma'), findsOneWidget);
    expect(find.text('Catálogo de Cursos'), findsNothing);
  });
}

class FakeAnonymousAuthNotifier extends AuthNotifier {
  @override
  AuthNotifierState build() => AuthNotifierState();
}
