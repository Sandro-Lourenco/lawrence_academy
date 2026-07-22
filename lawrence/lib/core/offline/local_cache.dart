import 'package:hive_flutter/hive_flutter.dart';

class LocalCache {
  static const String settingsBox = 'settings';
  static const String sessionBox = 'session_cache';
  static const String themeBox = 'theme';

  static Future<void> init() async {
    await Hive.initFlutter();

    // Abrir caixas padrão
    await Hive.openBox(settingsBox);
    await Hive.openBox(sessionBox);
    await Hive.openBox(themeBox);
  }

  static Box getBox(String name) {
    return Hive.box(name);
  }

  static Future<void> clearAll() async {
    await Hive.box(settingsBox).clear();
    await Hive.box(sessionBox).clear();
    await Hive.box(themeBox).clear();
  }
}
