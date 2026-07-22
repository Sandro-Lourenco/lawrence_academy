import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/favorite_item.dart';
import '../../../courses/presentation/controllers/catalog_controller.dart';

class FavoritesNotifier extends StateNotifier<AsyncValue<List<FavoriteItem>>> {
  final Ref ref;

  FavoritesNotifier(this.ref) : super(const AsyncValue.loading()) {
    loadFavorites();
  }

  Future<void> loadFavorites() async {
    state = const AsyncValue.loading();
    try {
      // Mock delay for realistic feel
      await Future.delayed(const Duration(milliseconds: 800));

      final coursesAsync = ref.read(catalogNotifierProvider);

      coursesAsync.whenData((allCourses) {
        if (allCourses.isEmpty) {
          state = const AsyncValue.data([]);
          return;
        }

        // Simulating that the first 2 courses are favorites
        final mockFavorites = allCourses
            .take(2)
            .map(
              (c) => FavoriteItem(
                id: c.id,
                course: c,
                favoritedAt: DateTime.now(),
              ),
            )
            .toList();

        state = AsyncValue.data(mockFavorites);
      });
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void toggleFavorite(String courseId) {
    // Logic to add/remove from local state or backend
  }
}

final favoritesNotifierProvider =
    StateNotifierProvider<FavoritesNotifier, AsyncValue<List<FavoriteItem>>>((
      ref,
    ) {
      return FavoritesNotifier(ref);
    });
