import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'router/app_router.dart';
import '../design_system/tokens/lawrence_theme.dart';
import '../features/lesson_progress/presentation/controllers/lesson_progress_controller.dart';
import '../features/auth/presentation/controllers/auth_controller.dart';

class LawrenceAcademyApp extends ConsumerWidget {
  const LawrenceAcademyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final auth = ref.watch(authNotifierProvider);
    if (auth.session != null) {
      ref.watch(lessonProgressSyncCoordinatorProvider);
    }

    return MaterialApp.router(
      title: 'Lawrence Academy',
      theme: LawrenceTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      routerConfig: router,
    );
  }
}
