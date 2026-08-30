import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lawrence/features/auth/presentation/pages/login_page.dart';

void main() {
  Future<void> pumpLogin(
    WidgetTester tester, {
    Size size = const Size(360, 640),
    double textScale = 1,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(
              size: size,
              textScaler: TextScaler.linear(textScale),
              disableAnimations: true,
            ),
            child: const LoginPage(),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('mobile login keeps the primary journey clear and scrollable', (
    tester,
  ) async {
    await pumpLogin(tester);

    expect(find.text('Bem-vindo de volta'), findsOneWidget);
    expect(find.text('ENTRAR NO ATELIÊ'), findsOneWidget);
    expect(find.text('Entrar com Google'), findsOneWidget);
    expect(find.byType(SingleChildScrollView), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('supports large accessible text without overflow', (
    tester,
  ) async {
    await pumpLogin(tester, textScale: 2);

    expect(find.text('Bem-vindo de volta'), findsOneWidget);
    expect(find.byType(SingleChildScrollView), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('registration exposes new-password autofill semantics', (
    tester,
  ) async {
    await pumpLogin(tester);
    final registrationLink = find.text('Ainda não tem conta? Cadastre-se');
    await tester.ensureVisible(registrationLink);
    await tester.tap(registrationLink);
    await tester.pumpAndSettle();

    expect(find.text('Crie sua conta'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(3));
    final editableFields = tester.widgetList<EditableText>(
      find.byType(EditableText),
    );
    expect(
      editableFields.last.autofillHints,
      contains(AutofillHints.newPassword),
    );
    expect(tester.takeException(), isNull);
  });
}
