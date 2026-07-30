import '../../../../features/courses/domain/entities/course.dart';
import '../entities/upload_file_payload.dart';

abstract class ITeacherCourseRepository {
  Future<List<Course>> getTeacherCourses();
  Future<Course> getTeacherCourse(String courseId);
  Future<Course> createCourse(
    Map<String, dynamic> data, {
    required String idempotencyKey,
  });
  Future<Course> updateCourse(String courseId, Map<String, dynamic> data);
  Future<void> archiveCourse(String courseId, {String? reason});
  Future<Module> createModule(
    String courseId,
    Map<String, dynamic> data, {
    required String idempotencyKey,
  });
  Future<Module> updateModule(
    String courseId,
    String moduleId,
    Map<String, dynamic> data,
  );
  Future<void> deleteModule(String courseId, String moduleId);
  Future<Lesson> createLesson(
    String courseId,
    String moduleId,
    Map<String, dynamic> data, {
    required String idempotencyKey,
  });
  Future<Lesson> updateLesson(
    String courseId,
    String lessonId,
    Map<String, dynamic> data,
  );
  Future<void> deleteLesson(String courseId, String lessonId);
  Future<void> uploadLessonVideo({
    required String courseId,
    required String lessonId,
    required UploadFilePayload file,
    required String idempotencyKey,
  });
  Future<void> uploadCourseMedia({
    required String courseId,
    required String assetType,
    required UploadFilePayload file,
    String altText = '',
  });
  Future<LessonBlock> createLessonBlock(
    String courseId,
    String lessonId,
    Map<String, dynamic> data, {
    required String idempotencyKey,
  });
  Future<List<LessonBlock>> listLessonBlocks(String courseId, String lessonId);
  Future<LessonBlock> updateLessonBlock(
    String courseId,
    String lessonId,
    String blockId,
    Map<String, dynamic> data,
  );
  Future<LessonBlock> duplicateLessonBlock(
    String courseId,
    String lessonId,
    String blockId, {
    required String idempotencyKey,
  });
  Future<void> deleteLessonBlock(
    String courseId,
    String lessonId,
    String blockId,
  );
  Future<Map<String, String>> uploadLessonAsset({
    required String courseId,
    required String lessonId,
    required UploadFilePayload file,
  });
  Future<Map<String, dynamic>> getPublicationChecklist(String courseId);
  Future<Course> publishCourse(
    String courseId, {
    required String idempotencyKey,
  });
  Future<List<Map<String, dynamic>>> getCourseVersions(String courseId);
  Future<Map<String, dynamic>> getCourseVersion(
    String courseId,
    String versionId,
  );
  Future<Course> restoreCourseVersion(
    String courseId,
    String versionId, {
    required String expectedAuthoringUpdatedAt,
    String? reason,
  });
  Future<void> unpublishCourse(String courseId, {String? reason});
  Future<void> restoreCourse(String courseId, {String? reason});
}
