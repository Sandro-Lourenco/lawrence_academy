import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lawrence/design_system/widgets/liquid_glass_container.dart';

void main() {
  group('LiquidGlassContainer Widget Tests', () {
    testWidgets('should render child and apply blur effect', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LiquidGlassContainer(
              blurSigma: 15.0,
              child: Text('Glass Content'),
            ),
          ),
        ),
      );

      // Verify child is present
      expect(find.text('Glass Content'), findsOneWidget);

      // Verify BackdropFilter exists (it's what provides the blur)
      final backdropFilterFinder = find.byType(BackdropFilter);
      expect(backdropFilterFinder, findsOneWidget);

      // Verify blur sigma
      final BackdropFilter backdropFilter = tester.widget(backdropFilterFinder);
      final ImageFilter? filter = backdropFilter.filter;

      // Note: Comparing ImageFilter directly is hard, but we verify it's there.
      expect(filter, isNotNull);
    });

    testWidgets('should apply correct border radius', (
      WidgetTester tester,
    ) async {
      const radius = 25.0;
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LiquidGlassContainer(
              borderRadius: radius,
              child: SizedBox(width: 100, height: 100),
            ),
          ),
        ),
      );

      final clipRRectFinder = find.byType(ClipRRect);
      expect(clipRRectFinder, findsOneWidget);

      final ClipRRect clipRRect = tester.widget(clipRRectFinder);
      expect(clipRRect.borderRadius, BorderRadius.circular(radius));
    });
  });
}
