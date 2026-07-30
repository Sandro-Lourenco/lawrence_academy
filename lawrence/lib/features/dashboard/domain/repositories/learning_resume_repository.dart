import '../entities/learning_resume_target.dart';

abstract interface class LearningResumeRepository {
  Future<LearningResumeTarget?> getForCourse({
    required String studentId,
    required String courseId,
  });

  Future<void> save(LearningResumeTarget target);
}
