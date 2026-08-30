import '../../../../features/courses/domain/entities/course.dart';
import '../../domain/entities/upload_file_payload.dart';
import '../../domain/entities/teacher_course_student.dart';
import '../../domain/repositories/teacher_course_repository.dart';
import '../datasources/teacher_course_remote_data_source.dart';

class TeacherCourseRepositoryImpl implements ITeacherCourseRepository {
  final ITeacherCourseRemoteDataSource _remoteDataSource;

  TeacherCourseRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<Course>> getTeacherCourses() {
    return _remoteDataSource.getTeacherCourses();
  }

  @override
  Future<Course> getTeacherCourse(String courseId) {
    return _remoteDataSource.getTeacherCourse(courseId);
  }

  @override
  Future<List<TeacherCourseStudent>> getCourseStudents(String courseId) {
    return _remoteDataSource.getCourseStudents(courseId);
  }

  @override
  Future<Course> createCourse(
    Map<String, dynamic> data, {
    required String idempotencyKey,
  }) {
    return _remoteDataSource.createCourse(data, idempotencyKey: idempotencyKey);
  }

  @override
  Future<Course> updateCourse(String courseId, Map<String, dynamic> data) {
    return _remoteDataSource.updateCourse(courseId, data);
  }

  @override
  Future<void> archiveCourse(String courseId, {String? reason}) {
    return _remoteDataSource.deleteCourse(courseId, reason: reason);
  }

  @override
  Future<Module> createModule(
    String courseId,
    Map<String, dynamic> data, {
    required String idempotencyKey,
  }) {
    return _remoteDataSource.createModule(
      courseId,
      data,
      idempotencyKey: idempotencyKey,
    );
  }

  @override
  Future<Module> updateModule(
    String courseId,
    String moduleId,
    Map<String, dynamic> data,
  ) {
    return _remoteDataSource.updateModule(courseId, moduleId, data);
  }

  @override
  Future<void> deleteModule(String courseId, String moduleId) {
    return _remoteDataSource.deleteModule(courseId, moduleId);
  }

  @override
  Future<Lesson> createLesson(
    String courseId,
    String moduleId,
    Map<String, dynamic> data, {
    required String idempotencyKey,
  }) {
    return _remoteDataSource.createLesson(
      courseId,
      moduleId,
      data,
      idempotencyKey: idempotencyKey,
    );
  }

  @override
  Future<Lesson> updateLesson(
    String courseId,
    String lessonId,
    Map<String, dynamic> data,
  ) {
    return _remoteDataSource.updateLesson(courseId, lessonId, data);
  }

  @override
  Future<void> deleteLesson(String courseId, String lessonId) {
    return _remoteDataSource.deleteLesson(courseId, lessonId);
  }

  @override
  Future<void> uploadLessonVideo({
    required String courseId,
    required String lessonId,
    required UploadFilePayload file,
    required String idempotencyKey,
  }) {
    return _remoteDataSource.uploadLessonVideo(
      courseId: courseId,
      lessonId: lessonId,
      file: file,
      idempotencyKey: idempotencyKey,
    );
  }

  @override
  Future<void> uploadCourseMedia({
    required String courseId,
    required String assetType,
    required UploadFilePayload file,
    String altText = '',
  }) => _remoteDataSource.uploadCourseMedia(
    courseId: courseId,
    assetType: assetType,
    file: file,
    altText: altText,
  );
  @override
  Future<LessonBlock> createLessonBlock(
    String courseId,
    String lessonId,
    Map<String, dynamic> data, {
    required String idempotencyKey,
  }) => _remoteDataSource.createLessonBlock(
    courseId,
    lessonId,
    data,
    idempotencyKey: idempotencyKey,
  );
  @override
  Future<List<LessonBlock>> listLessonBlocks(
    String courseId,
    String lessonId,
  ) => _remoteDataSource.listLessonBlocks(courseId, lessonId);
  @override
  Future<LessonBlock> updateLessonBlock(
    String courseId,
    String lessonId,
    String blockId,
    Map<String, dynamic> data,
  ) => _remoteDataSource.updateLessonBlock(courseId, lessonId, blockId, data);
  @override
  Future<LessonBlock> duplicateLessonBlock(
    String courseId,
    String lessonId,
    String blockId, {
    required String idempotencyKey,
  }) => _remoteDataSource.duplicateLessonBlock(
    courseId,
    lessonId,
    blockId,
    idempotencyKey: idempotencyKey,
  );
  @override
  Future<void> deleteLessonBlock(
    String courseId,
    String lessonId,
    String blockId,
  ) => _remoteDataSource.deleteLessonBlock(courseId, lessonId, blockId);
  @override
  Future<Map<String, String>> uploadLessonAsset({
    required String courseId,
    required String lessonId,
    required UploadFilePayload file,
  }) => _remoteDataSource.uploadLessonAsset(
    courseId: courseId,
    lessonId: lessonId,
    file: file,
  );
  @override
  Future<Map<String, dynamic>> getPublicationChecklist(String courseId) =>
      _remoteDataSource.getPublicationChecklist(courseId);
  @override
  Future<Course> publishCourse(
    String courseId, {
    required String idempotencyKey,
  }) =>
      _remoteDataSource.publishCourse(courseId, idempotencyKey: idempotencyKey);
  @override
  Future<List<Map<String, dynamic>>> getCourseVersions(String courseId) =>
      _remoteDataSource.getCourseVersions(courseId);
  @override
  Future<Map<String, dynamic>> getCourseVersion(
    String courseId,
    String versionId,
  ) => _remoteDataSource.getCourseVersion(courseId, versionId);
  @override
  Future<Course> restoreCourseVersion(
    String courseId,
    String versionId, {
    required String expectedAuthoringUpdatedAt,
    String? reason,
  }) => _remoteDataSource.restoreCourseVersion(
    courseId,
    versionId,
    expectedAuthoringUpdatedAt: expectedAuthoringUpdatedAt,
    reason: reason,
  );
  @override
  Future<void> unpublishCourse(String courseId, {String? reason}) =>
      _remoteDataSource.unpublishCourse(courseId, reason: reason);
  @override
  Future<void> restoreCourse(String courseId, {String? reason}) =>
      _remoteDataSource.restoreCourse(courseId, reason: reason);
}
