import 'package:flutter_test/flutter_test.dart';
import 'package:lawrence/features/courses/domain/entities/course.dart';

void main() {
  group('Course.fromJson', () {
    test('accepts PostgreSQL decimal serialized as string', () {
      final course = Course.fromJson({
        'id': 'course-id',
        'instructor_id': 'teacher-id',
        'title': 'Modelagem',
        'slug': 'modelagem',
        'category': 'costura',
        'level': 'iniciante',
        'summary': 'Curso de teste',
        'status': 'draft',
        'monthly_price': '50.0',
        'modules': <dynamic>[],
      });

      expect(course.monthlyPrice, 50.0);
    });

    test('maps the server authoring revision used by autosave CAS', () {
      final course = Course.fromJson({
        'id': 'course-id',
        'instructor_id': 'teacher-id',
        'title': 'Modelagem',
        'slug': 'modelagem',
        'authoring_revision': 12,
      });

      expect(course.authoringRevision, 12);
      expect(course.toJson()['authoring_revision'], 12);
    });

    test('continues accepting a numeric price', () {
      final course = Course.fromJson({
        'id': 'course-id',
        'instructor_id': 'teacher-id',
        'title': 'Modelagem',
        'slug': 'modelagem',
        'monthly_price': 49.90,
      });

      expect(course.monthlyPrice, 49.90);
    });

    test('maps the latest lesson video processing status', () {
      final lesson = Lesson.fromJson({
        'id': 'lesson-id',
        'module_id': 'module-id',
        'course_id': 'course-id',
        'title': 'Aula de acabamento',
        'status': 'draft',
        'duration_seconds': 0,
        'video_job_status': 'failed',
      });

      expect(lesson.videoJobStatus, 'failed');
      expect(lesson.toJson()['video_job_status'], 'failed');
    });

    test('preserves planning description and requirements', () {
      final course = Course.fromJson({
        'id': 'course-id',
        'instructor_id': 'teacher-id',
        'title': 'Modelagem',
        'slug': 'modelagem',
        'description': 'Formação completa em modelagem feminina.',
        'requirements': ['Fita métrica', 'Conhecimentos básicos de costura'],
        'course_type': 'complete',
        'subtitle': 'Do básico ao primeiro molde',
        'language': 'pt-BR',
        'estimated_duration_minutes': 720,
        'learning_objectives': ['Tirar medidas com precisão'],
        'target_audience': ['Pessoas iniciantes'],
        'required_materials': ['Papel kraft'],
        'competencies': ['Construção de bases'],
        'expected_outcomes': ['Criar moldes com autonomia'],
        'promotional_monthly_price': '39.90',
        'certificate_enabled': true,
        'reviews_enabled': false,
        'comments_enabled': true,
        'visibility': 'unlisted',
        'availability': 'immediate',
        'is_featured': false,
      });

      expect(course.description, 'Formação completa em modelagem feminina.');
      expect(course.requirements, [
        'Fita métrica',
        'Conhecimentos básicos de costura',
      ]);
      expect(course.toJson()['requirements'], course.requirements);
      expect(course.courseType, 'complete');
      expect(course.subtitle, 'Do básico ao primeiro molde');
      expect(course.estimatedDurationMinutes, 720);
      expect(course.learningObjectives, ['Tirar medidas com precisão']);
      expect(course.targetAudience, ['Pessoas iniciantes']);
      expect(course.promotionalMonthlyPrice, 39.90);
      expect(course.reviewsEnabled, false);
      expect(course.visibility, 'unlisted');
      expect(course.isFeatured, false);
    });
  });
}
