import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lawrence/main.dart';

void main() {
  testWidgets('App initialization smoke test', (WidgetTester tester) async {
    // Carrega o widget principal envolto no ProviderScope do Riverpod
    await tester.pumpWidget(
      const ProviderScope(
        child: LawrenceAcademyApp(),
      ),
    );

    // Verifica que o widget foi construído com sucesso
    expect(find.byType(LawrenceAcademyApp), findsOneWidget);
  });
}
