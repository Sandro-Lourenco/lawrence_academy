import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../courses/domain/entities/course.dart';
import '../../../courses/presentation/controllers/catalog_controller.dart';

class SearchState {
  final String query;
  final List<Course> results;
  final bool isSearching;

  SearchState({
    this.query = '',
    this.results = const [],
    this.isSearching = false,
  });

  SearchState copyWith({
    String? query,
    List<Course>? results,
    bool? isSearching,
  }) {
    return SearchState(
      query: query ?? this.query,
      results: results ?? this.results,
      isSearching: isSearching ?? this.isSearching,
    );
  }
}

class SearchNotifier extends StateNotifier<SearchState> {
  final Ref ref;
  Timer? _debounce;

  SearchNotifier(this.ref) : super(SearchState());

  void onQueryChanged(String query) {
    state = state.copyWith(query: query, isSearching: query.isNotEmpty);

    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _performSearch(query);
    });
  }

  void _performSearch(String query) {
    if (query.isEmpty) {
      state = state.copyWith(results: [], isSearching: false);
      return;
    }

    final coursesAsync = ref.read(catalogNotifierProvider);

    coursesAsync.whenData((allCourses) {
      final filtered = allCourses.where((c) {
        return c.title.toLowerCase().contains(query.toLowerCase()) ||
            c.summary.toLowerCase().contains(query.toLowerCase()) ||
            c.category.toLowerCase().contains(query.toLowerCase());
      }).toList();

      state = state.copyWith(results: filtered, isSearching: false);
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}

final searchNotifierProvider =
    StateNotifierProvider<SearchNotifier, SearchState>((ref) {
      return SearchNotifier(ref);
    });
