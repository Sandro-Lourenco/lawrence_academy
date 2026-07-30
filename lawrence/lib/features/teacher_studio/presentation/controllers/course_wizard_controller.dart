import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../app/providers/service_repositories.dart';
import '../../../../features/courses/domain/entities/course.dart';
import '../../domain/entities/upload_file_payload.dart';

class CourseWizardState {
  final Course? course;
  final bool isSaving;
  final String? error;
  final bool hasUnsavedChanges;
  final bool isUploading;
  final String? uploadMessage;
  final bool hasRevisionConflict;

  CourseWizardState({
    this.course,
    this.isSaving = false,
    this.error,
    this.hasUnsavedChanges = false,
    this.isUploading = false,
    this.uploadMessage,
    this.hasRevisionConflict = false,
  });

  CourseWizardState copyWith({
    Course? course,
    bool? isSaving,
    String? error,
    bool? hasUnsavedChanges,
    bool? isUploading,
    String? uploadMessage,
    bool? hasRevisionConflict,
  }) {
    return CourseWizardState(
      course: course ?? this.course,
      isSaving: isSaving ?? this.isSaving,
      error:
          error, // Se for nulo, zera o erro (comportamento desejado na maioria das vezes, a menos que especifiquemos)
      hasUnsavedChanges: hasUnsavedChanges ?? this.hasUnsavedChanges,
      isUploading: isUploading ?? this.isUploading,
      uploadMessage: uploadMessage,
      hasRevisionConflict: hasRevisionConflict ?? this.hasRevisionConflict,
    );
  }
}

class CourseWizardController
    extends AutoDisposeAsyncNotifier<CourseWizardState> {
  String? _courseId;
  final Map<String, String> _uploadIdempotencyKeys = {};
  final Map<String, String> _intentKeys = {};
  final Set<String> _mutationsInFlight = {};
  Timer? _videoStatusTimer;
  Timer? _autosaveTimer;
  Map<String, dynamic>? _pendingAutosavePayload;
  bool _autosaveRunning = false;
  int _draftRevision = 0;

  @override
  FutureOr<CourseWizardState> build() async {
    ref.onDispose(() {
      _videoStatusTimer?.cancel();
      _autosaveTimer?.cancel();
    });
    return CourseWizardState();
  }

  void init(String? courseId) async {
    _courseId = courseId;
    if (courseId == null || courseId.isEmpty) {
      state = AsyncValue.data(CourseWizardState());
      return;
    }

    state = const AsyncValue.loading();
    try {
      final usecases = ref.read(teacherCourseUseCasesProvider);
      final course = await usecases.getCourse(courseId);
      state = AsyncValue.data(CourseWizardState(course: course));
      if (courseHasActiveVideoProcessing(course)) _startVideoStatusPolling();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  void markUnsavedChanges() {
    _draftRevision += 1;
    if (state.hasValue && !state.value!.hasUnsavedChanges) {
      state = AsyncValue.data(
        state.value!.copyWith(hasUnsavedChanges: true, error: null),
      );
    }
  }

  void scheduleAutosave(
    Map<String, dynamic> partialData, {
    Duration debounce = const Duration(milliseconds: 800),
  }) {
    if (!state.hasValue) return;
    _draftRevision += 1;
    _pendingAutosavePayload = Map<String, dynamic>.from(partialData);
    state = AsyncValue.data(
      state.value!.copyWith(hasUnsavedChanges: true, error: null),
    );
    if (state.value!.hasRevisionConflict) return;
    _autosaveTimer?.cancel();
    _autosaveTimer = Timer(debounce, () => unawaited(_drainAutosave()));
  }

  Future<void> flushPendingAutosave() async {
    _autosaveTimer?.cancel();
    await _drainAutosave();
  }

  Future<void> _drainAutosave() async {
    if (_autosaveRunning || _pendingAutosavePayload == null) return;
    _autosaveRunning = true;
    final payload = _pendingAutosavePayload!;
    _pendingAutosavePayload = null;
    var continueWithNewerPayload = true;
    try {
      final saved = await saveDraft(payload, fromAutosave: true);
      if (!saved && _pendingAutosavePayload == null) {
        _pendingAutosavePayload = payload;
        continueWithNewerPayload = false;
      }
    } finally {
      _autosaveRunning = false;
      if (continueWithNewerPayload &&
          _pendingAutosavePayload != null &&
          !_mutationsInFlight.contains('save-draft')) {
        unawaited(_drainAutosave());
      }
    }
  }

  void clearFeedback() {
    if (!state.hasValue) return;
    state = AsyncValue.data(
      state.value!.copyWith(error: null, uploadMessage: null),
    );
  }

  Future<void> refreshVideoStatuses() async {
    await _refreshCourseForVideoStatus();
    final course = state.valueOrNull?.course;
    if (course != null && courseHasActiveVideoProcessing(course)) {
      _startVideoStatusPolling();
    }
  }

  Future<bool> saveDraft(
    Map<String, dynamic> partialData, {
    bool fromAutosave = false,
  }) async {
    const operation = 'save-draft';
    if (!state.hasValue || !_mutationsInFlight.add(operation)) return false;
    if (!fromAutosave) {
      _autosaveTimer?.cancel();
      _pendingAutosavePayload = null;
    }
    final revisionAtStart = _draftRevision;
    var saveSucceeded = false;

    state = AsyncValue.data(state.value!.copyWith(isSaving: true, error: null));

    try {
      final usecases = ref.read(teacherCourseUseCasesProvider);
      Course updated;

      if (_courseId == null || _courseId!.isEmpty) {
        final intent = _payloadIntent('create-course', partialData);
        updated = await usecases.createCourse(
          partialData,
          idempotencyKey: _intentKey(intent),
        );
        _courseId = updated.id;
        _completeIntent(intent);
      } else {
        updated = await usecases.updateCourse(_courseId!, {
          ...partialData,
          'expected_authoring_revision': state.value!.course!.authoringRevision,
        });
      }

      state = AsyncValue.data(
        state.value!.copyWith(
          course: updated,
          isSaving: false,
          hasUnsavedChanges: _draftRevision != revisionAtStart,
          error: null,
          hasRevisionConflict: false,
        ),
      );
      saveSucceeded = true;
      return true;
    } catch (e) {
      final revisionConflict = _isRevisionConflict(e);
      if (!fromAutosave) {
        _pendingAutosavePayload ??= Map<String, dynamic>.from(partialData);
      }
      state = AsyncValue.data(
        state.value!.copyWith(
          isSaving: false,
          error: revisionConflict
              ? 'Conflito de revisão: este curso foi alterado em outra sessão. '
                    'Atualize a revisão e confira seu rascunho antes de salvar.'
              : e.toString(),
          hasRevisionConflict: revisionConflict,
        ),
      );
      return false;
    } finally {
      _mutationsInFlight.remove(operation);
      if (saveSucceeded &&
          _pendingAutosavePayload != null &&
          !_autosaveRunning) {
        unawaited(_drainAutosave());
      }
    }
  }

  bool _isRevisionConflict(Object error) {
    final message = error.toString().toLowerCase();
    return message.contains('409') ||
        message.contains('stale') ||
        message.contains('revision conflict') ||
        message.contains('conflito de revisão');
  }

  Future<bool> refreshAfterRevisionConflict() async {
    if (_courseId == null || !state.hasValue) return false;
    try {
      final refreshed = await ref
          .read(teacherCourseUseCasesProvider)
          .getCourse(_courseId!);
      state = AsyncValue.data(
        state.value!.copyWith(
          course: refreshed,
          hasUnsavedChanges: _pendingAutosavePayload != null,
          error: null,
          hasRevisionConflict: false,
          uploadMessage:
              'Revisão atualizada. Confira seu rascunho e salve novamente.',
        ),
      );
      return true;
    } catch (error) {
      state = AsyncValue.data(state.value!.copyWith(error: error.toString()));
      return false;
    }
  }

  Future<bool> uploadCourseMedia({
    required String assetType,
    required UploadFilePayload file,
    String altText = '',
  }) async {
    if (_courseId == null || !state.hasValue) return false;
    state = AsyncValue.data(
      state.value!.copyWith(
        isUploading: true,
        uploadMessage: assetType == 'cover'
            ? 'Enviando capa...'
            : 'Enviando trailer...',
        error: null,
      ),
    );
    try {
      await ref
          .read(teacherCourseUseCasesProvider)
          .uploadCourseMedia(
            courseId: _courseId!,
            assetType: assetType,
            file: file,
            altText: altText,
          );
      final refreshed = await ref
          .read(teacherCourseUseCasesProvider)
          .getCourse(_courseId!);
      state = AsyncValue.data(
        state.value!.copyWith(
          course: refreshed,
          isUploading: false,
          uploadMessage: assetType == 'cover'
              ? 'Capa enviada.'
              : 'Trailer em processamento.',
        ),
      );
      if (assetType == 'trailer') _startVideoStatusPolling();
      return true;
    } catch (e) {
      state = AsyncValue.data(
        state.value!.copyWith(
          isUploading: false,
          error: e.toString(),
          uploadMessage: null,
        ),
      );
      return false;
    }
  }

  // Modules CRUD inside Wizard
  Future<bool> addModule(Map<String, dynamic> moduleData) async {
    final operation = _payloadIntent('create-module', moduleData);
    if (_courseId == null || !_mutationsInFlight.add(operation)) return false;
    try {
      final usecases = ref.read(teacherCourseUseCasesProvider);
      final newModule = await usecases.createModule(
        _courseId!,
        moduleData,
        idempotencyKey: _intentKey(operation),
      );
      _completeIntent(operation);

      // Update local state
      if (state.hasValue && state.value!.course != null) {
        final currentModules = List<Module>.from(state.value!.course!.modules);
        currentModules.add(newModule);

        final updatedCourse = Course(
          id: state.value!.course!.id,
          instructorId: state.value!.course!.instructorId,
          title: state.value!.course!.title,
          slug: state.value!.course!.slug,
          category: state.value!.course!.category,
          level: state.value!.course!.level,
          summary: state.value!.course!.summary,
          description: state.value!.course!.description,
          requirements: state.value!.course!.requirements,
          courseType: state.value!.course!.courseType,
          subtitle: state.value!.course!.subtitle,
          language: state.value!.course!.language,
          estimatedDurationMinutes:
              state.value!.course!.estimatedDurationMinutes,
          learningObjectives: state.value!.course!.learningObjectives,
          targetAudience: state.value!.course!.targetAudience,
          requiredMaterials: state.value!.course!.requiredMaterials,
          competencies: state.value!.course!.competencies,
          expectedOutcomes: state.value!.course!.expectedOutcomes,
          status: state.value!.course!.status,
          monthlyPrice: state.value!.course!.monthlyPrice,
          promotionalMonthlyPrice: state.value!.course!.promotionalMonthlyPrice,
          promotionStartsAt: state.value!.course!.promotionStartsAt,
          promotionEndsAt: state.value!.course!.promotionEndsAt,
          certificateEnabled: state.value!.course!.certificateEnabled,
          reviewsEnabled: state.value!.course!.reviewsEnabled,
          commentsEnabled: state.value!.course!.commentsEnabled,
          visibility: state.value!.course!.visibility,
          availability: state.value!.course!.availability,
          scheduledPublishAt: state.value!.course!.scheduledPublishAt,
          isFeatured: state.value!.course!.isFeatured,
          authoringRevision: state.value!.course!.authoringRevision,
          modules: currentModules,
        );
        state = AsyncValue.data(state.value!.copyWith(course: updatedCourse));
      }
      return true;
    } catch (e) {
      state = AsyncValue.data(state.value!.copyWith(error: e.toString()));
      return false;
    } finally {
      _mutationsInFlight.remove(operation);
    }
  }

  Future<bool> editModule(
    String moduleId,
    Map<String, dynamic> partialData,
  ) async {
    if (_courseId == null) return false;
    try {
      final usecases = ref.read(teacherCourseUseCasesProvider);
      final updatedModule = await usecases.updateModule(
        _courseId!,
        moduleId,
        partialData,
      );

      if (state.hasValue && state.value!.course != null) {
        final currentModules = List<Module>.from(state.value!.course!.modules);
        final index = currentModules.indexWhere((m) => m.id == moduleId);
        if (index != -1) {
          currentModules[index] = updatedModule;
        }

        final updatedCourse = Course(
          id: state.value!.course!.id,
          instructorId: state.value!.course!.instructorId,
          title: state.value!.course!.title,
          slug: state.value!.course!.slug,
          category: state.value!.course!.category,
          level: state.value!.course!.level,
          summary: state.value!.course!.summary,
          description: state.value!.course!.description,
          requirements: state.value!.course!.requirements,
          courseType: state.value!.course!.courseType,
          subtitle: state.value!.course!.subtitle,
          language: state.value!.course!.language,
          estimatedDurationMinutes:
              state.value!.course!.estimatedDurationMinutes,
          learningObjectives: state.value!.course!.learningObjectives,
          targetAudience: state.value!.course!.targetAudience,
          requiredMaterials: state.value!.course!.requiredMaterials,
          competencies: state.value!.course!.competencies,
          expectedOutcomes: state.value!.course!.expectedOutcomes,
          status: state.value!.course!.status,
          monthlyPrice: state.value!.course!.monthlyPrice,
          promotionalMonthlyPrice: state.value!.course!.promotionalMonthlyPrice,
          promotionStartsAt: state.value!.course!.promotionStartsAt,
          promotionEndsAt: state.value!.course!.promotionEndsAt,
          certificateEnabled: state.value!.course!.certificateEnabled,
          reviewsEnabled: state.value!.course!.reviewsEnabled,
          commentsEnabled: state.value!.course!.commentsEnabled,
          visibility: state.value!.course!.visibility,
          availability: state.value!.course!.availability,
          scheduledPublishAt: state.value!.course!.scheduledPublishAt,
          isFeatured: state.value!.course!.isFeatured,
          authoringRevision: state.value!.course!.authoringRevision,
          modules: currentModules,
        );
        state = AsyncValue.data(state.value!.copyWith(course: updatedCourse));
      }
      return true;
    } catch (e) {
      state = AsyncValue.data(state.value!.copyWith(error: e.toString()));
      return false;
    }
  }

  Future<bool> deleteModule(String moduleId) async {
    if (_courseId == null) return false;
    try {
      final usecases = ref.read(teacherCourseUseCasesProvider);
      await usecases.deleteModule(_courseId!, moduleId);

      if (state.hasValue && state.value!.course != null) {
        final currentModules = List<Module>.from(state.value!.course!.modules);
        currentModules.removeWhere((m) => m.id == moduleId);

        final updatedCourse = Course(
          id: state.value!.course!.id,
          instructorId: state.value!.course!.instructorId,
          title: state.value!.course!.title,
          slug: state.value!.course!.slug,
          category: state.value!.course!.category,
          level: state.value!.course!.level,
          summary: state.value!.course!.summary,
          description: state.value!.course!.description,
          requirements: state.value!.course!.requirements,
          courseType: state.value!.course!.courseType,
          subtitle: state.value!.course!.subtitle,
          language: state.value!.course!.language,
          estimatedDurationMinutes:
              state.value!.course!.estimatedDurationMinutes,
          learningObjectives: state.value!.course!.learningObjectives,
          targetAudience: state.value!.course!.targetAudience,
          requiredMaterials: state.value!.course!.requiredMaterials,
          competencies: state.value!.course!.competencies,
          expectedOutcomes: state.value!.course!.expectedOutcomes,
          status: state.value!.course!.status,
          monthlyPrice: state.value!.course!.monthlyPrice,
          promotionalMonthlyPrice: state.value!.course!.promotionalMonthlyPrice,
          promotionStartsAt: state.value!.course!.promotionStartsAt,
          promotionEndsAt: state.value!.course!.promotionEndsAt,
          certificateEnabled: state.value!.course!.certificateEnabled,
          reviewsEnabled: state.value!.course!.reviewsEnabled,
          commentsEnabled: state.value!.course!.commentsEnabled,
          visibility: state.value!.course!.visibility,
          availability: state.value!.course!.availability,
          scheduledPublishAt: state.value!.course!.scheduledPublishAt,
          isFeatured: state.value!.course!.isFeatured,
          authoringRevision: state.value!.course!.authoringRevision,
          modules: currentModules,
        );
        state = AsyncValue.data(state.value!.copyWith(course: updatedCourse));
      }
      return true;
    } catch (e) {
      state = AsyncValue.data(state.value!.copyWith(error: e.toString()));
      return false;
    }
  }

  Future<bool> addLesson({
    required String moduleId,
    required Map<String, dynamic> lessonData,
    UploadFilePayload? video,
  }) async {
    final operation = _payloadIntent('create-lesson:$moduleId', lessonData);
    if (_courseId == null || !_mutationsInFlight.add(operation)) return false;
    state = AsyncValue.data(
      state.value!.copyWith(
        isUploading: video != null,
        uploadMessage: video == null ? null : 'Preparando upload...',
        error: null,
      ),
    );
    try {
      final usecases = ref.read(teacherCourseUseCasesProvider);
      final lesson = await usecases.createLesson(
        _courseId!,
        moduleId,
        lessonData,
        idempotencyKey: _intentKey(operation),
      );
      if (video != null) {
        state = AsyncValue.data(
          state.value!.copyWith(
            isUploading: true,
            uploadMessage: 'Enviando vÃ­deo...',
          ),
        );
        final key = _idempotencyKey(lesson.id, video);
        await usecases.uploadLessonVideo(
          courseId: _courseId!,
          lessonId: lesson.id,
          file: video,
          idempotencyKey: key,
        );
        _uploadIdempotencyKeys.remove(_uploadFingerprint(lesson.id, video));
      }
      final refreshed = await usecases.getCourse(_courseId!);
      state = AsyncValue.data(
        state.value!.copyWith(
          course: refreshed,
          isUploading: false,
          uploadMessage: video == null
              ? 'Aula criada.'
              : 'VÃ­deo enviado para processamento.',
          error: null,
        ),
      );
      if (video != null) _startVideoStatusPolling();
      _completeIntent(operation);
      return true;
    } catch (error) {
      state = AsyncValue.data(
        state.value!.copyWith(
          isUploading: false,
          uploadMessage: null,
          error: error.toString(),
        ),
      );
      return false;
    } finally {
      _mutationsInFlight.remove(operation);
    }
  }

  Future<bool> editLesson({
    required String lessonId,
    required Map<String, dynamic> lessonData,
    UploadFilePayload? video,
  }) async {
    if (_courseId == null || !state.hasValue) return false;
    state = AsyncValue.data(
      state.value!.copyWith(
        isSaving: true,
        isUploading: video != null,
        uploadMessage: video == null
            ? 'Salvando aula...'
            : 'Atualizando aula e vídeo...',
        error: null,
      ),
    );
    try {
      final usecases = ref.read(teacherCourseUseCasesProvider);
      await usecases.updateLesson(_courseId!, lessonId, lessonData);
      if (video != null) {
        final key = _idempotencyKey(lessonId, video);
        await usecases.uploadLessonVideo(
          courseId: _courseId!,
          lessonId: lessonId,
          file: video,
          idempotencyKey: key,
        );
        _uploadIdempotencyKeys.remove(_uploadFingerprint(lessonId, video));
      }
      final refreshed = await usecases.getCourse(_courseId!);
      state = AsyncValue.data(
        state.value!.copyWith(
          course: refreshed,
          isSaving: false,
          isUploading: false,
          uploadMessage: video == null
              ? 'Aula atualizada.'
              : 'Aula atualizada e vídeo enviado para processamento.',
          error: null,
        ),
      );
      if (video != null) _startVideoStatusPolling();
      return true;
    } catch (error) {
      state = AsyncValue.data(
        state.value!.copyWith(
          isSaving: false,
          isUploading: false,
          uploadMessage: null,
          error: error.toString(),
        ),
      );
      return false;
    }
  }

  void _startVideoStatusPolling() {
    _videoStatusTimer?.cancel();
    var refreshesRemaining = 360;
    _videoStatusTimer = Timer.periodic(const Duration(seconds: 5), (
      timer,
    ) async {
      if (refreshesRemaining-- <= 0) {
        timer.cancel();
        if (state.hasValue) {
          state = AsyncValue.data(
            state.value!.copyWith(
              error:
                  'O processamento do vídeo está demorando mais que o esperado. '
                  'Atualize o status ou envie o arquivo novamente se houver falha.',
            ),
          );
        }
        return;
      }
      await _refreshCourseForVideoStatus();
      final course = state.valueOrNull?.course;
      final hasActiveVideoJob =
          course != null && courseHasActiveVideoProcessing(course);
      if (!hasActiveVideoJob) timer.cancel();
    });
  }

  Future<void> _refreshCourseForVideoStatus() async {
    if (_courseId == null || !state.hasValue) return;
    final requestedCourseId = _courseId;
    final courseAtRequest = state.value!.course;
    try {
      final refreshed = await ref
          .read(teacherCourseUseCasesProvider)
          .getCourse(requestedCourseId!);
      if (!state.hasValue ||
          _courseId != requestedCourseId ||
          !identical(state.value!.course, courseAtRequest)) {
        return;
      }
      state = AsyncValue.data(state.value!.copyWith(course: refreshed));
    } catch (_) {
      // A atualização automática é complementar; mantém a edição disponível.
    }
  }

  Future<bool> deleteLesson(String lessonId) async {
    if (_courseId == null || !state.hasValue) return false;
    state = AsyncValue.data(state.value!.copyWith(isSaving: true, error: null));
    try {
      final usecases = ref.read(teacherCourseUseCasesProvider);
      await usecases.deleteLesson(_courseId!, lessonId);
      final refreshed = await usecases.getCourse(_courseId!);
      state = AsyncValue.data(
        state.value!.copyWith(
          course: refreshed,
          isSaving: false,
          uploadMessage: 'Aula arquivada.',
          error: null,
        ),
      );
      return true;
    } catch (error) {
      state = AsyncValue.data(
        state.value!.copyWith(isSaving: false, error: error.toString()),
      );
      return false;
    }
  }

  Future<bool> saveLessonBlock(
    String lessonId,
    Map<String, dynamic> data, {
    String? blockId,
  }) async {
    final operation = blockId == null
        ? _payloadIntent('create-block:$lessonId', data)
        : 'update-block:$blockId';
    if (_courseId == null ||
        !state.hasValue ||
        !_mutationsInFlight.add(operation)) {
      return false;
    }
    state = AsyncValue.data(
      state.value!.copyWith(
        isSaving: true,
        uploadMessage: 'Salvando bloco...',
        error: null,
      ),
    );
    try {
      final usecases = ref.read(teacherCourseUseCasesProvider);
      if (blockId == null) {
        await usecases.createLessonBlock(
          _courseId!,
          lessonId,
          data,
          idempotencyKey: _intentKey(operation),
        );
      } else {
        await usecases.updateLessonBlock(_courseId!, lessonId, blockId, data);
      }
      final refreshed = await usecases.getCourse(_courseId!);
      state = AsyncValue.data(
        state.value!.copyWith(
          course: refreshed,
          isSaving: false,
          uploadMessage: 'Bloco salvo.',
        ),
      );
      if (blockId == null) _completeIntent(operation);
      return true;
    } catch (error) {
      state = AsyncValue.data(
        state.value!.copyWith(
          isSaving: false,
          error: error.toString(),
          uploadMessage: null,
        ),
      );
      return false;
    } finally {
      _mutationsInFlight.remove(operation);
    }
  }

  Future<List<LessonBlock>> listLessonBlocks(String lessonId) async {
    if (_courseId == null) return const [];
    return ref
        .read(teacherCourseUseCasesProvider)
        .listLessonBlocks(_courseId!, lessonId);
  }

  Future<Map<String, String>> uploadLessonAsset({
    required String lessonId,
    required UploadFilePayload file,
  }) async {
    if (_courseId == null) throw StateError('Salve o curso antes do upload.');
    state = AsyncValue.data(
      state.value!.copyWith(
        isUploading: true,
        uploadMessage: 'Enviando material...',
        error: null,
      ),
    );
    try {
      final result = await ref
          .read(teacherCourseUseCasesProvider)
          .uploadLessonAsset(
            courseId: _courseId!,
            lessonId: lessonId,
            file: file,
          );
      state = AsyncValue.data(
        state.value!.copyWith(
          isUploading: false,
          uploadMessage: 'Material enviado.',
        ),
      );
      return result;
    } catch (error) {
      state = AsyncValue.data(
        state.value!.copyWith(
          isUploading: false,
          uploadMessage: null,
          error: error.toString(),
        ),
      );
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getPublicationChecklist() async {
    if (_courseId == null) throw StateError('Salve o curso antes da revisão.');
    return ref
        .read(teacherCourseUseCasesProvider)
        .getPublicationChecklist(_courseId!);
  }

  Future<List<Map<String, dynamic>>> getCourseVersions() async {
    if (_courseId == null) return const [];
    return ref
        .read(teacherCourseUseCasesProvider)
        .getCourseVersions(_courseId!);
  }

  String _uploadFingerprint(String lessonId, UploadFilePayload file) =>
      '$lessonId:${file.filename}:${file.sizeBytes}';

  String _idempotencyKey(String lessonId, UploadFilePayload file) {
    final fingerprint = _uploadFingerprint(lessonId, file);
    _uploadIdempotencyKeys.removeWhere(
      (key, _) => key.startsWith('$lessonId:') && key != fingerprint,
    );
    return _uploadIdempotencyKeys.putIfAbsent(
      fingerprint,
      () => const Uuid().v4(),
    );
  }

  String _intentKey(String intent) =>
      _intentKeys.putIfAbsent(intent, () => const Uuid().v4());

  String _payloadIntent(String prefix, Map<String, dynamic> payload) {
    final intent = '$prefix:${jsonEncode(_canonicalize(payload))}';
    _intentKeys.removeWhere(
      (key, _) => key.startsWith('$prefix:') && key != intent,
    );
    return intent;
  }

  dynamic _canonicalize(dynamic value) {
    if (value is Map) {
      final keys = value.keys.map((key) => key.toString()).toList()..sort();
      return {for (final key in keys) key: _canonicalize(value[key])};
    }
    if (value is List) return value.map(_canonicalize).toList();
    return value;
  }

  void _completeIntent(String intent) {
    _intentKeys.remove(intent);
  }

  Future<Map<String, dynamic>> getCourseVersion(String versionId) async {
    if (_courseId == null) throw StateError('Curso ainda não foi salvo.');
    return ref
        .read(teacherCourseUseCasesProvider)
        .getCourseVersion(_courseId!, versionId);
  }

  Future<bool> restoreCourseVersion(
    String versionId, {
    required String expectedAuthoringUpdatedAt,
    String? reason,
  }) async {
    if (_courseId == null || !state.hasValue || state.value!.isSaving) {
      return false;
    }
    state = AsyncValue.data(
      state.value!.copyWith(
        isSaving: true,
        uploadMessage: 'Restaurando versão na área de autoria...',
        error: null,
      ),
    );
    try {
      final course = await ref
          .read(teacherCourseUseCasesProvider)
          .restoreCourseVersion(
            _courseId!,
            versionId,
            expectedAuthoringUpdatedAt: expectedAuthoringUpdatedAt,
            reason: reason,
          );
      state = AsyncValue.data(
        state.value!.copyWith(
          course: course,
          isSaving: false,
          uploadMessage:
              'Versão restaurada. Revise e publique quando estiver pronta.',
        ),
      );
      return true;
    } catch (error, stackTrace) {
      state = AsyncValue.data(
        state.value!.copyWith(
          isSaving: false,
          uploadMessage: null,
          error: error.toString(),
        ),
      );
      Error.throwWithStackTrace(error, stackTrace);
    }
  }

  Future<bool> publishCourse() async {
    final operation = 'publish-course:$_courseId';
    if (_courseId == null ||
        !state.hasValue ||
        !_mutationsInFlight.add(operation)) {
      return false;
    }
    state = AsyncValue.data(
      state.value!.copyWith(
        isSaving: true,
        uploadMessage: 'Publicando curso...',
        error: null,
      ),
    );
    try {
      final course = await ref
          .read(teacherCourseUseCasesProvider)
          .publishCourse(_courseId!, idempotencyKey: _intentKey(operation));
      _completeIntent(operation);
      state = AsyncValue.data(
        state.value!.copyWith(
          course: course,
          isSaving: false,
          uploadMessage: 'Curso publicado com sucesso.',
        ),
      );
      return true;
    } catch (error) {
      state = AsyncValue.data(
        state.value!.copyWith(
          isSaving: false,
          uploadMessage: null,
          error: error.toString(),
        ),
      );
      return false;
    } finally {
      _mutationsInFlight.remove(operation);
    }
  }

  Future<bool> duplicateLessonBlock(String lessonId, String blockId) async {
    final operation = 'duplicate-block:$blockId';
    if (_courseId == null || !_mutationsInFlight.add(operation)) return false;
    try {
      final usecases = ref.read(teacherCourseUseCasesProvider);
      await usecases.duplicateLessonBlock(
        _courseId!,
        lessonId,
        blockId,
        idempotencyKey: _intentKey(operation),
      );
      _completeIntent(operation);
      final refreshed = await usecases.getCourse(_courseId!);
      state = AsyncValue.data(state.value!.copyWith(course: refreshed));
      return true;
    } catch (error) {
      state = AsyncValue.data(state.value!.copyWith(error: error.toString()));
      return false;
    } finally {
      _mutationsInFlight.remove(operation);
    }
  }

  Future<bool> deleteLessonBlock(String lessonId, String blockId) async {
    if (_courseId == null) return false;
    try {
      final usecases = ref.read(teacherCourseUseCasesProvider);
      await usecases.deleteLessonBlock(_courseId!, lessonId, blockId);
      final refreshed = await usecases.getCourse(_courseId!);
      state = AsyncValue.data(state.value!.copyWith(course: refreshed));
      return true;
    } catch (error) {
      state = AsyncValue.data(state.value!.copyWith(error: error.toString()));
      return false;
    }
  }
}

const _activeVideoProcessingStatuses = {
  'upload_pending',
  'uploaded',
  'processing_pending',
  'processing',
  'validating',
  'transcoding',
  'generating_hls',
  'generating_thumbnail',
};

bool courseHasActiveVideoProcessing(Course course) {
  final hasActiveLesson = course.modules
      .expand((module) => module.lessons)
      .any(
        (lesson) =>
            _activeVideoProcessingStatuses.contains(lesson.videoJobStatus),
      );
  return hasActiveLesson ||
      _activeVideoProcessingStatuses.contains(course.trailerStatus);
}

final courseWizardControllerProvider =
    AsyncNotifierProvider.autoDispose<
      CourseWizardController,
      CourseWizardState
    >(() {
      return CourseWizardController();
    });
