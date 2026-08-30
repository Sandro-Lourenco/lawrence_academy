import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lawrence/design_system/tokens/lawrence_theme.dart';
import 'package:lawrence/design_system/widgets/couture_primary_button.dart';
import 'package:lawrence/design_system/widgets/couture_progress_bar.dart';
import 'package:lawrence/design_system/widgets/cinematic_background.dart';

void main() {
  testWidgets('primary action uses the canonical wine color', (tester) async {
    var pressed = false;
    await tester.pumpWidget(
      MaterialApp(
        theme: LawrenceTheme.lightTheme,
        home: Scaffold(
          body: CouturePrimaryButton(
            label: 'Continuar',
            onPressed: () => pressed = true,
          ),
        ),
      ),
    );

    final ink = tester
        .widgetList<Ink>(find.byType(Ink))
        .firstWhere((widget) => widget.decoration is BoxDecoration);
    final decoration = ink.decoration! as BoxDecoration;
    expect(decoration.gradient, isNull);
    expect(decoration.color, LawrenceColors.actionPrimary);

    await tester.tap(find.text('Continuar'));
    expect(pressed, isTrue);
  });

  testWidgets('progress clamps its value and exposes a percentage', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: LawrenceTheme.lightTheme,
        home: const Scaffold(body: CoutureProgressBar(value: 1.4)),
      ),
    );

    expect(find.bySemanticsLabel('Progresso do curso'), findsOneWidget);
    final semantics = tester.getSemantics(find.byType(CoutureProgressBar));
    expect(semantics.value, '100% concluído');
  });

  testWidgets('cinematic background stops ambient motion when requested', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: CinematicBackground(child: SizedBox.expand()),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.byType(CinematicBackground), findsOneWidget);
    expect(tester.binding.hasScheduledFrame, isFalse);
  });
}
