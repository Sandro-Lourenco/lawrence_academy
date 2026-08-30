import '../entities/lesson_entity.dart';

class LessonPlaybackSource {
  const LessonPlaybackSource.hls(this.url)
    : provider = null,
      isExternal = false;

  const LessonPlaybackSource.external(this.url, this.provider)
    : isExternal = true;

  final String url;
  final String? provider;
  final bool isExternal;
}

abstract class ILessonRepository {
  Future<LessonEntity> getLesson(String courseId, String lessonId);
  Future<List<LessonEntity>> getCourseLessons(String courseId);
  Future<LessonPlaybackSource> getLessonPlaybackSource(
    String courseId,
    String lessonId,
  );
  Future<bool> checkLessonAccess(String courseId, String lessonId);
}
