import 'package:flutter_test/flutter_test.dart';
import 'package:lawrence/features/activities/domain/entities/activity.dart';
import 'package:lawrence/features/activities/presentation/pages/projects_page.dart';

void main() {
  test('selectProjectActivities returns only canonical project activities', () {
    const activities = <Activity>[
      Activity(
        id: 'project-1',
        title: 'Projeto final',
        courseName: 'Modelagem',
        teacherName: 'Instrutora',
        type: ActivityType.project,
        status: ActivityStatus.inProgress,
      ),
      Activity(
        id: 'quiz-1',
        title: 'Questionário',
        courseName: 'Modelagem',
        teacherName: 'Instrutora',
        type: ActivityType.quiz,
        status: ActivityStatus.pending,
      ),
    ];

    final projects = selectProjectActivities(activities);

    expect(projects, hasLength(1));
    expect(projects.single.id, 'project-1');
  });

  test('selectProjectActivities returns an immutable-length empty result', () {
    final projects = selectProjectActivities(const <Activity>[]);

    expect(projects, isEmpty);
    expect(() => projects.add(_project), throwsUnsupportedError);
  });
}

const _project = Activity(
  id: 'project-2',
  title: 'Projeto',
  courseName: 'Costura',
  teacherName: 'Instrutora',
  type: ActivityType.project,
  status: ActivityStatus.pending,
);
