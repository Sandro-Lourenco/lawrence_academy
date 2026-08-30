import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/network_client.dart';
import '../../data/repositories/live_event_repository_impl.dart';
import '../../domain/entities/live_event.dart';
import '../../domain/repositories/live_event_repository.dart';

final liveEventRepositoryProvider = Provider<LiveEventRepository>(
  (ref) => LiveEventRepositoryImpl(ref.watch(networkClientProvider)),
);

final livesProvider = FutureProvider<List<LiveEvent>>(
  (ref) => ref.watch(liveEventRepositoryProvider).listPublic(),
);

final teacherLivesProvider = FutureProvider.autoDispose<List<LiveEvent>>(
  (ref) => ref.watch(liveEventRepositoryProvider).listForTeacher(),
);
