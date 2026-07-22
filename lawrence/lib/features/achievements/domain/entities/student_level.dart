class StudentLevel {
  final int currentLevel;
  final int currentXP;
  final int xpForNextLevel;
  final String title;

  const StudentLevel({
    required this.currentLevel,
    required this.currentXP,
    required this.xpForNextLevel,
    required this.title,
  });

  double get progressPercentage {
    if (xpForNextLevel <= 0) return 0;
    return (currentXP / xpForNextLevel).clamp(0.0, 1.0);
  }

  factory StudentLevel.fromJson(Map<String, dynamic> json) {
    return StudentLevel(
      currentLevel: json['current_level'] ?? 1,
      currentXP: json['current_xp'] ?? 0,
      xpForNextLevel: json['xp_for_next_level'] ?? 1000,
      title: json['title'] ?? 'Iniciante',
    );
  }
}
