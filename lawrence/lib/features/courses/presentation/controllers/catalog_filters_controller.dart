import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/course.dart';
import 'catalog_controller.dart';

class CatalogFilters {
  final String query;
  final String? category;
  final String? level;
  final String access;

  const CatalogFilters({
    this.query = '',
    this.category,
    this.level,
    this.access = 'all',
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CatalogFilters &&
          query == other.query &&
          category == other.category &&
          level == other.level &&
          access == other.access;

  @override
  int get hashCode => Object.hash(query, category, level, access);

  bool get hasActiveFilters =>
      query.trim().isNotEmpty ||
      category != null ||
      level != null ||
      access != 'all';

  Map<String, String> toQueryParameters() => {
    if (query.trim().isNotEmpty) 'q': query.trim(),
    'category': ?category,
    'level': ?level,
    if (access != 'all') 'access': access,
  };

  factory CatalogFilters.fromQueryParameters(Map<String, String> parameters) {
    final access = parameters['access'];
    return CatalogFilters(
      query: parameters['q']?.trim() ?? '',
      category: _emptyToNull(parameters['category']),
      level: _emptyToNull(parameters['level']),
      access: access == 'free' || access == 'paid' ? access! : 'all',
    );
  }

  static String? _emptyToNull(String? value) {
    final normalized = value?.trim();
    return normalized == null || normalized.isEmpty ? null : normalized;
  }

  CatalogFilters copyWith({
    String? query,
    String? category,
    String? level,
    String? access,
    bool clearCategory = false,
    bool clearLevel = false,
  }) {
    return CatalogFilters(
      query: query ?? this.query,
      category: clearCategory ? null : category ?? this.category,
      level: clearLevel ? null : level ?? this.level,
      access: access ?? this.access,
    );
  }
}

class CatalogFiltersNotifier extends StateNotifier<CatalogFilters> {
  CatalogFiltersNotifier() : super(const CatalogFilters());

  void replace(CatalogFilters filters) {
    if (state != filters) state = filters;
  }

  void setQuery(String value) => state = state.copyWith(query: value);
  void setCategory(String? value) =>
      state = state.copyWith(category: value, clearCategory: value == null);
  void setLevel(String? value) =>
      state = state.copyWith(level: value, clearLevel: value == null);
  void setAccess(String value) => state = state.copyWith(access: value);
  void clear() => state = const CatalogFilters();
}

final catalogFiltersProvider =
    StateNotifierProvider.autoDispose<CatalogFiltersNotifier, CatalogFilters>(
      (ref) => CatalogFiltersNotifier(),
    );

List<Course> filterCatalogCourses(
  List<Course> courses,
  CatalogFilters filters,
) {
  final query = filters.query.trim().toLowerCase();
  return courses
      .where((course) {
        final matchesSearch =
            query.isEmpty ||
            course.title.toLowerCase().contains(query) ||
            course.summary.toLowerCase().contains(query) ||
            course.category.toLowerCase().contains(query);
        final matchesCategory =
            filters.category == null || course.category == filters.category;
        final matchesLevel =
            filters.level == null || course.level == filters.level;
        final matchesAccess =
            filters.access == 'all' ||
            (filters.access == 'free' && course.isFree) ||
            (filters.access == 'paid' && !course.isFree);
        return matchesSearch &&
            matchesCategory &&
            matchesLevel &&
            matchesAccess;
      })
      .toList(growable: false);
}

final filteredCoursesProvider = Provider<AsyncValue<List<Course>>>((ref) {
  final courses = ref.watch(catalogNotifierProvider);
  final filters = ref.watch(catalogFiltersProvider);
  return courses.whenData((items) => filterCatalogCourses(items, filters));
});
