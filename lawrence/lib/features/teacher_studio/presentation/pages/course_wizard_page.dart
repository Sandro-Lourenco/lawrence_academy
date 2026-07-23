import 'package:flutter/material.dart';
import '../../../../design_system/tokens/liquid_theme.dart';
import '../../../../design_system/tokens/lawrence_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/course_wizard_controller.dart';
import 'components/module_editor_dialog.dart';
import 'components/lesson_editor_dialog.dart';
import 'components/module_lessons_section.dart';
import '../../../courses/domain/entities/course.dart';

class CourseWizardPage extends ConsumerStatefulWidget {
  final String? courseId;
  const CourseWizardPage({super.key, this.courseId});

  @override
  ConsumerState<CourseWizardPage> createState() => _CourseWizardPageState();
}

class _CourseWizardPageState extends ConsumerState<CourseWizardPage> {
  int _currentStep = 0;

  // Forms
  final _basicFormKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _slugController = TextEditingController();
  final _categoryController = TextEditingController(text: "costura");
  final _summaryController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _requirementsController = TextEditingController();
  final _monthlyPriceController = TextEditingController(text: "0,00");
  bool _isFreeCourse = false;
  String _level = 'iniciante';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(courseWizardControllerProvider.notifier).init(widget.courseId);
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _slugController.dispose();
    _categoryController.dispose();
    _summaryController.dispose();
    _descriptionController.dispose();
    _requirementsController.dispose();
    _monthlyPriceController.dispose();
    super.dispose();
  }

  void _syncControllersIfEmpty() {
    final state = ref.read(courseWizardControllerProvider);
    if (state.hasValue && state.value!.course != null) {
      if (_titleController.text.isEmpty && _slugController.text.isEmpty) {
        _titleController.text = state.value!.course!.title;
        _slugController.text = state.value!.course!.slug;
        _categoryController.text = state.value!.course!.category;
        _summaryController.text = state.value!.course!.summary;
        _descriptionController.text = state.value!.course!.description;
        _requirementsController.text = state.value!.course!.requirements.join(
          '\n',
        );
        _level = state.value!.course!.level;
        _monthlyPriceController.text = state.value!.course!.monthlyPrice
            .toStringAsFixed(2)
            .replaceAll('.', ',');
        _isFreeCourse = state.value!.course!.isFree;
      }
    }
  }

  Future<bool> _onWillPop() async {
    final state = ref.read(courseWizardControllerProvider);
    if (state.hasValue && state.value!.hasUnsavedChanges) {
      final shouldPop = await showDialog<bool>(
        context: context,
        builder: (c) => AlertDialog(
          backgroundColor: LiquidTheme.surface,
          title: const Text(
            "Alterações não salvas",
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            "Você tem alterações não salvas. Tem certeza que deseja sair?",
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(c).pop(false),
              child: const Text(
                "Cancelar",
                style: TextStyle(color: Colors.white),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(c).pop(true),
              child: const Text(
                "Sair sem salvar",
                style: TextStyle(color: Colors.redAccent),
              ),
            ),
          ],
        ),
      );
      return shouldPop ?? false;
    }
    return true;
  }

  void _saveBasicInfo() async {
    if (_basicFormKey.currentState!.validate()) {
      final success = await ref
          .read(courseWizardControllerProvider.notifier)
          .saveDraft({
            "title": _titleController.text.trim(),
            "slug": _slugController.text.trim(),
            "category": _categoryController.text.trim(),
            "level": _level,
            "summary": _summaryController.text.trim(),
            "description": _descriptionController.text.trim(),
            "requirements": _requirementsController.text
                .split('\n')
                .map((requirement) => requirement.trim())
                .where((requirement) => requirement.isNotEmpty)
                .toList(),
            "monthly_price": _isFreeCourse
                ? 0.0
                : double.parse(
                    _monthlyPriceController.text.trim().replaceAll(',', '.'),
                  ),
          });
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Rascunho salvo com sucesso!")),
        );
        setState(() => _currentStep = 1);
      }
    }
  }

  void _createModule() async {
    final data = await ModuleEditorDialog.show(context);
    if (data != null) {
      await ref.read(courseWizardControllerProvider.notifier).addModule(data);
    }
  }

  void _editModule(String moduleId, String title, int order) async {
    final data = await ModuleEditorDialog.show(
      context,
      title: title,
      order: order,
    );
    if (data != null) {
      await ref
          .read(courseWizardControllerProvider.notifier)
          .editModule(moduleId, data);
    }
  }

  Future<void> _createLesson(Module module) async {
    final result = await LessonEditorDialog.show(
      context,
      defaultOrder: module.lessons.length,
    );
    if (result == null) return;

    final video = result.video;
    final extension = (video?.extension ?? '').toLowerCase();
    final contentType = switch (extension) {
      'mov' => 'video/quicktime',
      'm4v' => 'video/x-m4v',
      _ => 'video/mp4',
    };
    final success = await ref
        .read(courseWizardControllerProvider.notifier)
        .addLesson(
          moduleId: module.id,
          lessonData: {
            'title': result.title,
            'description': result.description,
            'order_index': result.orderIndex,
            'status': result.status,
          },
          filePath: video?.path,
          filename: video?.name,
          sizeBytes: video?.size,
          contentType: video == null ? null : contentType,
        );
    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            video == null
                ? 'Aula criada com sucesso.'
                : 'VÃ­deo enviado para processamento.',
          ),
        ),
      );
    }
  }

  Future<void> _editLesson(Lesson lesson) async {
    final result = await LessonEditorDialog.show(
      context,
      defaultOrder: lesson.orderIndex,
      lesson: lesson,
    );
    if (result == null) return;
    final video = result.video;
    final success = await ref
        .read(courseWizardControllerProvider.notifier)
        .editLesson(
          lessonId: lesson.id,
          lessonData: {
            'title': result.title,
            'description': result.description,
            'order_index': result.orderIndex,
            'status': result.status,
          },
          filePath: video?.path,
          filename: video?.name,
          sizeBytes: video?.size,
          contentType: video == null ? null : _contentTypeFor(video.extension),
        );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? (video == null
                    ? 'Aula atualizada com sucesso.'
                    : 'Aula atualizada e vídeo enviado para processamento.')
              : 'Não foi possível atualizar a aula.',
        ),
      ),
    );
  }

  String _contentTypeFor(String? extension) {
    return switch ((extension ?? '').toLowerCase()) {
      'mov' => 'video/quicktime',
      'm4v' => 'video/x-m4v',
      _ => 'video/mp4',
    };
  }

  Future<void> _deleteLesson(Lesson lesson) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Arquivar aula?'),
        content: Text(
          'A aula “${lesson.title}” será removida da grade, sem apagar o módulo ou as outras aulas.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Arquivar aula'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final success = await ref
        .read(courseWizardControllerProvider.notifier)
        .deleteLesson(lesson.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success ? 'Aula arquivada.' : 'Não foi possível arquivar a aula.',
        ),
      ),
    );
  }

  void _deleteModule(String moduleId) async {
    final conf = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        backgroundColor: LiquidTheme.surface,
        title: const Text(
          "Excluir Módulo?",
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          "Tem certeza que deseja excluir? Esta ação não pode ser desfeita e deletará as aulas.",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(c, true),
            child: const Text("Excluir", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (conf == true) {
      await ref
          .read(courseWizardControllerProvider.notifier)
          .deleteModule(moduleId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final asyncState = ref.watch(courseWizardControllerProvider);

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "Teacher Studio - Wizard",
            style: TextStyle(fontFamily: 'Outfit', fontSize: 16),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        backgroundColor: LiquidTheme.background,
        body: asyncState.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: LiquidTheme.primary),
          ),
          error: (e, st) => Center(
            child: Text("Erro: $e", style: const TextStyle(color: Colors.red)),
          ),
          data: (state) {
            _syncControllersIfEmpty();

            // Check for explicit error in state
            if (state.error != null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.error!),
                    backgroundColor: Colors.red,
                  ),
                );
              });
            }

            final isMobile = MediaQuery.of(context).size.width < 600;

            return Column(
              children: [
                if (state.hasUnsavedChanges)
                  Container(
                    width: double.infinity,
                    color: Colors.orange.withValues(alpha: 0.2),
                    padding: const EdgeInsets.all(8),
                    child: const Text(
                      "Você tem alterações não salvas",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.orange),
                    ),
                  ),
                if (state.isUploading)
                  Container(
                    width: double.infinity,
                    color: LiquidTheme.primary.withValues(alpha: 0.2),
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        const SizedBox(width: 12),
                        Flexible(
                          child: Text(
                            state.uploadMessage ?? 'Enviando...',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: Stepper(
                    type: isMobile
                        ? StepperType.vertical
                        : StepperType.horizontal,
                    currentStep: _currentStep,
                    onStepTapped: (step) => setState(() => _currentStep = step),
                    controlsBuilder: (context, details) =>
                        const SizedBox.shrink(), // Custom controls
                    steps: [
                      Step(
                        isActive: _currentStep >= 0,
                        title: const Text(
                          "Básico",
                          style: TextStyle(color: Colors.white),
                        ),
                        content: _buildStepBasicInfo(state.isSaving),
                      ),
                      Step(
                        isActive: _currentStep >= 1,
                        title: const Text(
                          "Currículo",
                          style: TextStyle(color: Colors.white),
                        ),
                        content: _buildStepCurriculum(state),
                      ),
                      Step(
                        isActive: _currentStep >= 2,
                        title: const Text(
                          "Publicação",
                          style: TextStyle(color: Colors.white),
                        ),
                        content: _buildStepPublish(state),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildStepBasicInfo(bool isSaving) {
    return Form(
      key: _basicFormKey,
      child: Container(
        decoration: LiquidTheme.glassDecoration(radius: 16),
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextFormField(
              controller: _titleController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: "Título do Curso",
                labelStyle: TextStyle(color: Colors.white60),
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => ref
                  .read(courseWizardControllerProvider.notifier)
                  .markUnsavedChanges(),
              validator: (v) => v == null || v.isEmpty ? "Obrigatório" : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _slugController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: "Slug",
                labelStyle: TextStyle(color: Colors.white60),
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => ref
                  .read(courseWizardControllerProvider.notifier)
                  .markUnsavedChanges(),
              validator: (v) => v == null || v.isEmpty ? "Obrigatório" : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _summaryController,
              style: const TextStyle(color: Colors.white),
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: "Resumo do curso",
                labelStyle: TextStyle(color: Colors.white60),
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => ref
                  .read(courseWizardControllerProvider.notifier)
                  .markUnsavedChanges(),
              validator: (value) => value == null || value.trim().length < 10
                  ? "Informe um resumo com pelo menos 10 caracteres"
                  : null,
            ),
            const SizedBox(height: 16),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              value: _isFreeCourse,
              activeColor: LawrenceColors.primary,
              title: const Text(
                'Curso gratuito',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
              subtitle: const Text(
                'Alunos poderão assistir sem pagamento ou assinatura.',
                style: TextStyle(color: Colors.white70),
              ),
              onChanged: (value) {
                setState(() {
                  _isFreeCourse = value;
                  if (value) _monthlyPriceController.text = '0,00';
                });
                ref
                    .read(courseWizardControllerProvider.notifier)
                    .markUnsavedChanges();
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _monthlyPriceController,
              enabled: !_isFreeCourse,
              style: const TextStyle(color: Colors.white),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: "Mensalidade por curso (R\$)",
                helperText: "Valor cobrado mensalmente pelo Stripe",
                helperStyle: TextStyle(color: Colors.white54),
                labelStyle: TextStyle(color: Colors.white60),
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => ref
                  .read(courseWizardControllerProvider.notifier)
                  .markUnsavedChanges(),
              validator: (value) {
                if (_isFreeCourse) return null;
                final price = double.tryParse(
                  (value ?? '').trim().replaceAll(',', '.'),
                );
                return price == null || price <= 0
                    ? "Informe um valor vÃ¡lido"
                    : null;
              },
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: isSaving ? null : _saveBasicInfo,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: LiquidTheme.primary,
                  ),
                  child: isSaving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text(
                          "Salvar Rascunho e Continuar",
                          style: TextStyle(color: Colors.white),
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepCurriculum(CourseWizardState state) {
    if (state.course == null) {
      return const Text(
        "Salve as informações básicas primeiro.",
        style: TextStyle(color: Colors.white60),
      );
    }
    final modules = state.course!.modules;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 16,
            runSpacing: 12,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Grade curricular",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Organize módulos e gerencie cada aula separadamente.',
                    style: TextStyle(color: Colors.white70, fontSize: 15),
                  ),
                ],
              ),
              FilledButton.icon(
                onPressed: _createModule,
                icon: const Icon(Icons.add, size: 20),
                label: const Text("Novo módulo"),
                style: FilledButton.styleFrom(
                  backgroundColor: LawrenceColors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(160, 52),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (modules.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                "Nenhum módulo criado.",
                style: TextStyle(color: Colors.white54),
              ),
            ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: modules.length,
            itemBuilder: (c, i) {
              final mod = modules[i];
              return ModuleLessonsSection(
                module: mod,
                isBusy: state.isUploading || state.isSaving,
                onAddLesson: () => _createLesson(mod),
                onEditLesson: _editLesson,
                onReplaceVideo: _editLesson,
                onDeleteLesson: _deleteLesson,
                onEditModule: () =>
                    _editModule(mod.id, mod.title, mod.orderIndex),
                onDeleteModule: () => _deleteModule(mod.id),
              );
            },
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () => setState(() => _currentStep = 0),
                child: const Text(
                  "Voltar",
                  style: TextStyle(color: Colors.white60),
                ),
              ),
              ElevatedButton(
                onPressed: () => setState(() => _currentStep = 2),
                style: ElevatedButton.styleFrom(
                  backgroundColor: LiquidTheme.primary,
                ),
                child: const Text(
                  "Continuar",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepPublish(CourseWizardState state) {
    return Container(
      decoration: LiquidTheme.glassDecoration(radius: 16),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Icon(
            Icons.check_circle_outline,
            color: LiquidTheme.secondary,
            size: 48,
          ),
          const SizedBox(height: 16),
          const Text(
            "Pronto para Publicar",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          const SizedBox(height: 8),
          Text(
            state.hasUnsavedChanges
                ? "Você possui alterações não salvas. Certifique-se de salvar antes de publicar."
                : "Tudo certo! As aulas deste curso estão prontas.",
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white60),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () => setState(() => _currentStep = 1),
                child: const Text(
                  "Voltar",
                  style: TextStyle(color: Colors.white60),
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: state.hasUnsavedChanges
                    ? null
                    : () async {
                        await ref
                            .read(courseWizardControllerProvider.notifier)
                            .saveDraft({"status": "published"});
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Curso publicado!")),
                        );
                        Navigator.of(context).pop();
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: LiquidTheme.primary,
                ),
                child: const Text(
                  "Publicar Curso",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
