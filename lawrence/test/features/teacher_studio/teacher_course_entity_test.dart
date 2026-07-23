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

    test('preserves planning description and requirements', () {
      final course = Course.fromJson({
        'id': 'course-id',
        'instructor_id': 'teacher-id',
        'title': 'Modelagem',
        'slug': 'modelagem',
        'description': 'Formação completa em modelagem feminina.',
        'requirements': ['Fita métrica', 'Conhecimentos básicos de costura'],
      });

      expect(course.description, 'Formação completa em modelagem feminina.');
      expect(course.requirements, [
        'Fita métrica',
        'Conhecimentos básicos de costura',
      ]);
      expect(course.toJson()['requirements'], course.requirements);
    });
  });
}
