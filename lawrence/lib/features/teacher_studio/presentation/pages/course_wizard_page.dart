import 'package:flutter/material.dart';
import '../../../../core/error/app_error.dart';
import '../../../../design_system/tokens/lawrence_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/course_wizard_controller.dart';
import '../controllers/teacher_courses_controller.dart';
import '../widgets/studio_cinematic_background.dart';
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
  Set<String> _prerequisiteCourseIds = <String>{};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(courseWizardControllerProvider.notifier).init(widget.courseId);
    });
  }

  @override
  void didUpdateWidget(covariant CourseWizardPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.courseId == widget.courseId) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(courseWizardControllerProvider.notifier).init(widget.courseId);
      }
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
        _prerequisiteCourseIds = state.value!.course!.prerequisiteCourses
            .map((course) => course.id)
            .toSet();
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
          backgroundColor: const Color(0xF20A1022),
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

  double? _currentMonthlyPrice() => _isFreeCourse
      ? 0.0
      : double.tryParse(
          _monthlyPriceController.text.trim().replaceAll(',', '.'),
        );

  Map<String, dynamic> _basicDraftData() => {
    'title': _titleController.text.trim(),
    'category': _categoryController.text.trim(),
    'course_type': _courseType,
    'description': _descriptionController.text.trim(),
    'requirements': _lines(_requirementsController),
    'prerequisite_course_ids': _prerequisiteCourseIds.toList()..sort(),
    'required_materials': _lines(_requiredMaterialsController),
    'monthly_price': _currentMonthlyPrice(),
  };

  void _scheduleBasicAutosave() {
    final payload = _basicDraftData();
    final controller = ref.read(courseWizardControllerProvider.notifier);
    if (!_isPlanningPayloadValidForAutosave(payload)) {
      controller.markUnsavedChanges();
      return;
    }
    controller.scheduleAutosave(payload);
  }

  bool _isPlanningPayloadValidForAutosave(Map<String, dynamic> payload) {
    final title = (payload['title'] as String? ?? '').trim();
    final description = (payload['description'] as String? ?? '').trim();
    final category = (payload['category'] as String? ?? '').trim();
    final monthlyPrice = payload['monthly_price'];
    if (title.length < 3 ||
        title.length > 120 ||
        description.length < 10 ||
        description.length > 5000 ||
        category.length < 2 ||
        monthlyPrice is! num ||
        monthlyPrice < 0 ||
        monthlyPrice > 1000000) {
      return false;
    }

    for (final field in const ['requirements', 'required_materials']) {
      final items = payload[field] as List<String>? ?? const [];
      if (items.length > 20 ||
          items.any((item) => item.length < 2 || item.length > 240)) {
        return false;
      }
    }
    return true;
  }

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
            if (result.videoUrl != null) 'video_url': result.videoUrl,
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
            video != null
                ? 'Vídeo enviado para processamento.'
                : result.videoUrl != null
                ? 'Aula criada com o link do vídeo.'
                : 'Aula criada com sucesso.',
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
            if (result.videoUrl != null) 'video_url': result.videoUrl,
            // O link atual permanece reproduzível enquanto o novo upload é
            // processado. O worker troca a fonte somente na ativação do HLS.
            if (result.removeExternalVideo && video == null)
              'remove_external_video': true,
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
              ? (video != null
                    ? 'Aula atualizada e vídeo enviado para processamento.'
                    : result.videoUrl != null
                    ? 'Aula atualizada com o novo link.'
                    : 'Aula atualizada com sucesso.')
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

  Future<void> _reorderLessons(
    Module module,
    int oldIndex,
    int newIndex,
  ) async {
    final lessons = [...module.lessons]
      ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
    if (newIndex > oldIndex) newIndex -= 1;
    if (oldIndex == newIndex || oldIndex < 0 || oldIndex >= lessons.length) {
      return;
    }
    final moved = lessons.removeAt(oldIndex);
    lessons.insert(newIndex.clamp(0, lessons.length), moved);
    final controller = ref.read(courseWizardControllerProvider.notifier);
    for (var index = 0; index < lessons.length; index++) {
      if (lessons[index].orderIndex == index) continue;
      final saved = await controller.editLesson(
        lessonId: lessons[index].id,
        lessonData: {'order_index': index},
      );
      if (!saved || !mounted) break;
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
            child: const Text(
              "Excluir",
              style: TextStyle(color: LawrenceColors.danger),
            ),
          ),
        ],
      ),
    );
    if (conf == true) {
      final success = await ref
          .read(courseWizardControllerProvider.notifier)
          .deleteModule(moduleId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Módulo arquivado com sucesso.'
                : 'Não foi possível arquivar o módulo. Tente novamente.',
          ),
          backgroundColor: success
              ? LawrenceColors.success
              : LawrenceColors.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final asyncState = ref.watch(courseWizardControllerProvider);
    final availablePrerequisites =
        ref.watch(teacherCoursesControllerProvider).value?.where((course) {
          return course.id != widget.courseId &&
              (course.status == 'published' ||
                  _prerequisiteCourseIds.contains(course.id));
        }).toList() ??
        const <Course>[];
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
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          backgroundColor: const Color(0xF20A1022),
          elevation: 0,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(color: const Color(0x33A63B5E), height: 1),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () async {
              final shouldPop = await _onWillPop();
              if (shouldPop && context.mounted) {
                Navigator.of(context).pop();
              }
            },
          ),
        ),
        backgroundColor: const Color(0xFF070B18),
        body: asyncState.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: LawrenceColors.primary),
          ),
          error: (e, st) => Center(
            child: Text(
              "Erro: $e",
              style: const TextStyle(color: LawrenceColors.danger),
            ),
          ),
          data: (state) {
            _syncControllersIfEmpty();

            final feedbackError = state.error == null
                ? null
                : AppError.fromException(state.error);

            return StudioCinematicBackground(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final desktop = constraints.maxWidth >= 980;
                        final content = SingleChildScrollView(
                          padding: EdgeInsets.fromLTRB(
                            desktop ? 32 : 18,
                            24,
                            desktop ? 40 : 18,
                            96,
                          ),
                          child: Align(
                            alignment: Alignment.topCenter,
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 1120),
                              child: Container(
                                padding: EdgeInsets.all(desktop ? 28 : 18),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Color(0x8F25305A),
                                      Color(0x66101830),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(26),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: .16),
                                  ),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x55000000),
                                      blurRadius: 36,
                                      offset: Offset(0, 18),
                                    ),
                                    BoxShadow(
                                      color: Color(0x336655F5),
                                      blurRadius: 42,
                                      spreadRadius: -16,
                                    ),
                                  ],
                                ),
                                child: AnimatedSwitcher(
                                  duration:
                                      MediaQuery.disableAnimationsOf(context)
                                      ? Duration.zero
                                      : const Duration(milliseconds: 280),
                                  child: KeyedSubtree(
                                    key: ValueKey(_currentStep),
                                    child: _phaseContent(
                                      state,
                                      availablePrerequisites,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                        if (desktop) {
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              SizedBox(
                                width: 244,
                                child: _StudioPhaseRail(
                                  currentStep: _currentStep,
                                  courseTitle: state.course?.title,
                                  hasUnsavedChanges: state.hasUnsavedChanges,
                                  onStepTapped: (step) =>
                                      setState(() => _currentStep = step),
                                ),
                              ),
                              const VerticalDivider(width: 1),
                              Expanded(child: content),
                            ],
                          );
                        }
                        return Column(
                          children: [
                            _CompactPhaseHeader(
                              currentStep: _currentStep,
                              onStepTapped: (step) =>
                                  setState(() => _currentStep = step),
                            ),
                            Expanded(child: content),
                          ],
                        );
                      },
                    ),
                  ),
                  if (state.hasUnsavedChanges ||
                      state.isSaving ||
                      state.isUploading ||
                      state.uploadMessage != null ||
                      state.error != null)
                    Positioned(
                      top: 12,
                      left: 16,
                      right: 16,
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: _StudioFeedbackBanner(
                          error: feedbackError,
                          isBusy: state.isSaving || state.isUploading,
                          message: state.uploadMessage,
                          hasRevisionConflict: state.hasRevisionConflict,
                          onResolveConflict: ref
                              .read(courseWizardControllerProvider.notifier)
                              .refreshAfterRevisionConflict,
                          onClose: ref
                              .read(courseWizardControllerProvider.notifier)
                              .clearFeedback,
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _phaseContent(
    CourseWizardState state,
    List<Course> availablePrerequisites,
  ) => switch (_currentStep) {
    0 => _buildStepBasicInfo(state.isSaving, availablePrerequisites),
    1 => _buildStepOffer(state),
    2 => _buildStepMedia(state),
    3 => _buildStepCurriculum(state),
    _ => _buildStepPublish(state),
  };

  Widget _buildStepBasicInfo(
    bool isSaving,
    List<Course> availablePrerequisites,
  ) => PlanningPhaseForm(
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
    prerequisiteCourseOptions: availablePrerequisites,
    selectedPrerequisiteCourseIds: _prerequisiteCourseIds,
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
    onPrerequisiteCourseToggled: (courseId, selected) {
      if (selected && _prerequisiteCourseIds.length >= 20) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Selecione no máximo 20 cursos obrigatórios.'),
          ),
        );
        return;
      }
      setState(() {
        if (selected) {
          _prerequisiteCourseIds.add(courseId);
        } else {
          _prerequisiteCourseIds.remove(courseId);
        }
      });
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

  Widget _buildStepMedia(CourseWizardState state) {
    final course = state.course;
    if (course == null) {
      return _PhasePrerequisite(
        icon: Icons.image_outlined,
        title: 'Salve o planejamento primeiro',
        message:
            'A imagem-mestre e o trailer precisam estar vinculados a um rascunho. Preencha o nome e salve a primeira fase para liberar as prévias de exportação.',
        actionLabel: 'Voltar ao planejamento',
        onPressed: () => setState(() => _currentStep = 0),
      );
    }
    return CourseMediaForm(
      isUploading: state.isUploading,
      course: course,
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
      onExternalTrailerChanged: (url, remove) =>
          ref.read(courseWizardControllerProvider.notifier).saveDraft({
            'trailer_video_url': ?url,
            if (remove) 'remove_external_trailer': true,
          }),
      onBack: () => setState(() => _currentStep = 1),
      onContinue: () => setState(() => _currentStep = 3),
    );
  }

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
    final isQuickCourse = state.course!.courseType == 'quick';
    final modules = state.course!.modules
        .where((module) => isQuickCourse ? module.isSystem : !module.isSystem)
        .toList();
    final lessons = modules.expand((module) => module.lessons).toList();
    final totalSeconds = lessons.fold<int>(
      0,
      (total, lesson) =>
          total +
          (lesson.durationSeconds > 0
              ? lesson.durationSeconds
              : (lesson.estimatedDurationMinutes ?? 0) * 60),
    );
    final readyVideos = lessons
        .where(
          (lesson) =>
              lesson.hlsStoragePath?.isNotEmpty == true ||
              const {'youtube', 'vimeo'}.contains(lesson.videoSourceType),
        )
        .length;
    final failedVideos = lessons
        .where(
          (lesson) =>
              const {'failed', 'dead_letter'}.contains(lesson.videoJobStatus),
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
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2C111B), Color(0xFF181315)],
        ),
        border: Border.all(color: const Color(0x668F2645)),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 16,
            runSpacing: 12,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isQuickCourse
                        ? 'Aulas do curso rápido'
                        : 'Grade curricular',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    isQuickCourse
                        ? 'Adicione as aulas diretamente, sem criar módulos.'
                        : 'Organize módulos e gerencie cada aula separadamente.',
                    style: const TextStyle(
                      color: LawrenceColors.darkTextSecondary,
                      fontSize: 15,
                    ),
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
                      foregroundColor: LawrenceColors.goldHighlight,
                      side: const BorderSide(color: LawrenceColors.goldMid),
                      minimumSize: const Size(150, 52),
                    ),
                  ),
                  if (!isQuickCourse)
                    FilledButton.icon(
                      onPressed: _createModule,
                      icon: const Icon(Icons.add, size: 20),
                      label: const Text("Novo módulo"),
                      style: FilledButton.styleFrom(
                        backgroundColor: LawrenceColors.goldMid,
                        foregroundColor: LawrenceColors.brandNavy,
                        minimumSize: const Size(160, 52),
                      ),
                    ),
                  if (isQuickCourse && modules.isNotEmpty)
                    FilledButton.icon(
                      key: const Key('quick-course-add-lesson'),
                      onPressed: state.isUploading || state.isSaving
                          ? null
                          : () => _createLesson(modules.first),
                      icon: const Icon(Icons.add, size: 20),
                      label: const Text('Nova aula'),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF6B1328),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(150, 52),
                      ),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          const _LessonPublishingGuide(),
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
                  icon: Icons.schedule_outlined,
                  value: _formattedCourseDuration(totalSeconds),
                  label: 'carga horária',
                  color: const Color(0xFFA63B5E),
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
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0x99181315),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0x406B4A55)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.hourglass_top_rounded,
                    color: Color(0xFFD6A4B2),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      isQuickCourse
                          ? 'Preparando a área interna de aulas. Use “Atualizar status” se ela não aparecer em alguns segundos.'
                          : 'Crie o primeiro módulo para começar a adicionar aulas.',
                      style: const TextStyle(
                        color: LawrenceColors.darkTextSecondary,
                      ),
                    ),
                  ),
                ],
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
                isQuickCourse: isQuickCourse,
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
                onReorderLessons: (oldIndex, newIndex) =>
                    _reorderLessons(mod, oldIndex, newIndex),
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
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              FilledButton.icon(
                onPressed: () => setState(() => _currentStep = 4),
                icon: const Icon(Icons.arrow_forward, size: 20),
                label: const Text('Continuar'),
                style: FilledButton.styleFrom(
                  backgroundColor: LawrenceColors.goldMid,
                  foregroundColor: LawrenceColors.brandNavy,
                  minimumSize: const Size(160, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
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

  String _formattedCourseDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    if (hours == 0) return '${minutes}min';
    return minutes == 0 ? '${hours}h' : '${hours}h ${minutes}min';
  }
}

class _StudioFeedbackBanner extends StatelessWidget {
  const _StudioFeedbackBanner({
    required this.error,
    required this.isBusy,
    required this.message,
    required this.hasRevisionConflict,
    required this.onResolveConflict,
    required this.onClose,
  });

  final AppError? error;
  final bool isBusy;
  final String? message;
  final bool hasRevisionConflict;
  final VoidCallback onResolveConflict;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final isError = error != null;
    final isSuccess = !isError && !isBusy && message != null;
    final background = isError
        ? const Color(0xFF3B0D18)
        : isBusy
        ? const Color(0xFF151D45)
        : isSuccess
        ? const Color(0xFF0B3327)
        : const Color(0xFF3A2708);
    final accent = isError
        ? const Color(0xFFFF6B7D)
        : isBusy
        ? const Color(0xFFB94A6B)
        : isSuccess
        ? const Color(0xFF68E0A5)
        : const Color(0xFFFFC266);
    final label = isError
        ? '${error!.title}: ${error!.message}'
        : isBusy
        ? 'Salvando alterações…'
        : message ?? 'Alterações pendentes';

    return Semantics(
      liveRegion: true,
      label: label,
      child: Material(
        color: Colors.transparent,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: background,
              border: Border.all(color: accent, width: 1.25),
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x66000000),
                  blurRadius: 24,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isBusy)
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.25,
                        color: accent,
                      ),
                    )
                  else
                    Icon(
                      isError
                          ? error!.icon
                          : isSuccess
                          ? Icons.check_circle_outline
                          : Icons.edit_note_rounded,
                      color: accent,
                      size: 22,
                    ),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      label,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        height: 1.35,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (hasRevisionConflict) ...[
                    const SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: onResolveConflict,
                      style: TextButton.styleFrom(foregroundColor: accent),
                      icon: const Icon(Icons.sync, size: 18),
                      label: const Text('Atualizar'),
                    ),
                  ],
                  if (isError || isSuccess) ...[
                    const SizedBox(width: 4),
                    IconButton(
                      tooltip: 'Fechar mensagem',
                      onPressed: onClose,
                      color: Colors.white,
                      icon: const Icon(Icons.close, size: 20),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

const _studioPhases = [
  ('Planejamento', 'Proposta e informações'),
  ('Oferta', 'Preço e experiência'),
  ('Apresentação', 'Capa e trailer'),
  ('Estrutura', 'Módulos e aulas'),
  ('Lançamento', 'Prévia e publicação'),
];

class _PhasePrerequisite extends StatelessWidget {
  const _PhasePrerequisite({
    required this.icon,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onPressed,
  });

  final IconData icon;
  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(32),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xDD2C111B), Color(0xCC4B0C1B)],
      ),
      borderRadius: BorderRadius.circular(22),
      border: Border.all(color: const Color(0x55A63B5E)),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: const Color(0xFFA63B5E), size: 42),
        const SizedBox(height: 18),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFFB8C1DD), height: 1.5),
          ),
        ),
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: onPressed,
          icon: const Icon(Icons.arrow_back),
          label: Text(actionLabel),
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF6B1328),
            foregroundColor: Colors.white,
          ),
        ),
      ],
    ),
  );
}

class _StudioPhaseRail extends StatelessWidget {
  const _StudioPhaseRail({
    required this.currentStep,
    required this.courseTitle,
    required this.hasUnsavedChanges,
    required this.onStepTapped,
  });

  final int currentStep;
  final String? courseTitle;
  final bool hasUnsavedChanges;
  final ValueChanged<int> onStepTapped;

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: const Color(0xAA0B1124),
    child: SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 24, 18, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'STUDIO DE AUTORIA',
              style: TextStyle(
                color: Color(0xFFA63B5E),
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.3,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              courseTitle?.trim().isNotEmpty == true
                  ? courseTitle!
                  : 'Novo curso',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w800,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  hasUnsavedChanges
                      ? Icons.sync_rounded
                      : Icons.cloud_done_outlined,
                  size: 16,
                  color: hasUnsavedChanges
                      ? LawrenceColors.warning
                      : LawrenceColors.success,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    hasUnsavedChanges
                        ? 'Salvando alterações…'
                        : 'Rascunho salvo',
                    style: const TextStyle(
                      color: Color(0xFFB8C1DD),
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            for (var index = 0; index < _studioPhases.length; index++)
              _PhaseRailItem(
                index: index,
                title: _studioPhases[index].$1,
                subtitle: _studioPhases[index].$2,
                selected: currentStep == index,
                visited: index < currentStep,
                onTap: () => onStepTapped(index),
              ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .07),
                border: Border.all(color: Colors.white.withValues(alpha: .16)),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.shield_outlined,
                    color: Color(0xFFA63B5E),
                    size: 19,
                  ),
                  SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      'Você pode navegar livremente. Somente a publicação exige o checklist completo.',
                      style: TextStyle(
                        color: Color(0xFFB8C1DD),
                        fontSize: 11.5,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _PhaseRailItem extends StatelessWidget {
  const _PhaseRailItem({
    required this.index,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.visited,
    required this.onTap,
  });
  final int index;
  final String title;
  final String subtitle;
  final bool selected;
  final bool visited;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    selected: selected,
    label: 'Fase ${index + 1}: $title',
    child: Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: selected
                ? const Color(0xFF6B1328).withValues(alpha: .32)
                : Colors.transparent,
            border: Border.all(
              color: selected
                  ? const Color(0xFFA63B5E).withValues(alpha: .55)
                  : Colors.transparent,
            ),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            children: [
              Container(
                width: 30,
                height: 30,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected
                      ? const Color(0xFF6B1328)
                      : visited
                      ? LawrenceColors.success.withValues(alpha: .12)
                      : Colors.white.withValues(alpha: .08),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected
                        ? const Color(0xFFA63B5E)
                        : visited
                        ? LawrenceColors.success
                        : LawrenceColors.borderMist,
                  ),
                ),
                child: visited
                    ? const Icon(
                        Icons.check,
                        size: 16,
                        color: LawrenceColors.success,
                      )
                    : Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: selected
                              ? Colors.white
                              : const Color(0xFFB8C1DD),
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: selected
                            ? FontWeight.w800
                            : FontWeight.w600,
                        fontSize: 13.5,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Color(0xFFB8C1DD),
                        fontSize: 10.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _CompactPhaseHeader extends StatelessWidget {
  const _CompactPhaseHeader({
    required this.currentStep,
    required this.onStepTapped,
  });
  final int currentStep;
  final ValueChanged<int> onStepTapped;

  @override
  Widget build(BuildContext context) => Material(
    color: LawrenceColors.canvas,
    child: Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Fase ${currentStep + 1} de ${_studioPhases.length}  •  ${_studioPhases[currentStep].$1}',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              PopupMenuButton<int>(
                tooltip: 'Escolher fase',
                onSelected: onStepTapped,
                itemBuilder: (_) => [
                  for (var index = 0; index < _studioPhases.length; index++)
                    PopupMenuItem(
                      value: index,
                      child: Text('${index + 1}. ${_studioPhases[index].$1}'),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: (currentStep + 1) / _studioPhases.length,
            minHeight: 5,
            borderRadius: BorderRadius.circular(99),
          ),
        ],
      ),
    ),
  );
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

class _LessonPublishingGuide extends StatelessWidget {
  const _LessonPublishingGuide();

  @override
  Widget build(BuildContext context) {
    const steps = [
      (
        Icons.video_library_outlined,
        '1. Escolha a fonte',
        'Envie um arquivo privado ou use um link oficial do YouTube ou Vimeo.',
      ),
      (
        Icons.auto_awesome_motion_outlined,
        '2. Processamento seguro',
        'Uploads são validados e convertidos em HLS com qualidade adaptável.',
      ),
      (
        Icons.task_alt_outlined,
        '3. Confira e publique',
        'Links ficam prontos na hora; uploads mostram o status até finalizar.',
      ),
    ];

    return Semantics(
      container: true,
      label: 'Etapas para publicar aulas',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final itemWidth = constraints.maxWidth >= 920
              ? (constraints.maxWidth - 24) / 3
              : constraints.maxWidth >= 580
              ? (constraints.maxWidth - 12) / 2
              : constraints.maxWidth;
          return Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (final step in steps)
                SizedBox(
                  width: itemWidth,
                  child: Container(
                    constraints: const BoxConstraints(minHeight: 112),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0x99181315),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0x406B4A55)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFF6B1328),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            step.$1,
                            size: 21,
                            color: const Color(0xFFF3D7DE),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                step.$2,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                step.$3,
                                style: const TextStyle(
                                  color: LawrenceColors.darkTextSecondary,
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
