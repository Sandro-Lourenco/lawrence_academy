import '../../../../features/courses/domain/entities/course.dart';

abstract class ITeacherCourseRepository {
  Future<List<Course>> getTeacherCourses();
  Future<Course> getTeacherCourse(String courseId);
  Future<Course> createCourse(Map<String, dynamic> data);
  Future<Course> updateCourse(String courseId, Map<String, dynamic> data);
  Future<void> archiveCourse(String courseId);
  Future<Module> createModule(String courseId, Map<String, dynamic> data);
  Future<Module> updateModule(
    String courseId,
    String moduleId,
    Map<String, dynamic> data,
  );
  Future<void> deleteModule(String courseId, String moduleId);
  Future<Lesson> createLesson(
    String courseId,
    String moduleId,
    Map<String, dynamic> data,
  );
  Future<Lesson> updateLesson(
    String courseId,
    String lessonId,
    Map<String, dynamic> data,
  );
  Future<void> deleteLesson(String courseId, String lessonId);
  Future<void> uploadLessonVideo({
    required String courseId,
    required String lessonId,
    required String filePath,
    required String filename,
    required int sizeBytes,
    required String contentType,
  });
}
