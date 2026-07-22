import '../entities/lesson_entity.dart';

abstract class ILessonRepository {
  Future<LessonEntity> getLesson(String courseId, String lessonId);
  Future<List<LessonEntity>> getCourseLessons(String courseId);
  Future<String> getLessonStreamUrl(String courseId, String lessonId);
  Future<bool> checkLessonAccess(String courseId, String lessonId);
}
