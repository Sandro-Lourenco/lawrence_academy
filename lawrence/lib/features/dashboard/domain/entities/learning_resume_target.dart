enum LearningResumeView {
  watch,
  activities,
  learnMore;

  String get queryValue => switch (this) {
    LearningResumeView.watch => 'watch',
    LearningResumeView.activities => 'activities',
    LearningResumeView.learnMore => 'learn-more',
  };

  String get label => switch (this) {
    LearningResumeView.watch => 'aula',
    LearningResumeView.activities => 'atividade',
    LearningResumeView.learnMore => 'Saber mais',
  };

  static LearningResumeView fromQuery(String? value) => switch (value) {
    'activities' => LearningResumeView.activities,
    'learn-more' => LearningResumeView.learnMore,
    _ => LearningResumeView.watch,
  };
}

class LearningResumeTarget {
  final String studentId;
  final String courseId;
  final String lessonId;
  final LearningResumeView view;
  final DateTime updatedAt;

  const LearningResumeTarget({
    required this.studentId,
    required this.courseId,
    required this.lessonId,
    required this.view,
    required this.updatedAt,
  });
}
