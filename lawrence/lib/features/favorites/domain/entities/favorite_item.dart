import '../../../courses/domain/entities/course.dart';

class FavoriteItem {
  final String id;
  final Course course;
  final DateTime favoritedAt;

  const FavoriteItem({
    required this.id,
    required this.course,
    required this.favoritedAt,
  });
}
