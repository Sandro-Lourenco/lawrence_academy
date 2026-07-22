import '../../../../features/courses/domain/entities/course.dart';
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

  Future<Course> createCourse(Map<String, dynamic> data) {
    return _repository.createCourse(data);
  }

  Future<Course> updateCourse(String courseId, Map<String, dynamic> data) {
    return _repository.updateCourse(courseId, data);
  }

  Future<void> archiveCourse(String courseId) {
    return _repository.archiveCourse(courseId);
  }

  Future<Module> createModule(String courseId, Map<String, dynamic> data) {
    return _repository.createModule(courseId, data);
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
    Map<String, dynamic> data,
  ) {
    return _repository.createLesson(courseId, moduleId, data);
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
    required String filePath,
    required String filename,
    required int sizeBytes,
    required String contentType,
  }) {
    return _repository.uploadLessonVideo(
      courseId: courseId,
      lessonId: lessonId,
      filePath: filePath,
      filename: filename,
      sizeBytes: sizeBytes,
      contentType: contentType,
    );
  }
}
