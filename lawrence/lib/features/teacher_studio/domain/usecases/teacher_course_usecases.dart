import '../../../../features/courses/domain/entities/course.dart';
import '../entities/upload_file_payload.dart';
import '../repositories/teacher_course_repository.dart';

class TeacherCourseUseCases {
  final ITeacherCourseRepository _repository;

  TeacherCourseUseCases(this._repository);

  Future<List<Course>> listCourses() {
    return _repository.getTeacherCourses();
  }

  Future<Course> getCourse(String courseId) {
    return _repository.getTeacherCourse(courseId);
  }

  Future<Course> createCourse(
    Map<String, dynamic> data, {
    required String idempotencyKey,
  }) {
    return _repository.createCourse(data, idempotencyKey: idempotencyKey);
  }

  Future<Course> updateCourse(String courseId, Map<String, dynamic> data) {
    return _repository.updateCourse(courseId, data);
  }

  Future<void> archiveCourse(String courseId, {String? reason}) {
    return _repository.archiveCourse(courseId, reason: reason);
  }

  Future<Module> createModule(
    String courseId,
    Map<String, dynamic> data, {
    required String idempotencyKey,
  }) {
    return _repository.createModule(
      courseId,
      data,
      idempotencyKey: idempotencyKey,
    );
  }

  Future<Module> updateModule(
    String courseId,
    String moduleId,
    Map<String, dynamic> data,
  ) {
    return _repository.updateModule(courseId, moduleId, data);
  }

  Future<void> deleteModule(String courseId, String moduleId) {
    return _repository.deleteModule(courseId, moduleId);
  }

  Future<Lesson> createLesson(
    String courseId,
    String moduleId,
    Map<String, dynamic> data, {
    required String idempotencyKey,
  }) {
    return _repository.createLesson(
      courseId,
      moduleId,
      data,
      idempotencyKey: idempotencyKey,
    );
  }

  Future<Lesson> updateLesson(
    String courseId,
    String lessonId,
    Map<String, dynamic> data,
  ) {
    return _repository.updateLesson(courseId, lessonId, data);
  }

  Future<void> deleteLesson(String courseId, String lessonId) {
    return _repository.deleteLesson(courseId, lessonId);
  }

  Future<void> uploadLessonVideo({
    required String courseId,
    required String lessonId,
    required UploadFilePayload file,
    required String idempotencyKey,
  }) {
    return _repository.uploadLessonVideo(
      courseId: courseId,
      lessonId: lessonId,
      file: file,
      idempotencyKey: idempotencyKey,
    );
  }

  Future<void> uploadCourseMedia({
    required String courseId,
    required String assetType,
    required UploadFilePayload file,
    String altText = '',
  }) => _repository.uploadCourseMedia(
    courseId: courseId,
    assetType: assetType,
    file: file,
    altText: altText,
  );
  Future<LessonBlock> createLessonBlock(
    String courseId,
    String lessonId,
    Map<String, dynamic> data, {
    required String idempotencyKey,
  }) => _repository.createLessonBlock(
    courseId,
    lessonId,
    data,
    idempotencyKey: idempotencyKey,
  );
  Future<List<LessonBlock>> listLessonBlocks(
    String courseId,
    String lessonId,
  ) => _repository.listLessonBlocks(courseId, lessonId);
  Future<LessonBlock> updateLessonBlock(
    String courseId,
    String lessonId,
    String blockId,
    Map<String, dynamic> data,
  ) => _repository.updateLessonBlock(courseId, lessonId, blockId, data);
  Future<LessonBlock> duplicateLessonBlock(
    String courseId,
    String lessonId,
    String blockId, {
    required String idempotencyKey,
  }) => _repository.duplicateLessonBlock(
    courseId,
    lessonId,
    blockId,
    idempotencyKey: idempotencyKey,
  );
  Future<void> deleteLessonBlock(
    String courseId,
    String lessonId,
    String blockId,
  ) => _repository.deleteLessonBlock(courseId, lessonId, blockId);
  Future<Map<String, String>> uploadLessonAsset({
    required String courseId,
    required String lessonId,
    required UploadFilePayload file,
  }) => _repository.uploadLessonAsset(
    courseId: courseId,
    lessonId: lessonId,
    file: file,
  );
  Future<Map<String, dynamic>> getPublicationChecklist(String courseId) =>
      _repository.getPublicationChecklist(courseId);
  Future<Course> publishCourse(
    String courseId, {
    required String idempotencyKey,
  }) => _repository.publishCourse(courseId, idempotencyKey: idempotencyKey);
  Future<List<Map<String, dynamic>>> getCourseVersions(String courseId) =>
      _repository.getCourseVersions(courseId);
  Future<Map<String, dynamic>> getCourseVersion(
    String courseId,
    String versionId,
  ) => _repository.getCourseVersion(courseId, versionId);
  Future<Course> restoreCourseVersion(
    String courseId,
    String versionId, {
    required String expectedAuthoringUpdatedAt,
    String? reason,
  }) => _repository.restoreCourseVersion(
    courseId,
    versionId,
    expectedAuthoringUpdatedAt: expectedAuthoringUpdatedAt,
    reason: reason,
  );
  Future<void> unpublishCourse(String courseId, {String? reason}) =>
      _repository.unpublishCourse(courseId, reason: reason);
  Future<void> restoreCourse(String courseId, {String? reason}) =>
      _repository.restoreCourse(courseId, reason: reason);
}
