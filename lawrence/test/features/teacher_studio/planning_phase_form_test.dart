import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lawrence/design_system/tokens/lawrence_theme.dart';
import 'package:lawrence/features/teacher_studio/presentation/pages/components/planning_phase_form.dart';

void main() {
  late GlobalKey<FormState> formKey;
  late TextEditingController titleController;
  late TextEditingController slugController;
  late TextEditingController summaryController;
  late TextEditingController subtitleController;
  late TextEditingController descriptionController;
  late TextEditingController requirementsController;
  late TextEditingController durationController;
  late TextEditingController learningObjectivesController;
  late TextEditingController targetAudienceController;
  late TextEditingController requiredMaterialsController;
  late TextEditingController competenciesController;
  late TextEditingController expectedOutcomesController;

  setUp(() {
    formKey = GlobalKey<FormState>();
    titleController = TextEditingController();
    slugController = TextEditingController();
    summaryController = TextEditingController();
    subtitleController = TextEditingController();
    descriptionController = TextEditingController();
    requirementsController = TextEditingController();
    durationController = TextEditingController();
    learningObjectivesController = TextEditingController();
    targetAudienceController = TextEditingController();
    requiredMaterialsController = TextEditingController();
    competenciesController = TextEditingController();
    expectedOutcomesController = TextEditingController();
  });

  tearDown(() {
    titleController.dispose();
    slugController.dispose();
    summaryController.dispose();
    subtitleController.dispose();
    descriptionController.dispose();
    requirementsController.dispose();
    durationController.dispose();
    learningObjectivesController.dispose();
    targetAudienceController.dispose();
    requiredMaterialsController.dispose();
    competenciesController.dispose();
    expectedOutcomesController.dispose();
  });

  Widget buildSubject({VoidCallback? onSave}) => MaterialApp(
    theme: LawrenceTheme.lightTheme,
    home: Scaffold(
      body: SingleChildScrollView(
        child: PlanningPhaseForm(
          formKey: formKey,
          titleController: titleController,
          slugController: slugController,
          summaryController: summaryController,
          subtitleController: subtitleController,
          descriptionController: descriptionController,
          requirementsController: requirementsController,
          durationController: durationController,
          learningObjectivesController: learningObjectivesController,
          targetAudienceController: targetAudienceController,
          requiredMaterialsController: requiredMaterialsController,
          competenciesController: competenciesController,
          expectedOutcomesController: expectedOutcomesController,
          category: 'modelagem',
          level: 'iniciante',
          courseType: 'complete',
          language: 'pt-BR',
          isSaving: false,
          onChanged: () {},
          onCategoryChanged: (_) {},
          onLevelChanged: (_) {},
          onCourseTypeChanged: (_) {},
          onLanguageChanged: (_) {},
          onSave: onSave ?? () {},
        ),
      ),
    ),
  );

  testWidgets('shows confirmed planning fields and contract notice', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(buildSubject());

    expect(find.text('Planejamento do curso'), findsOneWidget);
    expect(find.text('Curso completo'), findsOneWidget);
    expect(find.text('Curso rápido'), findsOneWidget);
    expect(find.text('Workshop ou oficina'), findsOneWidget);
    expect(find.text('Nome do curso'), findsOneWidget);
    expect(find.text('Descrição curta'), findsOneWidget);
    expect(find.text('Descrição completa'), findsOneWidget);
    expect(find.text('Pré-requisitos do curso'), findsOneWidget);
    expect(find.text('O que o aluno aprenderá'), findsOneWidget);
    expect(find.text('Público-alvo'), findsOneWidget);
  });

  testWidgets('reports actionable validation errors', (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(buildSubject());
    formKey.currentState!.validate();
    await tester.pump();

    expect(find.text('Informe o nome do curso.'), findsOneWidget);
    expect(find.text('Informe o endereço do curso.'), findsOneWidget);
    expect(find.text('Escreva ao menos 10 caracteres.'), findsOneWidget);
    expect(find.text('Adicione pelo menos um item.'), findsNWidgets(2));
  });

  testWidgets('uses a full-width primary action on compact layouts', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(buildSubject());
    final button = tester.widget<FilledButton>(find.byType(FilledButton));

    expect(button.style?.minimumSize?.resolve({})?.height, 52);
    expect(
      button.style?.minimumSize?.resolve({})?.width,
      double.infinity,
    );
  });
}
