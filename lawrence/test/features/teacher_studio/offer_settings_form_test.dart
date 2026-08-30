import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lawrence/features/teacher_studio/presentation/pages/components/offer_settings_form.dart';

void main() {
  testWidgets('apresenta preço com prévia viva e escolha explícita de oferta', (
    tester,
  ) async {
    final monthly = TextEditingController(text: '89,90');
    final promotional = TextEditingController();
    addTearDown(monthly.dispose);
    addTearDown(promotional.dispose);
    bool? selectedFree;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: OfferSettingsForm(
              formKey: GlobalKey<FormState>(),
              monthlyPriceController: monthly,
              promotionalPriceController: promotional,
              isFree: false,
              promotionStartsAt: null,
              promotionEndsAt: null,
              certificateEnabled: true,
              reviewsEnabled: true,
              commentsEnabled: false,
              visibility: 'public',
              isSaving: false,
              onFreeChanged: (value) => selectedFree = value,
              onPromotionStartsChanged: (_) {},
              onPromotionEndsChanged: (_) {},
              onCertificateChanged: (_) {},
              onReviewsChanged: (_) {},
              onCommentsChanged: (_) {},
              onVisibilityChanged: (_) {},
              onChanged: () {},
              onBack: () {},
              onSave: () {},
            ),
          ),
        ),
      ),
    );

    expect(find.text('Desenhe uma oferta irresistível.'), findsOneWidget);
    expect(find.text('Assinatura mensal'), findsOneWidget);
    expect(find.text('Curso gratuito'), findsOneWidget);
    expect(find.text('PRÉVIA DA OFERTA'), findsOneWidget);
    expect(find.textContaining('89,90'), findsWidgets);
    expect(find.text('Visível no catálogo'), findsOneWidget);

    await tester.tap(find.text('Curso gratuito'));
    expect(selectedFree, isTrue);
  });
}
