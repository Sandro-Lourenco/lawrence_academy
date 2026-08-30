import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/offline/local_cache.dart';
import '../../../courses/presentation/controllers/catalog_controller.dart';
import '../../domain/entities/favorite_item.dart';

const _favoriteCourseIdsKey = 'favorite_course_ids';

class FavoritesNotifier extends AsyncNotifier<List<FavoriteItem>> {
  @override
  Future<List<FavoriteItem>> build() async {
    final courses = await ref.watch(catalogNotifierProvider.future);
    final rawIds = LocalCache.getBox(
      LocalCache.settingsBox,
    ).get(_favoriteCourseIdsKey, defaultValue: const <String>[]);
    final ids = (rawIds as List).map((value) => value.toString()).toSet();
    return [
      for (final course in courses)
        if (ids.contains(course.id))
          FavoriteItem(
            id: course.id,
            course: course,
            favoritedAt: DateTime.now(),
          ),
    ];
  }

  Future<void> toggleFavorite(String courseId) async {
    final previous = state.valueOrNull ?? const <FavoriteItem>[];
    final ids = previous.map((item) => item.id).toSet();
    if (!ids.add(courseId)) ids.remove(courseId);
    await LocalCache.getBox(
      LocalCache.settingsBox,
    ).put(_favoriteCourseIdsKey, ids.toList(growable: false));
    ref.invalidateSelf();
    await future;
  }
}

final favoritesNotifierProvider =
    AsyncNotifierProvider<FavoritesNotifier, List<FavoriteItem>>(
      FavoritesNotifier.new,
    );
