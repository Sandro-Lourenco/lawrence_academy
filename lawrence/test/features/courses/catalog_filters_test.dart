import 'package:flutter_test/flutter_test.dart';
import 'package:lawrence/features/courses/domain/entities/course.dart';
import 'package:lawrence/features/courses/presentation/controllers/catalog_filters_controller.dart';

void main() {
  const courses = [
    Course(
      id: '1',
      instructorId: 'teacher',
      title: 'Costura para iniciantes',
      slug: 'costura-iniciantes',
      category: 'costura',
      level: 'iniciante',
      summary: 'Aprenda pontos básicos',
      status: 'published',
      monthlyPrice: 49.9,
      modules: [],
    ),
    Course(
      id: '2',
      instructorId: 'teacher',
      title: 'Modelagem feminina',
      slug: 'modelagem-feminina',
      category: 'modelagem',
      level: 'intermediario',
      summary: 'Crie moldes profissionais',
      status: 'published',
      modules: [],
    ),
  ];

  test('serializa somente filtros ativos', () {
    const filters = CatalogFilters(
      query: 'vestido',
      category: 'costura',
      access: 'paid',
    );

    expect(filters.toQueryParameters(), {
      'q': 'vestido',
      'category': 'costura',
      'access': 'paid',
    });
  });

  test('restaura filtros válidos e ignora acesso desconhecido', () {
    final filters = CatalogFilters.fromQueryParameters({
      'q': ' molde ',
      'level': 'intermediario',
      'access': 'enterprise',
    });

    expect(filters.query, 'molde');
    expect(filters.level, 'intermediario');
    expect(filters.access, 'all');
  });

  test('combina busca, categoria, nível e acesso', () {
    final result = filterCatalogCourses(
      courses,
      const CatalogFilters(
        query: 'pontos',
        category: 'costura',
        level: 'iniciante',
        access: 'paid',
      ),
    );

    expect(result.map((course) => course.id), ['1']);
  });

  test('busca também considera categoria', () {
    final result = filterCatalogCourses(
      courses,
      const CatalogFilters(query: 'modelagem'),
    );

    expect(result.single.id, '2');
  });
}

