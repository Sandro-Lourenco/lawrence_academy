import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/offline/local_cache.dart';

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);

class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    if (!LocalCache.isBoxOpen(LocalCache.themeBox)) return ThemeMode.light;
    final saved = LocalCache.getBox(
      LocalCache.themeBox,
    ).get('theme_mode', defaultValue: 'light');
    return saved == 'dark' ? ThemeMode.dark : ThemeMode.light;
  }

  void setMode(ThemeMode mode) {
    state = mode;
    if (LocalCache.isBoxOpen(LocalCache.themeBox)) {
      LocalCache.getBox(
        LocalCache.themeBox,
      ).put('theme_mode', mode == ThemeMode.dark ? 'dark' : 'light');
    }
  }
}
