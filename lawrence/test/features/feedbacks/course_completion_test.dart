import 'package:flutter_test/flutter_test.dart';
import 'package:lawrence/features/feedbacks/domain/entities/course_completion.dart';

void main() {
  test('parses completion that requires a review before certificate', () {
    final completion = CourseCompletion.fromJson(const {
      'course_id': 'course-1',
      'progress_percentage': 100,
      'review_required': true,
      'review_submitted': false,
      'certificate_eligible': false,
    });

    expect(completion.progressPercentage, 100);
    expect(completion.reviewRequired, isTrue);
    expect(completion.certificateEligible, isFalse);
  });

  test('parses published feedback', () {
    final feedback = CourseFeedback.fromJson(const {
      'id': 'review-1',
      'course_id': 'course-1',
      'student_name': 'Maria',
      'rating': 5,
      'title': 'Excelente',
      'comment': 'Uma experiência transformadora.',
      'created_at': '2026-08-10T12:00:00Z',
    });

    expect(feedback.studentName, 'Maria');
    expect(feedback.rating, 5);
  });
}
