import 'package:flutter_test/flutter_test.dart';
import 'package:lawrence/features/achievements/domain/entities/achievement.dart';
import 'package:lawrence/features/achievements/domain/entities/student_level.dart';
import 'package:lawrence/features/achievements/presentation/controllers/achievements_controller.dart';

void main() {
  test('unlockedCount includes only confirmed unlocked achievements', () {
    const state = AchievementsState(
      achievements: [
        Achievement(
          id: '1',
          title: 'Primeira aula',
          description: 'Concluir uma aula',
          category: AchievementCategory.learning,
          status: AchievementStatus.unlocked,
          xpValue: 10,
          iconName: 'school',
        ),
        Achievement(
          id: '2',
          title: 'Primeiro curso',
          description: 'Concluir um curso',
          category: AchievementCategory.courses,
          status: AchievementStatus.locked,
          xpValue: 20,
          iconName: 'star',
        ),
      ],
    );

    expect(state.unlockedCount, 1);
  });

  test('level progress remains safe when the target is zero', () {
    const level = StudentLevel(
      currentLevel: 1,
      currentXP: 0,
      xpForNextLevel: 0,
      title: 'Nível inicial',
    );

    expect(level.progressPercentage, 0);
  });
}
