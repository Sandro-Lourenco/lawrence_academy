import 'package:flutter_test/flutter_test.dart';
import 'package:lawrence/features/courses/domain/entities/course.dart';
import 'package:lawrence/features/dashboard/domain/entities/learning_resume_target.dart';
import 'package:lawrence/features/dashboard/presentation/controllers/dashboard_controller.dart';
import 'package:lawrence/features/lesson_progress/domain/entities/lesson_progress_entity.dart';

void main() {
  const summary = AISummary(
    title: '',
    executiveSummary: '',
    keyTakeaways: [],
    stepByStepExecution: [],
    technicalGlossary: [],
  );
  const course = Course(
    id: 'course-1',
    instructorId: 'teacher-1',
    title: 'Costura para iniciantes',
    slug: 'costura-iniciantes',
    category: 'costura',
    level: 'iniciante',
    summary: 'Curso de costura',
    status: 'published',
    modules: [
      Module(
        id: 'module-1',
        courseId: 'course-1',
        title: 'Fundamentos',
        orderIndex: 0,
        lessons: [
          Lesson(
            id: 'lesson-1',
            moduleId: 'module-1',
            courseId: 'course-1',
            title: 'Introdução',
            status: 'published',
            durationSeconds: 300,
            aiSummary: summary,
          ),
          Lesson(
            id: 'lesson-2',
            moduleId: 'module-1',
            courseId: 'course-1',
            title: 'Prática',
            status: 'published',
            durationSeconds: 600,
            aiSummary: summary,
          ),
        ],
      ),
    ],
  );

  test('seleciona a aula incompleta e calcula o progresso real', () {
    final resume = buildDashboardResume(const [course], [
      LessonProgressEntity(
        courseId: 'course-1',
        lessonId: 'lesson-1',
        watchedSeconds: 300,
        progressPercentage: 100,
        completed: true,
      ),
      LessonProgressEntity(
        courseId: 'course-1',
        lessonId: 'lesson-2',
        watchedSeconds: 300,
        progressPercentage: 50,
        completed: false,
      ),
    ]);
    expect(resume!.progressPercentage, 75);
    expect(resume.lessonId, 'lesson-2');
    expect(resume.view, LearningResumeView.watch);
  });

  test('progresso inclui aulas ainda não iniciadas', () {
    final resume = buildDashboardResume(const [course], [
      LessonProgressEntity(
        courseId: 'course-1',
        lessonId: 'lesson-1',
        watchedSeconds: 150,
        progressPercentage: 50,
        completed: false,
      ),
    ]);
    expect(resume!.progressPercentage, 25);
  });

  for (final view in LearningResumeView.values) {
    test('retoma ${view.queryValue} salvo na aula exata', () {
      final resume = buildDashboardResume(
        const [course],
        const [],
        {
          'course-1': LearningResumeTarget(
            studentId: 'student-1',
            courseId: 'course-1',
            lessonId: 'lesson-2',
            view: view,
            updatedAt: DateTime.utc(2026, 7, 29),
          ),
        },
      );
      expect(resume!.lessonId, 'lesson-2');
      expect(resume.view, view);
    });
  }

  test('não cria retomada sem curso acessível', () {
    expect(buildDashboardResume(const [], const []), isNull);
  });
}
