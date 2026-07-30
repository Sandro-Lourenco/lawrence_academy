import 'package:hive_flutter/hive_flutter.dart';

import '../../domain/entities/learning_resume_target.dart';
import '../../domain/repositories/learning_resume_repository.dart';

class HiveLearningResumeRepository implements LearningResumeRepository {
  static const boxName = 'learning_resume_targets';

  Future<Box<dynamic>> get _box => Hive.openBox<dynamic>(boxName);

  String _key(String studentId, String courseId) => '$studentId:$courseId';

  @override
  Future<LearningResumeTarget?> getForCourse({
    required String studentId,
    required String courseId,
  }) async {
    final raw = await (await _box).get(_key(studentId, courseId));
    if (raw is! Map) return null;
    final lessonId = raw['lesson_id']?.toString();
    final updatedAt = DateTime.tryParse(raw['updated_at']?.toString() ?? '');
    if (lessonId == null || lessonId.isEmpty || updatedAt == null) return null;
    return LearningResumeTarget(
      studentId: studentId,
      courseId: courseId,
      lessonId: lessonId,
      view: LearningResumeView.fromQuery(raw['view']?.toString()),
      updatedAt: updatedAt,
    );
  }

  @override
  Future<void> save(LearningResumeTarget target) async {
    await (await _box).put(_key(target.studentId, target.courseId), {
      'lesson_id': target.lessonId,
      'view': target.view.queryValue,
      'updated_at': target.updatedAt.toUtc().toIso8601String(),
    });
  }
}
