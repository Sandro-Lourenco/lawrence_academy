import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lawrence/design_system/public/public_refractive_glass.dart';

Widget _host({required bool reduceMotion}) {
  return MaterialApp(
    home: MediaQuery(
      data: MediaQueryData(disableAnimations: reduceMotion),
      child: const Scaffold(
        body: Stack(
          children: [
            ColoredBox(color: Color(0xFF6B1328)),
            Align(
              alignment: Alignment.topCenter,
              child: SizedBox(
                width: 720,
                child: PublicRefractiveGlass(
                  child: SizedBox(height: 76, child: Text('LAWRENCE ACADEMY')),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('renders the bounded optical surface', (tester) async {
    await tester.pumpWidget(_host(reduceMotion: false));
    await tester.pumpAndSettle();

    expect(find.byType(PublicRefractiveGlass), findsOneWidget);
    expect(find.text('LAWRENCE ACADEMY'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('renders a static accessible fallback', (tester) async {
    await tester.pumpWidget(_host(reduceMotion: true));
    await tester.pumpAndSettle();

    expect(find.text('LAWRENCE ACADEMY'), findsOneWidget);
    expect(tester.binding.hasScheduledFrame, isFalse);
    expect(tester.takeException(), isNull);
  });
}
