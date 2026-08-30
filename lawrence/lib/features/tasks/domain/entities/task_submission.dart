class TaskSubmission {
  const TaskSubmission({
    required this.id,
    required this.taskId,
    required this.status,
    this.selectedOption,
    this.textAnswer,
    this.score,
    this.teacherFeedback,
    this.submittedAt,
    this.idempotencyKey,
    this.correctOption,
    this.isCorrect,
  });

  final String id;
  final String taskId;
  final String status;
  final String? selectedOption;
  final String? textAnswer;
  final double? score;
  final String? teacherFeedback;
  final DateTime? submittedAt;
  final String? idempotencyKey;
  final String? correctOption;
  final bool? isCorrect;

  factory TaskSubmission.fromJson(Map<String, dynamic> json) => TaskSubmission(
    id: json['id'] as String? ?? '',
    taskId: json['task_id'] as String? ?? '',
    status: json['status'] as String? ?? 'pending_review',
    selectedOption: json['selected_option'] as String?,
    textAnswer: json['text_answer'] as String?,
    score: (json['score'] as num?)?.toDouble(),
    teacherFeedback: json['teacher_feedback'] as String?,
    submittedAt: json['submitted_at'] == null
        ? null
        : DateTime.tryParse(json['submitted_at'].toString()),
    idempotencyKey: json['idempotency_key'] as String?,
    correctOption: json['correct_option'] as String?,
    isCorrect: json['is_correct'] as bool?,
  );
}
