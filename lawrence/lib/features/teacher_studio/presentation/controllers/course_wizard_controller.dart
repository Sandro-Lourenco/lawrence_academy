import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/providers/service_repositories.dart';
import '../../../../features/courses/domain/entities/course.dart';

class CourseWizardState {
  final Course? course;
  final bool isSaving;
  final String? error;
  final bool hasUnsavedChanges;
  final bool isUploading;
  final String? uploadMessage;

  CourseWizardState({
    this.course,
    this.isSaving = false,
    this.error,
    this.hasUnsavedChanges = false,
    this.isUploading = false,
    this.uploadMessage,
  });

  CourseWizardState copyWith({
    Course? course,
    bool? isSaving,
    String? error,
    bool? hasUnsavedChanges,
    bool? isUploading,
    String? uploadMessage,
  }) {
    return CourseWizardState(
      course: course ?? this.course,
      isSaving: isSaving ?? this.isSaving,
      error:
          error, // Se for nulo, zera o erro (comportamento desejado na maioria das vezes, a menos que especifiquemos)
      hasUnsavedChanges: hasUnsavedChanges ?? this.hasUnsavedChanges,
      isUploading: isUploading ?? this.isUploading,
      uploadMessage: uploadMessage,
    );
  }
}

class CourseWizardController
    extends AutoDisposeAsyncNotifier<CourseWizardState> {
  String? _courseId;

  @override
  FutureOr<CourseWizardState> build() async {
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
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  void markUnsavedChanges() {
    if (state.hasValue && !state.value!.hasUnsavedChanges) {
      state = AsyncValue.data(
        state.value!.copyWith(hasUnsavedChanges: true, error: null),
      );
    }
  }

  Future<bool> saveDraft(Map<String, dynamic> partialData) async {
    if (!state.hasValue) return false;

    state = AsyncValue.data(state.value!.copyWith(isSaving: true, error: null));

    try {
      final usecases = ref.read(teacherCourseUseCasesProvider);
      Course updated;

      if (_courseId == null || _courseId!.isEmpty) {
        updated = await usecases.createCourse(partialData);
        _courseId = updated.id;
      } else {
        updated = await usecases.updateCourse(_courseId!, partialData);
      }

      state = AsyncValue.data(
        state.value!.copyWith(
          course: updated,
          isSaving: false,
          hasUnsavedChanges: false,
          error: null,
        ),
      );
      return true;
    } catch (e) {
      state = AsyncValue.data(
        state.value!.copyWith(isSaving: false, error: e.toString()),
      );
      return false;
    }
  }

  // Modules CRUD inside Wizard
  Future<bool> addModule(Map<String, dynamic> moduleData) async {
    if (_courseId == null) return false;
    try {
      final usecases = ref.read(teacherCourseUseCasesProvider);
      final newModule = await usecases.createModule(_courseId!, moduleData);

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
          status: state.value!.course!.status,
          monthlyPrice: state.value!.course!.monthlyPrice,
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
          status: state.value!.course!.status,
          monthlyPrice: state.value!.course!.monthlyPrice,
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
          status: state.value!.course!.status,
          monthlyPrice: state.value!.course!.monthlyPrice,
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
    String? filePath,
    String? filename,
    int? sizeBytes,
    String? contentType,
  }) async {
    if (_courseId == null) return false;
    state = AsyncValue.data(
      state.value!.copyWith(
        isUploading: filePath != null,
        uploadMessage: filePath == null ? null : 'Preparando upload...',
        error: null,
      ),
    );
    try {
      final usecases = ref.read(teacherCourseUseCasesProvider);
      final lesson = await usecases.createLesson(
        _courseId!,
        moduleId,
        lessonData,
      );
      if (filePath != null &&
          filename != null &&
          sizeBytes != null &&
          contentType != null) {
        state = AsyncValue.data(
          state.value!.copyWith(
            isUploading: true,
            uploadMessage: 'Enviando vÃ­deo...',
          ),
        );
        await usecases.uploadLessonVideo(
          courseId: _courseId!,
          lessonId: lesson.id,
          filePath: filePath,
          filename: filename,
          sizeBytes: sizeBytes,
          contentType: contentType,
        );
      }
      final refreshed = await usecases.getCourse(_courseId!);
      state = AsyncValue.data(
        state.value!.copyWith(
          course: refreshed,
          isUploading: false,
          uploadMessage: filePath == null
              ? 'Aula criada.'
              : 'VÃ­deo enviado para processamento.',
          error: null,
        ),
      );
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
    }
  }

  Future<bool> editLesson({
    required String lessonId,
    required Map<String, dynamic> lessonData,
    String? filePath,
    String? filename,
    int? sizeBytes,
    String? contentType,
  }) async {
    if (_courseId == null || !state.hasValue) return false;
    state = AsyncValue.data(
      state.value!.copyWith(
        isSaving: true,
        isUploading: filePath != null,
        uploadMessage: filePath == null
            ? 'Salvando aula...'
            : 'Atualizando aula e vídeo...',
        error: null,
      ),
    );
    try {
      final usecases = ref.read(teacherCourseUseCasesProvider);
      await usecases.updateLesson(_courseId!, lessonId, lessonData);
      if (filePath != null &&
          filename != null &&
          sizeBytes != null &&
          contentType != null) {
        await usecases.uploadLessonVideo(
          courseId: _courseId!,
          lessonId: lessonId,
          filePath: filePath,
          filename: filename,
          sizeBytes: sizeBytes,
          contentType: contentType,
        );
      }
      final refreshed = await usecases.getCourse(_courseId!);
      state = AsyncValue.data(
        state.value!.copyWith(
          course: refreshed,
          isSaving: false,
          isUploading: false,
          uploadMessage: filePath == null
              ? 'Aula atualizada.'
              : 'Aula atualizada e vídeo enviado para processamento.',
          error: null,
        ),
      );
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
}

final courseWizardControllerProvider =
    AsyncNotifierProvider.autoDispose<
      CourseWizardController,
      CourseWizardState
    >(() {
      return CourseWizardController();
    });
