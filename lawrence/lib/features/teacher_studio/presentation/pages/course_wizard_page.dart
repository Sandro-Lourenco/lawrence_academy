import 'package:flutter/material.dart';
import '../../../../core/error/app_error.dart';
import '../../../../design_system/tokens/lawrence_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/course_wizard_controller.dart';
import 'components/module_editor_dialog.dart';
import 'components/lesson_editor_dialog.dart';
import 'components/module_lessons_section.dart';
import 'components/planning_phase_form.dart';
import 'components/offer_settings_form.dart';
import 'components/course_media_form.dart';
import 'components/lesson_blocks_editor_dialog.dart';
import 'components/publication_review.dart';
import 'package:file_picker/file_picker.dart';
import '../../domain/entities/upload_file_payload.dart';
import '../../../courses/domain/entities/course.dart';

class CourseWizardPage extends ConsumerStatefulWidget {
  final String? courseId;
  const CourseWizardPage({super.key, this.courseId});

  @override
  ConsumerState<CourseWizardPage> createState() => _CourseWizardPageState();
}

class _CourseWizardPageState extends ConsumerState<CourseWizardPage> {
  int _currentStep = 0;

  // Forms for the persisted planning draft.
  final _basicFormKey = GlobalKey<FormState>();
  final _offerFormKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _slugController = TextEditingController();
  final _categoryController = TextEditingController(text: "costura");
  final _summaryController = TextEditingController();
  final _subtitleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _requirementsController = TextEditingController();
  final _durationController = TextEditingController();
  final _learningObjectivesController = TextEditingController();
  final _targetAudienceController = TextEditingController();
  final _requiredMaterialsController = TextEditingController();
  final _competenciesController = TextEditingController();
  final _expectedOutcomesController = TextEditingController();
  final _monthlyPriceController = TextEditingController(text: "0,00");
  final _promotionalPriceController = TextEditingController();
  bool _isFreeCourse = true;
  DateTime? _promotionStartsAt;
  DateTime? _promotionEndsAt;
  bool _certificateEnabled = true;
  bool _reviewsEnabled = true;
  bool _commentsEnabled = true;
  String _visibility = 'public';
  String _level = 'iniciante';
  String _courseType = 'complete';
  String _language = 'pt-BR';

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
    _subtitleController.dispose();
    _descriptionController.dispose();
    _requirementsController.dispose();
    _durationController.dispose();
    _learningObjectivesController.dispose();
    _targetAudienceController.dispose();
    _requiredMaterialsController.dispose();
    _competenciesController.dispose();
    _expectedOutcomesController.dispose();
    _monthlyPriceController.dispose();
    _promotionalPriceController.dispose();
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
        _subtitleController.text = state.value!.course!.subtitle;
        _descriptionController.text = state.value!.course!.description;
        _requirementsController.text = state.value!.course!.requirements.join(
          '\n',
        );
        _level = state.value!.course!.level;
        _courseType = state.value!.course!.courseType;
        _language = state.value!.course!.language;
        _durationController.text =
            state.value!.course!.estimatedDurationMinutes?.toString() ?? '';
        _learningObjectivesController.text = state
            .value!
            .course!
            .learningObjectives
            .join('\n');
        _targetAudienceController.text = state.value!.course!.targetAudience
            .join('\n');
        _requiredMaterialsController.text = state
            .value!
            .course!
            .requiredMaterials
            .join('\n');
        _competenciesController.text = state.value!.course!.competencies.join(
          '\n',
        );
        _expectedOutcomesController.text = state.value!.course!.expectedOutcomes
            .join('\n');
        _monthlyPriceController.text = state.value!.course!.monthlyPrice
            .toStringAsFixed(2)
            .replaceAll('.', ',');
        _isFreeCourse = state.value!.course!.isFree;
        _promotionalPriceController.text =
            state.value!.course!.promotionalMonthlyPrice
                ?.toStringAsFixed(2)
                .replaceAll('.', ',') ??
            '';
        _promotionStartsAt = state.value!.course!.promotionStartsAt;
        _promotionEndsAt = state.value!.course!.promotionEndsAt;
        _certificateEnabled = state.value!.course!.certificateEnabled;
        _reviewsEnabled = state.value!.course!.reviewsEnabled;
        _commentsEnabled = state.value!.course!.commentsEnabled;
        _visibility = state.value!.course!.visibility;
      }
    }
  }

  Future<bool> _onWillPop() async {
    final state = ref.read(courseWizardControllerProvider);
    if (state.hasValue && state.value!.hasUnsavedChanges) {
      final shouldPop = await showDialog<bool>(
        context: context,
        builder: (c) => AlertDialog(
          backgroundColor: LawrenceColors.canvas,
          title: const Text(
            "Alterações não salvas",
            style: TextStyle(color: LawrenceColors.textPrimary),
          ),
          content: const Text(
            "Você tem alterações não salvas. Tem certeza que deseja sair?",
            style: TextStyle(color: LawrenceColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(c).pop(false),
              child: const Text(
                "Cancelar",
                style: TextStyle(color: LawrenceColors.textSecondary),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(c).pop(true),
              child: const Text(
                "Sair sem salvar",
                style: TextStyle(color: LawrenceColors.danger),
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
            ..._basicDraftData(),
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

  List<String> _lines(TextEditingController controller) => controller.text
      .split('\n')
      .map((item) => item.trim())
      .where((item) => item.isNotEmpty)
      .toList();

  Map<String, dynamic> _basicDraftData() => {
    'title': _titleController.text.trim(),
    'slug': _slugController.text.trim(),
    'category': _categoryController.text.trim(),
    'level': _level,
    'summary': _summaryController.text.trim(),
    'course_type': _courseType,
    'subtitle': _subtitleController.text.trim(),
    'language': _language,
    'estimated_duration_minutes': int.tryParse(_durationController.text.trim()),
    'description': _descriptionController.text.trim(),
    'requirements': _lines(_requirementsController),
    'learning_objectives': _lines(_learningObjectivesController),
    'target_audience': _lines(_targetAudienceController),
    'required_materials': _lines(_requiredMaterialsController),
    'competencies': _lines(_competenciesController),
    'expected_outcomes': _lines(_expectedOutcomesController),
  };

  void _scheduleBasicAutosave() => ref
      .read(courseWizardControllerProvider.notifier)
      .scheduleAutosave(_basicDraftData());

  Future<void> _saveOfferSettings() async {
    if (!(_offerFormKey.currentState?.validate() ?? false)) return;
    final promotionalText = _promotionalPriceController.text.trim();
    final success = await ref
        .read(courseWizardControllerProvider.notifier)
        .saveDraft(_offerDraftData(promotionalText: promotionalText));
    if (!mounted) return;
    if (success) {
      setState(() => _currentStep = 2);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Oferta e configurações salvas.')),
      );
    }
  }

  Map<String, dynamic> _offerDraftData({String? promotionalText}) {
    final promotion =
        promotionalText ?? _promotionalPriceController.text.trim();
    return {
      'monthly_price': _isFreeCourse
          ? 0.0
          : double.tryParse(
              _monthlyPriceController.text.trim().replaceAll(',', '.'),
            ),
      'promotional_monthly_price': _isFreeCourse || promotion.isEmpty
          ? null
          : double.tryParse(promotion.replaceAll(',', '.')),
      'promotion_starts_at': _isFreeCourse || promotion.isEmpty
          ? null
          : _promotionStartsAt?.toUtc().toIso8601String(),
      'promotion_ends_at': _isFreeCourse || promotion.isEmpty
          ? null
          : _promotionEndsAt?.toUtc().toIso8601String(),
      'certificate_enabled': _certificateEnabled,
      'reviews_enabled': _reviewsEnabled,
      'comments_enabled': _commentsEnabled,
      'visibility': _visibility,
    };
  }

  void _scheduleOfferAutosave() => ref
      .read(courseWizardControllerProvider.notifier)
      .scheduleAutosave(_offerDraftData());

  void _createModule() async {
    final data = await ModuleEditorDialog.show(context);
    if (data != null) {
      await ref.read(courseWizardControllerProvider.notifier).addModule(data);
    }
  }

  void _editModule(Module module) async {
    final data = await ModuleEditorDialog.show(
      context,
      title: module.title,
      order: module.orderIndex,
      description: module.description,
      status: module.status,
    );
    if (data != null) {
      await ref
          .read(courseWizardControllerProvider.notifier)
          .editModule(module.id, data);
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
            'estimated_duration_minutes': result.estimatedDurationMinutes,
            'is_required': result.isRequired,
          },
          video: video == null
              ? null
              : UploadFilePayload(
                  filename: video.name,
                  sizeBytes: video.size,
                  contentType: contentType,
                  path: video.path,
                  bytes: video.bytes,
                ),
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
            'estimated_duration_minutes': result.estimatedDurationMinutes,
            'is_required': result.isRequired,
          },
          video: video == null
              ? null
              : UploadFilePayload(
                  filename: video.name,
                  sizeBytes: video.size,
                  contentType: _contentTypeFor(video.extension),
                  path: video.path,
                  bytes: video.bytes,
                ),
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

  Future<void> _moveModule(List<Module> modules, int index, int delta) async {
    final target = index + delta;
    if (target < 0 || target >= modules.length) return;
    final first = modules[index];
    final second = modules[target];
    final controller = ref.read(courseWizardControllerProvider.notifier);
    final firstSaved = await controller.editModule(first.id, {
      'order_index': second.orderIndex,
    });
    if (firstSaved) {
      await controller.editModule(second.id, {'order_index': first.orderIndex});
    }
  }

  Future<void> _moveLesson(Module module, Lesson lesson, int delta) async {
    final lessons = [...module.lessons]
      ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
    final index = lessons.indexWhere((item) => item.id == lesson.id);
    final target = index + delta;
    if (index < 0 || target < 0 || target >= lessons.length) return;
    final other = lessons[target];
    final controller = ref.read(courseWizardControllerProvider.notifier);
    final firstSaved = await controller.editLesson(
      lessonId: lesson.id,
      lessonData: {'order_index': other.orderIndex},
    );
    if (firstSaved) {
      await controller.editLesson(
        lessonId: other.id,
        lessonData: {'order_index': lesson.orderIndex},
      );
    }
  }

  Future<void> _moveLessonToModule(Lesson lesson, List<Module> modules) async {
    final destinations = modules
        .where((item) => item.id != lesson.moduleId)
        .toList();
    if (destinations.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Crie outro módulo antes de mover esta aula.'),
        ),
      );
      return;
    }
    final destination = await showDialog<Module>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: const Text('Mover aula para'),
        children: [
          for (final module in destinations)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(dialogContext, module),
              child: Text(module.title),
            ),
        ],
      ),
    );
    if (destination == null) return;
    await ref
        .read(courseWizardControllerProvider.notifier)
        .editLesson(
          lessonId: lesson.id,
          lessonData: {
            'module_id': destination.id,
            'order_index': destination.lessons.length,
          },
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
        backgroundColor: LawrenceColors.canvas,
        title: const Text(
          "Excluir Módulo?",
          style: TextStyle(color: LawrenceColors.textPrimary),
        ),
        content: const Text(
          "Tem certeza que deseja excluir? Esta ação não pode ser desfeita e deletará as aulas.",
          style: TextStyle(color: LawrenceColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(c, true),
            child: const Text("Excluir", style: TextStyle(color: LawrenceColors.danger)),
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
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop(result);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Studio de autoria',
            style: TextStyle(
              color: LawrenceColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: LawrenceColors.canvas,
          elevation: 0,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(
              color: LawrenceColors.borderMist,
              height: 1,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: LawrenceColors.textPrimary),
            onPressed: () async {
              final shouldPop = await _onWillPop();
              if (shouldPop && context.mounted) {
                Navigator.of(context).pop();
              }
            },
          ),
        ),
        backgroundColor: LawrenceColors.canvasParchment,
        body: asyncState.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: LawrenceColors.primary),
          ),
          error: (e, st) => Center(
            child: Text("Erro: $e", style: const TextStyle(color: LawrenceColors.danger)),
          ),
          data: (state) {
            _syncControllersIfEmpty();

            final isMobile = MediaQuery.of(context).size.width < 600;
            final feedbackError = state.error == null
                ? null
                : AppError.fromException(state.error);

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
                if (state.isUploading ||
                    state.uploadMessage != null ||
                    state.error != null)
                  Container(
                    width: double.infinity,
                    color: state.error != null
                        ? LawrenceColors.danger.withValues(alpha: 0.16)
                        : state.isUploading
                        ? LawrenceColors.primary.withValues(alpha: 0.2)
                        : LawrenceColors.success.withValues(alpha: 0.16),
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (state.isUploading)
                          const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        else
                          Icon(
                            feedbackError != null
                                ? feedbackError.icon
                                : Icons.check_circle_outline,
                            color: state.error != null
                                ? LawrenceColors.danger
                                : LawrenceColors.success,
                          ),
                        const SizedBox(width: 12),
                        Flexible(
                          child: Text(
                            feedbackError == null
                                ? state.uploadMessage ?? 'Enviando...'
                                : '${feedbackError.title}: '
                                      '${feedbackError.message}',
                            style: TextStyle(
                              color: state.error != null
                                  ? LawrenceColors.danger
                                  : LawrenceColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (state.hasRevisionConflict) ...[
                          const SizedBox(width: 8),
                          TextButton.icon(
                            onPressed: ref
                                .read(courseWizardControllerProvider.notifier)
                                .refreshAfterRevisionConflict,
                            icon: const Icon(Icons.sync),
                            label: const Text('Atualizar revisão'),
                          ),
                        ],
                        if (!state.isUploading) ...[
                          const SizedBox(width: 8),
                          IconButton(
                            tooltip: 'Fechar mensagem',
                            onPressed: ref
                                .read(courseWizardControllerProvider.notifier)
                                .clearFeedback,
                            icon: const Icon(Icons.close),
                          ),
                        ],
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
                          style: TextStyle(color: LawrenceColors.textPrimary, fontWeight: FontWeight.bold),
                        ),
                        content: _buildStepBasicInfo(state.isSaving),
                      ),
                      Step(
                        isActive: _currentStep >= 1,
                        title: const Text(
                          'Oferta',
                          style: TextStyle(color: LawrenceColors.textPrimary, fontWeight: FontWeight.bold),
                        ),
                        content: _buildStepOffer(state),
                      ),
                      Step(
                        isActive: _currentStep >= 2,
                        title: const Text(
                          'Mídia',
                          style: TextStyle(color: LawrenceColors.textPrimary, fontWeight: FontWeight.bold),
                        ),
                        content: _buildStepMedia(state),
                      ),
                      Step(
                        isActive: _currentStep >= 3,
                        title: const Text(
                          "Currículo",
                          style: TextStyle(color: LawrenceColors.textPrimary, fontWeight: FontWeight.bold),
                        ),
                        content: _buildStepCurriculum(state),
                      ),
                      Step(
                        isActive: _currentStep >= 4,
                        title: const Text(
                          "Publicação",
                          style: TextStyle(color: LawrenceColors.textPrimary, fontWeight: FontWeight.bold),
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

  Widget _buildStepBasicInfo(bool isSaving) => PlanningPhaseForm(
    formKey: _basicFormKey,
    titleController: _titleController,
    slugController: _slugController,
    summaryController: _summaryController,
    subtitleController: _subtitleController,
    descriptionController: _descriptionController,
    requirementsController: _requirementsController,
    durationController: _durationController,
    learningObjectivesController: _learningObjectivesController,
    targetAudienceController: _targetAudienceController,
    requiredMaterialsController: _requiredMaterialsController,
    competenciesController: _competenciesController,
    expectedOutcomesController: _expectedOutcomesController,
    category: _categoryController.text,
    level: _level,
    courseType: _courseType,
    language: _language,
    isSaving: isSaving,
    onChanged: _scheduleBasicAutosave,
    onCategoryChanged: (value) {
      setState(() => _categoryController.text = value);
      _scheduleBasicAutosave();
    },
    onLevelChanged: (value) {
      setState(() => _level = value);
      _scheduleBasicAutosave();
    },
    onCourseTypeChanged: (value) {
      setState(() => _courseType = value);
      _scheduleBasicAutosave();
    },
    onLanguageChanged: (value) {
      setState(() => _language = value);
      _scheduleBasicAutosave();
    },
    onSave: _saveBasicInfo,
  );

  Widget _buildStepOffer(CourseWizardState state) => OfferSettingsForm(
    formKey: _offerFormKey,
    monthlyPriceController: _monthlyPriceController,
    promotionalPriceController: _promotionalPriceController,
    isFree: _isFreeCourse,
    promotionStartsAt: _promotionStartsAt,
    promotionEndsAt: _promotionEndsAt,
    certificateEnabled: _certificateEnabled,
    reviewsEnabled: _reviewsEnabled,
    commentsEnabled: _commentsEnabled,
    visibility: _visibility,
    isSaving: state.isSaving,
    onFreeChanged: (value) {
      setState(() {
        _isFreeCourse = value;
        if (value) {
          _monthlyPriceController.text = '0,00';
          _promotionalPriceController.clear();
          _promotionStartsAt = null;
          _promotionEndsAt = null;
        }
      });
      _scheduleOfferAutosave();
    },
    onPromotionStartsChanged: (value) {
      setState(() => _promotionStartsAt = value);
      _scheduleOfferAutosave();
    },
    onPromotionEndsChanged: (value) {
      setState(() => _promotionEndsAt = value);
      _scheduleOfferAutosave();
    },
    onCertificateChanged: (value) {
      setState(() => _certificateEnabled = value);
      _scheduleOfferAutosave();
    },
    onReviewsChanged: (value) {
      setState(() => _reviewsEnabled = value);
      _scheduleOfferAutosave();
    },
    onCommentsChanged: (value) {
      setState(() => _commentsEnabled = value);
      _scheduleOfferAutosave();
    },
    onVisibilityChanged: (value) {
      setState(() => _visibility = value);
      _scheduleOfferAutosave();
    },
    onChanged: _scheduleOfferAutosave,
    onBack: () => setState(() => _currentStep = 0),
    onSave: _saveOfferSettings,
  );

  Widget _buildStepMedia(CourseWizardState state) => CourseMediaForm(
    isUploading: state.isUploading,
    course: state.course!,
    onUpload: (PlatformFile file, String type, String mime, String alt) => ref
        .read(courseWizardControllerProvider.notifier)
        .uploadCourseMedia(
          assetType: type,
          file: UploadFilePayload(
            filename: file.name,
            sizeBytes: file.size,
            contentType: mime,
            path: file.path,
            bytes: file.bytes,
          ),
          altText: alt,
        ),
    onBack: () => setState(() => _currentStep = 1),
    onContinue: () => setState(() => _currentStep = 3),
  );

  // ignore: unused_element
  Widget _buildLegacyBasicInfo(bool isSaving) {
    return Form(
      key: _basicFormKey,
      child: Container(
        decoration: BoxDecoration(
          color: LawrenceColors.canvas,
          border: Border.all(color: LawrenceColors.borderMist),
          borderRadius: BorderRadius.circular(LawrenceRadii.card),
        ),
        padding: const EdgeInsets.all(LawrenceSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Semantics(
              header: true,
              child: const Text(
                'Planejamento do curso',
                style: TextStyle(
                  color: LawrenceColors.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: LawrenceSpacing.xs),
            const Text(
              'Fase 1 de 5 · Defina a proposta e as informações que identificam o curso.',
              style: TextStyle(color: LawrenceColors.textSecondary),
            ),
            const SizedBox(height: LawrenceSpacing.lg),
            Semantics(
              selected: true,
              label: 'Tipo selecionado: Curso completo',
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(LawrenceSpacing.md),
                decoration: BoxDecoration(
                  color: LawrenceColors.infoSurface,
                  border: Border.all(
                    color: LawrenceColors.actionPrimary,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(LawrenceRadii.card),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.school_outlined,
                      color: LawrenceColors.actionPrimary,
                    ),
                    SizedBox(width: LawrenceSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Curso completo',
                            style: TextStyle(
                              color: LawrenceColors.textPrimary,
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: LawrenceSpacing.xxs),
                          Text(
                            'Formação extensa organizada em módulos, aulas, materiais e atividades.',
                            style: TextStyle(
                              color: LawrenceColors.textSecondary,
                            ),
                          ),
                          SizedBox(height: LawrenceSpacing.xs),
                          Text(
                            'Os demais formatos dependem de definição do produto.',
                            style: TextStyle(
                              color: LawrenceColors.info,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.check_circle,
                      color: LawrenceColors.actionPrimary,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: LawrenceSpacing.xl),
            _sectionTitle('Informações básicas'),
            const SizedBox(height: LawrenceSpacing.md),
            TextFormField(
              controller: _titleController,
              textInputAction: TextInputAction.next,
              maxLength: 120,
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
              textInputAction: TextInputAction.next,
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
              maxLines: 3,
              maxLength: 240,
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
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
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
                    backgroundColor: LawrenceColors.primary,
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

  Widget _sectionTitle(String title) => Text(
    title,
    style: const TextStyle(
      color: Colors.white,
      fontSize: 18,
      fontWeight: FontWeight.w700,
    ),
  );

  Widget _buildStepCurriculum(CourseWizardState state) {
    if (state.course == null) {
      return const Text(
        "Salve as informações básicas primeiro.",
        style: TextStyle(color: Colors.white60),
      );
    }
    final modules = state.course!.modules;
    final lessons = modules.expand((module) => module.lessons).toList();
    final readyVideos = lessons
        .where((lesson) => lesson.hlsStoragePath?.isNotEmpty == true)
        .length;
    final failedVideos = lessons
        .where(
          (lesson) => const {
            'failed',
            'dead_letter',
          }.contains(lesson.videoJobStatus),
        )
        .length;
    final processingVideos = lessons
        .where(
          (lesson) => const {
            'upload_pending',
            'uploaded',
            'processing_pending',
            'processing',
            'validating',
            'transcoding',
            'generating_hls',
            'generating_thumbnail',
          }.contains(lesson.videoJobStatus),
        )
        .length;

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
                      color: LawrenceColors.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Organize módulos e gerencie cada aula separadamente.',
                    style: TextStyle(color: LawrenceColors.textSecondary, fontSize: 15),
                  ),
                ],
              ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  OutlinedButton.icon(
                    onPressed: state.isUploading
                        ? null
                        : ref
                              .read(courseWizardControllerProvider.notifier)
                              .refreshVideoStatuses,
                    icon: const Icon(Icons.refresh, size: 20),
                    label: const Text('Atualizar status'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: LawrenceColors.primary,
                      side: const BorderSide(color: LawrenceColors.primary),
                      minimumSize: const Size(150, 52),
                    ),
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
            ],
          ),
          if (lessons.isNotEmpty) ...[
            const SizedBox(height: 20),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _CurriculumMetric(
                  icon: Icons.menu_book_outlined,
                  value: '${lessons.length}',
                  label: lessons.length == 1 ? 'aula' : 'aulas',
                ),
                _CurriculumMetric(
                  icon: Icons.check_circle_outline,
                  value: '$readyVideos',
                  label: 'vídeos prontos',
                  color: LawrenceColors.success,
                ),
                if (processingVideos > 0)
                  _CurriculumMetric(
                    icon: Icons.autorenew,
                    value: '$processingVideos',
                    label: 'em processamento',
                    color: LawrenceColors.info,
                  ),
                if (failedVideos > 0)
                  _CurriculumMetric(
                    icon: Icons.error_outline,
                    value: '$failedVideos',
                    label: 'com falha',
                    color: LawrenceColors.danger,
                  ),
              ],
            ),
          ],
          const SizedBox(height: 24),
          if (modules.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                "Nenhum módulo criado.",
                style: TextStyle(color: LawrenceColors.textSecondary),
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
                onEditLessonContent: (lesson) =>
                    LessonBlocksEditorDialog.show(context, lesson.id),
                onReplaceVideo: _editLesson,
                onDeleteLesson: _deleteLesson,
                onEditModule: () => _editModule(mod),
                onDeleteModule: () => _deleteModule(mod.id),
                canMoveModuleUp: i > 0,
                canMoveModuleDown: i < modules.length - 1,
                onMoveModuleUp: () => _moveModule(modules, i, -1),
                onMoveModuleDown: () => _moveModule(modules, i, 1),
                onMoveLessonUp: (lesson) => _moveLesson(mod, lesson, -1),
                onMoveLessonDown: (lesson) => _moveLesson(mod, lesson, 1),
                onMoveLessonToModule: (lesson) =>
                    _moveLessonToModule(lesson, modules),
              );
            },
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () => setState(() => _currentStep = 2),
                child: const Text(
                  "Voltar",
                  style: TextStyle(color: LawrenceColors.textSecondary),
                ),
              ),
              ElevatedButton(
                onPressed: () => setState(() => _currentStep = 4),
                style: ElevatedButton.styleFrom(
                  backgroundColor: LawrenceColors.primary,
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
    if (state.course != null) {
      return PublicationReview(
        course: state.course!,
        isPublishing: state.isSaving,
        loadChecklist: () => ref
            .read(courseWizardControllerProvider.notifier)
            .getPublicationChecklist(),
        loadVersions: () => ref
            .read(courseWizardControllerProvider.notifier)
            .getCourseVersions(),
        loadVersion: (versionId) => ref
            .read(courseWizardControllerProvider.notifier)
            .getCourseVersion(versionId),
        restoreVersion: (versionId, expectedUpdatedAt, reason) => ref
            .read(courseWizardControllerProvider.notifier)
            .restoreCourseVersion(
              versionId,
              expectedAuthoringUpdatedAt: expectedUpdatedAt,
              reason: reason,
            ),
        onPublish: () =>
            ref.read(courseWizardControllerProvider.notifier).publishCourse(),
        onBack: () => setState(() => _currentStep = 3),
      );
    }
    return const Center(
      child: Text('Salve o rascunho antes de iniciar a revisão.'),
    );
  }
}

class _CurriculumMetric extends StatelessWidget {
  const _CurriculumMetric({
    required this.icon,
    required this.value,
    required this.label,
    this.color = Colors.white,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(LawrenceRadii.pill),
        border: Border.all(color: color.withValues(alpha: .28)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 17, color: color),
          const SizedBox(width: 7),
          Text(
            '$value $label',
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
