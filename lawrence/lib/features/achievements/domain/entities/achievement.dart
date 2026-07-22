enum AchievementCategory {
  learning,
  persistence,
  community,
  teacher,
  events,
  courses,
  certificates,
}

enum AchievementStatus { locked, unlocked }

enum BadgeRarity { bronze, silver, gold, platinum, diamond }

class Achievement {
  final String id;
  final String title;
  final String description;
  final AchievementCategory category;
  final DateTime? unlockedAt;
  final AchievementStatus status;
  final int xpValue;
  final String iconName;
  final BadgeRarity rarity;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    this.unlockedAt,
    required this.status,
    required this.xpValue,
    this.iconName = 'military_tech',
    this.rarity = BadgeRarity.bronze,
  });

  bool get isUnlocked => status == AchievementStatus.unlocked;

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      category: AchievementCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => AchievementCategory.learning,
      ),
      unlockedAt: json['unlocked_at'] != null
          ? DateTime.parse(json['unlocked_at'])
          : null,
      status: json['status'] == 'unlocked'
          ? AchievementStatus.unlocked
          : AchievementStatus.locked,
      xpValue: json['xp_value'] ?? 0,
      iconName: json['icon_name'] as String? ?? 'military_tech',
      rarity: BadgeRarity.values.firstWhere(
        (e) => e.name == json['rarity'],
        orElse: () => BadgeRarity.bronze,
      ),
    );
  }
}
