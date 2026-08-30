import 'package:flutter/foundation.dart';

@immutable
class TeacherCourseStudent {
  final String id;
  final String fullName;
  final String email;
  final String accessStatus;
  final DateTime? enrolledAt;
  final DateTime? currentPeriodEnd;
  final String? avatarUrl;
  final double progressPercentage;
  final int completedLessons;
  final int totalLessons;

  const TeacherCourseStudent({
    required this.id,
    required this.fullName,
    required this.email,
    required this.accessStatus,
    this.enrolledAt,
    this.currentPeriodEnd,
    this.avatarUrl,
    required this.progressPercentage,
    required this.completedLessons,
    required this.totalLessons,
  });

  factory TeacherCourseStudent.fromJson(Map<String, dynamic> json) =>
      TeacherCourseStudent(
        id: json['id'] as String,
        fullName: json['full_name'] as String? ?? 'Aluno',
        email: json['email'] as String? ?? '',
        accessStatus: json['access_status'] as String? ?? 'unknown',
        enrolledAt: DateTime.tryParse(json['enrolled_at'] as String? ?? ''),
        currentPeriodEnd: DateTime.tryParse(
          json['current_period_end'] as String? ?? '',
        ),
        avatarUrl: json['avatar_url'] as String?,
        progressPercentage:
            (json['progress_percentage'] as num?)?.toDouble() ?? 0,
        completedLessons: json['completed_lessons'] as int? ?? 0,
        totalLessons: json['total_lessons'] as int? ?? 0,
      );
}
