import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:workmanager/workmanager.dart';

import 'app/app.dart';
import 'app/config/env_config.dart';
import 'core/offline/local_cache.dart';
import 'core/offline/local_database.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    await LocalCache.init();
    await LocalDatabase.database;
    // The real sync operation is implemented in recovery batch B5.
    return Future.value(true);
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final env = EnvConfig.fromEnvironment();

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
    await LocalCache.init();
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
