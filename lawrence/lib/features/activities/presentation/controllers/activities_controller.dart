import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/activity.dart';

typedef ActivitiesLoader = Future<List<Activity>> Function();

/// Fonte temporária e explicitamente vazia enquanto o contrato de leitura de
/// atividades do aluno não existe na API canônica.
///
/// A aplicação não deve inventar projetos para preencher a interface. Quando o
/// endpoint for aprovado, este provider poderá receber o use case da feature sem
/// alterar a camada de apresentação.
final activitiesLoaderProvider = Provider<ActivitiesLoader>(
  (ref) => () async => const <Activity>[],
);

class ActivitiesState {
  final List<Activity> activities;
  final bool isLoading;
  final String? error;

  ActivitiesState({
    required this.activities,
    this.isLoading = false,
    this.error,
  });

  ActivitiesState copyWith({
    List<Activity>? activities,
    bool? isLoading,
    String? error,
  }) {
    return ActivitiesState(
      activities: activities ?? this.activities,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class ActivitiesNotifier extends StateNotifier<AsyncValue<List<Activity>>> {
  final ActivitiesLoader _load;

  ActivitiesNotifier(this._load) : super(const AsyncValue.loading()) {
    loadActivities();
  }

  Future<void> loadActivities() async {
    state = const AsyncValue.loading();
    try {
      state = AsyncValue.data(await _load());
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final activitiesNotifierProvider =
    StateNotifierProvider<ActivitiesNotifier, AsyncValue<List<Activity>>>((
      ref,
    ) {
      return ActivitiesNotifier(ref.watch(activitiesLoaderProvider));
    });
