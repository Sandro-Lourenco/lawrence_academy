import '../../domain/entities/lesson_entity.dart';
import '../models/lesson_api_model.dart';

class LessonMapper {
  static LessonEntity toEntity(LessonApiModel model) {
    return LessonEntity(
      id: model.id,
      moduleId: model.moduleId,
      courseId: model.courseId,
      title: model.title,
      description: model.description,
      orderIndex: model.orderIndex,
      durationSeconds: model.durationSeconds,
      hlsStoragePath: model.hlsStoragePath,
      materialPdfUrl: model.materialPdfUrl,
      status: model.status,
    );
  }

  static LessonApiModel toModel(LessonEntity entity) {
    return LessonApiModel(
      id: entity.id,
      moduleId: entity.moduleId,
      courseId: entity.courseId,
      title: entity.title,
      description: entity.description,
      orderIndex: entity.orderIndex,
      durationSeconds: entity.durationSeconds,
      hlsStoragePath: entity.hlsStoragePath,
      materialPdfUrl: entity.materialPdfUrl,
      status: entity.status,
    );
  }
}
