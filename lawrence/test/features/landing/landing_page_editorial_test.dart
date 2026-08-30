import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lawrence/features/landing/presentation/pages/landing_page.dart';

void main() {
  testWidgets('renders the original Maison Lawrence hero and primary action', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(size: Size(1280, 900), disableAnimations: true),
          child: LandingPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('MAISON LAWRENCE'), findsOneWidget);
    expect(
      find.text('Vista o conhecimento.\nAssine a sua técnica.'),
      findsOneWidget,
    );
    expect(find.text('Explorar cursos'), findsOneWidget);
    expect(find.text('Conhecer o método'), findsOneWidget);
    expect(find.byType(CustomScrollView), findsOneWidget);
    expect(tester.binding.hasScheduledFrame, isFalse);
  });

  testWidgets('keeps the hero readable in a compact mobile viewport', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(
            size: Size(390, 844),
            textScaler: TextScaler.linear(1.5),
            disableAnimations: true,
          ),
          child: LandingPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('Vista o conhecimento.\nAssine a sua técnica.'),
      findsOneWidget,
    );
    expect(find.text('Explorar cursos'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
