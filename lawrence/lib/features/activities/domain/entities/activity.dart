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
  });

  bool get isCompleted =>
      status == ActivityStatus.submitted || status == ActivityStatus.graded;
}
