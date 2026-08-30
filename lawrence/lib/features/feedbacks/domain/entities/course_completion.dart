class CourseCompletion {
  const CourseCompletion({
    required this.courseId,
    required this.progressPercentage,
    required this.reviewRequired,
    required this.reviewSubmitted,
    required this.certificateEligible,
  });

  final String courseId;
  final int progressPercentage;
  final bool reviewRequired;
  final bool reviewSubmitted;
  final bool certificateEligible;

  factory CourseCompletion.fromJson(Map<String, dynamic> json) =>
      CourseCompletion(
        courseId: json['course_id'] as String,
        progressPercentage: json['progress_percentage'] as int? ?? 0,
        reviewRequired: json['review_required'] as bool? ?? false,
        reviewSubmitted: json['review_submitted'] as bool? ?? false,
        certificateEligible: json['certificate_eligible'] as bool? ?? false,
      );
}

class CourseFeedback {
  const CourseFeedback({
    required this.id,
    required this.courseId,
    required this.studentName,
    required this.rating,
    required this.title,
    required this.comment,
    required this.createdAt,
    this.studentAvatarUrl,
  });

  final String id;
  final String courseId;
  final String studentName;
  final String? studentAvatarUrl;
  final int rating;
  final String title;
  final String comment;
  final DateTime createdAt;

  factory CourseFeedback.fromJson(Map<String, dynamic> json) => CourseFeedback(
    id: json['id'] as String,
    courseId: json['course_id'] as String,
    studentName: json['student_name'] as String? ?? 'Aluno Lawrence',
    studentAvatarUrl: json['student_avatar_url'] as String?,
    rating: json['rating'] as int? ?? 0,
    title: json['title'] as String? ?? '',
    comment: json['comment'] as String? ?? '',
    createdAt: DateTime.parse(json['created_at'] as String),
  );
}
