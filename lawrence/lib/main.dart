import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:workmanager/workmanager.dart';

import 'app/app.dart';
import 'app/config/env_config.dart';
import 'core/offline/local_cache.dart';
import 'core/offline/local_database.dart';
import 'features/lesson_progress/presentation/controllers/lesson_progress_controller.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    ProviderContainer? container;
    try {
      final env = EnvConfig.fromEnvironment();
      await Supabase.initialize(
        url: env.supabaseUrl,
        anonKey: env.supabaseAnonKey,
      );
      container = ProviderContainer(
        overrides: [envConfigProvider.overrideWithValue(env)],
      );
      await container.read(syncLessonProgressUseCaseProvider).execute();
      return true;
    } catch (error, stackTrace) {
      debugPrint('[OfflineSync] Background sync failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      return false;
    } finally {
      container?.dispose();
    }
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    usePathUrlStrategy();
  }

  final env = EnvConfig.fromEnvironment();

  await LocalCache.init();
  await Supabase.initialize(url: env.supabaseUrl, anonKey: env.supabaseAnonKey);

  runApp(
    ProviderScope(
      overrides: [envConfigProvider.overrideWithValue(env)],
      child: const LawrenceAcademyApp(),
    ),
  );

  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_initializeAndroidBackgroundServices(env));
    });
  }
}

Future<void> _initializeAndroidBackgroundServices(EnvConfig env) async {
  try {
    await LocalDatabase.database;
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: env.environment == AppEnvironment.dev,
    );
    await Workmanager().registerPeriodicTask(
      'offline-sync',
      'offlineSyncTask',
      frequency: const Duration(hours: 1),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
    );
  } catch (error, stackTrace) {
    debugPrint('[Bootstrap] Android background services failed: $error');
    debugPrintStack(stackTrace: stackTrace);
  }
}
