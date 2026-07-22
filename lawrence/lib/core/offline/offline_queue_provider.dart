import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import 'local_database.dart';

class OfflineQueueState {
  final int pendingCount;
  final bool isSyncing;
  final bool isOnline;

  const OfflineQueueState({
    this.pendingCount = 0,
    this.isSyncing = false,
    this.isOnline = true,
  });

  OfflineQueueState copyWith({
    int? pendingCount,
    bool? isSyncing,
    bool? isOnline,
  }) {
    return OfflineQueueState(
      pendingCount: pendingCount ?? this.pendingCount,
      isSyncing: isSyncing ?? this.isSyncing,
      isOnline: isOnline ?? this.isOnline,
    );
  }
}

final offlineQueueProvider =
    AsyncNotifierProvider<OfflineQueueNotifier, OfflineQueueState>(
      OfflineQueueNotifier.new,
    );

class OfflineQueueNotifier extends AsyncNotifier<OfflineQueueState> {
  @override
  Future<OfflineQueueState> build() async {
    Connectivity().onConnectivityChanged.listen((
      List<ConnectivityResult> results,
    ) {
      final isOnline = !results.contains(ConnectivityResult.none);
      if (isOnline && state.value?.isOnline == false) {
        syncPendingItems();
      }
      if (state.value != null) {
        state = AsyncValue.data(state.value!.copyWith(isOnline: isOnline));
      }
    });

    final connectivityResult = await Connectivity().checkConnectivity();
    final isOnline = !connectivityResult.contains(ConnectivityResult.none);

    return OfflineQueueState(
      pendingCount: await _getPendingCount(),
      isOnline: isOnline,
    );
  }

  Future<int> _getPendingCount() async {
    final db = await LocalDatabase.database;
    final result = await db.rawQuery(
      "SELECT COUNT(*) FROM sync_queue WHERE status = 'PENDING'",
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<void> enqueueEvent(String action, String payload) async {
    final db = await LocalDatabase.database;
    await db.insert('sync_queue', {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'action': action,
      'payload': payload,
      'status': 'PENDING',
      'created_at': DateTime.now().millisecondsSinceEpoch,
      'retry_count': 0,
    });

    final currentCount = await _getPendingCount();
    if (state.value != null) {
      state = AsyncValue.data(
        state.value!.copyWith(pendingCount: currentCount),
      );
    }

    if (state.value?.isOnline == true) {
      syncPendingItems();
    }
  }

  Future<void> syncPendingItems() async {
    if (state.value?.isSyncing == true) return;
    if (state.value != null) {
      state = AsyncValue.data(state.value!.copyWith(isSyncing: true));
    }

    try {
      final db = await LocalDatabase.database;
      final pending = await db.query('sync_queue', where: "status = 'PENDING'");

      if (pending.isNotEmpty) {
        // O envio em lote para o backend ocorrerá aqui (Task 6B-002 vai finalizar a API e conectaremos)
        // Por hora, apenas simulamos
      }
    } finally {
      final currentCount = await _getPendingCount();
      if (state.value != null) {
        state = AsyncValue.data(
          state.value!.copyWith(isSyncing: false, pendingCount: currentCount),
        );
      }
    }
  }
}
