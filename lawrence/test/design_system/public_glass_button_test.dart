import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lawrence/design_system/public/public_glass_button.dart';

void main() {
  testWidgets('public glass button remains accessible with reduced motion', (
    tester,
  ) async {
    var taps = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: Scaffold(
            body: PublicGlassButton(
              label: 'Explorar cursos',
              onPressed: () => taps += 1,
            ),
          ),
        ),
      ),
    );

    expect(find.bySemanticsLabel('Explorar cursos'), findsOneWidget);
    await tester.tap(find.text('Explorar cursos'));
    await tester.pump();
    expect(taps, 1);
    expect(tester.takeException(), isNull);
  });
}
