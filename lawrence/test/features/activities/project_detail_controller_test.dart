import 'package:flutter_test/flutter_test.dart';
import 'package:lawrence/features/activities/domain/entities/activity.dart';
import 'package:lawrence/features/activities/presentation/controllers/project_detail_controller.dart';

void main() {
  const project = Activity(
    id: 'project-1',
    title: 'Projeto final',
    courseName: 'Modelagem',
    teacherName: 'Instrutora',
    type: ActivityType.project,
    status: ActivityStatus.inProgress,
  );
  const quiz = Activity(
    id: 'quiz-1',
    title: 'Questionário',
    courseName: 'Modelagem',
    teacherName: 'Instrutora',
    type: ActivityType.quiz,
    status: ActivityStatus.pending,
  );

  test('findAuthorizedProject returns the matching project', () {
    expect(findAuthorizedProject(const [project, quiz], 'project-1'), project);
  });

  test('findAuthorizedProject rejects a matching non-project activity', () {
    expect(findAuthorizedProject(const [project, quiz], 'quiz-1'), isNull);
  });

  test('findAuthorizedProject returns null for an unknown id', () {
    expect(findAuthorizedProject(const [project], 'unknown'), isNull);
  });
}
