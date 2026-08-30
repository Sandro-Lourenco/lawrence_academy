import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lawrence/design_system/tokens/lawrence_theme.dart';
import 'package:lawrence/features/courses/domain/entities/course.dart';
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

  Widget buildSubject({
    VoidCallback? onSave,
    List<Course> prerequisiteCourses = const [],
    Set<String> selectedPrerequisiteIds = const {},
    void Function(String, bool)? onPrerequisiteToggled,
  }) => MaterialApp(
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
          prerequisiteCourseOptions: prerequisiteCourses,
          selectedPrerequisiteCourseIds: selectedPrerequisiteIds,
          isSaving: false,
          onChanged: () {},
          onCategoryChanged: (_) {},
          onLevelChanged: (_) {},
          onCourseTypeChanged: (_) {},
          onLanguageChanged: (_) {},
          onPrerequisiteCourseToggled: onPrerequisiteToggled ?? (_, _) {},
          onSave: onSave ?? () {},
        ),
      ),
    ),
  );

  testWidgets('shows only the essential course fields', (tester) async {
    tester.view.physicalSize = const Size(1200, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(buildSubject());

    expect(find.text('Informações do curso'), findsOneWidget);
    expect(find.text('Completo'), findsOneWidget);
    expect(find.text('Rápido'), findsOneWidget);
    expect(find.text('Workshop'), findsOneWidget);
    expect(find.text('Título'), findsOneWidget);
    expect(find.text('Descrição'), findsOneWidget);
    expect(find.text('Categoria'), findsOneWidget);
    expect(find.text('Conhecimentos prévios'), findsOneWidget);
    expect(
      find.text('Cursos que precisam ser concluídos antes'),
      findsOneWidget,
    );
    expect(find.text('Materiais necessários'), findsOneWidget);
    expect(find.text('Descrição curta'), findsNothing);
    expect(find.text('Público-alvo'), findsNothing);
  });

  testWidgets('selects a published prerequisite as a course object', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    String? selectedId;

    await tester.pumpWidget(
      buildSubject(
        prerequisiteCourses: const [
          Course(
            id: 'course-basic',
            instructorId: 'teacher-1',
            title: 'Fundamentos da Costura',
            slug: 'fundamentos-da-costura',
            category: 'costura',
            level: 'iniciante',
            summary: 'Curso introdutório',
            status: 'published',
            modules: [],
          ),
        ],
        onPrerequisiteToggled: (id, selected) {
          if (selected) selectedId = id;
        },
      ),
    );

    expect(find.text('Fundamentos da Costura'), findsOneWidget);
    await tester.tap(find.byType(Checkbox));
    expect(selectedId, 'course-basic');
  });

  testWidgets('reports actionable validation errors', (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(buildSubject());
    formKey.currentState!.validate();
    await tester.pump();

    expect(find.text('Informe ao menos 3 caracteres.'), findsOneWidget);
    expect(find.text('Informe ao menos 10 caracteres.'), findsOneWidget);
    expect(find.text('Informe o endereço do curso.'), findsNothing);
  });

  testWidgets('rejects planning items shorter than the API contract', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    requirementsController.text = '-';
    requiredMaterialsController.text = 'A';

    await tester.pumpWidget(buildSubject());
    formKey.currentState!.validate();
    await tester.pump();

    expect(
      find.text('Cada item deve ter entre 2 e 240 caracteres.'),
      findsNWidgets(2),
    );
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
    expect(button.style?.minimumSize?.resolve({})?.width, double.infinity);
  });
}
