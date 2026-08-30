import 'task_submission.dart';

class Task {
  const Task({
    required this.id,
    required this.courseId,
    required this.lessonId,
    required this.title,
    required this.type,
    this.description,
    this.options = const {},
    this.maxAttempts = 1,
    this.passingScore = 0,
    this.courseName,
    this.teacherName,
    this.attemptsUsed = 0,
    this.latestSubmission,
  });

  final String id;
  final String courseId;
  final String lessonId;
  final String title;
  final String type;
  final String? description;
  final Map<String, dynamic> options;
  final int maxAttempts;
  final double passingScore;
  final String? courseName;
  final String? teacherName;
  final int attemptsUsed;
  final TaskSubmission? latestSubmission;

  factory Task.fromJson(Map<String, dynamic> json) => Task(
    id: json['id'] as String,
    courseId: json['course_id'] as String? ?? '',
    lessonId: json['lesson_id'] as String? ?? '',
    title: json['title'] as String? ?? 'Atividade',
    type: json['task_type'] as String? ?? 'essay',
    description: json['description'] as String?,
    options: (json['options'] as Map?)?.cast<String, dynamic>() ?? const {},
    maxAttempts: (json['max_attempts'] as num?)?.toInt() ?? 1,
    passingScore: (json['passing_score'] as num?)?.toDouble() ?? 0,
    courseName: json['course_name'] as String?,
    teacherName: json['teacher_name'] as String?,
    attemptsUsed: (json['attempts_used'] as num?)?.toInt() ?? 0,
    latestSubmission: json['submission'] is Map
        ? TaskSubmission.fromJson(
            (json['submission'] as Map).cast<String, dynamic>(),
          )
        : null,
  );
}
