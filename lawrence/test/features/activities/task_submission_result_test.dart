import 'package:flutter_test/flutter_test.dart';
import 'package:lawrence/features/tasks/domain/entities/task_submission.dart';

void main() {
  test('parses automatic correction without exposing it before submission', () {
    final result = TaskSubmission.fromJson(const {
      'id': 'submission-1',
      'task_id': 'task-1',
      'status': 'graded',
      'selected_option': 'A',
      'score': 0,
      'correct_option': 'B',
      'is_correct': false,
    });

    expect(result.selectedOption, 'A');
    expect(result.correctOption, 'B');
    expect(result.isCorrect, isFalse);
  });
}
