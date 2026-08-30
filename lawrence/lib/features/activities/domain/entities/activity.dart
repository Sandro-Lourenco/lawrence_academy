enum ActivityType { quiz, essay, trueFalse, project, upload }

enum ActivityStatus { pending, inProgress, submitted, graded, overdue }

class Activity {
  final String id;
  final String title;
  final String courseName;
  final String teacherName;
  final ActivityType type;
  final ActivityStatus status;
  final DateTime? deadline;
  final double? grade;
  final String? feedback;
  final String courseId;
  final String lessonId;
  final String? description;
  final Map<String, dynamic> options;
  final int maxAttempts;
  final int attemptsUsed;
  final String? selectedOption;
  final String? textAnswer;
  final String? correctOption;
  final bool? isCorrect;

  const Activity({
    required this.id,
    required this.title,
    required this.courseName,
    required this.teacherName,
    required this.type,
    required this.status,
    this.deadline,
    this.grade,
    this.feedback,
    this.courseId = '',
    this.lessonId = '',
    this.description,
    this.options = const {},
    this.maxAttempts = 1,
    this.attemptsUsed = 0,
    this.selectedOption,
    this.textAnswer,
    this.correctOption,
    this.isCorrect,
  });

  bool get isCompleted =>
      status == ActivityStatus.submitted || status == ActivityStatus.graded;
}
