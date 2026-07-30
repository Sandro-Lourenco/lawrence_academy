import '../../../../features/courses/domain/entities/course.dart';
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
  Future<Course> createCourse(Map<String, dynamic> data) {
    return _remoteDataSource.createCourse(data);
  }

  @override
  Future<Course> updateCourse(String courseId, Map<String, dynamic> data) {
    return _remoteDataSource.updateCourse(courseId, data);
  }

  @override
  Future<void> archiveCourse(String courseId) {
    return _remoteDataSource.deleteCourse(courseId);
  }

  @override
  Future<Module> createModule(String courseId, Map<String, dynamic> data) {
    return _remoteDataSource.createModule(courseId, data);
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
    Map<String, dynamic> data,
  ) {
    return _remoteDataSource.createLesson(courseId, moduleId, data);
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
    required String filePath,
    required String filename,
    required int sizeBytes,
    required String contentType,
  }) {
    return _remoteDataSource.uploadLessonVideo(
      courseId: courseId,
      lessonId: lessonId,
      filePath: filePath,
      filename: filename,
      sizeBytes: sizeBytes,
      contentType: contentType,
    );
  }

  @override
  Future<void> uploadCourseMedia({
    required String courseId, required String assetType, required String filePath,
    required String filename, required int sizeBytes, required String contentType,
    String altText = '',
  }) => _remoteDataSource.uploadCourseMedia(
    courseId: courseId, assetType: assetType, filePath: filePath,
    filename: filename, sizeBytes: sizeBytes, contentType: contentType,
    altText: altText,
  );
  @override
  Future<LessonBlock> createLessonBlock(String courseId, String lessonId, Map<String, dynamic> data) => _remoteDataSource.createLessonBlock(courseId, lessonId, data);
  @override
  Future<List<LessonBlock>> listLessonBlocks(String courseId, String lessonId) => _remoteDataSource.listLessonBlocks(courseId, lessonId);
  @override
  Future<LessonBlock> updateLessonBlock(String courseId, String lessonId, String blockId, Map<String, dynamic> data) => _remoteDataSource.updateLessonBlock(courseId, lessonId, blockId, data);
  @override
  Future<LessonBlock> duplicateLessonBlock(String courseId, String lessonId, String blockId) => _remoteDataSource.duplicateLessonBlock(courseId, lessonId, blockId);
  @override
  Future<void> deleteLessonBlock(String courseId, String lessonId, String blockId) => _remoteDataSource.deleteLessonBlock(courseId, lessonId, blockId);
}
