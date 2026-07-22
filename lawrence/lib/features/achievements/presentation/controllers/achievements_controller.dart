import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/achievement.dart';
import '../../domain/entities/student_level.dart';

typedef AchievementsLoader = Future<AchievementsState> Function();

final achievementsLoaderProvider = Provider<AchievementsLoader>(
  (ref) => () async => const AchievementsState(achievements: []),
);

class AchievementsState {
  final StudentLevel? level;
  final List<Achievement> achievements;
  final bool isLoading;

  const AchievementsState({
    this.level,
    required this.achievements,
    this.isLoading = false,
  });

  int get unlockedCount =>
      achievements.where((achievement) => achievement.isUnlocked).length;

  AchievementsState copyWith({
    StudentLevel? level,
    List<Achievement>? achievements,
    bool? isLoading,
  }) {
    return AchievementsState(
      level: level ?? this.level,
      achievements: achievements ?? this.achievements,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class AchievementsNotifier
    extends StateNotifier<AsyncValue<AchievementsState>> {
  final AchievementsLoader _load;

  AchievementsNotifier(this._load) : super(const AsyncValue.loading()) {
    loadData();
  }

  Future<void> loadData() async {
    state = const AsyncValue.loading();
    try {
      state = AsyncValue.data(await _load());
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final achievementsNotifierProvider =
    StateNotifierProvider<AchievementsNotifier, AsyncValue<AchievementsState>>((
      ref,
    ) {
      return AchievementsNotifier(ref.watch(achievementsLoaderProvider));
    });
